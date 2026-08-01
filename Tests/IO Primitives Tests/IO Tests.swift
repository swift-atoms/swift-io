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
//
// `IO` is generic, and `@Test`/`@Suite` macros cannot attach to types in a
// generic context. A file-private standalone `Test` struct hosts the four
// canonical category sub-suites; Swift Testing discovers them directly.
// ============================================================================

@Suite("IO")
private struct Test {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

// ============================================================================
// MARK: - Fixtures
// ============================================================================

/// Minimal capability struct for exercising IO<C> construction.
private struct TrivialCapabilities: Sendable {
    let tag: Int
}

/// Capability type with a phantom-tag generic parameter.
private struct TaggedCapabilities<Tag>: Sendable {
    let marker: Int
}

private enum Client {}

// ============================================================================
// MARK: - Unit
// ============================================================================

extension Test.Unit {

    @Test
    func `IO bundles capabilities and runner`() {
        let caps = TrivialCapabilities(tag: 42)
        let io = IO<TrivialCapabilities>(capabilities: caps, runner: .unimplemented)
        #expect(io.capabilities.tag == 42)
    }

    @Test
    func `IO is Sendable across task boundaries when capabilities are Sendable`() async {
        let io = IO<TrivialCapabilities>(
            capabilities: TrivialCapabilities(tag: 1),
            runner: .unimplemented
        )
        let tag = await Task { io.capabilities.tag }.value
        #expect(tag == 1)
    }

    @Test
    func `convenience initializer supplies an unimplemented runner`() {
        let io = IO<TrivialCapabilities>(capabilities: TrivialCapabilities(tag: 7))
        #expect(io.capabilities.tag == 7)
    }
}

// ============================================================================
// MARK: - Edge Case
// ============================================================================

extension Test.`Edge Case` {

    @Test
    func `IO is generic over arbitrary Sendable capability types`() {
        let io = IO<TaggedCapabilities<Client>>(
            capabilities: TaggedCapabilities<Client>(marker: 99),
            runner: .unimplemented
        )
        #expect(io.capabilities.marker == 99)
    }
}
