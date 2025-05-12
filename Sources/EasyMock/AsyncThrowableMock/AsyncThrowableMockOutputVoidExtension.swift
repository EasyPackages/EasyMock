//
// Created by Paolo Prodossimo Lopes
// Open-source utility for testing - Use freely with attribution.
//

@available(iOS 13.0, *)
@available(macOS 10.15, *)
@available(tvOS 13.0, *)
@available(watchOS 6.0, *)
@available(visionOS 1.0, *)
extension AsyncThrowableMock where Output == Void {
    ///
    /// Creates an `AsyncThrowableMock` for a scenario with no output (`Void`).
    ///
    /// - Example:
    /// ```swift
    /// let mock = AsyncThrowableMock<Void, Void>()
    /// try await mock.synchronize()
    /// ```
    ///
    public convenience init() {
        self.init(())
    }
}
