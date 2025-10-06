//
//  MockPokemonListRepository.swift
//  UbiquitiHATests
//
//  Created by Ivannikov Georgiy on 05.10.2025.
//

import Foundation
@testable import UbiquitiHA

final class MockPokemonListRepository: PokemonListRepositoryProtocol {
    var fetchPokemonsResult: Result<[Pokemon], Error> = .success([])
    var fetchPokemonsCallCount = 0
    var lastFetchPokemonsOffset: Int?
    var lastFetchPokemonsLimit: Int?
    
    func fetchPokemons(offset: Int, limit: Int) async throws -> [Pokemon] {
        fetchPokemonsCallCount += 1
        lastFetchPokemonsOffset = offset
        lastFetchPokemonsLimit = limit
        
        switch fetchPokemonsResult {
        case .success(let pokemons):
            return pokemons
        case .failure(let error):
            throw error
        }
    }
    
    // MARK: - Helper Methods
    
    func reset() {
        fetchPokemonsResult = .success([])
        fetchPokemonsCallCount = 0
        lastFetchPokemonsOffset = nil
        lastFetchPokemonsLimit = nil
    }
}