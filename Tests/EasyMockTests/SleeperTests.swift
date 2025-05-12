import Testing

@testable import EasyMock

@Suite("Sleeper")
struct SleeperTests {

    @Test("should return immediately when delay is zero")
    func testWaitReturnsImmediatelyWhenDelayIsZero() async throws {
        let sut = Sleeper()
        let start = ContinuousClock().now
        
        try await sut.wait()
        
        let duration = start.duration(to: ContinuousClock().now)
        #expect(duration < .milliseconds(10))
    }

    @Test("should wait approximately the configured delay")
    func testWaitHonorsConfiguredDelay() async throws {
        var sut = Sleeper()
        sut.set(0.2)
        
        let start = ContinuousClock().now
        
        try await sut.wait()
        
        let duration = start.duration(to: ContinuousClock().now)
        
        #expect(duration >= .milliseconds(200))
        #expect(duration <= .milliseconds(300))
    }

    @Test("should wait different delays on multiple calls")
    func testWaitWithDifferentDelays() async throws {
        var sut = Sleeper()

        sut.set(0.1)
        let start1 = ContinuousClock().now
        try await sut.wait()
        let duration1 = start1.duration(to: ContinuousClock().now)
        #expect(duration1 >= .milliseconds(100))

        sut.set(0.05)
        let start2 = ContinuousClock().now
        try await sut.wait()
        let duration2 = start2.duration(to: ContinuousClock().now)
        #expect(duration2 >= .milliseconds(50))
        #expect(duration2 < duration1)
    }
}
