//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 17/09/2024.
//

import Foundation

@propertyWrapper
public struct Dependency<Value>: Sendable {
    private let keyPath: @Sendable () -> WritableKeyPath<Dependencies, Value>

    public var wrappedValue: Value {
        get { Dependencies[keyPath()] }
    }

    public init(_ keyPath: @Sendable @escaping @autoclosure () -> WritableKeyPath<Dependencies, Value>) {
        self.keyPath = keyPath
    }
    
    public static subscript(_ keyPath: WritableKeyPath<Dependencies, Value>) -> Value {
        get {
            Dependencies[keyPath]
        }
    }
}
