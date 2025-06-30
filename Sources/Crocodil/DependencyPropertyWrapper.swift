//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 17/09/2024.
//

import Foundation

@propertyWrapper
public struct Dependency<Value>: Sendable {
    private let keyPath: @Sendable () -> KeyPath<Dependencies, Value>

    public var wrappedValue: Value {
        Dependencies[keyPath()]
    }

    public init(_ keyPath: @Sendable @escaping @autoclosure () -> KeyPath<Dependencies, Value>) {
        self.keyPath = keyPath
    }

    public static subscript(_ keyPath: KeyPath<Dependencies, Value>) -> Value {
        Dependencies[keyPath]
    }
}
