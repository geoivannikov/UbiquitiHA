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
            PokemonListView<PokemonListViewModel>(viewModel: PokemonListViewModel())
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .detail(let pokemon):
                        let detailVM = PokemonDetailViewModel(pokemon: pokemon)
                        PokemonDetailView<PokemonDetailViewModel>(viewModel: detailVM)
                    }
                }
        }
    }
}

// MARK: - Preview
#Preview {
    RootView()
        .environmentObject(Coordinator())
}
