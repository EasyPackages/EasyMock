//
// Created by Paolo Prodossimo Lopes
// Open-source utility for testing - Use freely with attribution.
//

import Foundation

///
/// A utility mock that extends `Mock` to simulate errors and successful results in unit tests.
///
/// `ThrowableMock` is useful when you're testing code that can either return a value or throw an error.
/// Like `Mock`, it records inputs and returns a predefined output, but also gives you control over simulating failures.
///
/// Use cases incluem, por exemplo:
/// - Testar tratamentos de erro (`try/catch`)
/// - Simular falhas de rede ou de camada de serviço
/// - Garantir que exceções sejam lançadas nas condições corretas
///
/// ## Quick Example
/// ```swift
/// enum MyError: Error { case failure }
/// let mock = ThrowableMock<String, Bool>(true)
/// mock.mock(throwing: MyError.failure)
/// XCTAssertThrowsError(try mock.synchronize("input"))
/// ```
///
/// ## Complete example
/// ```swift
/// enum MyError: Error { case failure }
///
/// protocol Service {
///     func run() throws
///     func validate(id: Int) throws
///     func loadValue() throws -> String
///     func compute(for input: Int) throws -> String
/// }
///
/// struct ServiceMock: Service {
///     let runMocked = ThrowableMock<Void, Void>(())
///     let validateMocked = ThrowableMock<Int, Void>(())
///     let loadValueMocked = ThrowableMock<Void, String>("default")
///     let computeMocked = ThrowableMock<Int, String>("none")
///
///     func run() throws {
///         try runMocked.synchronize()
///     }
///
///     func validate(id: Int) throws {
///         try validateMocked.synchronize(id)
///     }
///
///     func loadValue() throws -> String {
///         try loadValueMocked.synchronize()
///     }
///
///     func compute(for input: Int) throws -> String {
///         try computeMocked.synchronize(input)
///     }
/// }
///
/// let mock = ServiceMock()
/// mock.loadValueMocked.mock(returning: "Token123")
/// mock.computeMocked.mock(throwing: MyError.failure)
///
/// let value = try mock.loadValue()
/// #expect(value == "Token123")
///
/// do {
///     _ = try mock.compute(for: 99)
///     #expect(false) // shouldn't reach here
/// } catch {
///     #expect(error as? MyError == .failure)
/// }
/// ```
///
public final class ThrowableMock<Input, Output>: @unchecked Sendable {

    // MARK: - Private

    private let mocked: Mock<Input, Output>
    private var error: Error?

    // MARK: - Initialization

    ///
    /// Creates a throwable mock with a default return value.
    ///
    /// - Parameter initialValue: The initial value to return if no error is thrown.
    ///
    public init(_ initialValue: Output) {
        mocked = Mock(initialValue)
    }

    // MARK: - Public Properties

    ///
    /// The value currently returned by `synchronize` (if no error is mocked).
    ///
    public var returnValue: Output {
        mocked.returnValue
    }

    ///
    /// All input values that were passed to the mock.
    ///
    public var spies: [Input] {
        mocked.spies
    }

    ///
    /// The number of times the mock has been called.
    ///
    public var callCount: Int {
        mocked.callCount
    }

    ///
    /// Whether the mock was called at least once.
    ///
    public var wasCalled: Bool {
        mocked.wasCalled
    }

    // MARK: - Behavior Control

    ///
    /// Simulates a call to the mock, throwing an error if configured.
    ///
    /// - Parameter input: The input value to store and forward to observers.
    /// - Throws: The error configured via `mock(throwing:)`, if any.
    /// - Returns: The current return value if no error is thrown.
    ///
    /// - Example:
    /// ```swift
    /// let mock = ThrowableMock<String, Bool>(true)
    /// mock.mock(throwing: nil)
    /// let result = try mock.synchronize("event") // returns true
    /// ```
    ///
    @discardableResult public func synchronize(_ input: Input) throws -> Output {
        let output = mocked.synchronize(input)
        if let error {
            throw error
        }
        return output
    }

    ///
    /// Sets an error to be thrown on future calls.
    ///
    /// - Parameter error: The error to simulate. Pass `nil` to disable error throwing.
    ///
    /// - Example:
    /// ```swift
    /// mock.mock(throwing: MyError.invalidToken)
    /// ```
    ///
    public func mock(throwing error: Error?) {
        self.error = error
    }

    ///
    /// Changes the return value of the mock.
    ///
    /// - Parameter returning: The new value to return (if no error is configured).
    ///
    public func mock(returning: Output) {
        mocked.mock(returning: returning)
    }

    // MARK: - Observation

    ///
    /// Adds an observer triggered with the input every time `synchronize` is called.
    ///
    /// - Parameter completion: Closure called with the input value.
    ///
    public func observe(_ completion: @escaping ((Input) -> Void)) {
        mocked.observe(completion)
    }

    ///
    /// Adds a general observer triggered on every call to `synchronize`, regardless of input.
    ///
    /// - Parameter completion: Closure called without parameters.
    ///
    public func observe(_ completion: @escaping (() -> Void)) {
        mocked.observe(completion)
    }
}
