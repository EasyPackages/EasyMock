//
// Created by Paolo Prodossimo Lopes
// Open-source utility for testing - Use freely with attribution.
//

@available(iOS 13.0, *)
@available(macOS 10.15, *)
@available(tvOS 13.0, *)
@available(watchOS 6.0, *)
@available(visionOS 1.0, *)
extension AsyncMock where Output == Void {
    ///
    /// Cria um `AsyncMock` sem valor de retorno (`Void`).
    ///
    /// - Example:
    /// ```swift
    /// let mock = AsyncMock<Void, Void>()
    /// await mock.synchronize()
    /// ```
    ///
    public convenience init() {
        self.init(())
    }
}
