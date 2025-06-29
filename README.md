
# 🐊💉 Crocodil — Dependency Injection Library for Swift

Crocodil is a dependency injection (DI) library for Swift that provides a straightforward, boilerplate-free way to manage dependencies in your applications.


## Overview
Dependency Injection is a design pattern that implements Inversion of Control (IoC) to decouple component dependencies. Crocodil offers an elegant macro-powered approach to DI in Swift.

### Problems Solved by Dependency Injection

1. **Tight Coupling**
Without DI, components often create dependencies directly, leading to tight coupling. Crocodil promotes loose coupling, making components easier to test, reuse, and maintain.

2. **Initializer Injection Not Always Possible**
Scenarios where initializer-based DI doesn't work:
- Interfacing with system or third-party frameworks where initializers can't be modified
- Singleton objects that manage their own instantiation
- Legacy codebases with rigid construction patterns

3. **Testing Complexity**
DI enables easy mocking and stubbing. Crocodil makes swapping dependencies effortless for testing purposes.


## Why Crocodil Injection

- **Inject Anything**
Supports injection of enums, structs, classes, closures, and protocol conforming instances

- **Compile-time Safety**
Ensures key-path validity and detects missing dependencies during compilation. 

- **Swift Concurrency Compliant**
Drop-in replacement for singletons, without triggering strict concurrency mode violations.

- **Clean Property Injection**
Uses @Dependency for clean and read-only property injection.

- **Thread Safety**
Built-in concurrency support with safe, synchronized access to dependencies.

- **Macro-powered Simplicity**
With @DependencyEntry`, Crocodil uses Swift macros to register and declare dependencies in one place.

## Usage
### Registering Dependencies
Declaration and registration happen in one shot, ensuring compile-time completeness:

```swift
extension Dependencies {
    // Register protocol implementation
    @DependencyEntry var networkClient: ClientProtocol = NetworkClient()

    // Register shared instance
    @DependencyEntry var userDefaultsStorage = UserDefaults.standard
    
    // Register lazily initialized instance
    @DependencyEntry var lazyService = { Service() }()

    // Register closure
    @DependencyEntry var now = { Date() }
}
```

### Accessing Dependencies

Use `@Dependency` to inject dependencies via key paths:

```swift
@Observable
class ViewModel {
    @Dependency(\.networkClient) var client
    @Dependency(\.userDefaultsStorage) var storage
}
```
Or access dependencies directly:

```swift
let currentTime = Dependency[\.now]
let time = currentTime()
```

### Mocking Dependencies
Swap out dependencies at runtime, perfect for unit tests:

```swift
Dependencies.inject(\.networkClient, NetworkClientMock())
```
## Examples
### Effortless Singletons Replacement

Replace your good old singletons with Swift 6 strict concurrency compatible alternative and never deal with nasty
`Static property 'shared' is not concurrency-safe because it is nonisolated global shared mutable state` again:

```diff

extension Dependencies {
+    @DependencyEntry var networkClient: ClientProtocol = NetworkClient()
}

class NetworkClient {
-    static let shared: NetworkClient = NetworkClient()
+    static var shared: NetworkClient { Dependency[\.networkClient] }
}
```

## Crocodil Injection vs. SwiftUI's EnvironmentValues

| Feature           | SwiftUI EnvironmentValues   | Crocodil Injection              |
|-------------------|-----------------------------|---------------------------------|
| Context           | SwiftUI-only                | Framework-agnostic              |
| Propagation       | Passed down view hierarchy  | Globally accessible             |
| View Re-rendering | Triggers updates            | Does **not** trigger updates    |
| Keys Mechanism    | Uses `EnvironmentKey`       | Uses `DependencyKey`            |
| Macro             | `@Entry`                    | `@DependencyEntry`              |
| Thread Safety     | Limited                     | **Built-in concurrent safety**  |


## How does it work

Crocodil provides a workaround to silence the Swift 6 concurrency warning by using `nonisolated(unsafe)` and syncronizes access to the variable via dedicated concurrent queue which makes access to the shared vaiable actually safe. Crocodil is designed in a way to make it impossible to access the variables directly in any unsafe way.
 

> [!WARNING]
> Although access to the dependencies is syncronized and is thread-safe it doesn't make the dependencies themselves thread-safe or sendable. It's developer's respinsibiliy to make the injected things' internal state thread-safe.


## ⚠️ Limitations
- **Circular Dependencies**: Crocodil cannot detect circular references. 
- **Thread Safety**: While read/write access to the injected instances is synchronized, the injected instances are not automatically thread-safe.
