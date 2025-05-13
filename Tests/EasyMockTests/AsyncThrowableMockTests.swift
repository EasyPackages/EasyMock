import Testing
import Foundation

@testable import EasyMock

@Suite("AsyncThrowableMock")
struct AsyncThrowableMockTests {

    @Test("should not be marked as called initially")
    func testWasNotCalledInitially() {
        let sut = makeSut()
        
        #expect(sut.wasCalled == false)
    }

    @Test("should return the configured output")
    func testReturnsConfiguredOutput() {
        let output = "any-ouput-mock"
        
        let sut = makeSut(output: output)
        
        #expect(sut.returnValue == output)
    }

    @Test("should start with call count equal to 0")
    func testInitialCallCountIsZero() {
        let sut = makeSut()
        
        #expect(sut.callCount == 0)
    }

    @Test("should start with empty spies list")
    func testInitialSpiesIsEmpty() {
        let sut = makeSut()
        
        #expect(sut.spies == [])
    }

    @Test("should add input to spies when synchronized")
    func testInputAddedToSpies() async throws {
        let input = "any-input-mock"
        let sut = makeSut()
        
        try await sut.synchronize(input)
        
        #expect(sut.spies == [input])
    }

    @Test("should increase call count after synchronization")
    func testCallCountIncreasedAfterSync() async throws {
        let input = "any-input-mock"
        let sut = makeSut()
        
        try await sut.synchronize(input)
        
        #expect(sut.callCount == 1)
    }

    @Test("should be marked as called after synchronization")
    func testWasCalledAfterSync() async throws {
        let input = "any-input-mock"
        let sut = makeSut()
        
        try await sut.synchronize(input)
        
        #expect(sut.wasCalled == true)
    }

    @Test("should maintain return value after synchronization")
    func testReturnValueAfterSync() async throws {
        let output = "any-output-mock"
        let sut = makeSut(output: output)
        
        try await sut.synchronize("any-output-mock")
        
        #expect(sut.returnValue == output)
    }

    @Test("should override return value after mock call")
    func testOverrideReturnValue() {
        let output = "any-other-output"
        let sut = makeSut(output: "any-output-mock")
        
        sut.mock(returning: output)
        
        #expect(sut.returnValue == output)
    }

    @Test("should not trigger observers immediately when subscribing")
    func testObserversNotCalledWhenSubscribing() {
        let sut = makeSut()
        
        sut.observe { _ in Issue.record("must not be called whe subscribe") }
        sut.observe { Issue.record("must not be called whe subscribe") }
    }

    @Test("should not trigger observers when mocking return value")
    func testObserversNotCalledOnMocking() {
        let sut = makeSut()
        sut.observe { _ in Issue.record("must not be called whe mocking") }
        sut.observe { Issue.record("must not be called whe mocking") }
        
        sut.mock(returning: "any-output")
    }

    @Test("should notify observers in correct order during sync")
    func testObserversReceiveValuesOnSync() async throws {
        let input = "any-input-mock"
        var received = [String?]()
        let sut = makeSut()
        sut.observe { received.append($0) }
        sut.observe { received.append(nil) }
        
        try await sut.synchronize(input)
        
        #expect(received == [input, nil])
    }
    
    @Test("should return initial mocked output when synchronized")
    func testReturnsConfiguredOutputOnSync() async throws {
        let output = "any-output-mock"
        let sut = makeSut(output: output)
        
        let synchronizedValue = try await sut.synchronize("any")
        
        #expect(synchronizedValue == output)
    }
    
    @Test("should return newly mocked output after override")
    func testReturnsUpdatedOutputAfterMockOverride() async throws {
        let output = "any-other-output-mock"
        let sut = makeSut(output: "any-output-mock")
        sut.mock(returning: output)
        
        let synchronizedValue = try await sut.synchronize("any")
        
        #expect(synchronizedValue == output)
    }
    
    @Test("should return mocked output when input is Void")
    func testReturnsMockedOutputWithVoidInput() async throws {
        let output = "output-mock"
        let sut = AsyncThrowableMock<Void, String>(output)
        
        #expect(try await sut.synchronize() == output)
    }
    
    @Test("should return Void when output type is Void")
    func testReturnsVoidWhenOutputTypeIsVoid() async throws {
        let sut = AsyncThrowableMock<String, Void>()
        
        #expect(try await sut.synchronize("input-mock") == ())
    }
    
    @Test("should throw the configured error on synchronize")
    func testThrowsConfiguredErrorOnSync() async {
        let errorMock = makeError()
        let sut = makeSut()
        sut.mock(throwing: errorMock)
        
        do {
            try await sut.synchronize("any")
            Issue.record("Expected error, but no error was thrown")
        } catch {
            #expect(error as NSError == errorMock)
        }
    }
    
    @Test("should throw the configured error when output is Void")
    func testThrowsConfiguredErrorWithVoidOutput() async {
        let errorMock = makeError()
        let sut = AsyncThrowableMock<Void, String>("any")
        sut.mock(throwing: errorMock)
        
        do {
            try await sut.synchronize()
            Issue.record("Expected error, but no error was thrown")
        } catch {
            #expect(error as NSError == errorMock)
        }
    }
    
    @Test("should not trigger observers when mocking throws error value")
    func testObserversNotCalledOnMockingThrowsError() {
        let sut = makeSut()
        sut.observe { _ in Issue.record("must not be called whe mocking") }
        sut.observe { Issue.record("must not be called whe mocking") }
        
        sut.mock(throwing: makeError())
    }
    
    @Test("should wait for the configured delay before completing")
    func testsynchronizeAppliesDelay() async throws {
        let delay = 0.2
        let tolerance = 0.05
        let clock = ContinuousClock()
        let start = clock.now
        let sut = makeSut()
        sut.mock(delay: delay)

        try await sut.synchronize("any-input")

        let duration = start.duration(to: clock.now)
        let minimumExpected = delay
        let maximumExpected = delay + tolerance

        #expect(
            duration >= .seconds(minimumExpected) && duration <= .seconds(maximumExpected),
            "Duration (\(duration)) was not within the expected range (\(minimumExpected)s to \(maximumExpected)s)"
        )
    }
    
    @Test("should not trigger observers when mocking delay")
    func testObserversNotCalledOnMockingDelay() {
        let sut = makeSut()
        sut.observe { _ in Issue.record("must not be called whe mocking") }
        sut.observe { Issue.record("must not be called whe mocking") }
        
        sut.mock(delay: 10)
    }
    
    @Test("should safely handle concurrent synchronize calls")
    func testConcurrentSynchronizeWithoutRaceConditions() async {
        let sut = makeSut()
        let iterations = 100

        await withTaskGroup(of: Void.self) { group in
            for i in 0..<iterations {
                group.addTask {
                    _ = try? await sut.synchronize("input-\(i)")
                }
            }
        }

        #expect(sut.spies.count == iterations)
    }

    private func makeSut(output: String = "ouput-mock") -> AsyncThrowableMock<String, String> {
        AsyncThrowableMock<String, String>(output)
    }
}
