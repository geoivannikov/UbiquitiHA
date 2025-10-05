//
//  LoadPokemonsUseCaseProtocol.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 02.10.2025.
//

import Foundation

protocol LoadPokemonsUseCaseProtocol {
    func execute(offset: Int, limit: Int) async throws -> [Pokemon]
}

final class LoadPokemonsUseCase: LoadPokemonsUseCaseProtocol {
    private let repository: PokemonListRepositoryProtocol

    init(repository: PokemonListRepositoryProtocol) {
        self.repository = repository
    }

    func execute(offset: Int, limit: Int) async throws -> [Pokemon] {
        try await repository.fetchPokemons(offset: offset, limit: limit)
    }
}
