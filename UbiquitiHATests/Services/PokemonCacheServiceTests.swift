//
//  PokemonCacheServiceTests.swift
//  UbiquitiHATests
//
//  Created by Ivannikov Georgiy on 04.10.2025.
//

import Testing
@testable import UbiquitiHA

struct PokemonCacheServiceTests {
    
    // MARK: - Setup
    
    private func createSUT() -> (PokemonCacheService, MockDatabaseService) {
        let mockDatabaseService = MockDatabaseService()
        let cacheService = PokemonCacheService(databaseService: mockDatabaseService)
        return (cacheService, mockDatabaseService)
    }
    
    // MARK: - fetchPokemonsFromCache Tests
    
    @Test func testFetchPokemonsFromCache_WithValidData_ReturnsCorrectPokemons() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        let samplePokemonModels = TestDataFactory.samplePokemonModels
        mockDatabase.setupMockData(pokemonModels: samplePokemonModels)
        
        // When
        let result = try await cacheService.fetchPokemonsFromCache(offset: 0, limit: 3)
        
        // Then
        #expect(result.count == 3)
        #expect(result[0].id == 1)
        #expect(result[0].name == "Bulbasaur")
        #expect(result[1].id == 2)
        #expect(result[1].name == "Ivysaur")
        #expect(result[2].id == 3)
        #expect(result[2].name == "Venusaur")
        #expect(mockDatabase.fetchCallCount == 1)
    }
    
    @Test func testFetchPokemonsFromCache_WithPagination_ReturnsCorrectSubset() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        let samplePokemonModels = TestDataFactory.samplePokemonModels
        mockDatabase.setupMockData(pokemonModels: samplePokemonModels)
        
        // When
        let result = try await cacheService.fetchPokemonsFromCache(offset: 2, limit: 2)
        
        // Then
        #expect(result.count == 2)
        #expect(result[0].id == 3)
        #expect(result[0].name == "Venusaur")
        #expect(result[1].id == 4)
        #expect(result[1].name == "Charmander")
    }
    
    @Test func testFetchPokemonsFromCache_WithOffsetBeyondData_ReturnsEmptyArray() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        let samplePokemonModels = TestDataFactory.samplePokemonModels
        mockDatabase.setupMockData(pokemonModels: samplePokemonModels)
        
        // When
        let result = try await cacheService.fetchPokemonsFromCache(offset: 10, limit: 5)
        
        // Then
        #expect(result.isEmpty)
    }
    
    @Test func testFetchPokemonsFromCache_WithLimitExceedingData_ReturnsAvailableData() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        let samplePokemonModels = TestDataFactory.samplePokemonModels
        mockDatabase.setupMockData(pokemonModels: samplePokemonModels)
        
        // When
        let result = try await cacheService.fetchPokemonsFromCache(offset: 0, limit: 10)
        
        // Then
        #expect(result.count == 5)
        #expect(mockDatabase.fetchCallCount == 1)
    }
    
    @Test func testFetchPokemonsFromCache_WithEmptyCache_ReturnsEmptyArray() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        mockDatabase.setupMockData(pokemonModels: [])
        
        // When
        let result = try await cacheService.fetchPokemonsFromCache(offset: 0, limit: 5)
        
        // Then
        #expect(result.isEmpty)
        #expect(mockDatabase.fetchCallCount == 1)
    }
    
    @Test func testFetchPokemonsFromCache_WithDatabaseError_ThrowsError() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        mockDatabase.shouldThrowError = true
        mockDatabase.errorToThrow = TestError.databaseError
        
        // When & Then
        await #expect(throws: TestError.databaseError) {
            try await cacheService.fetchPokemonsFromCache(offset: 0, limit: 5)
        }
    }
    
    // MARK: - fetchPokemonDetailsFromCache Tests
    
    @Test func testFetchPokemonDetailsFromCache_WithValidData_ReturnsCorrectDetails() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        let sampleDescriptionModels = TestDataFactory.samplePokemonDescriptionModels
        mockDatabase.setupMockData(descriptionModels: sampleDescriptionModels)
        
        // When
        let result = try await cacheService.fetchPokemonDetailsFromCache(pokemonId: 1)
        
        // Then
        #expect(result != nil)
        #expect(result?.id == 1)
        #expect(result?.description == "A seed Pokémon")
        #expect(mockDatabase.fetchCallCount == 1)
    }
    
    @Test func testFetchPokemonDetailsFromCache_WithNonExistentPokemon_ReturnsNil() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        let sampleDescriptionModels = TestDataFactory.samplePokemonDescriptionModels
        mockDatabase.setupMockData(descriptionModels: sampleDescriptionModels)
        
        // When
        let result = try await cacheService.fetchPokemonDetailsFromCache(pokemonId: 999)
        
        // Then
        #expect(result == nil)
        #expect(mockDatabase.fetchCallCount == 1)
    }
    
    @Test func testFetchPokemonDetailsFromCache_WithEmptyCache_ReturnsNil() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        mockDatabase.setupMockData(descriptionModels: [])
        
        // When
        let result = try await cacheService.fetchPokemonDetailsFromCache(pokemonId: 1)
        
        // Then
        #expect(result == nil)
        #expect(mockDatabase.fetchCallCount == 1)
    }
    
    @Test func testFetchPokemonDetailsFromCache_WithDatabaseError_ThrowsError() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        mockDatabase.shouldThrowError = true
        mockDatabase.errorToThrow = TestError.databaseError
        
        // When & Then
        await #expect(throws: TestError.databaseError) {
            try await cacheService.fetchPokemonDetailsFromCache(pokemonId: 1)
        }
    }
    
    // MARK: - fetchPokemon Tests
    
    @Test func testFetchPokemon_WithValidId_ReturnsCorrectModel() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        let samplePokemonModels = TestDataFactory.samplePokemonModels
        mockDatabase.setupMockData(pokemonModels: samplePokemonModels)
        
        // When
        let result = try await cacheService.fetchPokemon(by: 3)
        
        // Then
        #expect(result != nil)
        #expect(result?.id == 3)
        #expect(result?.name == "Venusaur")
        #expect(mockDatabase.fetchCallCount == 1)
    }
    
    @Test func testFetchPokemon_WithNonExistentId_ReturnsNil() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        let samplePokemonModels = TestDataFactory.samplePokemonModels
        mockDatabase.setupMockData(pokemonModels: samplePokemonModels)
        
        // When
        let result = try await cacheService.fetchPokemon(by: 999)
        
        // Then
        #expect(result == nil)
        #expect(mockDatabase.fetchCallCount == 1)
    }
    
    @Test func testFetchPokemon_WithEmptyCache_ReturnsNil() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        mockDatabase.setupMockData(pokemonModels: [])
        
        // When
        let result = try await cacheService.fetchPokemon(by: 1)
        
        // Then
        #expect(result == nil)
        #expect(mockDatabase.fetchCallCount == 1)
    }
    
    @Test func testFetchPokemon_WithDatabaseError_ThrowsError() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        mockDatabase.shouldThrowError = true
        mockDatabase.errorToThrow = TestError.databaseError
        
        // When & Then
        await #expect(throws: TestError.databaseError) {
            try await cacheService.fetchPokemon(by: 1)
        }
    }
    
    // MARK: - savePokemon Tests
    
    @Test func testSavePokemon_WithValidPokemon_SavesSuccessfully() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        let pokemon = TestDataFactory.createPokemon()
        
        // When
        try await cacheService.savePokemon(pokemon)
        
        // Then
        #expect(mockDatabase.createCallCount == 1)
        #expect(mockDatabase.lastCreatedModel is PokemonModel)
        
        let savedModel = mockDatabase.lastCreatedModel as? PokemonModel
        #expect(savedModel?.id == pokemon.id)
        #expect(savedModel?.name == pokemon.name)
    }
    
    @Test func testSavePokemon_WithDatabaseError_ThrowsError() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        let pokemon = TestDataFactory.createPokemon()
        mockDatabase.shouldThrowError = true
        mockDatabase.errorToThrow = TestError.databaseError
        
        // When & Then
        await #expect(throws: TestError.databaseError) {
            try await cacheService.savePokemon(pokemon)
        }
    }
    
    // MARK: - savePokemonDetails Tests
    
    @Test func testSavePokemonDetails_WithValidDetails_SavesSuccessfully() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        let descriptionModel = TestDataFactory.createPokemonDescriptionModel()
        
        // When
        try await cacheService.savePokemonDetails(descriptionModel)
        
        // Then
        #expect(mockDatabase.createCallCount == 1)
        #expect(mockDatabase.lastCreatedModel is PokemonDescriptionModel)
        
        let savedModel = mockDatabase.lastCreatedModel as? PokemonDescriptionModel
        #expect(savedModel?.pokemonId == descriptionModel.pokemonId)
        #expect(savedModel?.pokemonDescription == descriptionModel.pokemonDescription)
    }
    
    @Test func testSavePokemonDetails_WithDatabaseError_ThrowsError() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        let descriptionModel = TestDataFactory.createPokemonDescriptionModel()
        mockDatabase.shouldThrowError = true
        mockDatabase.errorToThrow = TestError.databaseError
        
        // When & Then
        await #expect(throws: TestError.databaseError) {
            try await cacheService.savePokemonDetails(descriptionModel)
        }
    }
    
    // MARK: - Integration Tests
    
    @Test func testSaveAndFetchPokemon_IntegrationTest() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        let pokemon = TestDataFactory.createPokemon(id: 25, name: "Pikachu", types: ["Electric"])
        
        // When - Save pokemon
        try await cacheService.savePokemon(pokemon)
        
        // Then - Verify save
        #expect(mockDatabase.createCallCount == 1)
        
        // When - Fetch pokemon
        let fetchedPokemon = try await cacheService.fetchPokemon(by: 25)
        
        // Then - Verify fetch
        #expect(fetchedPokemon != nil)
        #expect(fetchedPokemon?.id == 25)
        #expect(fetchedPokemon?.name == "Pikachu")
    }
    
    @Test func testSaveAndFetchPokemonDetails_IntegrationTest() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        let descriptionModel = TestDataFactory.createPokemonDescriptionModel(
            pokemonId: 25,
            description: "A mouse Pokémon"
        )
        
        // When - Save description
        try await cacheService.savePokemonDetails(descriptionModel)
        
        // Then - Verify save
        #expect(mockDatabase.createCallCount == 1)
        
        // When - Fetch description
        let fetchedDetails = try await cacheService.fetchPokemonDetailsFromCache(pokemonId: 25)
        
        // Then - Verify fetch
        #expect(fetchedDetails != nil)
        #expect(fetchedDetails?.id == 25)
        #expect(fetchedDetails?.description == "A mouse Pokémon")
    }
}