//
//  PokemonDetailViewModel.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 02.10.2025.
//

import Foundation
import SwiftUI

protocol PokemonDetailViewModelProtocol: ObservableObject {
    var details: PokemonDetails { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get set }
    var backgroundColor: Color { get }
    func load() async
}

final class PokemonDetailViewModel: PokemonDetailViewModelProtocol {
    @Published private(set) var details = PokemonDetails()
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    
    @Inject private var loadUseCase: LoadPokemonDescriptionUseCaseProtocol
    
    var backgroundColor: Color { pokemon.backgroundColor }
    private let pokemon: Pokemon

    init(pokemon: Pokemon) {
        self.pokemon = pokemon
    }

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
