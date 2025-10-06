//
//  PokemonCacheServiceEdgeCaseTests.swift
//  UbiquitiHATests
//
//  Created by Ivannikov Georgiy on 04.10.2025.
//

import Testing
@testable import UbiquitiHA
import Foundation

struct PokemonCacheServiceEdgeCaseTests {
    
    // MARK: - Setup
    
    private func createSUT() -> (PokemonCacheService, MockDatabaseService) {
        let mockDatabaseService = MockDatabaseService()
        let cacheService = PokemonCacheService(databaseService: mockDatabaseService)
        return (cacheService, mockDatabaseService)
    }
    
    // MARK: - Edge Cases for Pagination
    
    @Test func testFetchPokemonsFromCache_WithZeroLimit_ReturnsEmptyArray() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        let samplePokemonModels = TestDataFactory.samplePokemonModels
        mockDatabase.setupMockData(pokemonModels: samplePokemonModels)
        
        // When
        let result = try await cacheService.fetchPokemonsFromCache(offset: 0, limit: 0)
        
        // Then
        #expect(result.isEmpty)
    }
    
    // MARK: - Edge Cases for Data Types
    
    @Test func testFetchPokemonsFromCache_WithSpecialCharactersInName_HandlesCorrectly() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        let pokemonWithSpecialName = TestDataFactory.createPokemonModel(
            id: 1,
            name: "Pokémon-é",
            types: ["Normal"]
        )
        mockDatabase.setupMockData(pokemonModels: [pokemonWithSpecialName])
        
        // When
        let result = try await cacheService.fetchPokemonsFromCache(offset: 0, limit: 1)
        
        // Then
        #expect(result.count == 1)
        #expect(result[0].name == "Pokémon-é")
    }
    
    @Test func testFetchPokemonsFromCache_WithEmptyTypesArray_HandlesCorrectly() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        let pokemonWithNoTypes = TestDataFactory.createPokemonModel(
            id: 1,
            name: "Unknown",
            types: []
        )
        mockDatabase.setupMockData(pokemonModels: [pokemonWithNoTypes])
        
        // When
        let result = try await cacheService.fetchPokemonsFromCache(offset: 0, limit: 1)
        
        // Then
        #expect(result.count == 1)
        #expect(result[0].types.isEmpty)
    }
    
    @Test func testFetchPokemonsFromCache_WithLargeTypesArray_HandlesCorrectly() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        let pokemonWithManyTypes = TestDataFactory.createPokemonModel(
            id: 1,
            name: "Arceus",
            types: ["Normal", "Fire", "Water", "Electric", "Grass", "Ice", "Fighting", "Poison", "Ground", "Flying", "Psychic", "Bug", "Rock", "Ghost", "Dragon", "Dark", "Steel", "Fairy"]
        )
        mockDatabase.setupMockData(pokemonModels: [pokemonWithManyTypes])
        
        // When
        let result = try await cacheService.fetchPokemonsFromCache(offset: 0, limit: 1)
        
        // Then
        #expect(result.count == 1)
        #expect(result[0].types.count == 18)
    }
    
    // MARK: - Edge Cases for Pokemon Details
    
    @Test func testFetchPokemonDetailsFromCache_WithEmptyDescription_ReturnsDetailsWithEmptyDescription() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        let descriptionWithEmptyText = TestDataFactory.createPokemonDescriptionModel(
            pokemonId: 1,
            description: ""
        )
        mockDatabase.setupMockData(descriptionModels: [descriptionWithEmptyText])
        
        // When
        let result = try await cacheService.fetchPokemonDetailsFromCache(pokemonId: 1)
        
        // Then
        #expect(result != nil)
        #expect(result?.description == "")
    }
    
    @Test func testFetchPokemonDetailsFromCache_WithNilDescription_ReturnsDetailsWithEmptyDescription() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        let descriptionWithNilText = TestDataFactory.createPokemonDescriptionModel(
            pokemonId: 1,
            description: ""
        )
        mockDatabase.setupMockData(descriptionModels: [descriptionWithNilText])
        
        // When
        let result = try await cacheService.fetchPokemonDetailsFromCache(pokemonId: 1)
        
        // Then
        #expect(result != nil)
        #expect(result?.description == "")
    }
    
    @Test func testFetchPokemonDetailsFromCache_WithVeryLongDescription_HandlesCorrectly() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        let longDescription = String(repeating: "A very long description. ", count: 100)
        let descriptionWithLongText = TestDataFactory.createPokemonDescriptionModel(
            pokemonId: 1,
            description: longDescription
        )
        mockDatabase.setupMockData(descriptionModels: [descriptionWithLongText])
        
        // When
        let result = try await cacheService.fetchPokemonDetailsFromCache(pokemonId: 1)
        
        // Then
        #expect(result != nil)
        #expect(result?.description == longDescription)
    }
    
    // MARK: - Edge Cases for Save Operations
    
    @Test func testSavePokemon_WithMinimalData_SavesSuccessfully() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        let minimalPokemon = TestDataFactory.createPokemon(
            id: 0,
            name: "",
            number: "",
            types: [],
            height: 0,
            weight: 0,
            baseExperience: 0
        )
        
        // When
        try await cacheService.savePokemon(minimalPokemon)
        
        // Then
        #expect(mockDatabase.createCallCount == 1)
        let savedModel = mockDatabase.lastCreatedModel as? PokemonModel
        #expect(savedModel?.id == 0)
        #expect(savedModel?.name == "")
    }
    
    @Test func testSavePokemon_WithMaximumData_SavesSuccessfully() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        let maxPokemon = TestDataFactory.createPokemon(
            id: Int.max,
            name: String(repeating: "A", count: 1000),
            number: String(repeating: "9", count: 10),
            types: Array(repeating: "Type", count: 50),
            height: Int.max,
            weight: Int.max,
            baseExperience: Int.max
        )
        
        // When
        try await cacheService.savePokemon(maxPokemon)
        
        // Then
        #expect(mockDatabase.createCallCount == 1)
        let savedModel = mockDatabase.lastCreatedModel as? PokemonModel
        #expect(savedModel?.id == Int.max)
    }
    
    // MARK: - Performance Tests
    
    @Test func testFetchPokemonsFromCache_WithLargeDataset_PerformsEfficiently() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        let largeDataset = TestDataFactory.createMultiplePokemonModels(count: 1000)
        mockDatabase.setupMockData(pokemonModels: largeDataset)
        
        // When
        let startTime = Date()
        let result = try await cacheService.fetchPokemonsFromCache(offset: 500, limit: 100)
        let endTime = Date()
        
        // Then
        #expect(result.count == 100)
        #expect(result[0].id == 501) // Should be sorted by id
        
        // Performance check (should complete in reasonable time)
        let executionTime = endTime.timeIntervalSince(startTime)
        #expect(executionTime < 1.0) // Should complete within 1 second
    }
    
    // MARK: - Concurrency Tests
    
    @Test func testConcurrentSaveOperations_HandlesCorrectly() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        let pokemons = TestDataFactory.createMultiplePokemons(count: 10)
        
        // When - Save multiple pokemons concurrently
        try await withThrowingTaskGroup(of: Void.self) { group in
            for pokemon in pokemons {
                group.addTask {
                    try await cacheService.savePokemon(pokemon)
                }
            }
            
            try await group.waitForAll()
        }
        
        // Then
        #expect(mockDatabase.createCallCount == 10)
    }
    
    @Test func testConcurrentFetchOperations_HandlesCorrectly() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        let samplePokemonModels = TestDataFactory.samplePokemonModels
        mockDatabase.setupMockData(pokemonModels: samplePokemonModels)
        
        // When - Fetch multiple times concurrently
        let results = try await withThrowingTaskGroup(of: [Pokemon].self) { group in
            for _ in 0..<5 {
                group.addTask {
                    try await cacheService.fetchPokemonsFromCache(offset: 0, limit: 3)
                }
            }
            
            var allResults: [[Pokemon]] = []
            for try await result in group {
                allResults.append(result)
            }
            return allResults
        }
        
        // Then
        #expect(results.count == 5)
        for result in results {
            #expect(result.count == 3)
        }
        #expect(mockDatabase.fetchCallCount == 5)
    }
}
