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
    private let remoteDataSource: PokemonRemoteDataSourceProtocol

    init(remoteDataSource: PokemonRemoteDataSourceProtocol = DIContainer.shared.resolve()) {
        self.remoteDataSource = remoteDataSource
    }

    func execute(pokemon: Pokemon) async throws -> PokemonDetails {
        let speciesResponse = try await remoteDataSource.fetchPokemonDescription(name: pokemon.name)
        return PokemonDetails(pokemon: pokemon, pokemonSpeciesResponse: speciesResponse)
    }
}
