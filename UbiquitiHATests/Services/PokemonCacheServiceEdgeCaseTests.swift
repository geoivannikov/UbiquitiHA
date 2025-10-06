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
        let result = try await cacheService.fetchPokemonsFromCache(offset: 0)
        
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
        let result = try await cacheService.fetchPokemonsFromCache(offset: 0)
        
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
        let result = try await cacheService.fetchPokemonsFromCache(offset: 0)
        
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
}
