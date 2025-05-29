//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 17/09/2024.
//

import Foundation

public struct Dependencies: Sendable {
    private init() {
        
    }
    
    /** A static subscript for updating the `currentValue` of `DependencyKey` instances. */
    public subscript<Key>(key: Key.Type) -> Key.Value where Key: DependencyKey, Key.Value: Sendable {
        get {
            DispatchQueue.di.sync { key.currentValue }
        }
        set {
            DispatchQueue.di.async(flags: .barrier) { key.currentValue = newValue }
        }
    }

    /** A static subscript accessor for updating and references dependencies directly. */
    static subscript<T>(_ keyPath: WritableKeyPath<Self, T>) -> T {
        get {
            Self()[keyPath: keyPath]
        }
        set {
            var instance = Self()
            instance[keyPath: keyPath] = newValue
        }
    }
    
    public static func set<T>(_ keyPath: WritableKeyPath<Self, T>, _ value: T) {
        var instance = Self()
        instance[keyPath: keyPath] = value
    }
}


fileprivate extension DispatchQueue {
    static let di = DispatchQueue(label: "com.crocodil.dependencies", attributes: .concurrent)
}
