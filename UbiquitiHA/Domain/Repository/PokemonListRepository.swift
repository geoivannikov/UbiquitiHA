//
//  PokemonListRepository.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 04.10.2025.
//

import Foundation

protocol PokemonListRepositoryProtocol {
    func fetchPokemons(offset: Int, limit: Int) async throws -> [Pokemon]
}

final class PokemonListRepository: PokemonListRepositoryProtocol {
    private let remoteDataSource: PokemonRemoteDataSourceProtocol
    private let cacheService: PokemonCacheServiceProtocol
    private let networkMonitor: NetworkMonitorProtocol
    
    init(remoteDataSource: PokemonRemoteDataSourceProtocol,
         cacheService: PokemonCacheServiceProtocol,
         networkMonitor: NetworkMonitorProtocol
    ) {
        self.remoteDataSource = remoteDataSource
        self.cacheService = cacheService
        self.networkMonitor = networkMonitor
    }
    
    func fetchPokemons(offset: Int, limit: Int) async throws -> [Pokemon] {
        guard networkMonitor.isConnected else {
            return try await fetchPokemonsFromCache(offset: offset, limit: limit)
        }
        
        do {
            let response = try await remoteDataSource.fetchPokemonsList(offset: offset, limit: limit)
            let pokemonIds = extractPokemonIds(from: response.results)
            return try await fetchPokemonsWithCache(pokemonIds: pokemonIds)
        } catch {
            return try await fetchPokemonsFromCache(offset: offset, limit: limit)
        }
    }
    
    // MARK: - Private Methods
    
    private func fetchPokemonsFromCache(offset: Int, limit: Int) async throws -> [Pokemon] {
        let pokemons = try await cacheService.fetchPokemonsFromCache(offset: offset, limit: limit)
        
        if pokemons.isEmpty && offset == 0 {
            throw PokemonError.noCache
        }
        
        return pokemons
    }
    
    private func extractPokemonIds(from entries: [PokemonEntry]) -> [Int] {
        return entries.compactMap { entry -> Int? in
            guard let url = URL(string: entry.url),
                  let lastPathComponent = url.pathComponents.last,
                  let id = Int(lastPathComponent) else { return nil }
            return id
        }
    }
    
    private func fetchPokemonsWithCache(pokemonIds: [Int]) async throws -> [Pokemon] {
        let (cachedPokemons, missingIds) = try await getCachedPokemons(ids: pokemonIds)
        let newPokemons = try await fetchMissingPokemons(ids: missingIds)
        
        try await saveNewPokemonsToCache(newPokemons)
        
        return buildPokemonList(ids: pokemonIds, cached: cachedPokemons, new: newPokemons)
    }
    
    private func getCachedPokemons(ids: [Int]) async throws -> ([Int: Pokemon], [Int]) {
        var cachedPokemons: [Int: Pokemon] = [:]
        var missingIds: [Int] = []
        
        for id in ids {
            do {
                if let cachedModel = try await cacheService.fetchPokemon(by: id) {
                    cachedPokemons[id] = Pokemon(from: cachedModel)
                } else {
                    missingIds.append(id)
                }
            } catch {
                missingIds.append(id)
            }
        }
        
        return (cachedPokemons, missingIds)
    }
    
    private func fetchMissingPokemons(ids: [Int]) async throws -> [Pokemon] {
        let detailResponses = try await fetchPokemonDetails(ids: ids)
        return try await createPokemonsFromDetails(detailResponses)
    }
    
    private func fetchPokemonDetails(ids: [Int]) async throws -> [PokemonDetailResponse] {
        try await withThrowingTaskGroup(of: PokemonDetailResponse?.self) { group in
            ids.forEach { id in
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
    }
    
    private func createPokemonsFromDetails(_ details: [PokemonDetailResponse]) async throws -> [Pokemon] {
        try await withThrowingTaskGroup(of: Pokemon?.self) { group in
            details.forEach { detail in
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
    }
    
    private func saveNewPokemonsToCache(_ pokemons: [Pokemon]) async throws {
        for pokemon in pokemons {
            try await cacheService.savePokemon(pokemon)
        }
    }
    
    private func buildPokemonList(ids: [Int], cached: [Int: Pokemon], new: [Pokemon]) -> [Pokemon] {
        var result: [Pokemon] = []
        
        for id in ids {
            if let cachedPokemon = cached[id] {
                result.append(cachedPokemon)
            } else if let newPokemon = new.first(where: { $0.id == id }) {
                result.append(newPokemon)
            }
        }
        
        return result
    }
}
