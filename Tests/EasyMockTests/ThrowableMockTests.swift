import Testing
import Foundation

@testable import EasyMock

@Suite("ThrowableMock")
struct ThrowableMockTests {

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
    func testInputAddedToSpies() throws {
        let input = "any-input-mock"
        let sut = makeSut()
        
        try sut.synchronize(input)
        
        #expect(sut.spies == [input])
    }

    @Test("should increase call count after synchronization")
    func testCallCountIncreasedAfterSync() throws {
        let input = "any-input-mock"
        let sut = makeSut()
        
        try sut.synchronize(input)
        
        #expect(sut.callCount == 1)
    }

    @Test("should be marked as called after synchronization")
    func testWasCalledAfterSync() throws {
        let input = "any-input-mock"
        let sut = makeSut()
        
        try sut.synchronize(input)
        
        #expect(sut.wasCalled == true)
    }

    @Test("should maintain return value after synchronization")
    func testReturnValueAfterSync() throws {
        let output = "any-output-mock"
        let sut = makeSut(output: output)
        
        try sut.synchronize("any-output-mock")
        
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
    func testObserversReceiveValuesOnSync() throws {
        let input = "any-input-mock"
        var received = [String?]()
        let sut = makeSut()
        sut.observe { received.append($0) }
        sut.observe { received.append(nil) }
        
        try sut.synchronize(input)
        
        #expect(received == [input, nil])
    }
    
    @Test("should return initial mocked output when synchronized")
    func testReturnsConfiguredOutputOnSync() throws {
        let output = "any-output-mock"
        let sut = makeSut(output: output)
        
        let synchronizedValue = try sut.synchronize("any")
        
        #expect(synchronizedValue == output)
    }
    
    @Test("should return newly mocked output after override")
    func testReturnsUpdatedOutputAfterMockOverride() throws {
        let output = "any-other-output-mock"
        let sut = makeSut(output: "any-output-mock")
        sut.mock(returning: output)
        
        let synchronizedValue = try sut.synchronize("any")
        
        #expect(synchronizedValue == output)
    }
    
    @Test("should return mocked output when input is Void")
    func testReturnsMockedOutputWithVoidInput() throws {
        let output = "output-mock"
        let sut = ThrowableMock<Void, String>(output)
        
        #expect(try sut.synchronize() == output)
    }
    
    @Test("should return Void when output type is Void")
    func testReturnsVoidWhenOutputTypeIsVoid() throws {
        let sut = ThrowableMock<String, Void>()
        
        #expect(try sut.synchronize("input-mock") == ())
    }
    
    @Test("should throw the configured error on synchronize")
    func testThrowsConfiguredErrorOnSync() {
        let errorMock = makeError()
        let sut = makeSut()
        sut.mock(throwing: errorMock)
        
        do {
            try sut.synchronize("any")
            Issue.record("Expected error, but no error was thrown")
        } catch {
            #expect(error as NSError == errorMock)
        }
    }
    
    @Test("should throw the configured error when output is Void")
    func testThrowsConfiguredErrorWithVoidOutput() {
        let errorMock = makeError()
        let sut = ThrowableMock<Void, String>("any")
        sut.mock(throwing: errorMock)
        
        do {
            try sut.synchronize()
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
    
    @Test("should safely handle concurrent synchronize calls")
    func testConcurrentSynchronizeWithoutRaceConditions() async {
        let sut = makeSut()
        let iterations = 100

        await withTaskGroup(of: Void.self) { group in
            for i in 0..<iterations {
                group.addTask {
                    _ = try? sut.synchronize("input-\(i)")
                }
            }
        }

        #expect(sut.spies.count == iterations)
    }

    private func makeSut(output: String = "ouput-mock") -> ThrowableMock<String, String> {
        ThrowableMock<String, String>(output)
    }
}

func makeError() -> NSError {
    NSError(
        domain: "make.error",
        code: -1,
        userInfo: [kCFURLLocalizedNameKey as String : "mock"]
    )
}
