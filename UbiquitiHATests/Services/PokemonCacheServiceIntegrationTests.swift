//
//  PokemonCacheServiceIntegrationTests.swift
//  UbiquitiHATests
//
//  Created by Ivannikov Georgiy on 04.10.2025.
//

import Testing
@testable import UbiquitiHA

struct PokemonCacheServiceIntegrationTests {
    
    // MARK: - Setup
    
    private func createSUT() -> (PokemonCacheService, MockDatabaseService) {
        let mockDatabaseService = MockDatabaseService()
        let cacheService = PokemonCacheService(databaseService: mockDatabaseService)
        return (cacheService, mockDatabaseService)
    }
    
    // MARK: - Full Workflow Tests
    
    @Test func testCompletePokemonWorkflow_SaveFetchAndUpdate() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        let pokemon = TestDataFactory.createPokemon(
            id: 1,
            name: "Pikachu",
            types: ["Electric"]
        )
        let description = TestDataFactory.createPokemonDescriptionModel(
            pokemonId: 1,
            description: "A mouse Pokémon"
        )
        
        // When - Save pokemon
        try await cacheService.savePokemon(pokemon)
        
        // When - Save description
        try await cacheService.savePokemonDetails(description)
        
        // When - Fetch pokemon
        let fetchedPokemon = try await cacheService.fetchPokemon(by: 1)
        
        // When - Fetch pokemon details
        let fetchedDetails = try await cacheService.fetchPokemonDetailsFromCache(pokemonId: 1)
        
        // When - Fetch pokemon list
        let pokemonList = try await cacheService.fetchPokemonsFromCache(offset: 0, limit: 10)
        
        // Then - Verify all operations
        #expect(mockDatabase.createCallCount == 2) // Pokemon + Description
        #expect(mockDatabase.fetchCallCount == 3) // Fetch pokemon + details + list
        
        #expect(fetchedPokemon != nil)
        #expect(fetchedPokemon?.name == "Pikachu")
        
        #expect(fetchedDetails != nil)
        #expect(fetchedDetails?.description == "A mouse Pokémon")
        
        #expect(pokemonList.count == 1)
        #expect(pokemonList[0].name == "Pikachu")
    }
    
    @Test func testMultiplePokemonsWorkflow_WithPagination() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        let pokemons = TestDataFactory.createMultiplePokemons(count: 10)
        
        // When - Save multiple pokemons
        for pokemon in pokemons {
            try await cacheService.savePokemon(pokemon)
        }
        
        // When - Fetch first page
        let firstPage = try await cacheService.fetchPokemonsFromCache(offset: 0, limit: 5)
        
        // When - Fetch second page
        let secondPage = try await cacheService.fetchPokemonsFromCache(offset: 5, limit: 5)
        
        // When - Fetch third page (should be empty)
        let thirdPage = try await cacheService.fetchPokemonsFromCache(offset: 10, limit: 5)
        
        // Then - Verify pagination
        #expect(mockDatabase.createCallCount == 10)
        #expect(mockDatabase.fetchCallCount == 3)
        
        #expect(firstPage.count == 5)
        #expect(firstPage[0].id == 1)
        #expect(firstPage[4].id == 5)
        
        #expect(secondPage.count == 5)
        #expect(secondPage[0].id == 6)
        #expect(secondPage[4].id == 10)
        
        #expect(thirdPage.isEmpty)
    }
    
    @Test func testPokemonWithDetailsWorkflow_CompleteScenario() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        let pokemon = TestDataFactory.createPokemon(
            id: 25,
            name: "Pikachu",
            types: ["Electric"]
        )
        let description = TestDataFactory.createPokemonDescriptionModel(
            pokemonId: 25,
            description: "A mouse Pokémon that can generate electricity"
        )
        
        // When - Save pokemon and description
        try await cacheService.savePokemon(pokemon)
        try await cacheService.savePokemonDetails(description)
        
        // When - Fetch pokemon by ID
        let fetchedPokemon = try await cacheService.fetchPokemon(by: 25)
        
        // When - Fetch pokemon details
        let fetchedDetails = try await cacheService.fetchPokemonDetailsFromCache(pokemonId: 25)
        
        // When - Fetch from list
        let pokemonList = try await cacheService.fetchPokemonsFromCache(offset: 0, limit: 10)
        
        // Then - Verify complete workflow
        #expect(mockDatabase.createCallCount == 2)
        #expect(mockDatabase.fetchCallCount == 3)
        
        // Verify pokemon data
        #expect(fetchedPokemon != nil)
        #expect(fetchedPokemon?.id == 25)
        #expect(fetchedPokemon?.name == "Pikachu")
        #expect(fetchedPokemon?.types == ["Electric"])
        
        // Verify details data
        #expect(fetchedDetails != nil)
        #expect(fetchedDetails?.id == 25)
        #expect(fetchedDetails?.description == "A mouse Pokémon that can generate electricity")
        
        // Verify list data
        #expect(pokemonList.count == 1)
        #expect(pokemonList[0].id == 25)
        #expect(pokemonList[0].name == "Pikachu")
    }
    
    // MARK: - Error Recovery Tests
    
    @Test func testErrorRecovery_AfterDatabaseError_ContinuesWorking() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        let pokemon = TestDataFactory.createPokemon()
        
        // When - First save fails
        mockDatabase.shouldThrowError = true
        mockDatabase.errorToThrow = TestError.databaseError
        
        // Then - Should throw error
        await #expect(throws: TestError.databaseError) {
            try await cacheService.savePokemon(pokemon)
        }
        
        // When - Reset error and try again
        mockDatabase.shouldThrowError = false
        mockDatabase.reset()
        
        // When - Save should succeed
        try await cacheService.savePokemon(pokemon)
        
        // Then - Should work normally
        #expect(mockDatabase.createCallCount == 1)
        
        let fetchedPokemon = try await cacheService.fetchPokemon(by: pokemon.id)
        #expect(fetchedPokemon != nil)
        #expect(fetchedPokemon?.name == pokemon.name)
    }
    
    @Test func testPartialFailure_SomeOperationsSucceed() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        let pokemon1 = TestDataFactory.createPokemon(id: 1, name: "Pokemon1")
        let pokemon2 = TestDataFactory.createPokemon(id: 2, name: "Pokemon2")
        let pokemon3 = TestDataFactory.createPokemon(id: 3, name: "Pokemon3")
        
        // When - Save first pokemon (should succeed)
        try await cacheService.savePokemon(pokemon1)
        
        // When - Configure error for second pokemon
        mockDatabase.shouldThrowError = true
        mockDatabase.errorToThrow = TestError.databaseError
        
        // When - Second save fails
        await #expect(throws: TestError.databaseError) {
            try await cacheService.savePokemon(pokemon2)
        }
        
        // When - Reset error and save third pokemon
        mockDatabase.shouldThrowError = false
        
        try await cacheService.savePokemon(pokemon3)
        
        // When - Fetch all pokemons
        let allPokemons = try await cacheService.fetchPokemonsFromCache(offset: 0, limit: 10)
        
        // Then - Should have only pokemon1 and pokemon3
        #expect(allPokemons.count == 2)
        #expect(allPokemons[0].id == 1)
        #expect(allPokemons[1].id == 3)
    }
    
    // MARK: - Data Consistency Tests
    
    @Test func testDataConsistency_AfterMultipleOperations() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        let pokemons = TestDataFactory.createMultiplePokemons(count: 5)
        
        // When - Save all pokemons
        for pokemon in pokemons {
            try await cacheService.savePokemon(pokemon)
        }
        
        // When - Fetch all pokemons multiple times
        let fetch1 = try await cacheService.fetchPokemonsFromCache(offset: 0, limit: 10)
        let fetch2 = try await cacheService.fetchPokemonsFromCache(offset: 0, limit: 10)
        let fetch3 = try await cacheService.fetchPokemonsFromCache(offset: 0, limit: 10)
        
        // Then - All fetches should return same data
        #expect(fetch1.count == fetch2.count)
        #expect(fetch2.count == fetch3.count)
        #expect(fetch1.count == 5)
        
        for i in 0..<5 {
            #expect(fetch1[i].id == fetch2[i].id)
            #expect(fetch2[i].id == fetch3[i].id)
        }
    }
    
    @Test func testDataConsistency_WithMixedOperations() async throws {
        // Given
        let (cacheService, mockDatabase) = createSUT()
        let pokemon = TestDataFactory.createPokemon(id: 1, name: "TestPokemon")
        let description = TestDataFactory.createPokemonDescriptionModel(
            pokemonId: 1,
            description: "Test description"
        )
        
        // When - Save pokemon
        try await cacheService.savePokemon(pokemon)
        
        // When - Fetch pokemon (should work)
        let fetchedPokemon = try await cacheService.fetchPokemon(by: 1)
        #expect(fetchedPokemon != nil)
        
        // When - Save description
        try await cacheService.savePokemonDetails(description)
        
        // When - Fetch description (should work)
        let fetchedDetails = try await cacheService.fetchPokemonDetailsFromCache(pokemonId: 1)
        #expect(fetchedDetails != nil)
        
        // When - Fetch from list (should include pokemon)
        let pokemonList = try await cacheService.fetchPokemonsFromCache(offset: 0, limit: 10)
        #expect(pokemonList.count == 1)
        #expect(pokemonList[0].id == 1)
        
        // Then - All operations should be consistent
        #expect(fetchedPokemon?.id == pokemonList[0].id)
        #expect(fetchedDetails?.id == pokemonList[0].id)
    }
}
