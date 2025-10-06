//
//  PokemonListView.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 02.10.2025.
//

import SwiftUI

struct PokemonListView<ViewModel: PokemonListViewModelProtocol>: View {
    @EnvironmentObject private var coordinator: Coordinator
    @StateObject private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.pokemons.isEmpty {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                    .scaleEffect(2)
            }
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.pokemons) { pokemon in
                        PokemonListItem(pokemon: pokemon)
                            .frame(minHeight: 120)
                    }
                    
                    if viewModel.isLoading && !viewModel.pokemons.isEmpty && viewModel.isLoading {
                        ForEach(0..<Constants.loadingSkeletonCount, id: \.self) { _ in
                            ProgressView()
                                .frame(minHeight: 120)
                        }
                    }
                    Color.clear
                        .frame(height: 1)
                        .onAppear { Task {
                            guard !viewModel.pokemons.isEmpty else {
                                return
                            }
                            await viewModel.loadNextPage() }
                        }
                }
                .padding()
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
        }
        .navigationTitle("UbiquitiHA")
        .navigationBarTitleDisplayMode(.large)
        .onLoad {
            await viewModel.loadNextPage()
        }
        .errorAlert(errorMessage: $viewModel.errorMessage)
        .overlay(alignment: .bottom) {
            if viewModel.showNetworkStatus {
                NetworkStatusBanner(message: viewModel.networkStatusMessage)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.3), value: viewModel.showNetworkStatus)
            }
        }
    }
}

private struct PokemonListItem: View {
    @EnvironmentObject var coordinator: Coordinator
    let pokemon: Pokemon

    var body: some View {
        Button {
            coordinator.showDetail(pokemon: pokemon)
        } label: {
            PokemonCardView(pokemon: pokemon)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
        .animation(.easeInOut(duration: 0.3), value: pokemon.id)
    }
}

// MARK: - Preview

#Preview("With Pokemons") {
    let mockPokemons = [
        Pokemon(id: 1, name: "Pikachu", number: "#001", types: ["Electric"], imageData: nil, height: 40, weight: 6, baseExperience: 112),
        Pokemon(id: 2, name: "Charmander", number: "#004", types: ["Fire"], imageData: nil, height: 60, weight: 8, baseExperience: 62),
        Pokemon(id: 3, name: "Squirtle", number: "#007", types: ["Water"], imageData: nil, height: 50, weight: 9, baseExperience: 63),
        Pokemon(id: 4, name: "Bulbasaur", number: "#001", types: ["Grass", "Poison"], imageData: nil, height: 70, weight: 6, baseExperience: 64),
        Pokemon(id: 5, name: "Caterpie", number: "#010", types: ["Bug"], imageData: nil, height: 30, weight: 3, baseExperience: 39),
        Pokemon(id: 6, name: "Weedle", number: "#013", types: ["Bug", "Poison"], imageData: nil, height: 30, weight: 3, baseExperience: 39)
    ]
    
    let mockViewModel = MockPokemonListViewModel(pokemons: mockPokemons)
    
    return NavigationStack {
        PokemonListView<MockPokemonListViewModel>(viewModel: mockViewModel)
    }
    .environmentObject(Coordinator())
}

#Preview("Loading State") {
    let mockViewModel = MockPokemonListViewModel(pokemons: [], isLoading: true)
    
    return NavigationStack {
        PokemonListView<MockPokemonListViewModel>(viewModel: mockViewModel)
    }
    .environmentObject(Coordinator())
}

#Preview("Empty State") {
    let mockViewModel = MockPokemonListViewModel(pokemons: [])
    
    return NavigationStack {
        PokemonListView<MockPokemonListViewModel>(viewModel: mockViewModel)
    }
    .environmentObject(Coordinator())
}

#Preview("Network Status") {
    let mockPokemons = [
        Pokemon(id: 1, name: "Pikachu", number: "#001", types: ["Electric"], imageData: nil, height: 40, weight: 6, baseExperience: 112),
        Pokemon(id: 2, name: "Charmander", number: "#004", types: ["Fire"], imageData: nil, height: 60, weight: 8, baseExperience: 62)
    ]
    
    let mockViewModel = MockPokemonListViewModel(
        pokemons: mockPokemons,
        showNetworkStatus: true
    )
    mockViewModel.networkStatusMessage = "No internet connection"
    
    return NavigationStack {
        PokemonListView<MockPokemonListViewModel>(viewModel: mockViewModel)
    }
    .environmentObject(Coordinator())
}

// MARK: - Mock ViewModel for Preview
fileprivate class MockPokemonListViewModel: PokemonListViewModelProtocol {
    @Published var pokemons: [Pokemon] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isConnected: Bool = true
    @Published var showNetworkStatus: Bool = false
    @Published var networkStatusMessage: String = ""
    
    init(pokemons: [Pokemon] = [], isLoading: Bool = false, showNetworkStatus: Bool = false) {
        self.pokemons = pokemons
        self.isLoading = isLoading
        self.showNetworkStatus = showNetworkStatus
    }
    
    func loadNextPage() async {}
}
