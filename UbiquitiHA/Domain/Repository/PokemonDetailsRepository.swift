//
//  PokemonDetailsService.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 04.10.2025.
//

import Foundation

protocol PokemonDetailsRepositoryProtocol {
    func fetchPokemonDetails(pokemon: Pokemon) async throws -> PokemonDetails
}

final class PokemonDetailsRepository: PokemonDetailsRepositoryProtocol {
    private let remoteDataSource: PokemonRemoteDataSourceProtocol
    private let cacheService: PokemonCacheServiceProtocol
    private let networkMonitor: NetworkMonitorProtocol
    
    init(remoteDataSource: PokemonRemoteDataSourceProtocol,
         cacheService: PokemonCacheServiceProtocol,
         networkMonitor: NetworkMonitorProtocol) {
        self.remoteDataSource = remoteDataSource
        self.cacheService = cacheService
        self.networkMonitor = networkMonitor
    }
    
    func fetchPokemonDetails(pokemon: Pokemon) async throws -> PokemonDetails {
        guard networkMonitor.isConnected else {
            return try await fetchPokemonDetailsFromCache(pokemon: pokemon)
        }
        
        do {
            return try await fetchPokemonDetailsFromAPI(pokemon: pokemon)
        } catch {
            return try await fetchPokemonDetailsFromCache(pokemon: pokemon)
        }
    }
    
    // MARK: - Private Methods
    
    private func fetchPokemonDetailsFromCache(pokemon: Pokemon) async throws -> PokemonDetails {
        guard let cachedDetails = try await cacheService.fetchPokemonDetailsFromCache(pokemonId: pokemon.id) else {
            throw PokemonError.noCache
        }
        return cachedDetails
    }
    
    private func fetchPokemonDetailsFromAPI(pokemon: Pokemon) async throws -> PokemonDetails {
        let speciesResponse = try await remoteDataSource.fetchPokemonDescription(name: pokemon.name)
        let pokemonDetails = PokemonDetails(pokemon: pokemon, pokemonSpeciesResponse: speciesResponse)
        let detailsModel = PokemonDescriptionModel(details: pokemonDetails)
        
        try await cacheService.savePokemonDetails(detailsModel)
        
        return pokemonDetails
    }
}
