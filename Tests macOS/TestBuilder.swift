//
//  TestBuilder.swift
//  Tests macOS
//
//  Created by Joshua Homann on 2/21/22.
//

import Combine
import Foundation
import XCTest

struct When {
    var precondition: () -> Void
}

struct That {
    var timeOut: TimeInterval = 2
    @TestResultBuilder var predicate: () -> [TestResult]
}

struct TestResult {
    var description: String
    var subscribe: (XCTestExpectation) -> AnyCancellable
}

struct Output<SomePublisher: Publisher>: CustomStringConvertible {
    var description: String
    var publisher: SomePublisher
    init(
        _ description: String = "",
        of publisher: SomePublisher
    ) {
        self.description = description
        self.publisher = publisher
    }
    func contains(_ value: SomePublisher.Output) -> TestResult where SomePublisher.Output: Equatable {
        .init(description: description) { expectation in
            publisher
                .contains { $0 == value }
                .sink(receiveCompletion: { _ in }, receiveValue: { value in
                    if value {
                        expectation.fulfill()
                    }
                })
        }
    }
    func at(_ index: Int, equals value: SomePublisher.Output) -> TestResult where SomePublisher.Output: Equatable {
        .init(description: description) { expectation in
            publisher
                .output(at: index)
                .sink(receiveCompletion: { _ in }, receiveValue: { output in
                    if value == output{
                        expectation.fulfill()
                    }
                })
        }
    }
    func `in`<SomeRange: RangeExpression>(
        _ range: SomeRange,
        equals value: [SomePublisher.Output]
    ) -> TestResult where SomePublisher.Output: Equatable, SomeRange.Bound == Int {
        .init(description: description) { expectation in
            publisher
                .output(in: range)
                .collect()
                .sink(receiveCompletion: { _ in }, receiveValue: { output in
                    if value == output{
                        expectation.fulfill()
                    }
                })
        }
    }
    func prefixEquals(_ value: [SomePublisher.Output]) -> TestResult where SomePublisher.Output: Equatable {
        .init(description: description) { expectation in
            publisher
                .prefix(value.count)
                .collect()
                .sink(receiveCompletion: { _ in }, receiveValue: { output in
                    if value == output  {
                        expectation.fulfill()
                    }
                })
        }
    }
}

@resultBuilder
struct TestResultBuilder {
    typealias Expression = TestResult
    typealias Component = [TestResult]

    static func buildBlock(_ components: Component...) -> Component {
        components.flatMap { $0 }
    }
    static func buildExpression(_ expression: Expression) -> Component {
        [expression]
    }
}

@resultBuilder
struct TestBuilder {
    static func buildBlock(_ when: When, _ that: That) -> (When, That) {
        (when, that)
    }
}
