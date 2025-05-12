//
// Created by Paolo Prodossimo Lopes
// Open-source utility for testing - Use freely with attribution.
//

@available(iOS 13.0, *)
@available(macOS 10.15, *)
@available(tvOS 13.0, *)
@available(watchOS 6.0, *)
@available(visionOS 1.0, *)
extension AsyncThrowableMock where Input == Void {
    ///
    /// Calls `synchronize` without input when `Input == Void`.
    ///
    /// - Throws: The mocked error if one is set.
    /// - Returns: The mocked return value.
    ///
    /// - Example:
    /// ```swift
    /// let mock = AsyncThrowableMock<Void, String>("done")
    /// let result = try await mock.synchronize() // returns "done"
    /// ```
    ///
    @discardableResult public func synchronize() async throws -> Output {
        try await synchronize(())
    }
}
