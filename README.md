<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://github.com/KazaiMazai/Crocodil/blob/main/Docs/Resources/Logo-dark.svg">
  <source media="(prefers-color-scheme: light)" srcset="https://github.com/KazaiMazai/Crocodil/blob/main/Docs/Resources/Logo.svg">
  <img src="https://github.com/KazaiMazai/Crocodil/blob/main/Docs/Resources/Logo.svg">
</picture>

[![CI](https://github.com/KazaiMazai/Crocodil/workflows/Tests/badge.svg)](https://github.com/KazaiMazai/Crocodil/actions?query=workflow%3ATests)


Crocodil is a dependency injection (DI) library for Swift that provides a straightforward, boilerplate-free way to register and access dependencies in your applications.


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

- **Inject Anything**.
Supports injection of enums, structs, classes, closures, and protocol conforming instances

- **Macro-powered Simplicity**. With @DependencyEntry`, Crocodil uses Swift macros to register and declare dependencies in one place.

- **Compile-time Safety**. Ensures key-path validity and detects missing dependencies during compilation. 

- **Swift Concurrency Compliant**. Drop-in replacement for singletons, without triggering strict concurrency mode violations.

- **Clean Property Injection**. Uses @Dependency propery wrapper for clean and read-only dependency access.

- **Thread Safety**. Built-in concurrency support with safe, synchronized access to dependencies.

## Installation

Using [Swift Package Manager](https://swift.org/package-manager/):

```swift
.package(url: "https://github.com/KazaiMazai/Crocodil.git", from: "0.1.0")
``` 

Or via Xcode:

- File → Add Packages
- Enter the URL:
```
https://github.com/KazaiMazai/Crocodil.git
```

## Usage

### Registering Dependencies
Declaration and registration happen in one shot. The variable name then acts as a keypath-based key ensuring compile-time completeness:

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

### Mutating Dependencies

 Crocodil allows to mutate dependencies atomically:
 
```swift
extension Dependencies {
    @DependencyEntry var intValue: Int = 0
}

Dependencies.update(intValue: {
    $0 += 1
})
 
```

> [!NOTE]
> Due to Swift macro limitations, atomic mutation is availave only for dependencies injected with explicitly declared type. 

Declare type explicitly to enable code generation of atomic mutation func:
```diff
extension Dependencies {
-   @DependencyEntry var intValue = 0
+   @DependencyEntry var intValue: Int = 0
}
```
### Access Control Scopes

Crocodil respects access control attributes allowing to naturally scope the dependencies instances.
This will create and register 2 independent instances of dependencies. 
Each will be accessed according to access control attributes:

```swift
//FileA.swift: 
fileprivate extension Dependencies {
    @DependencyEntry var localService = Service()
} 
 
//FileB.swift:
fileprivate extension Dependencies {
    @DependencyEntry var localService = Service()
} 
```

### Lifecycle

@DependencyEntry supports all kinds of types including closures and lazy instance initialization.
This allows to design any kind of dependency lifecycle: 

```swift
 extension Dependencies {
   // Plain singleton
    @DependencyEntry var networkClient: ClientProtocol = NetworkClient()

    // Lazily initialized singleton
    @DependencyEntry var lazyService = { Service() }()

    // Transient instance via closure
    @DependencyEntry var now = { Date() }
 } 
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


## How Does It Work

Crocodil provides a workaround to silence the Swift 6 concurrency warning by using `nonisolated(unsafe)` and syncronizes access to the variable via dedicated concurrent queue which makes access to the shared vaiable actually safe. 
Crocodil is designed in a way to make it impossible to access the variables directly in any unsafe way.
 

> [!WARNING]
> Although access to the dependencies is syncronized and is thread-safe it doesn't make the dependencies themselves thread-safe or sendable. It's developer's respinsibiliy to make the injected things' internal state thread-safe.


## Crocodil Injection vs. SwiftUI's EnvironmentValues

| Feature           | SwiftUI EnvironmentValues   | Crocodil Injection              |
|-------------------|-----------------------------|---------------------------------|
| Context           | SwiftUI-only                | Framework-agnostic              |
| Propagation       | Passed down view hierarchy  | Globally accessible             |
| View Re-rendering | Triggers updates            | Does **not** trigger updates    |
| Keys Mechanism    | Uses `EnvironmentKey`       | Uses `DependencyKey`            |
| Macro             | `@Entry`                    | `@DependencyEntry`              |
| Thread Safety     | Limited                     | **Built-in concurrent safety**  |



## ⚠️ Limitations

### Circular Dependencies

Crocodil cannot detect circular references. Accessing Dependency within another dependency declaration should be made with extra care or avoided.

```swift
extension Dependencies {
    // Be aware of circular references. They are possible and will lead to a crash:
    @DependencyEntry var service = Service(Dependency[\.anotherService])
    @DependencyEntry var anotherService = AnotherService(Dependency[\.service]) 
}
```

 ### Thread Safety
 
 While read/write access to the injected instances is synchronized, the injected instances themselves are not automatically thread-safe.


## Alternatives

There are many dependency injection libraries in the Swift, but only one of them is Crocodil

- [Factory](https://github.com/hmlongco/Factory)
- [Needle](https://github.com/uber/needle)
- [Swinject](https://github.com/Swinject/Swinject)
- [Weaver](https://github.com/scribd/Weaver)
- [Dependencies](https://github.com/pointfreeco/swift-dependencies)

## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.
