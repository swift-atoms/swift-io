# swift-io-primitives

Layer 1 (primitives) package hosting bare witness **types** for the swift-io constellation — `IO` capability, `IO.Runner`, and the plain `Bound` struct that combines them. No actors, no strategy factories, no kernel dependency. Those live at Layer 3 (swift-foundations/swift-io).

The package is intentionally empty while the canonical witness shape is still under investigation. Candidate shapes (capability+runner split, generic-over-error, generic-over-ops, domain-generic-substrate, and several prior-art shapes from Tokio/ZIO/Eio/monoio) are sketched as nested SwiftPM experiments under `/Users/coen/Developer/swift-primitives/Experiments/io-witness-*/`. Once the zoo returns a winner, its types move here.

## Tier

Tier 2 — depends only on `swift-witness-primitives` (tier 2) and `swift-standard-library-extensions` (tier 0).

## Status

Empty scaffold. See:
- `/Users/coen/Developer/swift-foundations/swift-io/Research/io-witness-capability-runner-split.md`
- `/Users/coen/Developer/swift-primitives/Experiments/_index.json` (io-witness-* entries)
