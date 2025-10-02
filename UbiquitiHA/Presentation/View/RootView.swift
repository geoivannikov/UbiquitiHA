//
//  RootView.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 02.10.2025.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var coordinator: Coordinator

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            PokemonListView()
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .detail(let pokemon):
//                    TODO: Display details
                        EmptyView()
                    }
                }
        }
    }
}
