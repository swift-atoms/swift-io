public struct IO<Capabilities: Sendable>: Sendable {

    public let capabilities: Capabilities

    #if !hasFeature(Embedded)

        public let runner: Runner

        public init(capabilities: Capabilities, runner: Runner) {
            self.capabilities = capabilities
            self.runner = runner
        }

    #else

        public init(capabilities: Capabilities) {
            self.capabilities = capabilities
        }

    #endif
}
