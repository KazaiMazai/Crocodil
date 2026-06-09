//
//  Container 2.swift
//  Crocodil
//
//  Created by Serge Kazakov on 01/07/2025.
//
import Foundation

public protocol Injectable {
    
    static var queue: DispatchQueue { get }
    
    /** A func for updating the dependency via container's `keyPath` */
    static func inject<Value>(_ keyPath: WritableKeyPath<Self, Value>, _ value: Value)
    
    /** A subscript for accessing to dependency via container's `keyPath` */
    static subscript<Value>(_ keyPath: KeyPath<Self, Value>) -> Value { get }
}

public extension Injectable {
    static var queue: DispatchQueue { DispatchQueue.di }
    
    /** A subscript for read/write access to the dependency via `DependencyKey`. */
    @available(iOS 17.0, *)
    subscript<Key>(key: Key.Type) -> Key.Value where Key: DependencyKey {
        get {
            Self.queue.sync { key.instance }
        }
        set {
            Self.queue.asyncUnsafe(flags: .barrier) { key.instance = newValue }
        }
    }

    /** A subscript for read/write access to the sendable dependency via `DependencyKey` */
    subscript<Key>(key: Key.Type) -> Key.Value where Key: DependencyKey, Key.Value: Sendable {
        get {
            Self.queue.sync { key.instance }
        }
        set {
            Self.queue.async(flags: .barrier) { key.instance = newValue }
        }
    }

    /** A func for updating the dependency via `DependencyKey` atomically */
    static func update<Key>(
        _ key: Key.Type,
        atomically: @Sendable @escaping (inout Key.Value) -> Void)
    where
    Key: DependencyKey {
        Self.queue.async(flags: .barrier) { atomically(&key.instance) }
    }
    
    /** A func for updating the dependency via `DependencyKey` atomically */
    static func update<Key>(
        _ key: Key.Type,
        atomically: @Sendable @escaping (inout Key.Value) throws -> Void) async throws
    where
    Key: DependencyKey {
        try await withCheckedThrowingContinuation { continuation in
            Self.queue.async(flags: .barrier) {
                do {
                    try atomically(&key.instance)
                    continuation.resume(returning: Void())
                } catch {
                    continuation.resume(throwing: error)
                }
                
            }
        }
        
    }
}

fileprivate extension DispatchQueue {
    // swiftlint:disable:next identifier_name
    static let di = DispatchQueue(label: "com.crocodil.queue", attributes: .concurrent)
}
