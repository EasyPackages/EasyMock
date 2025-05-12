//
// Created by Paolo Prodossimo Lopes
// Open-source utility for testing - Use freely with attribution.
//

import Foundation

///
/// A generic and thread-safe mock object for capturing inputs and providing controlled outputs during unit tests.
///
/// `Mock` is useful when testing interactions with a dependency that:
/// - Receives input
/// - Produces output
/// - Should allow inspection of what was called
///
/// It records every input passed to it, returns a customizable value,
/// and allows attaching observers to react when the mock is invoked.
///
/// Internally, `Mock` uses a concurrent queue with a barrier flag to ensure thread-safe access to its recorded inputs.
///
/// ## Use Cases
/// - Verifying that a method was called with the correct inputs
/// - Returning controlled data during tests
/// - Tracking how many times a dependency was invoked
///
/// ## Quick Example
/// ```swift
/// let mock = Mock<String, Bool>(true)
/// mock.mock(returning: false)
/// let result = mock.synchronize("input")
/// ```
///
/// ## Complete example
/// ```swift
/// protocol Interface {
///     func perform()
///     func performWithInput(input: Int)
///     func performWithReturn() -> String
///     func performWithInputAndReturn(input: Int) -> String
/// }
///
/// struct InterfaceMock: Interface {
///     let performMocked = Mock<Void, Void>()
///     let performWithInputMocked = Mock<Int, Void>()
///     let performWithReturnMocked = Mock<Void, String>()
///     let performWithInputAndReturnMocked = Mock<Int, String>()
///
///     func perform() {
///         performMocked.synchronize()
///     }
///
///     func performWithInput(input: Int) {
///         performWithInputMocked.synchronize(input)
///     }
///
///     func performWithReturn() -> String {
///         performWithReturnMocked.synchronize()
///     }
///
///     func performWithInputAndReturn(input: Int) -> String {
///         performWithInputAndReturnMocked.synchronize(input)
///     }
/// }
///
/// let interfaceMock = InterfaceMock()
/// interfaceMock.perform()
/// interfaceMock.performWithInput(input: 42)
/// interfaceMock.performWithReturnMocked.mock(returning: "Hello")
/// interfaceMock.performWithInputAndReturnMocked.mock(returning: "World")
///
/// #expect(interfaceMock.performMocked.wasCalled == true)
/// #expect(interfaceMock.performWithInputMocked.spies == [42])
/// #expect(interfaceMock.performWithReturnMocked.returnValue == "Hello")
/// ```
///
public final class Mock<Input, Output>: @unchecked Sendable {

    // MARK: - Private Properties

    private let queue = DispatchQueue(label: "easymock.mock.queue", attributes: .concurrent)
    private var receivedValues = [Input]()
    private var observers = [((Input) -> Void)]()

    // MARK: - Public Properties

    ///
    /// The value that will be returned when `synchronize` is called.
    ///
    public private(set) var returnValue: Output

    ///
    /// All input values that were passed to the mock.
    ///
    /// Use this to assert the sequence or content of invocations.
    ///
    public var spies: [Input] {
        receivedValues
    }

    ///
    /// The number of times the mock was called.
    ///
    public var callCount: Int {
        receivedValues.count
    }

    ///
    /// Indicates whether the mock has been called at least once.
    ///
    public var wasCalled: Bool {
        !receivedValues.isEmpty
    }

    // MARK: - Initialization

    ///
    /// Initializes the mock with an initial return value.
    ///
    /// - Parameter initialValue: The value to be returned by default.
    ///
    public init(_ initialValue: Output) {
        returnValue = initialValue
    }

    // MARK: - Behavior

    ///
    /// Simulates an invocation of the dependency, recording the input and returning the mocked output.
    ///
    /// - Parameter input: The input to store and forward to observers.
    /// - Returns: The value currently set in `returnValue`.
    ///
    /// - Example:
    /// ```swift
    /// let result = mock.synchronize("data") // Triggers observers, stores input
    /// ```
    ///
    @discardableResult public func synchronize(_ input: Input) -> Output {
        queue.sync(flags: .barrier) {
            defer { observers.forEach { $0(input) } }
            receivedValues.append(input)
            return returnValue
        }
    }

    ///
    /// Sets a new return value for future calls.
    ///
    /// - Parameter returning: The value to be returned by subsequent `synchronize` calls.
    ///
    public func mock(returning: Output) {
        returnValue = returning
    }

    // MARK: - Observation

    ///
    /// Adds an observer that receives the input whenever the mock is called.
    ///
    /// - Parameter completion: A closure that receives the input.
    ///
    public func observe(_ completion: @escaping ((Input) -> Void)) {
        observers.append(completion)
    }

    ///
    /// Adds an observer that is triggered on each call regardless of input.
    ///
    /// - Parameter completion: A closure called every time `synchronize` is invoked.
    ///
    public func observe(_ completion: @escaping (() -> Void)) {
        observers.append({ [completion] _ in completion() })
    }
}
