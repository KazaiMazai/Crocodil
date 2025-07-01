//
//  Untitled.swift
//  Crocodil
//
//  Created by Serge Kazakov on 01/07/2025.
//
import Foundation

/**
 A protocol that custom dependency containers should conform to.

 The `Container` protocol provides a foundation for implementing dependency injection containers
 in Swift. It extends the `Injectable` protocol and adds static subscript and injection capabilities
 that allow for easy access to dependencies and runtime dependency injection.

 ## Conformance Requirements

 - Must provide a default initializer `init()`
 - Must conform to `Injectable` protocol (nothing to do here)

 ## Usage

 The main container `Dependencies` already conforms to this protocol. You can also create custom containers:

 ```swift
 struct Environment: Container {
     init() { }
     
     @DependencyEntry var developerMode: Bool = false
 }
 ```

 ## Accessing Dependencies

 Use `InjectableKeyPath` type alias to create property wrappers for your custom container:

 ```swift
 typealias Feature<Value> = InjectableKeyPath<Environment, Value>

 @Observable
 class ViewModel {
     @Feature(\.developerMode) var developerMode
 }
 ```

 Or access dependencies directly using subscript syntax:

 ```swift
 let isDevMode = Environment[\.developerMode]
 ```

 ## Injecting Dependencies

 Replace dependencies at runtime, perfect for testing:

 ```swift
 Environment.inject(\.developerMode, true)
 ```

 ## Key Features

 - **Static Access**: Use subscript syntax to access dependencies without creating container instances
 - **Runtime Injection**: Inject dependencies at runtime using writable key paths
 - **Type Safety**: Leverages Swift's type system for compile-time safety
 - **Injectable Integration**: Works seamlessly with the `Injectable` protocol and `@DependencyEntry` macro
 */
public protocol Container: Injectable {
    /**
     Creates a new instance of the container.

     This initializer should be implemented to set up the container with any required
     configuration, if needed.
     */
    init()
}

extension Container {
    /**
     Accesses a dependency using a key path

     This subscript allows you to access dependencies directly on the container type,
     providing a convenient way to retrieve dependencies..

     - Parameter keyPath: The key path to the dependency property
     - Returns: The dependency value

     ## Example

     ```swift
     let isDevMode = Environment[\.developerMode]
     ```
     */
    public static subscript<Value>(_ keyPath: KeyPath<Self, Value>) -> Value {
        Self()[keyPath: keyPath]
    }

    /**
     Injects a dependency at runtime using a writable key path.

     This method allows you to replace dependencies at runtime, which is useful for
     testing scenarios or dynamic dependency configuration.

     - Parameters:
       - keyPath: The writable key path to the dependency property
       - value: The new value to inject

     ## Example

     ```swift
     // Inject values for testing
     Environment.inject(\.developerMode, true)
     ```
     */
    public static func inject<Value>(_ keyPath: WritableKeyPath<Self, Value>, _ value: Value) {
        var instance = Self()
        instance[keyPath: keyPath] = value
    }
}
