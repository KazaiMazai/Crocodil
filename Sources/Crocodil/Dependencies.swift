//
//  File.swift
//
//
//  Created by Sergey Kazakov on 17/09/2024.
//

import Foundation

public struct Dependencies: Sendable {
    private init() { }
}

public extension Dependencies {
    /** A static subscript for updating the `currentValue` of `DependencyKey` instances. */
    @available(iOS 17.0, *)
    subscript<Key>(key: Key.Type) -> Key.Value where Key: DependencyKey {
        get {
            DispatchQueue.di.sync { key.instance }
        }
        set {
            DispatchQueue.di.asyncUnsafe(flags: .barrier) { key.instance = newValue }
        }
    }

    /** A static subscript for updating the `currentValue` of `DependencyKey` instances. */
    subscript<Key>(key: Key.Type) -> Key.Value where Key: DependencyKey, Key.Value: Sendable {
        get {
            DispatchQueue.di.sync { key.instance }
        }
        set {
            DispatchQueue.di.async(flags: .barrier) { key.instance = newValue }
        }
    }

    static func inject<Value>(_ keyPath: WritableKeyPath<Self, Value>, _ value: Value) {
        var instance = Dependencies()
        instance[keyPath: keyPath] = value
    }

    /** Updating the `currentValue` of `DependencyKey` instances atomically. */
    static func update<Key>(
        _ key: Key.Type,
        atomically: @Sendable @escaping (inout Key.Value) -> Void) where Key: DependencyKey {
            DispatchQueue.di.async(flags: .barrier) { atomically(&key.instance) }
        }
}

extension Dependencies {
    static subscript<Value>(_ keyPath: KeyPath<Dependencies, Value>) -> Value {
        Dependencies()[keyPath: keyPath]
    }
}

fileprivate extension DispatchQueue {
    // swiftlint:disable:next identifier_name
    static let di = DispatchQueue(label: "com.crocodil.queue", attributes: .concurrent)
}
