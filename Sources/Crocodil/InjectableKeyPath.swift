//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 17/09/2024.
//

import Foundation

@propertyWrapper
public struct InjectableKeyPath<Root: Injectable, Value>: Sendable {
    private let keyPath: @Sendable () -> KeyPath<Root, Value>
    
    public var wrappedValue: Value {
        Root[keyPath()]
    }
    
    public init(_ keyPath: @Sendable @escaping @autoclosure () -> KeyPath<Root, Value>) {
        self.keyPath = keyPath
    }
    
    public static subscript(_ keyPath: KeyPath<Root, Value>) -> Value {
        Root[keyPath]
    }
}
