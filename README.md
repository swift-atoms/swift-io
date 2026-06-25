# IO Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

The canonical Layer 1 witness shape for I/O in Swift — `IO<Capabilities>` pairs a domain's operation set with the scheduling evidence that runs it, with zero platform dependencies.

---

## Quick Start

`IO<Capabilities>` is one generic shell shared by every I/O domain. A domain (files, sockets, servers, timers, basic fd byte-ops) supplies its own `Capabilities` struct of `@Sendable` operation closures; `IO` bundles that struct with an `IO.Runner` — the executor the operations run on plus an idempotent shutdown hook. The two concerns stay structurally separate: capabilities describe *what* operations exist, the runner describes *where* they run, so one runner can back many domains.

```swift
import IO_Primitives_Test_Support  // re-exports IO_Primitives + the `.unimplemented` runner

// A domain defines its own capability surface (this is what `swift-io` does at L3).
enum BasicFD {
    struct Descriptor: Sendable { let raw: Int32 }
    enum Failure: Error, Sendable { case wouldBlock }

    struct Capabilities: Sendable {
        let read:  @Sendable (borrowing Descriptor, Int) async throws(Failure) -> Int
        let write: @Sendable (borrowing Descriptor, Int) async throws(Failure) -> Int
        let close: @Sendable (consuming Descriptor) async -> Void
    }
}

// One generic shell bundles the domain's closures. A production factory would
// supply a real runner; here the test-support `.unimplemented` runner stands in.
let io = IO(
    capabilities: BasicFD.Capabilities(
        read:  { fd, count throws(BasicFD.Failure) in count },
        write: { fd, count throws(BasicFD.Failure) in count },
        close: { fd in }
    )
)

// Consumers work against a typed bundle; typed throws survive the surface.
let bytesRead = try await io.capabilities.read(BasicFD.Descriptor(raw: 3), 64)
```

In production an `IO.Runner` carries two closures supplied by the scheduling strategy: `executor` returns the `UnownedSerialExecutor` the bundle is pinned to (so consumer actors can forward `unownedExecutor` and avoid an executor hop), and `shutdown` releases the underlying OS resources. The package ships the witness types only — no actors, no strategy factories, no kernel imports. Those live at Layer 3.

---

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-io-primitives.git", branch: "main")
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "IO Primitives", package: "swift-io-primitives"),
    ]
)
```

Requires Swift 6.3.1 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the matching Linux / Windows toolchain).

---

## Architecture

Two library products, zero external dependencies.

| Product | Target | Purpose |
|---------|--------|---------|
| `IO Primitives` | `Sources/IO Primitives/` | The `IO<Capabilities>` bundle (capabilities + runner) and nested `IO.Runner` (executor closure + shutdown hook). |
| `IO Primitives Test Support` | `Tests/Support/` | Re-exports the main target plus `IO.Runner.unimplemented` (a trapping runner) and an `IO(capabilities:)` convenience initializer for tests that exercise only the capability surface. |

Foundation-free.

---

## Platform Support

| Platform | Status |
|----------|--------|
| macOS 26 | Full support |
| Linux | Full support |
| Windows | Full support |
| iOS / tvOS / watchOS / visionOS | Supported |
| Swift Embedded | Supported |

---

## Community

<!-- BEGIN: discussion -->
<!-- Discussion thread created at publication. -->
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
