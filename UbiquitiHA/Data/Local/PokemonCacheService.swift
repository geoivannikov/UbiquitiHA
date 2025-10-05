//
//  PokemonCacheService.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 04.10.2025.
//

import Foundation

protocol PokemonCacheServiceProtocol {
    func fetchPokemonsFromCache(offset: Int, limit: Int) async throws -> [Pokemon]
    func fetchPokemonDetailsFromCache(pokemonId: Int) async throws -> PokemonDetails?
    func fetchPokemon(by id: Int) async throws -> PokemonModel?
    func savePokemon(_ pokemon: Pokemon) async throws
    func savePokemonDetails(_ details: PokemonDescriptionModel) async throws
}

final class PokemonCacheService: PokemonCacheServiceProtocol {
    private let databaseService: DatabaseServiceProtocol
    
    init(databaseService: DatabaseServiceProtocol) {
        self.databaseService = databaseService
    }
    
    func fetchPokemonsFromCache(offset: Int, limit: Int) async throws -> [Pokemon] {
        let allCachedPokemons = try await databaseService.fetch(of: PokemonModel.self, sortDescriptors: []).sorted { $0.id < $1.id }
        let startIndex = offset
        let endIndex = min(offset + limit, allCachedPokemons.count)
        
        guard startIndex < allCachedPokemons.count else {
            return []
        }
        
        let paginatedPokemons = Array(allCachedPokemons[startIndex..<endIndex])
        return paginatedPokemons.map(Pokemon.init)
    }
    
    func fetchPokemonDetailsFromCache(pokemonId: Int) async throws -> PokemonDetails? {
        let details = try await databaseService.fetch(of: PokemonDescriptionModel.self, sortDescriptors: [])
        guard let cachedDetails = details.lazy.first(where: { $0.pokemonId == pokemonId }) else {
            return nil
        }
        
        let pokemon = Pokemon(id: pokemonId)
        return PokemonDetails(pokemon: pokemon, model: cachedDetails)
    }
    
    func fetchPokemon(by id: Int) async throws -> PokemonModel? {
        let pokemons = try await databaseService.fetch(of: PokemonModel.self, sortDescriptors: []).sorted { $0.id < $1.id }
        return pokemons.lazy.first { $0.id == id }
    }
    
    func savePokemon(_ pokemon: Pokemon) async throws {
        let model = PokemonModel(from: pokemon)
        try await databaseService.create(model)
    }
    
    func savePokemonDetails(_ details: PokemonDescriptionModel) async throws {
        try await databaseService.create(details)
    }
}
