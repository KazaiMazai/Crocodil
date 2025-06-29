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
        let macros = ["DependencyEntry": DependencyInjectionMacro.self]
            
        assertMacroExpansion(
              """
              extension Dependencies {
                  @DependencyEntry var value = 10
              }
              """,
              
              expandedSource:
                """
                extension Dependencies {
                    var value {
                        get {
                            self[_ValueKey.self]
                        }
                        set {
                            self[_ValueKey.self] = newValue
                        }
                    }

                    private enum _ValueKey: DependencyKey {
                        nonisolated(unsafe) static var instance = 10
                    }
                }
                """,
              macros: macros
        )
    }
    
    func test_WhenDependencyEntryWithType_DepenencyInjectionKeyGeneratedWithExplicitType() {
        let macros = ["DependencyEntry": DependencyInjectionMacro.self]
            
        assertMacroExpansion(
              """
              extension Dependencies {
                  @DependencyEntry var value: Int = 10
              }
              """,
              
              expandedSource:
                """
                extension Dependencies {
                    var value: Int {
                        get {
                            self[_ValueKey.self]
                        }
                        set {
                            self[_ValueKey.self] = newValue
                        }
                    }

                    private enum _ValueKey: DependencyKey {
                        nonisolated(unsafe) static var instance : Int  = 10
                    }
                }
                """,
              macros: macros
        )
    }
}
#endif
