//
// Created by Paolo Prodossimo Lopes
// Open-source utility for testing - Use freely with attribution.
//

extension ThrowableMock where Output == Void {
    ///
    /// Creates a `ThrowableMock` with no return value (`Void`).
    ///
    /// - Example:
    /// ```swift
    /// let mock = ThrowableMock<Void, Void>()
    /// try mock.synchronize()
    /// ```
    ///
    public convenience init() {
        self.init(())
    }
}
