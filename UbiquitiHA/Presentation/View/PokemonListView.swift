//
//  PokemonListView.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 02.10.2025.
//

import SwiftUI

struct PokemonListView: View {
    @EnvironmentObject private var coordinator: Coordinator
    @StateObject private var viewModel: PokemonListViewModel

    init(viewModel: PokemonListViewModel = PokemonListViewModel()) {
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
                        let isLast = (pokemon.id == viewModel.pokemons.last?.id)
                        PokemonListItem(pokemon: pokemon, isLast: isLast) {
                            Task { await viewModel.loadNextPage() }
                        }
                        .id("pokemon-\(pokemon.id)")
                        .frame(minHeight: 120)
                    }
                    
                    if viewModel.isLoading && !viewModel.pokemons.isEmpty {
                        ForEach(0..<2, id: \.self) { _ in
                            ProgressView()
                        }
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
    let isLast: Bool
    let onAppear: () -> Void

    var body: some View {
        Button {
            coordinator.showDetail(pokemon: pokemon)
        } label: {
            PokemonCardView(pokemon: pokemon)
        }
        .onAppear {
            if isLast { onAppear() }
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
        .animation(.easeInOut(duration: 0.3), value: pokemon.id)
    }
}
