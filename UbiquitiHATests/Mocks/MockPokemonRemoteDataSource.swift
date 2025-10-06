//
//  MockPokemonRemoteDataSource.swift
//  UbiquitiHATests
//
//  Created by Ivannikov Georgiy on 05.10.2025.
//

import Foundation
@testable import UbiquitiHA

final class MockPokemonRemoteDataSource: PokemonRemoteDataSourceProtocol {
    var fetchPokemonsListResult: Result<PokemonListResponse, Error> = .failure(PokemonError.unknown)
    var fetchPokemonResult: Result<PokemonDetailResponse, Error> = .failure(PokemonError.unknown)
    var fetchPokemonDescriptionResult: Result<PokemonSpeciesResponse, Error> = .failure(PokemonError.unknown)
    var fetchPokemonImageResult: Result<Data, Error> = .failure(PokemonError.unknown)
    
    var fetchPokemonsListCallCount = 0
    var fetchPokemonCallCount = 0
    var fetchPokemonDescriptionCallCount = 0
    var fetchPokemonImageCallCount = 0
    
    var lastFetchPokemonsListOffset: Int?
    var lastFetchPokemonsListLimit: Int?
    var lastFetchPokemonId: Int?
    var lastFetchPokemonDescriptionName: String?
    var lastFetchPokemonImageResponse: PokemonDetailResponse?
    
    func fetchPokemonsList(offset: Int, limit: Int) async throws -> PokemonListResponse {
        fetchPokemonsListCallCount += 1
        lastFetchPokemonsListOffset = offset
        lastFetchPokemonsListLimit = limit
        
        switch fetchPokemonsListResult {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
    
    func fetchPokemon(id: Int) async throws -> PokemonDetailResponse {
        fetchPokemonCallCount += 1
        lastFetchPokemonId = id
        
        switch fetchPokemonResult {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
    
    func fetchPokemonDescription(name: String) async throws -> PokemonSpeciesResponse {
        fetchPokemonDescriptionCallCount += 1
        lastFetchPokemonDescriptionName = name
        
        switch fetchPokemonDescriptionResult {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
    
    func fetchPokemonImage(from response: PokemonDetailResponse) async throws -> Data {
        fetchPokemonImageCallCount += 1
        lastFetchPokemonImageResponse = response
        
        switch fetchPokemonImageResult {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        }
    }
    
    // MARK: - Helper Methods
    
    func reset() {
        fetchPokemonsListResult = .failure(PokemonError.unknown)
        fetchPokemonResult = .failure(PokemonError.unknown)
        fetchPokemonDescriptionResult = .failure(PokemonError.unknown)
        fetchPokemonImageResult = .failure(PokemonError.unknown)
        
        fetchPokemonsListCallCount = 0
        fetchPokemonCallCount = 0
        fetchPokemonDescriptionCallCount = 0
        fetchPokemonImageCallCount = 0
        
        lastFetchPokemonsListOffset = nil
        lastFetchPokemonsListLimit = nil
        lastFetchPokemonId = nil
        lastFetchPokemonDescriptionName = nil
        lastFetchPokemonImageResponse = nil
    }
}