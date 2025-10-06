//
//  MockPokemonDetailsRepository.swift
//  UbiquitiHATests
//
//  Created by Ivannikov Georgiy on 05.10.2025.
//

import Foundation
@testable import UbiquitiHA

final class MockPokemonDetailsRepository: PokemonDetailsRepositoryProtocol {
    var fetchPokemonDetailsResult: Result<PokemonDetails, Error> = .failure(PokemonError.unknown)
    var fetchPokemonDetailsCallCount = 0
    var lastFetchPokemonDetailsPokemon: Pokemon?
    
    func fetchPokemonDetails(pokemon: Pokemon) async throws -> PokemonDetails {
        fetchPokemonDetailsCallCount += 1
        lastFetchPokemonDetailsPokemon = pokemon
        
        switch fetchPokemonDetailsResult {
        case .success(let details):
            return details
        case .failure(let error):
            throw error
        }
    }
    
    // MARK: - Helper Methods
    
    func reset() {
        fetchPokemonDetailsResult = .failure(PokemonError.unknown)
        fetchPokemonDetailsCallCount = 0
        lastFetchPokemonDetailsPokemon = nil
    }
}