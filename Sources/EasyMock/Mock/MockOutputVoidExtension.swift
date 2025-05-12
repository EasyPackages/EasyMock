//
// Created by Paolo Prodossimo Lopes
// Open-source utility for testing - Use freely with attribution.
//

extension Mock where Output == Void {
    ///
    /// Initializes a mock where both input and output are `Void`.
    ///
    /// - Example:
    /// ```swift
    /// let mock = Mock<Void, Void>()
    /// mock.synchronize() // returns ()
    /// ```
    ///
    public convenience init() {
        self.init(())
    }
}
