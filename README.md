# swift-io

Use this package when a domain package (files, sockets, servers, raw descriptors) needs one value that carries its I/O operations as a struct of `@Sendable` closures, together with the executor that work runs on, so that callers can swap in a live or fake implementation. Start from `IO<Capabilities>`, with your own capabilities struct as `Capabilities`, and `IO.Runner`. In tests, import `IO Test Support` for the one-argument `IO(capabilities:)`.

## Laws

- `IO<Capabilities>` adds no behaviour of its own. Each call through `capabilities` reaches the supplied closure exactly once, in the order the caller makes it, with nothing cached, retried or reordered, and the closure's typed error reaches the caller unchanged.
- `IO` never calls `IO.Runner.executor` or `IO.Runner.shutdown` itself. Whoever builds the runner decides when to shut it down.
- `IO.Runner.unimplemented` traps the moment either closure is called. The one-argument `IO(capabilities:)` installs it, so that initializer is only for fakes that never touch the runner. It lives in `IO Test Support`, not in `IO`.
