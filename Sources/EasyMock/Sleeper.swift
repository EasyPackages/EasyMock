@available(iOS 13.0.0, *)
@available(macOS 10.15, *)
struct Sleeper {
    private var delay = 0.0
    
    func wait() async throws {
        guard delay > 0 else { return }
        
        let seconds = UInt64(delay * 1_000_000_000)
        try? await Task.sleep(nanoseconds: seconds)
    }
    
    mutating func set(_ value: Double) {
        delay = value
    }
}
