import Testing

@testable import EasyMock

@Suite("AsyncMock")
struct AsyncMockTests {

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
    func testInputAddedToSpies() async {
        let input = "any-input-mock"
        let sut = makeSut()
        
        await sut.synchronize(input)
        
        #expect(sut.spies == [input])
    }

    @Test("should increase call count after synchronization")
    func testCallCountIncreasedAfterSync() async {
        let input = "any-input-mock"
        let sut = makeSut()
        
        await sut.synchronize(input)
        
        #expect(sut.callCount == 1)
    }

    @Test("should be marked as called after synchronization")
    func testWasCalledAfterSync() async {
        let input = "any-input-mock"
        let sut = makeSut()
        
        await sut.synchronize(input)
        
        #expect(sut.wasCalled == true)
    }

    @Test("should maintain return value after synchronization")
    func testReturnValueAfterSync() async {
        let output = "any-output-mock"
        let sut = makeSut(output: output)
        
        await sut.synchronize("any-output-mock")
        
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
    func testObserversReceiveValuesOnSync() async {
        let input = "any-input-mock"
        var received = [String?]()
        let sut = makeSut()
        sut.observe { received.append($0) }
        sut.observe { received.append(nil) }
        
        await sut.synchronize(input)
        
        #expect(received == [input, nil])
    }
    
    @Test("should return initial mocked output when synchronized")
    func testReturnsConfiguredOutputOnSync() async {
        let output = "any-output-mock"
        let sut = makeSut(output: output)
        
        let synchronizedValue = await sut.synchronize("any")
        
        #expect(synchronizedValue == output)
    }
    
    @Test("should return newly mocked output after override")
    func testReturnsUpdatedOutputAfterMockOverride() async {
        let output = "any-other-output-mock"
        let sut = makeSut(output: "any-output-mock")
        sut.mock(returning: output)
        
        let synchronizedValue = await sut.synchronize("any")
        
        #expect(synchronizedValue == output)
    }
    
    @Test("should return mocked output when input is Void")
    func testReturnsMockedOutputWithVoidInput() async {
        let output = "output-mock"
        let sut = AsyncMock<Void, String>(output)
        
        #expect(await sut.synchronize() == output)
    }
    
    @Test("should return Void when output type is Void")
    func testReturnsVoidWhenOutputTypeIsVoid() async {
        let sut = AsyncMock<String, Void>()
        
        #expect(await sut.synchronize("input-mock") == ())
    }
    
    @Test("should wait for the configured delay before completing")
    func testsynchronizeAppliesDelay() async {
        let delay = 0.2
        let clock = ContinuousClock()
        let start = clock.now
        let sut = makeSut()
        sut.mock(delay: delay)

        await sut.synchronize("any-input")

        let duration = start.duration(to: clock.now)
        #expect(duration >= .seconds(delay))
        #expect(duration <= .seconds(delay + (delay * 0.1)))
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
                    await sut.synchronize("input-\(i)")
                }
            }
        }

        #expect(sut.spies.count == iterations)
    }

    private func makeSut(output: String = "ouput-mock") -> AsyncMock<String, String> {
        AsyncMock<String, String>(output)
    }
}
