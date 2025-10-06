//
//  MockLoadPokemonsUseCase.swift
//  UbiquitiHATests
//
//  Created by Ivannikov Georgiy on 05.10.2025.
//

import Foundation
@testable import UbiquitiHA

final class MockLoadPokemonsUseCase: LoadPokemonsUseCaseProtocol {
    var executeResult: Result<[Pokemon], Error> = .failure(PokemonError.unknown)
    var executeCallCount = 0
    var lastExecuteOffset: Int?
    var lastExecuteLimit: Int?
    
    func execute(offset: Int, limit: Int) async throws -> [Pokemon] {
        executeCallCount += 1
        lastExecuteOffset = offset
        lastExecuteLimit = limit
        
        switch executeResult {
        case .success(let pokemons):
            return pokemons
        case .failure(let error):
            throw error
        }
    }
    
    // MARK: - Helper Methods
    
    func reset() {
        executeResult = .failure(PokemonError.unknown)
        executeCallCount = 0
        lastExecuteOffset = nil
        lastExecuteLimit = nil
    }
}