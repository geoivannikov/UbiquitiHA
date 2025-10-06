//
//  MockPokemonCacheService.swift
//  UbiquitiHATests
//
//  Created by Ivannikov Georgiy on 05.10.2025.
//

import Foundation
@testable import UbiquitiHA

final class MockPokemonCacheService: PokemonCacheServiceProtocol {
    var fetchPokemonsFromCacheResult: Result<[Pokemon], Error> = .success([])
    var fetchPokemonDetailsFromCacheResult: Result<PokemonDetails?, Error> = .success(nil)
    var fetchPokemonResult: Result<PokemonModel?, Error> = .success(nil)
    var savePokemonResult: Result<Void, Error> = .success(())
    var savePokemonDetailsResult: Result<Void, Error> = .success(())
    
    var fetchPokemonsFromCacheCallCount = 0
    var fetchPokemonDetailsFromCacheCallCount = 0
    var fetchPokemonCallCount = 0
    var savePokemonCallCount = 0
    var savePokemonDetailsCallCount = 0
    
    var lastFetchPokemonsFromCacheOffset: Int?
    var lastFetchPokemonsFromCacheLimit: Int?
    var lastFetchPokemonDetailsFromCachePokemonId: Int?
    var lastFetchPokemonId: Int?
    var lastSavePokemon: Pokemon?
    var lastSavePokemonDetails: PokemonDescriptionModel?
    
    func fetchPokemonsFromCache(offset: Int, limit: Int) async throws -> [Pokemon] {
        fetchPokemonsFromCacheCallCount += 1
        lastFetchPokemonsFromCacheOffset = offset
        lastFetchPokemonsFromCacheLimit = limit
        
        switch fetchPokemonsFromCacheResult {
        case .success(let pokemons):
            return pokemons
        case .failure(let error):
            throw error
        }
    }
    
    func fetchPokemonDetailsFromCache(pokemonId: Int) async throws -> PokemonDetails? {
        fetchPokemonDetailsFromCacheCallCount += 1
        lastFetchPokemonDetailsFromCachePokemonId = pokemonId
        
        switch fetchPokemonDetailsFromCacheResult {
        case .success(let details):
            return details
        case .failure(let error):
            throw error
        }
    }
    
    func fetchPokemon(by id: Int) async throws -> PokemonModel? {
        fetchPokemonCallCount += 1
        lastFetchPokemonId = id
        
        switch fetchPokemonResult {
        case .success(let model):
            return model
        case .failure(let error):
            throw error
        }
    }
    
    func savePokemon(_ pokemon: Pokemon) async throws {
        savePokemonCallCount += 1
        lastSavePokemon = pokemon
        
        switch savePokemonResult {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }
    
    func savePokemonDetails(_ details: PokemonDescriptionModel) async throws {
        savePokemonDetailsCallCount += 1
        lastSavePokemonDetails = details
        
        switch savePokemonDetailsResult {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }
    
    // MARK: - Helper Methods
    
    func reset() {
        fetchPokemonsFromCacheResult = .success([])
        fetchPokemonDetailsFromCacheResult = .success(nil)
        fetchPokemonResult = .success(nil)
        savePokemonResult = .success(())
        savePokemonDetailsResult = .success(())
        
        fetchPokemonsFromCacheCallCount = 0
        fetchPokemonDetailsFromCacheCallCount = 0
        fetchPokemonCallCount = 0
        savePokemonCallCount = 0
        savePokemonDetailsCallCount = 0
        
        lastFetchPokemonsFromCacheOffset = nil
        lastFetchPokemonsFromCacheLimit = nil
        lastFetchPokemonDetailsFromCachePokemonId = nil
        lastFetchPokemonId = nil
        lastSavePokemon = nil
        lastSavePokemonDetails = nil
    }
}