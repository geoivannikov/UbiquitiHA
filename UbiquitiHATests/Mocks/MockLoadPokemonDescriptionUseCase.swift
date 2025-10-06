//
//  MockLoadPokemonDescriptionUseCase.swift
//  UbiquitiHATests
//
//  Created by Ivannikov Georgiy on 05.10.2025.
//

import Foundation
@testable import UbiquitiHA

final class MockLoadPokemonDescriptionUseCase: LoadPokemonDescriptionUseCaseProtocol {
    var executeResult: Result<PokemonDetails, Error> = .failure(PokemonError.unknown)
    var executeCallCount = 0
    var lastExecutePokemon: Pokemon?
    
    func execute(pokemon: Pokemon) async throws -> PokemonDetails {
        executeCallCount += 1
        lastExecutePokemon = pokemon
        
        switch executeResult {
        case .success(let details):
            return details
        case .failure(let error):
            throw error
        }
    }
    
    // MARK: - Helper Methods
    
    func reset() {
        executeResult = .failure(PokemonError.unknown)
        executeCallCount = 0
        lastExecutePokemon = nil
    }
}