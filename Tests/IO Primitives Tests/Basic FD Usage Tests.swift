// ===----------------------------------------------------------------------===//
//
// Demonstration: how `IO<Capabilities>` at L1 is consumed by `swift-io`
// (the basic fd byte-ops domain). The capability struct below is a stand-in
// for what the production swift-io package would define at L3.
//
// Shape: IO<BasicFD.Capabilities> — bundle with four fd-based operations.
//
// Multi-type-per-file exception: this demo file defines its own `BasicFD`
// namespace + types + `Capabilities` struct alongside the test suite. The
// domain types are colocated with the tests that exercise them so the
// demonstration reads as a single self-contained example. All types are
// nested (Nest.Name), compliant with other code-surface rules.
//
// ===----------------------------------------------------------------------===//

import IO_Primitives_Test_Support
import Testing

// ============================================================================
// MARK: - Domain types (would live in swift-io at L3)
// ============================================================================

private enum BasicFD {}

extension BasicFD {
    struct Descriptor: Sendable, Equatable {
        let raw: Int32
    }

    enum Interest: Sendable, Equatable {
        case read
        case write
    }

    enum Error: Swift.Error, Sendable, Equatable {
        case wouldBlock
        case brokenPipe
    }
}

extension BasicFD {
    /// The basic fd byte-ops capability surface.
    struct Capabilities: Sendable {
        let read: @Sendable (borrowing BasicFD.Descriptor, Int) async throws(BasicFD.Error) -> Int
        let write: @Sendable (borrowing BasicFD.Descriptor, Int) async throws(BasicFD.Error) -> Int
        let close: @Sendable (consuming BasicFD.Descriptor) async -> Void
        let ready:
            @Sendable (borrowing BasicFD.Descriptor, BasicFD.Interest) async throws(BasicFD.Error)
                -> Void
    }
}

// ============================================================================
// MARK: - Suite
// ============================================================================

extension BasicFD {

    @Suite("Basic FD Usage (swift-io)")
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// ============================================================================
// MARK: - Fixtures
// ============================================================================

private actor Recorder {
    var calls: [String] = []
}

extension Recorder {
    func log(_ entry: String) { calls.append(entry) }
    func snapshot() -> [String] { calls }
}

/// Fake factory mirroring what a per-strategy production factory would
/// produce (e.g., `IO.blocking()`).
///
/// Records each call.
private func fake(recorder: Recorder) -> IO<BasicFD.Capabilities> {
    let caps = BasicFD.Capabilities(
        read: { fd, n throws(BasicFD.Error) in
            await recorder.log("read(fd: \(fd.raw), n: \(n))")
            return n
        },
        write: { fd, n throws(BasicFD.Error) in
            await recorder.log("write(fd: \(fd.raw), n: \(n))")
            return n
        },
        close: { fd in
            await recorder.log("close(fd: \(fd.raw))")
        },
        ready: { fd, interest throws(BasicFD.Error) in
            await recorder.log("ready(fd: \(fd.raw), \(interest))")
        }
    )
    return IO(capabilities: caps)
}

// ============================================================================
// MARK: - Integration
// ============================================================================

extension BasicFD.Test.Integration {

    @Test
    func `consumer performs the basic fd byte-ops sequence`() async throws {
        let recorder = Recorder()
        let io = fake(recorder: recorder)

        try await io.capabilities.ready(BasicFD.Descriptor(raw: 3), .read)
        _ = try await io.capabilities.read(BasicFD.Descriptor(raw: 3), 64)
        _ = try await io.capabilities.write(BasicFD.Descriptor(raw: 4), 64)
        await io.capabilities.close(BasicFD.Descriptor(raw: 3))

        let calls = await recorder.snapshot()
        #expect(
            calls == [
                "ready(fd: 3, read)",
                "read(fd: 3, n: 64)",
                "write(fd: 4, n: 64)",
                "close(fd: 3)",
            ]
        )
    }

    @Test
    func `typed errors propagate through the capability surface`() async {
        let caps = BasicFD.Capabilities(
            read: { _, _ throws(BasicFD.Error) in throw .wouldBlock },
            write: { _, _ throws(BasicFD.Error) in 0 },
            close: { _ in },
            ready: { _, _ throws(BasicFD.Error) in }
        )
        let io = IO(capabilities: caps)

        do throws(BasicFD.Error) {
            _ = try await io.capabilities.read(BasicFD.Descriptor(raw: 3), 64)
            Issue.record("expected wouldBlock")
        } catch {
            #expect(error == .wouldBlock)
        }
    }
}
