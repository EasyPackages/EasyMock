![Banner](./doc-images/banner.jpg)

[![Swift](https://github.com/EasyPackages/EasyMock/actions/workflows/swift.yml/badge.svg)](https://github.com/EasyPackages/EasyMock/actions/workflows/swift.yml)

# Simulate. Test. Verify

A lightweight and expressive library for unit testing in Swift — supporting `async/await`, delays, error simulation, and call tracking.

## Overview

**EasyMock** is a test utility designed for creating mock objects (test doubles) in Swift with minimal setup and maximum readability.  
It’s ideal for testing interactions, async flows, and error handling — without boilerplate.

### ✨ Features

- ✅ Controlled input/output (stubbing)
- 🔍 Call tracking (spies)
- ⏱ Simulated delays (like network latency)
- 🌀 Full `async/await` support
- ❗ Error simulation (`throw`)
- 🧪 Designed for clarity in unit tests

## Why Use EasyMock?

### Replace This:

```swift
final class AuthenticatorMock: Authenticator {
    private(set) var authenticateCallCount = 0
    private(set) var wasCalledWithCredential: Credential?
    var credentialDelay: Double?
    var authenticateStub = makeAnyAuthenticated()
    var authenticateErrorStub: Error?
    
    func authenticate(_ credential: Credential) async throws -> Authenticated {
        if let delay {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        if let authenticateErrorStub {
            throw authenticateErrorStub
        }
        
        authenticateCallCount += 1
        wasCalledWithCredential = credential
        return authenticateStub
    }
}
```

### With This:

```swift
struct AuthenticatorMock: Authenticator {
    let authenticateMocked = AsyncThrowableMock<Credential, Authenticated>(makeAnyAuthenticated())
    
    func authenticate(_ credential: Credential) async throws -> Authenticated {
        try await authenticateMocked.synchronize(credential)
    }
}
```

## Installation

### Using Swift Package Manager

Add to `Package.swift`:

```swift
dependencies: [
    .package(
        url: "https://github.com/your-username/EasyMock.git",
        from: "1.0.0"
    )
]
```

In your target:

```swift
.target(
    name: "YourApp",
    dependencies: ["EasyMock"]
)
```

## Examples

### Basic Mock

```swift
let mock = Mock<String, Bool>(true)
let result = mock.synchronize("input")

#expect(mock.spies == ["input"])
#expect(result == true)
```

### AsyncMock

```swift
let asyncMock = AsyncMock<Void, String>("Done")
asyncMock.mock(delay: 1.0)

let result = await asyncMock.synchronize()
#expect(result == "Done")
```

### ThrowableMock

```swift
enum LoginError: Error { case invalid }

let mock = ThrowableMock<String, Bool>(false)
mock.mock(throwing: LoginError.invalid)

XCTAssertThrowsError(try mock.synchronize("admin"))
```

### AsyncThrowableMock

```swift
let asyncMock = AsyncThrowableMock<String, Int>(42)
asyncMock.mock(delay: 0.5)
asyncMock.mock(throwing: nil)

let value = try await asyncMock.synchronize("ping")
XCTAssertEqual(value, 42)
```

## Supported Platforms

- iOS 13+
- macOS 10.15+
- Swift 5.9+

## Author

Created by [Paolo Prodossimo Lopes](https://github.com/PaoloProdossimoLopes)  
Feel free to contribute, open issues, or suggest improvements.
