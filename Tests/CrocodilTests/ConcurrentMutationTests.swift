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
        Dependencies.inject(\.intValue, 0)
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

    func test_whenAsyncUpdateReturnsValue_ThenUpdatedValueIsReturnedAtomically() async throws {
        Dependencies.inject(\.intValue, 41)

        let newValue = try await Dependencies.update(intValue: { value -> Int in
            value += 1
            return value
        })

        XCTAssertEqual(newValue, 42)
    }

    func test_whenAsyncUpdateReturnsValue_ThenPreviousValueCanBeReturned() async throws {
        Dependencies.inject(\.intValue, 7)

        let previous = try await Dependencies.update(intValue: { value -> Int in
            defer { value += 1 }
            return value
        })

        XCTAssertEqual(previous, 7)
        XCTAssertEqual(Dependency[\.intValue], 8)
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
