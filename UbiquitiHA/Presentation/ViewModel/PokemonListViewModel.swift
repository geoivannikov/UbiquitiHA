//
//  PokemonListViewModel.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 02.10.2025.
//

import Foundation

final class PokemonListViewModel: ObservableObject {
    // MARK: - Public State

    @Published private(set) var pokemons: [Pokemon] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Dependencies

    private let loadUseCase: LoadPokemonsUseCaseProtocol

    // MARK: - Paging

    private(set) var offset = 0
    private let pageSize = 100

    // MARK: - Init

    init(loadUseCase: LoadPokemonsUseCaseProtocol = DIContainer.shared.resolve()) {
        self.loadUseCase = loadUseCase
    }

    // MARK: - Public Methods

    func loadNextPage() async {
        guard await MainActor.run(body: { !isLoading }) else { return }

        await MainActor.run { isLoading = true }

        defer {
            Task {
                await MainActor.run { isLoading = false }
            }
        }

        do {
            let newPokemons = try await loadUseCase.execute(offset: offset, limit: pageSize)

            await MainActor.run {
                pokemons.append(contentsOf: newPokemons)
                offset += pageSize
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }
}
