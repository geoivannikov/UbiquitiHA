//
//  PokemonRepository.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 04.10.2025.
//

import Foundation

protocol PokemonRepositoryProtocol {
    func fetchPokemons(offset: Int, limit: Int) async throws -> [Pokemon]
    func fetchPokemonDetails(pokemon: Pokemon) async throws -> PokemonDetails
}

final class PokemonRepository: PokemonRepositoryProtocol {
    private let remoteDataSource: PokemonRemoteDataSourceProtocol
    private let localDataSource: PokemonLocalDataSourceProtocol
    private let networkMonitor: NetworkMonitorProtocol
    
    init(remoteDataSource: PokemonRemoteDataSourceProtocol,
         localDataSource: PokemonLocalDataSourceProtocol,
         networkMonitor: NetworkMonitorProtocol) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
        self.networkMonitor = networkMonitor
    }
    
    // MARK: - Pokemon List Operations
    
    func fetchPokemons(offset: Int, limit: Int) async throws -> [Pokemon] {
        if networkMonitor.isConnected {
            do {
                let response = try await remoteDataSource.fetchPokemonsList(offset: offset, limit: limit)
                let entries = response.results

                let pokemonIds = entries.compactMap { entry -> Int? in
                    guard let url = URL(string: entry.url),
                          let lastPathComponent = url.pathComponents.last,
                          let id = Int(lastPathComponent) else { return nil }
                    return id
                }
                
                return try await fetchPokemonsWithCache(pokemonIds: pokemonIds)
            } catch {
                return try fetchPokemonsFromCache(offset: offset, limit: limit)
            }
        } else {
            let pokemons = try fetchPokemonsFromCache(offset: offset, limit: limit)
            
            if pokemons.isEmpty && offset == 0 {
                throw RepositoryError.apiFailedNoCache
            }
            
            return pokemons
        }
    }
    
    private func fetchPokemonsWithCache(pokemonIds: [Int]) async throws -> [Pokemon] {
        var cachedPokemons: [Int: Pokemon] = [:]
        var missingIds: [Int] = []
        
        for id in pokemonIds {
            do {
                if let cachedModel = try localDataSource.fetchPokemon(by: id) {
                    cachedPokemons[id] = Pokemon(from: cachedModel)
                } else {
                    missingIds.append(id)
                }
            } catch {
                missingIds.append(id)
            }
        }

        let detailResponses: [PokemonDetailResponse] = try await withThrowingTaskGroup(of: PokemonDetailResponse?.self) { group in
            missingIds.forEach { id in
                group.addTask {
                    try? await self.remoteDataSource.fetchPokemon(id: id)
                }
            }

            return try await group.reduce(into: []) { result, next in
                if let model = next {
                    result.append(model)
                }
            }
        }

        let newPokemons: [Pokemon] = try await withThrowingTaskGroup(of: Pokemon?.self) { group in
            detailResponses.forEach { detail in
                group.addTask {
                    do {
                        let imageData = try await self.remoteDataSource.fetchPokemonImage(from: detail)
                        return Pokemon(detail: detail, imageData: imageData)
                    } catch {
                        return Pokemon(detail: detail, imageData: nil)
                    }
                }
            }

            return try await group.reduce(into: []) { result, next in
                if let pokemon = next {
                    result.append(pokemon)
                }
            }
        }
        
        try newPokemons.map { PokemonModel(from: $0) }.forEach {
            try localDataSource.savePokemon($0)
        }

        var result: [Pokemon] = []
        for id in pokemonIds {
            if let cachedPokemon = cachedPokemons[id] {
                result.append(cachedPokemon)
            } else if let newPokemon = newPokemons.first(where: { $0.id == id }) {
                result.append(newPokemon)
            }
        }

        return result
    }
    
    private func fetchPokemonsFromCache(offset: Int, limit: Int) throws -> [Pokemon] {
        let allCachedPokemons = try localDataSource.fetchPokemons()
        
        let startIndex = offset
        let endIndex = min(offset + limit, allCachedPokemons.count)
        
        guard startIndex < allCachedPokemons.count else {
            return []
        }
        
        let paginatedPokemons = Array(allCachedPokemons[startIndex..<endIndex])
        return paginatedPokemons.map(Pokemon.init)
    }
    
    // MARK: - Pokemon Details Operations
    
    func fetchPokemonDetails(pokemon: Pokemon) async throws -> PokemonDetails {
        if networkMonitor.isConnected {
            do {
                let speciesResponse = try await remoteDataSource.fetchPokemonDescription(name: pokemon.name)
                let pokemonDetails = PokemonDetails(pokemon: pokemon, pokemonSpeciesResponse: speciesResponse)
                
                let detailsModel = PokemonDescriptionModel(
                    pokemonId: pokemon.id,
                    description: pokemonDetails.description
                )
                try localDataSource.savePokemonDetails(detailsModel)
                
                return pokemonDetails
            } catch {
                guard let cachedDetails = try localDataSource.fetchPokemonDetails(by: pokemon.id) else {
                    throw RepositoryError.apiFailedNoCache
                }
                
                return PokemonDetails(pokemon: pokemon, model: cachedDetails)
            }
        } else {
            guard let cachedDetails = try localDataSource.fetchPokemonDetails(by: pokemon.id) else {
                throw RepositoryError.apiFailedNoCache
            }
            
            return PokemonDetails(pokemon: pokemon, model: cachedDetails)
        }
    }
}
