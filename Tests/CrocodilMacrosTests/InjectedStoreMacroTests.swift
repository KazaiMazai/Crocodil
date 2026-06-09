//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 25/08/2024.
//

#if canImport(CrocodilMacros)
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
@testable import CrocodilMacros

final class InjectedStoreMacroTests: XCTestCase {
    func test_WhenDependencyEntry_DepenencyInjectionKeyGenerated() {
        let macros = ["DependencyEntry": DependencyEntryMacro.self]
            
        assertMacroExpansion(
              """
              extension Dependencies {
                  @DependencyEntry var someValue = 10
              }
              """,

              expandedSource:
                """
                extension Dependencies {
                    var someValue {
                        get {
                            self[_SomeValueKey.self]
                        }
                        set {
                            self[_SomeValueKey.self] = newValue
                        }
                    }



                    private enum _SomeValueKey: DependencyKey {
                        nonisolated(unsafe) static var instance = 10
                    }
                }
                """,
              macros: macros
        )
    }
    
    func test_WhenDependencyEntryWithType_DepenencyInjectionKeyGeneratedWithExplicitType() {
        let macros = ["DependencyEntry": DependencyEntryMacro.self]
            
        assertMacroExpansion(
              """
              extension Dependencies {
                  @DependencyEntry fileprivate var someValue: Int = 10
              }
              """,

              expandedSource:
                """
                extension Dependencies {
                    fileprivate var someValue: Int {
                        get {
                            self[_SomeValueKey.self]
                        }
                        set {
                            self[_SomeValueKey.self] = newValue
                        }
                    }

                    fileprivate static func update(
                        someValue atomically: @Sendable @escaping (inout Int ) -> Void) {
                        update(_SomeValueKey.self, atomically: atomically)
                    }

                    fileprivate static func update(
                    someValue atomically: @Sendable @escaping (inout Int ) throws -> Void) async throws {
                        try await update(_SomeValueKey.self, atomically: atomically)
                    }

                    private enum _SomeValueKey: DependencyKey {
                        nonisolated(unsafe) static var instance : Int  = 10
                    }
                }
                """,
              macros: macros
        )
    }
}
#endif
