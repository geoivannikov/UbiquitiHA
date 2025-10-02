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
}

final class PokemonRemoteDataSource: PokemonRemoteDataSourceProtocol {
    private let session: URLSession
    private let baseURL = "https://pokeapi.co/api/v2"

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchPokemonsList(offset: Int, limit: Int) async throws -> PokemonListResponse {
        let endpoint = "\(baseURL)/pokemon?limit=\(limit)&offset=\(offset)"
        return try await fetch(urlString: endpoint, as: PokemonListResponse.self)
    }

    func fetchPokemon(url: String) async throws -> PokemonDetailResponse {
        guard let url = URL(string: url) else {
            throw APIError.invalidURL(url)
        }
        return try await fetch(url: url, as: PokemonDetailResponse.self)
    }

    func fetchPokemonDescription(name: String) async throws -> PokemonSpeciesResponse {
        let endpoint = "\(baseURL)/pokemon-species/\(name)"
        return try await fetch(urlString: endpoint, as: PokemonSpeciesResponse.self)
    }

    // MARK: - Private helpers

    private func fetch<T: Decodable>(urlString: String, as type: T.Type) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL(urlString)
        }
        return try await fetch(url: url, as: type)
    }

    private func fetch<T: Decodable>(url: URL, as type: T.Type) async throws -> T {
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse(nil)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }
}
