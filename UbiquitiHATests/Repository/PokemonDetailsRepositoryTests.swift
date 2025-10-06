//
//  PokemonDetailsRepositoryTests.swift
//  UbiquitiHATests
//
//  Created by Ivannikov Georgiy on 05.10.2025.
//

import XCTest
@testable import UbiquitiHA

final class PokemonDetailsRepositoryTests: XCTestCase {
    
    private var repository: PokemonDetailsRepository!
    private var mockRemoteDataSource: MockPokemonRemoteDataSource!
    private var mockCacheService: MockPokemonCacheService!
    private var mockNetworkMonitor: MockNetworkMonitor!
    
    override func setUp() {
        super.setUp()
        mockRemoteDataSource = MockPokemonRemoteDataSource()
        mockCacheService = MockPokemonCacheService()
        mockNetworkMonitor = MockNetworkMonitor()
        
        repository = PokemonDetailsRepository(
            remoteDataSource: mockRemoteDataSource,
            cacheService: mockCacheService,
            networkMonitor: mockNetworkMonitor
        )
    }
    
    override func tearDown() {
        repository = nil
        mockRemoteDataSource = nil
        mockCacheService = nil
        mockNetworkMonitor = nil
        super.tearDown()
    }
    
    // MARK: - Network Connected Tests
    
    func testFetchPokemonDetailsWhenConnectedAndAPISuccess() async throws {
        // Given
        let pokemon = TestDataFactory.createPokemon()
        let speciesResponse = PokemonSpeciesResponse(
            flavorText: "A mouse Pokémon",
            genus: "Mouse Pokémon",
            formsCount: 1
        )
        
        mockNetworkMonitor.isConnected = true
        mockRemoteDataSource.fetchPokemonDescriptionResult = .success(speciesResponse)
        
        // When
        let result = try await repository.fetchPokemonDetails(pokemon: pokemon)
        
        // Then
        XCTAssertEqual(result.id, pokemon.id)
        XCTAssertEqual(result.name, pokemon.name)
        XCTAssertEqual(result.description, speciesResponse.flavorText)
        XCTAssertEqual(result.species, speciesResponse.genus)
        XCTAssertEqual(result.formsCount, speciesResponse.formsCount)
        XCTAssertEqual(result.types, pokemon.types)
        XCTAssertEqual(result.weight, pokemon.weight)
        XCTAssertEqual(result.height, pokemon.height)
        XCTAssertEqual(result.baseExperience, pokemon.baseExperience)
        
        // Verify API calls
        XCTAssertEqual(mockRemoteDataSource.fetchPokemonDescriptionCallCount, 1)
        XCTAssertEqual(mockRemoteDataSource.lastFetchPokemonDescriptionName, pokemon.name)
        
        // Verify cache save
        XCTAssertEqual(mockCacheService.savePokemonDetailsCallCount, 1)
        XCTAssertNotNil(mockCacheService.lastSavePokemonDetails)
    }
    
    func testFetchPokemonDetailsWhenConnectedAndAPIFailureThenCacheSuccess() async throws {
        // Given
        let pokemon = TestDataFactory.createPokemon()
        let cachedDetails = PokemonDetails(
            id: pokemon.id,
            name: pokemon.name,
            description: "Cached description",
            weight: pokemon.weight,
            height: pokemon.height,
            baseExperience: pokemon.baseExperience,
            species: "Cached species",
            types: pokemon.types,
            formsCount: 1
        )
        
        mockNetworkMonitor.isConnected = true
        mockRemoteDataSource.fetchPokemonDescriptionResult = .failure(PokemonError.networkError(URLError(.notConnectedToInternet)))
        mockCacheService.fetchPokemonDetailsFromCacheResult = .success(cachedDetails)
        
        // When
        let result = try await repository.fetchPokemonDetails(pokemon: pokemon)
        
        // Then
        XCTAssertEqual(result.id, cachedDetails.id)
        XCTAssertEqual(result.description, cachedDetails.description)
        XCTAssertEqual(result.species, cachedDetails.species)
        
        // Verify API call was attempted
        XCTAssertEqual(mockRemoteDataSource.fetchPokemonDescriptionCallCount, 1)
        
        // Verify cache fallback
        XCTAssertEqual(mockCacheService.fetchPokemonDetailsFromCacheCallCount, 1)
        XCTAssertEqual(mockCacheService.lastFetchPokemonDetailsFromCachePokemonId, pokemon.id)
    }
    
    func testFetchPokemonDetailsWhenConnectedAndAPIFailureThenCacheFailure() async {
        // Given
        let pokemon = TestDataFactory.createPokemon()
        
        mockNetworkMonitor.isConnected = true
        mockRemoteDataSource.fetchPokemonDescriptionResult = .failure(PokemonError.networkError(URLError(.notConnectedToInternet)))
        mockCacheService.fetchPokemonDetailsFromCacheResult = .failure(PokemonError.noCache)
        
        // When & Then
        do {
            _ = try await repository.fetchPokemonDetails(pokemon: pokemon)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is PokemonError)
        }
        
        // Verify API call was attempted
        XCTAssertEqual(mockRemoteDataSource.fetchPokemonDescriptionCallCount, 1)
        
        // Verify cache fallback was attempted
        XCTAssertEqual(mockCacheService.fetchPokemonDetailsFromCacheCallCount, 1)
    }
    
    // MARK: - Network Disconnected Tests
    
    func testFetchPokemonDetailsWhenDisconnectedAndCacheSuccess() async throws {
        // Given
        let pokemon = TestDataFactory.createPokemon()
        let cachedDetails = PokemonDetails(
            id: pokemon.id,
            name: pokemon.name,
            description: "Cached description",
            weight: pokemon.weight,
            height: pokemon.height,
            baseExperience: pokemon.baseExperience,
            species: "Cached species",
            types: pokemon.types,
            formsCount: 1
        )
        
        mockNetworkMonitor.isConnected = false
        mockCacheService.fetchPokemonDetailsFromCacheResult = .success(cachedDetails)
        
        // When
        let result = try await repository.fetchPokemonDetails(pokemon: pokemon)
        
        // Then
        XCTAssertEqual(result.id, cachedDetails.id)
        XCTAssertEqual(result.description, cachedDetails.description)
        XCTAssertEqual(result.species, cachedDetails.species)
        
        // Verify no API calls were made
        XCTAssertEqual(mockRemoteDataSource.fetchPokemonDescriptionCallCount, 0)
        
        // Verify cache was used
        XCTAssertEqual(mockCacheService.fetchPokemonDetailsFromCacheCallCount, 1)
        XCTAssertEqual(mockCacheService.lastFetchPokemonDetailsFromCachePokemonId, pokemon.id)
    }
    
    func testFetchPokemonDetailsWhenDisconnectedAndCacheFailure() async {
        // Given
        let pokemon = TestDataFactory.createPokemon()
        
        mockNetworkMonitor.isConnected = false
        mockCacheService.fetchPokemonDetailsFromCacheResult = .failure(PokemonError.noCache)
        
        // When & Then
        do {
            _ = try await repository.fetchPokemonDetails(pokemon: pokemon)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is PokemonError)
            if case PokemonError.noCache = error {
                // Expected error
            } else {
                XCTFail("Expected noCache error")
            }
        }
        
        // Verify no API calls were made
        XCTAssertEqual(mockRemoteDataSource.fetchPokemonDescriptionCallCount, 0)
        
        // Verify cache was attempted
        XCTAssertEqual(mockCacheService.fetchPokemonDetailsFromCacheCallCount, 1)
    }
    
    func testFetchPokemonDetailsWhenDisconnectedAndCacheReturnsNil() async {
        // Given
        let pokemon = TestDataFactory.createPokemon()
        
        mockNetworkMonitor.isConnected = false
        mockCacheService.fetchPokemonDetailsFromCacheResult = .success(nil)
        
        // When & Then
        do {
            _ = try await repository.fetchPokemonDetails(pokemon: pokemon)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is PokemonError)
            if case PokemonError.noCache = error {
                // Expected error
            } else {
                XCTFail("Expected noCache error")
            }
        }
        
        // Verify no API calls were made
        XCTAssertEqual(mockRemoteDataSource.fetchPokemonDescriptionCallCount, 0)
        
        // Verify cache was attempted
        XCTAssertEqual(mockCacheService.fetchPokemonDetailsFromCacheCallCount, 1)
    }
    
    // MARK: - Edge Cases
    
    func testFetchPokemonDetailsWithEmptyPokemon() async throws {
        // Given
        let pokemon = Pokemon(id: 0)
        let speciesResponse = PokemonSpeciesResponse(
            flavorText: "A mouse Pokémon",
            genus: "Mouse Pokémon",
            formsCount: 1
        )
        
        mockNetworkMonitor.isConnected = true
        mockRemoteDataSource.fetchPokemonDescriptionResult = .success(speciesResponse)
        
        // When
        let result = try await repository.fetchPokemonDetails(pokemon: pokemon)
        
        // Then
        XCTAssertEqual(result.id, pokemon.id)
        XCTAssertEqual(result.name, pokemon.name)
        XCTAssertEqual(result.description, speciesResponse.flavorText)
        XCTAssertEqual(result.species, speciesResponse.genus)
        
        // Verify API call
        XCTAssertEqual(mockRemoteDataSource.fetchPokemonDescriptionCallCount, 1)
        XCTAssertEqual(mockRemoteDataSource.lastFetchPokemonDescriptionName, pokemon.name)
    }
    
    func testFetchPokemonDetailsWithSpecialCharactersInName() async throws {
        // Given
        let pokemon = Pokemon(
            id: 1,
            name: "nidoran-f",
            number: "#029",
            types: ["Poison"],
            imageData: nil,
            height: 4,
            weight: 60,
            baseExperience: 112
        )
        let speciesResponse = PokemonSpeciesResponse(
            flavorText: "A poison Pokémon",
            genus: "Poison Pin Pokémon",
            formsCount: 1
        )
        
        mockNetworkMonitor.isConnected = true
        mockRemoteDataSource.fetchPokemonDescriptionResult = .success(speciesResponse)
        
        // When
        let result = try await repository.fetchPokemonDetails(pokemon: pokemon)
        
        // Then
        XCTAssertEqual(result.id, pokemon.id)
        XCTAssertEqual(result.name, pokemon.name)
        XCTAssertEqual(result.description, speciesResponse.flavorText)
        XCTAssertEqual(result.species, speciesResponse.genus)
        
        // Verify API call with special characters
        XCTAssertEqual(mockRemoteDataSource.fetchPokemonDescriptionCallCount, 1)
        XCTAssertEqual(mockRemoteDataSource.lastFetchPokemonDescriptionName, "nidoran-f")
    }
    
    func testFetchPokemonDetailsWithLongDescription() async throws {
        // Given
        let pokemon = TestDataFactory.createPokemon()
        let longDescription = String(repeating: "A", count: 10000)
        let speciesResponse = PokemonSpeciesResponse(
            flavorText: longDescription,
            genus: "Mouse Pokémon",
            formsCount: 1
        )
        
        mockNetworkMonitor.isConnected = true
        mockRemoteDataSource.fetchPokemonDescriptionResult = .success(speciesResponse)
        
        // When
        let result = try await repository.fetchPokemonDetails(pokemon: pokemon)
        
        // Then
        XCTAssertEqual(result.description, longDescription)
        
        // Verify cache save with long description
        XCTAssertEqual(mockCacheService.savePokemonDetailsCallCount, 1)
        XCTAssertNotNil(mockCacheService.lastSavePokemonDetails)
        XCTAssertEqual(mockCacheService.lastSavePokemonDetails?.pokemonDescription, longDescription)
    }
    
    func testFetchPokemonDetailsWithMultipleForms() async throws {
        // Given
        let pokemon = TestDataFactory.createPokemon()
        let speciesResponse = PokemonSpeciesResponse(
            flavorText: "A mouse Pokémon",
            genus: "Mouse Pokémon",
            formsCount: 5
        )
        
        mockNetworkMonitor.isConnected = true
        mockRemoteDataSource.fetchPokemonDescriptionResult = .success(speciesResponse)
        
        // When
        let result = try await repository.fetchPokemonDetails(pokemon: pokemon)
        
        // Then
        XCTAssertEqual(result.formsCount, 5)
        
        // Verify cache save
        XCTAssertEqual(mockCacheService.savePokemonDetailsCallCount, 1)
        XCTAssertEqual(mockCacheService.lastSavePokemonDetails?.formsCount, 5)
    }
    
    // MARK: - Error Handling Tests
    
    func testFetchPokemonDetailsWithDecodingError() async throws {
        // Given
        let pokemon = TestDataFactory.createPokemon()
        let cachedDetails = PokemonDetails(
            id: pokemon.id,
            name: pokemon.name,
            description: "Cached description",
            weight: pokemon.weight,
            height: pokemon.height,
            baseExperience: pokemon.baseExperience,
            species: "Cached species",
            types: pokemon.types,
            formsCount: 1
        )
        
        mockNetworkMonitor.isConnected = true
        mockRemoteDataSource.fetchPokemonDescriptionResult = .failure(PokemonError.decodingError(DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Test error"))))
        mockCacheService.fetchPokemonDetailsFromCacheResult = .success(cachedDetails)
        
        // When
        let result = try await repository.fetchPokemonDetails(pokemon: pokemon)
        
        // Then
        XCTAssertEqual(result.id, cachedDetails.id)
        XCTAssertEqual(result.description, cachedDetails.description)
        
        // Verify API call was attempted
        XCTAssertEqual(mockRemoteDataSource.fetchPokemonDescriptionCallCount, 1)
        
        // Verify cache fallback
        XCTAssertEqual(mockCacheService.fetchPokemonDetailsFromCacheCallCount, 1)
    }
    
    func testFetchPokemonDetailsWithServerError() async throws {
        // Given
        let pokemon = TestDataFactory.createPokemon()
        let cachedDetails = PokemonDetails(
            id: pokemon.id,
            name: pokemon.name,
            description: "Cached description",
            weight: pokemon.weight,
            height: pokemon.height,
            baseExperience: pokemon.baseExperience,
            species: "Cached species",
            types: pokemon.types,
            formsCount: 1
        )
        
        mockNetworkMonitor.isConnected = true
        mockRemoteDataSource.fetchPokemonDescriptionResult = .failure(PokemonError.serverError(500))
        mockCacheService.fetchPokemonDetailsFromCacheResult = .success(cachedDetails)
        
        // When
        let result = try await repository.fetchPokemonDetails(pokemon: pokemon)
        
        // Then
        XCTAssertEqual(result.id, cachedDetails.id)
        XCTAssertEqual(result.description, cachedDetails.description)
        
        // Verify API call was attempted
        XCTAssertEqual(mockRemoteDataSource.fetchPokemonDescriptionCallCount, 1)
        
        // Verify cache fallback
        XCTAssertEqual(mockCacheService.fetchPokemonDetailsFromCacheCallCount, 1)
    }
    
    func testFetchPokemonDetailsWithTimeoutError() async throws {
        // Given
        let pokemon = TestDataFactory.createPokemon()
        let cachedDetails = PokemonDetails(
            id: pokemon.id,
            name: pokemon.name,
            description: "Cached description",
            weight: pokemon.weight,
            height: pokemon.height,
            baseExperience: pokemon.baseExperience,
            species: "Cached species",
            types: pokemon.types,
            formsCount: 1
        )
        
        mockNetworkMonitor.isConnected = true
        mockRemoteDataSource.fetchPokemonDescriptionResult = .failure(PokemonError.timeout)
        mockCacheService.fetchPokemonDetailsFromCacheResult = .success(cachedDetails)
        
        // When
        let result = try await repository.fetchPokemonDetails(pokemon: pokemon)
        
        // Then
        XCTAssertEqual(result.id, cachedDetails.id)
        XCTAssertEqual(result.description, cachedDetails.description)
        
        // Verify API call was attempted
        XCTAssertEqual(mockRemoteDataSource.fetchPokemonDescriptionCallCount, 1)
        
        // Verify cache fallback
        XCTAssertEqual(mockCacheService.fetchPokemonDetailsFromCacheCallCount, 1)
    }
}