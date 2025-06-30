//
//  ConcurrentMutationTests.swift
//  Crocodil
//
//  Created by Serge Kazakov on 30/06/2025.
//

import XCTest
import Crocodil
import Dispatch

fileprivate extension Dependencies {
    @DependencyEntry var intValue: Int = 0
}
    
final class ConcurrentMutationTests: XCTestCase {
    
    func test_whenUpdatedAtomically_DependencyUpdatedCorrectly() {
        let concurrentQueue = DispatchQueue(label: "", attributes: .concurrent)
        let count = 10000
        
        let expectation = expectation(description: "Concurrent updates")
        expectation.expectedFulfillmentCount = count
        
        for _ in 0..<count {
            concurrentQueue.async {
                Dependencies.update(intValue: {
                    $0 += 1
                })
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 3)
        XCTAssertEqual(Dependency[\.intValue], count)
    }
}
