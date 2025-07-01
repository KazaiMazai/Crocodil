//
//  Dependency.swift
//  Crocodil
//
//  Created by Serge Kazakov on 02/07/2025.
//

/**
 A typealias for property wrappers that access dependencies from the default `Dependencies` container.

 ```swift
 class ViewModel {
     @Dependency(\.apiClient) var apiClient
 }
 ```

 or accessing dependencies directly:

 ```swift
 let apiClient = Dependency[\.apiClient]
 ```
 */

public typealias Dependency<Value> = InjectableKeyPath<Dependencies, Value>
