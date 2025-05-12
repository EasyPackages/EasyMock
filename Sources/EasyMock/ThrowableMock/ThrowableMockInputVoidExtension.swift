//
// Created by Paolo Prodossimo Lopes
// Open-source utility for testing - Use freely with attribution.
//

extension ThrowableMock where Input == Void {
    ///
    /// Convenience call for mocks with `Void` input.
    ///
    /// - Throws: The configured error, if any.
    /// - Returns: The current return value.
    ///
    /// - Example:
    /// ```swift
    /// let mock = ThrowableMock<Void, Int>(3)
    /// let result = try mock.synchronize()
    /// ```
    ///
    @discardableResult public func synchronize() throws -> Output {
        try synchronize(())
    }
}
