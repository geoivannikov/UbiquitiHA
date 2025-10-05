//
//  PokemonRemoteDataSource.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 02.10.2025.
//

import Foundation

protocol PokemonRemoteDataSourceProtocol {
    func fetchPokemonsList(offset: Int, limit: Int) async throws -> PokemonListResponse
    func fetchPokemon(id: Int) async throws -> PokemonDetailResponse
    func fetchPokemonDescription(name: String) async throws -> PokemonSpeciesResponse
    func fetchPokemonImage(from response: PokemonDetailResponse) async throws -> Data
}

final class PokemonRemoteDataSource: PokemonRemoteDataSourceProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchPokemonsList(offset: Int, limit: Int) async throws -> PokemonListResponse {
        let url = "\(Constants.pokeApiBaseURL)/pokemon?limit=\(limit)&offset=\(offset)"
        return try await networkService.fetch(urlString: url, as: PokemonListResponse.self)
    }

    func fetchPokemon(id: Int) async throws -> PokemonDetailResponse {
        let url = "\(Constants.pokeApiBaseURL)/pokemon/\(id)"
        return try await networkService.fetch(urlString: url, as: PokemonDetailResponse.self)
    }

    func fetchPokemonDescription(name: String) async throws -> PokemonSpeciesResponse {
        let endpoint = "\(Constants.pokeApiBaseURL)/pokemon-species/\(name)"
        return try await networkService.fetch(urlString: endpoint, as: PokemonSpeciesResponse.self)
    }
    
    func fetchPokemonImage(from response: PokemonDetailResponse) async throws -> Data {
        let url = response.sprites.other.officialArtwork.frontDefault
        return try await networkService.fetchData(from: url)
    }
}
