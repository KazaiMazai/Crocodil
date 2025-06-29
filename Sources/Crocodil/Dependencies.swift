//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 17/09/2024.
//

import Foundation

public struct Dependencies: Sendable {
    private init() { }
   
    /** A static subscript for updating the `currentValue` of `DependencyKey` instances. */
    public subscript<Key>(key: Key.Type) -> Key.Value where Key: DependencyKey {
        get {
            DispatchQueue.di.sync { key.instance }
        }
        set {
            DispatchQueue.di.asyncUnsafe(flags: .barrier) { key.instance = newValue }
        }
    }
    
    /** A static subscript for updating the `currentValue` of `DependencyKey` instances. */
    public subscript<Key>(key: Key.Type) -> Key.Value where Key: DependencyKey, Key.Value: Sendable {
        get {
            DispatchQueue.di.sync { key.instance }
        }
        set {
            DispatchQueue.di.async(flags: .barrier) { key.instance = newValue }
        }
    }

    /** A static subscript accessor for updating and references dependencies directly. */
    static subscript<T>(_ keyPath: WritableKeyPath<Dependencies, T>) -> T {
        get {
            let dependencies = Dependencies()
            return dependencies[keyPath: keyPath]
        }
        set {
            var dependencies = Dependencies()
            dependencies[keyPath: keyPath] = newValue
        }
    }
    
    public static func inject<T>(_ keyPath: WritableKeyPath<Self, T>, _ value: T) {
        var instance = Self()
        instance[keyPath: keyPath] = value
    }
}

fileprivate extension DispatchQueue {
    static let di = DispatchQueue(label: "com.crocodil.queue", attributes: .concurrent)
}
 
