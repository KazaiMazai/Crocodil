//
//  LazyDependenciesTests.swift
//  Crocodil
//
//  Created by Sergey Kazakov on 29/06/2025.
//
import XCTest
import Crocodil
 
fileprivate extension Dependencies {
    @DependencyEntry var lazyDependencyInstantiationCount: Int = 0
    
    @DependencyEntry var lazyDepencency: String = {
        let count = Dependency[\.lazyDependencyInstantiationCount]
        Dependencies.inject(\.lazyDependencyInstantiationCount, count + 1)
        return "I'm lazy!"
    }()
    
    @DependencyEntry var untouchedLazyDependencyInstantiationCount: Int = 0
    
    @DependencyEntry var untouchedLazyDepencency: String = {
        let count = Dependency[\.untouchedLazyDependencyInstantiationCount]
        Dependencies.inject(\.untouchedLazyDependencyInstantiationCount, count + 1)
        return "I'm lazy but never instantiated!"
    }()
}

final class LazyDependenciesTests: XCTestCase {
    @Dependency(\.lazyDepencency) var lazyDepencency
    @Dependency(\.lazyDependencyInstantiationCount) var lazyDependencyInstantiationCount
    @Dependency(\.untouchedLazyDependencyInstantiationCount) var untouchedLazyDependencyInstantiationCount
    
    override func tearDown() {
        Dependencies.inject(\.lazyDepencency, "I'm lazy!")
    }
    
    func test_whenLazyDependencyNotAccessed_ThenNotInstantiated() {
        XCTAssertEqual(untouchedLazyDependencyInstantiationCount, 0)
    }
    
    func test_whenLazyDependencyAccessed_ThenInstantiatedOnce() {
        XCTAssertEqual(lazyDepencency, "I'm lazy!")
        XCTAssertEqual(lazyDependencyInstantiationCount, 1)
    }
    
    func test_whenLazyDependencyAccessedMultipleTimes_ThenInstantiatedOnce() {
        XCTAssertEqual(lazyDepencency, "I'm lazy!")
        XCTAssertEqual(lazyDepencency, "I'm lazy!")
        XCTAssertEqual(Dependency[\.lazyDepencency], "I'm lazy!")
        XCTAssertEqual(lazyDependencyInstantiationCount, 1)
    }
    
    func test_whenLazyDependencyInjected_ThenDependencyUpdated() {
        XCTAssertEqual(lazyDepencency, "I'm lazy!")
        XCTAssertEqual(Dependency[\.lazyDepencency], "I'm lazy!")
        
        Dependencies.inject(\.lazyDepencency, "too lazy")
        Dependencies.inject(\.lazyDepencency, "lazy as hell")
        Dependencies.inject(\.lazyDepencency, "sloath")
        
        XCTAssertEqual(Dependency[\.lazyDepencency], "sloath")
        XCTAssertEqual(lazyDepencency, "sloath")
    }
     
    func test_whenLazyDependencyTouchedAndInjectedMultipleTimes_ThenIntitatedOnlyOnce() {
        XCTAssertEqual(lazyDepencency, "I'm lazy!")
        XCTAssertEqual(Dependency[\.lazyDepencency], "I'm lazy!")
        
        Dependencies.inject(\.lazyDepencency, "too lazy")
        Dependencies.inject(\.lazyDepencency, "lazy as hell")
        Dependencies.inject(\.lazyDepencency, "sloath")
         
        XCTAssertEqual(lazyDependencyInstantiationCount, 1)
        Thread.sleep(forTimeInterval: 1)

        XCTAssertEqual(lazyDependencyInstantiationCount, 1)

        
    }
    
    func test_whenLazyDependencyNotTouchedAndInjectedMultipleTimes_ThenIntitatedOnce() {
        Dependencies.inject(\.lazyDepencency, "I'm too lazy")
        Dependencies.inject(\.lazyDepencency, "Now I'm a sloath")
   
        XCTAssertEqual(lazyDependencyInstantiationCount, 1)
    }
}
