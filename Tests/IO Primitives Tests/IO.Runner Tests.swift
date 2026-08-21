import IO_Primitives_Test_Support
import Testing

@Suite("IO.Runner")
private struct Test {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

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

extension Test.Unit {

    @Test
    func `Runner stores executor and shutdown closures`() async {
        let counter = Counter()

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
