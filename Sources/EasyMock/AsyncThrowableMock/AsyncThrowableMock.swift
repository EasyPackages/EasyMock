//
// Created by Paolo Prodossimo Lopes
// Open-source utility for testing - Use freely with attribution.
//

import Foundation

///
/// A test utility that simulates asynchronous and throwable behaviors for mocking dependencies.
///
/// `AsyncThrowableMock` is ideal for unit testing asynchronous functions that may either return a value or throw an error.
/// It wraps `ThrowableMock` to provide enhanced support for `async/await` flows and introduces configurable delays
/// to simulate real-world asynchronous latency (like network calls, disk access, etc.).
///
/// This utility is particularly useful in testing:
/// - Retry logic
/// - Error handling paths
/// - Loading states with delays
/// - Awaitable async flows
///
/// Internally, inputs are recorded, return values can be customized, and observers can be registered to react on calls.
/// Errors can be injected to simulate failures.
///
/// - Important: This class is `@unchecked Sendable` and requires platforms that support Swift Concurrency:
///   iOS 13.0+, macOS 10.15+, tvOS 13.0+, watchOS 6.0+, visionOS 1.0+.
///
/// ## Quick Example
/// ```swift
/// let mock = AsyncThrowableMock<String, Bool>(true)
/// mock.mock(throwing: nil)
/// mock.mock(delay: 1.0)
/// let result = try await mock.synchronize("load")
/// XCTAssertTrue(result)
/// ```
///
/// ## Complete example
/// ```swift
/// enum AppError: Error { case timeout }
///
/// protocol AsyncService {
///     func load() async throws
///     func fetch(id: Int) async throws
///     func readMessage() async throws -> String
///     func title(for id: Int) async throws -> String
/// }
///
/// struct AsyncServiceMock: AsyncService {
///     let loadMocked = AsyncThrowableMock<Void, Void>(())
///     let fetchMocked = AsyncThrowableMock<Int, Void>(())
///     let readMessageMocked = AsyncThrowableMock<Void, String>("default")
///     let titleMocked = AsyncThrowableMock<Int, String>("none")
///
///     func load() async throws {
///         try await loadMocked.synchronize()
///     }
///
///     func fetch(id: Int) async throws {
///         try await fetchMocked.synchronize(id)
///     }
///
///     func readMessage() async throws -> String {
///         try await readMessageMocked.synchronize()
///     }
///
///     func title(for id: Int) async throws -> String {
///         try await titleMocked.synchronize(id)
///     }
/// }
///
/// let mock = AsyncServiceMock()
/// mock.readMessageMocked.mock(returning: "OK")
/// mock.titleMocked.mock(throwing: AppError.timeout)
///
/// let message = try await mock.readMessage()
/// #expect(message == "OK")
///
/// do {
///     _ = try await mock.title(for: 99)
///     #expect(false) // shouldn't reach here
/// } catch {
///     #expect(error as? AppError == .timeout)
/// }
/// ```
///
@available(iOS 13.0, *)
@available(macOS 10.15, *)
@available(tvOS 13.0, *)
@available(watchOS 6.0, *)
@available(visionOS 1.0, *)
public final class AsyncThrowableMock<Input, Output>: @unchecked Sendable {

    // MARK: - Private Properties

    private let mocked: ThrowableMock<Input, Output>
    private var sleeper = Sleeper()

    // MARK: - Initialization

    ///
    /// Creates a new asynchronous throwable mock with a given initial return value.
    ///
    /// - Parameter initialValue: The default value to return when `synchronize` is called.
    ///
    public init(_ initialValue: Output) {
        self.mocked = ThrowableMock(initialValue)
    }

    // MARK: - Public Properties

    ///
    /// The current value returned by `synchronize` if no error is mocked.
    ///
    public var returnValue: Output {
        mocked.returnValue
    }

    ///
    /// All recorded input values received from previous calls.
    ///
    /// Useful for assertions in unit tests.
    ///
    public var spies: [Input] {
        mocked.spies
    }

    ///
    /// The number of times `synchronize` was called.
    ///
    public var callCount: Int {
        mocked.callCount
    }

    ///
    /// Whether `synchronize` was ever called.
    ///
    public var wasCalled: Bool {
        mocked.wasCalled
    }

    // MARK: - Behavior

    ///
    /// Simulates an asynchronous operation by:
    /// - Recording the input.
    /// - Throwing a mock error (if one was set).
    /// - Waiting an optional delay (if configured).
    /// - Returning the mock output (if no error).
    ///
    /// - Parameter input: The input value to record.
    /// - Throws: The error set via `mock(throwing:)`, if any.
    /// - Returns: The mocked output value.
    ///
    /// - Example:
    /// ```swift
    /// let mock = AsyncThrowableMock<String, Bool>(true)
    /// try await mock.synchronize("ping") // returns true
    /// ```
    ///
    @discardableResult public func synchronize(_ input: Input) async throws -> Output {
        try await sleeper.wait()
        return try mocked.synchronize(input)
    }

    ///
    /// Configures an artificial delay to simulate latency.
    ///
    /// This delay will be applied to subsequent `synchronize` calls.
    ///
    /// - Parameter delay: Delay duration in seconds.
    ///
    /// - Example:
    /// ```swift
    /// mock.mock(delay: 2.0) // Simulates 2 seconds of network delay
    /// ```
    ///
    public func mock(delay: Double) {
        sleeper.set(delay)
    }

    ///
    /// Sets a new value to return from future calls.
    ///
    /// - Parameter output: The value to return when `synchronize` is called.
    ///
    public func mock(returning output: Output) {
        mocked.mock(returning: output)
    }

    ///
    /// Configures an error to be thrown on subsequent calls to `synchronize`.
    ///
    /// Pass `nil` to disable error throwing.
    ///
    /// - Parameter error: The error to simulate.
    ///
    /// - Example:
    /// ```swift
    /// mock.mock(throwing: MyError.test)
    /// ```
    ///
    public func mock(throwing error: Error?) {
        mocked.mock(throwing: error)
    }

    // MARK: - Observation

    ///
    /// Adds an observer that receives the input on every `synchronize` call.
    ///
    /// - Parameter completion: Closure executed with the recorded input.
    ///
    public func observe(_ completion: @escaping ((Input) -> Void)) {
        mocked.observe(completion)
    }

    ///
    /// Adds an observer that is triggered on every `synchronize`, regardless of input.
    ///
    /// - Parameter completion: Closure executed on each call.
    ///
    public func observe(_ completion: @escaping (() -> Void)) {
        mocked.observe(completion)
    }
}
