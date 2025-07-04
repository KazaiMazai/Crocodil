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
 struct AppFeatures: Container {
     init() { }
     
     @DependencyEntry var newOnboarding: Bool = false
 }
 ```

 ## Accessing Dependencies

 Use `InjectableKeyPath` typealias to create property wrappers for your custom container:

 ```swift
 typealias Feature<Value> = InjectableKeyPath<AppFeatures, Value>

 class ViewModel {
     @Feature(\.newOnboarding) var newOnboarding
 }
 ```

 Or access dependencies directly using subscript syntax:

 ```swift
 let isNewOnboarding = AppFeatures[\.newOnboarding]
 ```

 ## Injecting Dependencies

 Replace dependencies at runtime:

 ```swift
 AppFeatures.inject(\.newOnboarding, true)
 ```
 */
public protocol Container: Injectable {
   
    init()
}

extension Container {
    public static subscript<Value>(_ keyPath: KeyPath<Self, Value>) -> Value {
        Self()[keyPath: keyPath]
    }

    public static func inject<Value>(_ keyPath: WritableKeyPath<Self, Value>, _ value: Value) {
        var instance = Self()
        instance[keyPath: keyPath] = value
    }
}
