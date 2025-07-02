//
//  DependenciesTests.swift
//  Crocodil
//
//  Created by Sergey Kazakov on 29/06/2025.
//

import XCTest
import Crocodil
import Dispatch


fileprivate extension CustomContainerDependenciesTests {
    struct Environment: Container {
        init() { }
        
        @DependencyEntry var developerMode: Bool = false
    }
     
    typealias Feature<Value> = InjectableKeyPath<Environment, Value>
}

final class CustomContainerDependenciesTests: XCTestCase {
    @Feature(\.developerMode) var developerMode
     
    override func setUp() {
        Environment.inject(\.developerMode, false)
    }
    
    func test_whenDependencyProvided_CanBeAccessedViaProperyWrapper() {
        XCTAssertEqual(developerMode, false)
    }
     
    func test_whenSettingDepenency_DependencyUpdated() {
        Environment.inject(\.developerMode, true)
        XCTAssertEqual(Feature[\.developerMode], true)
    }
}
