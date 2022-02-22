//
//  TestCase.swift
//  Tests macOS
//
//  Created by Joshua Homann on 2/21/22.
//

import XCTest
import Combine

class TestCase: XCTestCase {
    var subscriptions: Set<AnyCancellable> = []
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        subscriptions = []
    }
    func expect<SomePublisher: Publisher>(
        _ description: String = "",
        timeout: TimeInterval = 2,
        given setup: @escaping () -> Void,
        publisher: SomePublisher,
        contains value: SomePublisher.Output
    ) where SomePublisher.Output: Equatable, SomePublisher.Failure == Never {
        let expectation = XCTestExpectation(description: description)
        publisher.sink(receiveValue: {
            if $0 == value {
                expectation.fulfill()
            }
        })
            .store(in: &subscriptions)
        setup()
        wait(for: [expectation], timeout: timeout)
    }

    func expect<SomePublisher: Publisher>(
        _ description: String = "",
        timeout: TimeInterval = 2,
        given setup: @escaping () -> Void,
        publisher: SomePublisher,
        accumulatedOutputEquals value: [SomePublisher.Output]
    ) where SomePublisher.Output: Equatable, SomePublisher.Failure == Never {
        let expectation = XCTestExpectation(description: description)
        publisher.collect().sink(receiveValue: {
            if $0 == value {
                expectation.fulfill()
            }
        })
            .store(in: &subscriptions)
        setup()
        wait(for: [expectation], timeout: timeout)
    }

    func expect(@TestBuilder builder: @escaping () -> (When, That)) {
        let (when, that) = builder()
        let testResults = that.predicate()
        let expectations = testResults
            .map(\.description)
            .map(XCTestExpectation.init(description:))
        zip(testResults, expectations).forEach { (testResult, expectation) in
            testResult.subscribe(expectation).store(in: &subscriptions)
        }
        when.precondition()
        wait(for: expectations, timeout: that.timeOut)
    }
}
