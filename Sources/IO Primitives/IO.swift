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

/// A generic IO bundle pairing a domain-specific capability set with a
/// scheduling runner.
///
/// ``IO`` is the canonical L1 shape for *any* IO witness in the ecosystem.
/// It is generic over the domain's ``Capabilities`` type so that each
/// domain — basic fd byte ops, sockets, servers, files, timers — ships
/// its own distinct capability struct while sharing the bundling pattern
/// and the runner concern.
///
/// ## Architectural role
///
/// Three concerns are kept structurally separate:
///
/// 1. **Capabilities** — the domain-specific operations. A value of some
///    domain-defined struct (for example `File.Capabilities`,
///    `Socket.Capabilities`, or the basic fd-byte-ops witness defined
///    in `swift-io`).
/// 2. **Runner** — the scheduling evidence. A ``Runner`` value exposing
///    the underlying executor and a shutdown hook, produced by a
///    strategy (blocking / events / completions) at construction time.
/// 3. **Strategies** — dispatch mechanisms (blocking thread pool, kernel
///    readiness reactor, kernel completion queue). Strategies live at
///    L3; they are *generic over the work they dispatch* and therefore
///    reused across every domain.
///
/// The intended composition at L3:
///
/// ```swift
/// // Each domain defines its Capabilities
/// extension File {
///     public struct Capabilities: Sendable {
///         public let open:   @Sendable (File.Path, File.Flags) async throws(IO.Error) -> Kernel.Descriptor
///         public let close:  @Sendable (consuming Kernel.Descriptor) async -> Void
///         public let read:   @Sendable (borrowing Kernel.Descriptor, Span.Raw.Mutable) async throws(IO.Error) -> Int
///         public let write:  @Sendable (borrowing Kernel.Descriptor, Span.Raw) async throws(IO.Error) -> Int
///         public let stat:   @Sendable (File.Path) async throws(IO.Error) -> File.Stat
///         // ...
///     }
/// }
///
/// // Per-(domain × strategy) factories wire closures to the strategy
/// extension IO where Capabilities == File.Capabilities {
///     public static func blocking(_ pool: Blocking = .shared) -> IO<File.Capabilities> {
///         let caps = File.Capabilities(
///             open:  { path, flags in try await pool.dispatch { try Kernel.File.Open.open(path, flags) } },
///             close: { fd          in try await pool.dispatch { Kernel.Close.close(consume fd) } },
///             // ...
///         )
///         return IO(capabilities: caps, runner: pool.runner)
///     }
/// }
/// ```
///
/// Consumers then work with a typed ``IO`` specialised to their domain:
///
/// ```swift
/// let file: IO<File.Capabilities> = .blocking()
/// let fd = try await file.capabilities.open(path, .readOnly)
/// try await file.capabilities.close(consume fd)
///
/// // TCA26 shared-executor co-location is uniform across domains:
/// actor Server {
///     let io: IO<Socket.Capabilities>
///     nonisolated var unownedExecutor: UnownedSerialExecutor {
///         io.runner.executor()
///     }
/// }
/// ```
///
/// ## Why this shape
///
/// The design follows the Plotkin–Power–Pretnar algebraic-effects
/// coproduct construction:
///
/// - Each domain supplies its own signature (``Capabilities``).
/// - The runner is the shared scheduling concern.
/// - ``IO`` is the coproduct shell that combines them.
///
/// See `swift-io-primitives/Research/README.md` for the full design
/// rationale and the experiments that validated each choice.
public struct IO<Capabilities: Sendable>: Sendable {

    /// The domain-specific operation set.
    ///
    /// A value of some domain-defined struct (for example `File.Capabilities`,
    /// `Socket.Capabilities`, or the basic fd-byte-ops witness).
    public let capabilities: Capabilities

    /// The scheduling evidence — the underlying executor plus a shutdown hook.
    ///
    /// Produced by a strategy (blocking / events / completions) at
    /// construction time.
    public let runner: Runner

    /// Creates an IO bundle from a capability set and a runner.
    ///
    /// Not typically called directly by consumers; instead, use a
    /// per-(domain × strategy) factory such as
    /// `IO<File.Capabilities>.blocking()` or
    /// `IO<Socket.Capabilities>.completions(on:)`.
    public init(capabilities: Capabilities, runner: Runner) {
        self.capabilities = capabilities
        self.runner = runner
    }
}
