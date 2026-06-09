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

    func test_whenUpdatedAtomicallyAsync_DependencyUpdatedCorrectly() async throws {
        Dependencies.inject(\.intValue, 0)
        let count = 10000

        try await withThrowingTaskGroup(of: Void.self) { group in
            for _ in 0..<count {
                group.addTask {
                    try await Dependencies.update(intValue: {
                        $0 += 1
                    })
                }
            }
            try await group.waitForAll()
        }

        XCTAssertEqual(Dependency[\.intValue], count)
    }

    func test_whenAsyncUpdateThrows_ThenErrorIsPropagated() async {
        struct UpdateError: Error { }

        do {
            try await Dependencies.update(intValue: { _ in
                throw UpdateError()
            })
            XCTFail("Expected update to throw")
        } catch {
            XCTAssertTrue(error is UpdateError)
        }
    }
}
