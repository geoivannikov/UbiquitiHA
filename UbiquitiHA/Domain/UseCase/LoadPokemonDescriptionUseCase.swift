//
//  LoadPokemonDescriptionUseCase.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 02.10.2025.
//

protocol LoadPokemonDescriptionUseCaseProtocol {
    func execute(pokemon: Pokemon) async throws -> PokemonDetails
}

final class LoadPokemonDescriptionUseCase: LoadPokemonDescriptionUseCaseProtocol {
    private let repository: PokemonDetailsRepositoryProtocol

    init(repository: PokemonDetailsRepositoryProtocol) {
        self.repository = repository
    }

    func execute(pokemon: Pokemon) async throws -> PokemonDetails {
        try await repository.fetchPokemonDetails(pokemon: pokemon)
    }
}
