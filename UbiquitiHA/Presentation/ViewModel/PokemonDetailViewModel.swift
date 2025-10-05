//
//  PokemonDetailViewModel.swift
//  UbiquitiHA
//
//  Created by Ivannikov-EXTERNAL Georgiy on 02.10.2025.
//

import Foundation
import SwiftUI

final class PokemonDetailViewModel: ObservableObject {
    // MARK: - Public State

    @Published private(set) var details = PokemonDetails()
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    var backgroundColor: Color {
        pokemon.backgroundColor
    }

    // MARK: - Dependencies

    private let loadUseCase: LoadPokemonDescriptionUseCaseProtocol
    private let pokemon: Pokemon

    // MARK: - Init

    init(loadUseCase: LoadPokemonDescriptionUseCaseProtocol = DIContainer.shared.resolve(),
         pokemon: Pokemon) {
        self.loadUseCase = loadUseCase
        self.pokemon = pokemon
    }

    // MARK: - Public Methods

    func load() async {
        guard await MainActor.run(body: { !isLoading }) else { return }

        await MainActor.run {
            isLoading = true
        }

        defer {
            Task {
                await MainActor.run {
                    isLoading = false
                }
            }
        }

        do {
            let result = try await loadUseCase.execute(pokemon: pokemon)

            await MainActor.run {
                details = result
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }
}
