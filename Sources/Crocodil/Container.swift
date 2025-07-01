//
//  Untitled.swift
//  Crocodil
//
//  Created by Serge Kazakov on 01/07/2025.
//
import Foundation

public protocol Container: Injectable {
    init()
}

extension Container {
    public static subscript<Value>(_ keyPath: KeyPath<Self, Value>) -> Value {
        Self()[keyPath: keyPath]
    }

    public static func inject<Value>(_ keyPath: WritableKeyPath<Self, Value>, _ value: Value) {
        var instance = Self()
        instance[keyPath: keyPath] = value
    }
}
