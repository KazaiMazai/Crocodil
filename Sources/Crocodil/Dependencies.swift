//
//  File.swift
//
//
//  Created by Sergey Kazakov on 17/09/2024.
//

import Foundation

public typealias Dependency<Value> = InjectableKeyPath<Dependencies, Value>

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
