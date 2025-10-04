//
//  PokemonRemoteDataSource.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 02.10.2025.
//

import Foundation

protocol PokemonRemoteDataSourceProtocol {
    func fetchPokemonsList(offset: Int, limit: Int) async throws -> PokemonListResponse
    func fetchPokemon(url: String) async throws -> PokemonDetailResponse
    func fetchPokemonDescription(name: String) async throws -> PokemonSpeciesResponse
    func fetchImageData(from urlString: String) async throws -> Data
}

final class PokemonRemoteDataSource: PokemonRemoteDataSourceProtocol {
    private let networkService: NetworkServiceProtocol
    private let baseURL = "https://pokeapi.co/api/v2"

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchPokemonsList(offset: Int, limit: Int) async throws -> PokemonListResponse {
        let endpoint = "\(baseURL)/pokemon?limit=\(limit)&offset=\(offset)"
        return try await networkService.fetch(urlString: endpoint, as: PokemonListResponse.self)
    }

    func fetchPokemon(url: String) async throws -> PokemonDetailResponse {
        try await networkService.fetch(urlString: url, as: PokemonDetailResponse.self)
    }

    func fetchPokemonDescription(name: String) async throws -> PokemonSpeciesResponse {
        let endpoint = "\(baseURL)/pokemon-species/\(name)"
        return try await networkService.fetch(urlString: endpoint, as: PokemonSpeciesResponse.self)
    }
    
    func fetchImageData(from urlString: String) async throws -> Data {
        return try await networkService.fetchData(from: urlString)
    }
}
