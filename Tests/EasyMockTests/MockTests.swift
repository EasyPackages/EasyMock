import Testing
import Foundation

@testable import EasyMock

@Suite("Mock")
struct MockTests {

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
    func testInputAddedToSpies() {
        let input = "any-input-mock"
        let sut = makeSut()
        
        sut.synchronize(input)
        
        #expect(sut.spies == [input])
    }

    @Test("should increase call count after synchronization")
    func testCallCountIncreasedAfterSync() {
        let input = "any-input-mock"
        let sut = makeSut()
        
        sut.synchronize(input)
        
        #expect(sut.callCount == 1)
    }

    @Test("should be marked as called after synchronization")
    func testWasCalledAfterSync() {
        let input = "any-input-mock"
        let sut = makeSut()
        
        sut.synchronize(input)
        
        #expect(sut.wasCalled == true)
    }

    @Test("should maintain return value after synchronization")
    func testReturnValueAfterSync() {
        let output = "any-output-mock"
        let sut = makeSut(output: output)
        
        sut.synchronize("any-output-mock")
        
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
    func testObserversReceiveValuesOnSync() {
        let input = "any-input-mock"
        var received = [String?]()
        let sut = makeSut()
        sut.observe { received.append($0) }
        sut.observe { received.append(nil) }
        
        sut.synchronize(input)
        
        #expect(received == [input, nil])
    }
    
    @Test("should return initial mocked output when synchronized")
    func testReturnsConfiguredOutputOnSync() {
        let output = "any-output-mock"
        let sut = makeSut(output: output)
        
        let synchronizedValue = sut.synchronize("any")
        
        #expect(synchronizedValue == output)
    }
    
    @Test("should return newly mocked output after override")
    func testReturnsUpdatedOutputAfterMockOverride() {
        let output = "any-other-output-mock"
        let sut = makeSut(output: "any-output-mock")
        sut.mock(returning: output)
        
        let synchronizedValue = sut.synchronize("any")
        
        #expect(synchronizedValue == output)
    }
    
    @Test("should return mocked output when input is Void")
    func testReturnsMockedOutputWithVoidInput() {
        let output = "output-mock"
        let sut = Mock<Void, String>(output)
        
        #expect(sut.synchronize() == output)
    }
    
    @Test("should return Void when output type is Void")
    func testReturnsVoidWhenOutputTypeIsVoid() {
        let sut = Mock<String, Void>()
        
        #expect(sut.synchronize("input-mock") == ())
    }
    
    @Test("should safely handle concurrent synchronize calls")
    func testConcurrentSynchronizeWithoutRaceConditions() async {
        let sut = makeSut()
        let iterations = 100

        await withTaskGroup(of: Void.self) { group in
            for i in 0..<iterations {
                group.addTask {
                    sut.synchronize("input-\(i)")
                }
            }
        }

        #expect(sut.spies.count == iterations)
    }
    
    @Sendable
    private func makeSut(output: String = "ouput-mock") -> Mock<String, String> {
        Mock<String, String>(output)
    }
}
