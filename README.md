# swift-io

A platform-independent witness shape for typed I/O capabilities.

`IO<Capabilities>` bundles a domain's `Sendable` operation set with the scheduling evidence used to run it. The package defines only the shared shape: platform packages own concrete file, socket, server, and other I/O capabilities.

## Installation

Add the package from its canonical home:

```swift
dependencies: [
    .package(
        url: "https://github.com/swift-atoms/swift-io.git",
        branch: "main"
    )
]
```

Then depend on the narrowest product your target needs:

```swift
.product(name: "IO", package: "swift-io")
```

## Core

A domain defines its own capability surface and passes the resulting bundle through `IO`:

```swift
import IO

enum FileDomain {
    struct Descriptor: Sendable {
        let rawValue: Int32
    }

    enum Failure: Error, Sendable {
        case unavailable
    }

    struct Capabilities: Sendable {
        let read: @Sendable (
            borrowing Descriptor,
            Int
        ) async throws(Failure) -> Int
    }
}

func read(
    from descriptor: borrowing FileDomain.Descriptor,
    using io: borrowing IO<FileDomain.Capabilities>
) async throws(FileDomain.Failure) -> Int {
    try await io.capabilities.read(descriptor, 4096)
}
```

Outside Embedded Swift, `IO.Runner` carries an `UnownedSerialExecutor` provider and an asynchronous shutdown hook, and `IO` is initialized with both capabilities and a runner. Under Embedded, the unavailable executor surface is omitted and `IO(capabilities:)` preserves the capability bundle directly.

## Products

- `IO` — the generic capability bundle and, outside Embedded, its runner witness.
- `IO Standard Library Integration` — the standard-library integration and compatibility re-export seam.
- `IO Apple Foundation Integration` — the Apple Foundation integration seam; this is the only product that imports Foundation.

The package has no external dependencies. Its core and standard-library integration are Foundation-free.

## License

See [LICENSE.md](LICENSE.md).
