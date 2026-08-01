// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-primitives open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-primitives
// project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

import IO_Primitives_Test_Support
import Testing

// ============================================================================
// MARK: - Suite
// ============================================================================

@Suite("IO.Runner")
private struct Test {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

// ============================================================================
// MARK: - Fixtures
// ============================================================================

private actor Counter {
    var value: Int = 0
}

extension Counter {
    func increment() { value += 1 }
}

private final class SimpleExecutor: SerialExecutor, @unchecked Sendable {
}

extension SimpleExecutor {
    static let shared = SimpleExecutor()
    func enqueue(_ job: consuming ExecutorJob) {}
    func asUnownedSerialExecutor() -> UnownedSerialExecutor {
        unsafe UnownedSerialExecutor(ordinary: self)
    }
}

// ============================================================================
// MARK: - Unit
// ============================================================================

extension Test.Unit {

    @Test
    func `Runner stores executor and shutdown closures`() async {
        let counter = Counter()
        // Runner's generic parameter is phantom; any Sendable satisfies it.
        let runner = unsafe IO<Int>.Runner(
            executor: {
                unsafe UnownedSerialExecutor(ordinary: SimpleExecutor.shared)
            },
            shutdown: {
                await counter.increment()
            }
        )

        unsafe (_ = runner.executor())
        await runner.shutdown()
        await #expect(counter.value == 1)
    }
}
