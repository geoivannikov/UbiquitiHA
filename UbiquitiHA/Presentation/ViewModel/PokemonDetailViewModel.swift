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

    @MainActor
    func load() async {
        guard !isLoading else { return }
        isLoading = true

        defer {
            isLoading = false
        }

        do {
            let result = try await Task.detached {
                try await self.loadUseCase.execute(pokemon: self.pokemon)
            }.value

            details = result
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
