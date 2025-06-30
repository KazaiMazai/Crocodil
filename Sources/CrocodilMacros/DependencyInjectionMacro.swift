//
//  File.swift
//
//
//  Created by Sergey Kazakov on 25/08/2024.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

public struct DependencyInjectionMacro: AccessorMacro, PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let variableDeclaration = declaration.as(VariableDeclSyntax.self),
              let propertiesAttributes = variableDeclaration.propertiesAttributes()
        else {
            return []
        }
        
        return [
          """
          get { self[_\(raw: propertiesAttributes.keyName).self] }
          """,
          """
          set { self[_\(raw: propertiesAttributes.keyName).self] = newValue }
          """
        ]
    }
    
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
  

            guard let variableDeclaration = declaration.as(VariableDeclSyntax.self),
                  let propertiesAttributes = variableDeclaration.propertiesAttributes()
            else {
                return []
            }
            
            let updateAtomically: FunctionDeclSyntax? = try FunctionDeclSyntax.updateAtomically(propertiesAttributes)
            let dependencyKeyEnum: SwiftSyntax.DeclSyntax = try SwiftSyntax.DeclSyntax.dependencyKeyEnum(propertiesAttributes)
            
            return [
                """
                \(updateAtomically)
                """,
                
                """
                \(dependencyKeyEnum)
                """
            ]
             
        }
}

extension SwiftSyntax.DeclSyntax {
    static func dependencyKeyEnum(_ propertyAttributes: PropertyAttributes) throws -> SwiftSyntax.DeclSyntax {
        SwiftSyntax.DeclSyntax(
            """
            private enum _\(raw: propertyAttributes.keyName): DependencyKey {
                nonisolated(unsafe) static var instance \(raw: propertyAttributes.initializerClause)
            }
            """
        )
    }
}

extension FunctionDeclSyntax {
    static func updateAtomically(_ propertyAttributes: PropertyAttributes
    ) throws -> FunctionDeclSyntax? {
        
        guard let propertyType = propertyAttributes.propertyInferredType else {
            return nil
        }
        
        return try FunctionDeclSyntax(
        """
        \(raw: propertyAttributes.accessAttribute.name) static func update(
        \(raw: propertyAttributes.propertyName) atomically: @Sendable @escaping (inout \(raw: propertyType)) -> Void) {
            update(_\(raw: propertyAttributes.keyName).self, atomically: atomically)
        }
        """
        )
    }
}


struct PropertyAttributes {
    let propertyName: String
    let propertyType: TypeSyntax?
    let propertyInferredType: TypeSyntax?
    let initializerClauseSyntax: InitializerClauseSyntax
    let accessAttribute: AccessAttribute
    
    var initializerClause: String {
        propertyType.map { ":\($0) \(initializerClauseSyntax)" } ?? "\(initializerClauseSyntax)"
        
    }
    
    var keyName: String { "\(propertyName.capitalized)Key" }
}

extension VariableDeclSyntax {
    func propertiesAttributes() -> PropertyAttributes? {
        guard !modifiers.contains(where: { $0.name == "static" }) else {
            return nil
        }
        
        var propertyInferredType: TypeSyntax? = nil
        if let firstBinding = bindings.first,
           let typeAnnotation = firstBinding.typeAnnotation {
            
            propertyInferredType = typeAnnotation.type
        }
        
        
        for binding in bindings {
            guard let propertyName = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
                  let initializer = binding.initializer
            else {
                continue
            }
            
            return PropertyAttributes(
                propertyName: propertyName,
                propertyType: binding.typeAnnotation?.type,
                propertyInferredType: propertyInferredType,
                initializerClauseSyntax: initializer,
                accessAttribute: accessAttribute()
            )
        }
        return nil
    }
    
    
    func accessAttribute() -> AccessAttribute {
        modifiers
            .compactMap { $0.name.text }
            .compactMap { AccessAttribute(rawValue: $0) }
            .first ?? .missingAttribute
    }
}

enum AccessAttribute: String {
    case `private`
    case `fileprivate`
    case `internal`
    case `public`
    case `open`
    case missingAttribute = ""

    var name: String {
        rawValue
    }
}
