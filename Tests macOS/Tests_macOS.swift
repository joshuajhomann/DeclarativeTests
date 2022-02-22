//
//  Tests_macOS.swift
//  Tests macOS
//
//  Created by Joshua Homann on 2/21/22.
//

import XCTest
import Combine
@testable import DeclarativeTests

class Tests_macOS: TestCase {
    var viewModel: ViewModel!

    @MainActor
    override func setUpWithError() throws {
        try super.setUpWithError()
        viewModel = .init()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        viewModel = nil
    }

    @MainActor
    func testVersion1() throws {
        let expectation = XCTestExpectation(description: "There is a 2")
        viewModel
            .$doubled
            .contains(where: { $0 == 2 })
            .sink(receiveValue: { succeeded in
                if succeeded {
                    expectation.fulfill()
                }
            })
            .store(in: &subscriptions)
        viewModel.input = 3
        viewModel.input = 2
        viewModel.input = 1
        wait(for: [expectation], timeout: 2)
    }

    @MainActor
    func testVersion2() throws {
        let viewModel = self.viewModel!
        expect(
            "There is a 2",
            given: {
                viewModel.input = 3
                viewModel.input = 2
                viewModel.input = 1
            },
            publisher: viewModel.$doubled,
            contains: 2
        )
    }

    @MainActor
    func testVersion3() throws {
        let viewModel = self.viewModel!
        expect {
            When {
                viewModel.input = 1
                viewModel.input = 2
                viewModel.input = 3
            }
            That {
                Output(of: viewModel.$doubled).contains(6)
                Output(of: viewModel.$doubled).at(1, equals: 2)
                Output(of: viewModel.$doubled).in(1...3, equals: [2,4,6])
                Output(of: viewModel.$tripled).prefixEquals([0,3,6,9])
            }
        }
    }

}
