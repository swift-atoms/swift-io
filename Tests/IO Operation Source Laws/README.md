# IO operation source laws

These fixtures record compile-time ownership and region laws. They are
documentation inputs, not an executable test target.

- positive-move-only-output.swift.fixture records transfer of a move-only
  result.
- positive-sending-capture.swift.fixture records transfer of a non-Sendable
  capture into the privately owned one-shot result closure.
- negative-repeat-wait.swift.fixture records that the result wait consumes its
  operation.
- negative-share-result.swift.fixture records that the move-only result cannot
  be given to two consumers.
- negative-sendable-operation.swift.fixture records that the operation is not a
  concurrently reusable closure capture.

The executable lifecycle fixtures record cancellation before waiting and
physical completion before cancellation. The public lifecycle article states
the cancellation-during-wait and drop-without-wait laws because their concrete
scheduling mechanics belong to the strategy that supplies the closures.
