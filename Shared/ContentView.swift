//
//  ContentView.swift
//  Shared
//
//  Created by Joshua Homann on 2/21/22.
//

import SwiftUI

@MainActor
final class ViewModel: ObservableObject {
    @Published var input = 0
    @Published private(set) var doubled = 0
    @Published private(set) var tripled = 0
    init() {
        $input.map { $0 * 2 }.assign(to: &$doubled)
        $input.map { $0 * 3 }.assign(to: &$tripled)
    }
}

struct ContentView: View {
    @StateObject private var viewModel: ViewModel = .init()
    var body: some View {
        VStack {
            Stepper(
                String(describing: viewModel.input),
                onIncrement: { viewModel.input += 1 },
                onDecrement: { viewModel.input -= 1 }
            )
            Text("Doubled: \(viewModel.doubled)")
            Text("Tripled: \(viewModel.tripled)")
        }
        .font(.largeTitle)
        .frame(minWidth: 300, minHeight: 300)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
