//
// Created by Paolo Prodossimo Lopes
// Open-source utility for testing - Use freely with attribution.
//

extension Mock where Input == Void {
    ///
    /// Calls `synchronize` with no input (used when `Input == Void`).
    ///
    /// - Returns: The current mocked return value.
    ///
    /// - Example:
    /// ```swift
    /// let mock = Mock<Void, Int>(42)
    /// let result = mock.synchronize() // returns 42
    /// ```
    ///
    @discardableResult
    public func synchronize() -> Output {
        synchronize(())
    }
}
