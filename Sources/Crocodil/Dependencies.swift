//
//  File.swift
//
//
//  Created by Sergey Kazakov on 17/09/2024.
//

import Foundation

/**
 The `Dependencies` struct is the default container for dependencies in the Crocodil framework.

 It conforms to the `Injectable` protocol, which allows for runtime injection of dependencies.

 ## Usage

 ## Example

 extension Dependencies {
    @DependencyEntry var apiClient: APIClient = APIClient()
 }

 ```swift
 class ViewModel {
     @Dependency(\.apiClient) var apiClient
 }

 let apiClient = Dependency[\.apiClient] 

 Dependencies.inject(\.apiClient, MockAPIClient()) 
 ```
 */
public struct Dependencies: Sendable {
    private init() { }
}

extension Dependencies: Injectable {
    public static func inject<Value>(_ keyPath: WritableKeyPath<Self, Value>, _ value: Value) {
        var instance = Dependencies()
        instance[keyPath: keyPath] = value
    }

    public static subscript<Value>(_ keyPath: KeyPath<Self, Value>) -> Value {
        Dependencies()[keyPath: keyPath]
    }
}
