//
//  LoadPokemonDescriptionUseCase.swift
//  UbiquitiHA
//
//  Created by Ivannikov-EXTERNAL Georgiy on 02.10.2025.
//

protocol LoadPokemonDescriptionUseCaseProtocol {
    func execute(pokemon: Pokemon) async throws -> PokemonDetails
}

final class LoadPokemonDescriptionUseCase: LoadPokemonDescriptionUseCaseProtocol {
    private let repository: PokemonDetailsRepository

    init(repository: PokemonDetailsRepository) {
        self.repository = repository
    }

    func execute(pokemon: Pokemon) async throws -> PokemonDetails {
        try await repository.fetchPokemonDetails(pokemon: pokemon)
    }
}
