//
//  MockDatabaseService.swift
//  UbiquitiHATests
//
//  Created by Ivannikov Georgiy on 04.10.2025.
//

import Foundation
@testable import UbiquitiHA
import SwiftData

final class MockDatabaseService: DatabaseServiceProtocol {
    // MARK: - Properties for tracking calls
    var createCallCount = 0
    var fetchCallCount = 0
    var updateCallCount = 0
    var deleteCallCount = 0
    
    var lastCreatedModel: Any?
    var lastFetchedType: Any.Type?
    var lastDeletedModel: Any?
    
    // MARK: - Configurable behavior
    var shouldThrowError = false
    var errorToThrow: Error = TestError.databaseError
    
    // MARK: - Mock data
    var mockPokemonModels: [PokemonModel] = []
    var mockPokemonDescriptionModels: [PokemonDescriptionModel] = []
    
    // MARK: - DatabaseServiceProtocol implementation
    
    func create<T: DatabaseModel>(_ model: T) async throws {
        createCallCount += 1
        lastCreatedModel = model
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        // Store the model for testing purposes
        if let pokemonModel = model as? PokemonModel {
            mockPokemonModels.append(pokemonModel)
        } else if let descriptionModel = model as? PokemonDescriptionModel {
            mockPokemonDescriptionModels.append(descriptionModel)
        }
    }
    
    func fetch<T: DatabaseModel>(of type: T.Type, sortDescriptors: [SortDescriptor<T>]) async throws -> [T] {
        fetchCallCount += 1
        lastFetchedType = type
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        if type == PokemonModel.self {
            return mockPokemonModels as! [T]
        } else if type == PokemonDescriptionModel.self {
            return mockPokemonDescriptionModels as! [T]
        }
        
        return []
    }
    
    func update(_ block: (_ ctx: ModelContext) throws -> Void) async throws {
        updateCallCount += 1
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        // Mock implementation - do nothing
    }
    
    func delete<T: DatabaseModel>(_ model: T) async throws {
        deleteCallCount += 1
        lastDeletedModel = model
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        // Remove from mock data
        if let pokemonModel = model as? PokemonModel {
            mockPokemonModels.removeAll { $0.id == pokemonModel.id }
        } else if let descriptionModel = model as? PokemonDescriptionModel {
            mockPokemonDescriptionModels.removeAll { $0.pokemonId == descriptionModel.pokemonId }
        }
    }
    
    // MARK: - Helper methods for testing
    
    func reset() {
        createCallCount = 0
        fetchCallCount = 0
        updateCallCount = 0
        deleteCallCount = 0
        lastCreatedModel = nil
        lastFetchedType = nil
        lastDeletedModel = nil
        shouldThrowError = false
        mockPokemonModels.removeAll()
        mockPokemonDescriptionModels.removeAll()
    }
    
    func setupMockData(pokemonModels: [PokemonModel] = [], descriptionModels: [PokemonDescriptionModel] = []) {
        self.mockPokemonModels = pokemonModels
        self.mockPokemonDescriptionModels = descriptionModels
    }
}

// MARK: - Test Error

enum TestError: Error, Equatable {
    case databaseError
    case networkError
    case cacheError
}
