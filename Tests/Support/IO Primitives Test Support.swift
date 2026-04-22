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

public import IO_Primitives

// ============================================================================
// MARK: - Unimplemented runners
// ============================================================================

extension IO.Runner {

    /// A runner that traps if either ``executor`` or ``shutdown`` is invoked.
    ///
    /// Use this when a test constructs an ``IO`` but never actually executes
    /// anything via its runner — the test only needs the bundle to exist.
    /// If the test path accidentally reaches the executor or shutdown, the
    /// trap signals that the runner should have been supplied.
    ///
    /// ```swift
    /// let io = IO(
    ///     capabilities: File.Capabilities.stub,
    ///     runner: .unimplemented
    /// )
    /// ```
    public static var unimplemented: IO.Runner {
        unsafe IO.Runner(
            executor: { fatalError("IO.Runner.unimplemented.executor() was called") },
            shutdown: { fatalError("IO.Runner.unimplemented.shutdown() was called") }
        )
    }
}

// ============================================================================
// MARK: - Convenience initializer
// ============================================================================

extension IO {

    /// Create an ``IO`` with the given capabilities and an ``IO/Runner/unimplemented``
    /// runner. For tests that exercise only the capability surface.
    public init(capabilities: Capabilities) {
        self.init(capabilities: capabilities, runner: .unimplemented)
    }
}
