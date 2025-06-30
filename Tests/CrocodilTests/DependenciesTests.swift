//
//  DependenciesTests.swift
//  Crocodil
//
//  Created by Sergey Kazakov on 29/06/2025.
//

import XCTest
import Crocodil
import Dispatch

extension Int {
    static func nextAutoIncremented() -> Int {
        Dependency[\.nextAutoIncremented]()
    }
}

fileprivate extension Dependencies {
    // Injected instance with explicit type
    @DependencyEntry var intValue: Int = 1
    
    @DependencyEntry var nextAutoIncremented = {
        Dependencies.update(intValue: {
            $0 += 1
        })
        
        return Dependency[\.intValue]
    }
    
    // Injected instance with explicit type
    @DependencyEntry private var privateIntValue: Int = 1
    
    // Injected instance with implicit type inference
    @DependencyEntry var stringValue = "I'm a string!"
    
    // Injected lazily evaluate instance with implicit type inference
    @DependencyEntry var lazyStringValue = { "I'm lazy!" }()
    
    // Closure injection
    @DependencyEntry var closure = { Date.distantPast }
    
    // Instance conforming to protocol
    @DependencyEntry var protocolConformingInstance: ClientProcotol = Client(endpoint: "www.google.com")
    
    
}

protocol ClientProcotol: Sendable {
   var endpoint: String { get }
}

struct Client: ClientProcotol {
   let endpoint: String
}

final class DependenciesTests: XCTestCase {
    //Instance with explicit type
    @Dependency(\.intValue) var intValue
    
    //Instance with explicit type
    @Dependency(\.stringValue) var stringValue
    @Dependency(\.lazyStringValue) var lazyStringValue
    @Dependency(\.closure) var closure
    @Dependency(\.protocolConformingInstance) var client: ClientProcotol
    
    func test_whenDependencyProvided_CanBeAccessedViaProperyWrapper() {
        XCTAssertEqual(intValue, 1)
        XCTAssertEqual(stringValue, "I'm a string!")
        XCTAssertEqual(lazyStringValue, "I'm lazy!")
        XCTAssertEqual(closure(), .distantPast)
        XCTAssertEqual(client.endpoint, "www.google.com")
    }
     
    func test_whenReadAndWriteValue_ThenNoDeadlockOccurs() {
        XCTAssertEqual(Dependency[\.intValue], 1)
        
        Dependencies.inject(\.intValue, Dependency[\.intValue] + 1)
        XCTAssertEqual(Dependency[\.intValue], 2)
    }
    
    func test_whenSettingDepenency_DependencyUpdated() {
        Dependencies.inject(\.intValue, 2)
        XCTAssertEqual(Dependency[\.intValue], 2)
        
    }
}

