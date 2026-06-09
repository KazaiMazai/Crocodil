//
//  QueueOverrideTests.swift
//  Crocodil
//
//  Created by Serge Kazakov on 09/06/2026.
//

import XCTest
import Crocodil
import Dispatch

/// A box that lets a `@Sendable` update closure report back to the test.
private final class Box<T>: @unchecked Sendable {
    var value: T
    init(_ value: T) { self.value = value }
}

/// A custom container that overrides the synchronization queue to the main queue.
struct MainContainer: Container {
    init() { }

    static var queue: DispatchQueue { .main }

    @DependencyEntry var value: Int = 0
}

final class QueueOverrideTests: XCTestCase {

    func test_whenQueueOverriddenToMain_ThenUpdateRunsOnMainQueue() async throws {
        let ranOnMainThread = Box(false)

        try await MainContainer.update(value: { value in
            dispatchPrecondition(condition: .onQueue(.main))
            ranOnMainThread.value = Thread.isMainThread
            value += 1
        })

        XCTAssertTrue(ranOnMainThread.value)
    }

    func test_whenDefaultQueue_ThenUpdateDoesNotRunOnMainThread() async throws {
        let ranOnMainThread = Box(true)

        try await Dependencies.update(intValueForQueueTest: { value in
            ranOnMainThread.value = Thread.isMainThread
            value += 1
        })

        XCTAssertFalse(ranOnMainThread.value)
    }
}

fileprivate extension Dependencies {
    @DependencyEntry var intValueForQueueTest: Int = 0
}
