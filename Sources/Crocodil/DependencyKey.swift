//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 18/09/2024.
//

import Foundation

/**
 A protocol that defines a key used for dependency injection.

 Types conforming to `DependencyKey` provide a mechanism
 to inject dependencies  by associating a specific type of value (`Value`) .
 */
public protocol DependencyKey {
    associatedtype Value

    static var instance: Self.Value { get set }
}
