//
// Created by Paolo Prodossimo Lopes
// Open-source utility for testing - Use freely with attribution.
//

@available(iOS 13.0, *)
@available(macOS 10.15, *)
@available(tvOS 13.0, *)
@available(watchOS 6.0, *)
@available(visionOS 1.0, *)
extension AsyncMock where Input == Void {
    ///
    /// Simula uma chamada assíncrona sem entrada (`Void`).
    ///
    /// - Returns: O valor atualmente configurado.
    ///
    /// - Example:
    /// ```swift
    /// let mock = AsyncMock<Void, String>("done")
    /// let result = await mock.synchronize() // returns "done"
    /// ```
    ///
    @discardableResult
    public func synchronize() async -> Output {
        await synchronize(())
    }
}
