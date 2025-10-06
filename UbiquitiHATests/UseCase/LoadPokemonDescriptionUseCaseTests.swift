//
//  LoadPokemonDescriptionUseCaseTests.swift
//  UbiquitiHATests
//
//  Created by Ivannikov Georgiy on 05.10.2025.
//

import XCTest
@testable import UbiquitiHA

final class LoadPokemonDescriptionUseCaseTests: XCTestCase {
    
    private var useCase: LoadPokemonDescriptionUseCase!
    private var mockRepository: MockPokemonDetailsRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockPokemonDetailsRepository()
        useCase = LoadPokemonDescriptionUseCase(repository: mockRepository)
    }
    
    override func tearDown() {
        useCase = nil
        mockRepository = nil
        super.tearDown()
    }
    
    // MARK: - Success Tests
    
    func testExecuteWithSuccess() async throws {
        // Given
        let pokemon = TestDataFactory.createPokemon()
        let expectedDetails = PokemonDetails(
            id: pokemon.id,
            name: pokemon.name,
            description: "A mouse Pokémon",
            weight: pokemon.weight,
            height: pokemon.height,
            baseExperience: pokemon.baseExperience,
            species: "Mouse Pokémon",
            types: pokemon.types,
            formsCount: 1
        )
        
        mockRepository.fetchPokemonDetailsResult = Result<PokemonDetails, Error>.success(expectedDetails)
        
        // When
        let result = try await useCase.execute(pokemon: pokemon)
        
        // Then
        XCTAssertEqual(result.id, expectedDetails.id)
        XCTAssertEqual(result.name, expectedDetails.name)
        XCTAssertEqual(result.description, expectedDetails.description)
        XCTAssertEqual(result.species, expectedDetails.species)
        XCTAssertEqual(result.types, expectedDetails.types)
        XCTAssertEqual(result.weight, expectedDetails.weight)
        XCTAssertEqual(result.height, expectedDetails.height)
        XCTAssertEqual(result.baseExperience, expectedDetails.baseExperience)
        XCTAssertEqual(result.formsCount, expectedDetails.formsCount)
        
        // Verify repository call
        XCTAssertEqual(mockRepository.fetchPokemonDetailsCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchPokemonDetailsPokemon?.id, pokemon.id)
        XCTAssertEqual(mockRepository.lastFetchPokemonDetailsPokemon?.name, pokemon.name)
    }
    
    func testExecuteWithEmptyPokemon() async throws {
        // Given
        let pokemon = Pokemon(id: 0)
        let expectedDetails = PokemonDetails(
            id: pokemon.id,
            name: pokemon.name,
            description: "A mouse Pokémon",
            weight: pokemon.weight,
            height: pokemon.height,
            baseExperience: pokemon.baseExperience,
            species: "Mouse Pokémon",
            types: pokemon.types,
            formsCount: 1
        )
        
        mockRepository.fetchPokemonDetailsResult = Result<PokemonDetails, Error>.success(expectedDetails)
        
        // When
        let result = try await useCase.execute(pokemon: pokemon)
        
        // Then
        XCTAssertEqual(result.id, expectedDetails.id)
        XCTAssertEqual(result.name, expectedDetails.name)
        XCTAssertEqual(result.description, expectedDetails.description)
        
        // Verify repository call
        XCTAssertEqual(mockRepository.fetchPokemonDetailsCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchPokemonDetailsPokemon?.id, pokemon.id)
    }
    
    func testExecuteWithSpecialCharactersInName() async throws {
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
        let expectedDetails = PokemonDetails(
            id: pokemon.id,
            name: pokemon.name,
            description: "A poison Pokémon",
            weight: pokemon.weight,
            height: pokemon.height,
            baseExperience: pokemon.baseExperience,
            species: "Poison Pin Pokémon",
            types: pokemon.types,
            formsCount: 1
        )
        
        mockRepository.fetchPokemonDetailsResult = Result<PokemonDetails, Error>.success(expectedDetails)
        
        // When
        let result = try await useCase.execute(pokemon: pokemon)
        
        // Then
        XCTAssertEqual(result.id, expectedDetails.id)
        XCTAssertEqual(result.name, expectedDetails.name)
        XCTAssertEqual(result.description, expectedDetails.description)
        XCTAssertEqual(result.species, expectedDetails.species)
        
        // Verify repository call
        XCTAssertEqual(mockRepository.fetchPokemonDetailsCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchPokemonDetailsPokemon?.id, pokemon.id)
        XCTAssertEqual(mockRepository.lastFetchPokemonDetailsPokemon?.name, "nidoran-f")
    }
    
    func testExecuteWithLongDescription() async throws {
        // Given
        let pokemon = TestDataFactory.createPokemon()
        let longDescription = String(repeating: "A", count: 10000)
        let expectedDetails = PokemonDetails(
            id: pokemon.id,
            name: pokemon.name,
            description: longDescription,
            weight: pokemon.weight,
            height: pokemon.height,
            baseExperience: pokemon.baseExperience,
            species: "Mouse Pokémon",
            types: pokemon.types,
            formsCount: 1
        )
        
        mockRepository.fetchPokemonDetailsResult = Result<PokemonDetails, Error>.success(expectedDetails)
        
        // When
        let result = try await useCase.execute(pokemon: pokemon)
        
        // Then
        XCTAssertEqual(result.description, longDescription)
        
        // Verify repository call
        XCTAssertEqual(mockRepository.fetchPokemonDetailsCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchPokemonDetailsPokemon?.id, pokemon.id)
    }
    
    func testExecuteWithMultipleForms() async throws {
        // Given
        let pokemon = TestDataFactory.createPokemon()
        let expectedDetails = PokemonDetails(
            id: pokemon.id,
            name: pokemon.name,
            description: "A mouse Pokémon",
            weight: pokemon.weight,
            height: pokemon.height,
            baseExperience: pokemon.baseExperience,
            species: "Mouse Pokémon",
            types: pokemon.types,
            formsCount: 5
        )
        
        mockRepository.fetchPokemonDetailsResult = Result<PokemonDetails, Error>.success(expectedDetails)
        
        // When
        let result = try await useCase.execute(pokemon: pokemon)
        
        // Then
        XCTAssertEqual(result.formsCount, 5)
        
        // Verify repository call
        XCTAssertEqual(mockRepository.fetchPokemonDetailsCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchPokemonDetailsPokemon?.id, pokemon.id)
    }
    
    // MARK: - Error Tests
    
    func testExecuteWithNoCacheError() async {
        // Given
        let pokemon = TestDataFactory.createPokemon()
        
        mockRepository.fetchPokemonDetailsResult = Result<PokemonDetails, Error>.failure(PokemonError.noCache)
        
        // When & Then
        do {
            _ = try await useCase.execute(pokemon: pokemon)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is PokemonError)
            if case PokemonError.noCache = error {
                // Expected error
            } else {
                XCTFail("Expected noCache error")
            }
        }
        
        // Verify repository call
        XCTAssertEqual(mockRepository.fetchPokemonDetailsCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchPokemonDetailsPokemon?.id, pokemon.id)
    }
    
    func testExecuteWithNetworkError() async {
        // Given
        let pokemon = TestDataFactory.createPokemon()
        
        mockRepository.fetchPokemonDetailsResult = Result<PokemonDetails, Error>.failure(PokemonError.networkError(URLError(.notConnectedToInternet)))
        
        // When & Then
        do {
            _ = try await useCase.execute(pokemon: pokemon)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is PokemonError)
            if case PokemonError.networkError = error {
                // Expected error
            } else {
                XCTFail("Expected networkError")
            }
        }
        
        // Verify repository call
        XCTAssertEqual(mockRepository.fetchPokemonDetailsCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchPokemonDetailsPokemon?.id, pokemon.id)
    }
    
    func testExecuteWithServerError() async {
        // Given
        let pokemon = TestDataFactory.createPokemon()
        
        mockRepository.fetchPokemonDetailsResult = Result<PokemonDetails, Error>.failure(PokemonError.serverError(500))
        
        // When & Then
        do {
            _ = try await useCase.execute(pokemon: pokemon)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is PokemonError)
            if case PokemonError.serverError = error {
                // Expected error
            } else {
                XCTFail("Expected serverError")
            }
        }
        
        // Verify repository call
        XCTAssertEqual(mockRepository.fetchPokemonDetailsCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchPokemonDetailsPokemon?.id, pokemon.id)
    }
    
    func testExecuteWithTimeoutError() async {
        // Given
        let pokemon = TestDataFactory.createPokemon()
        
        mockRepository.fetchPokemonDetailsResult = Result<PokemonDetails, Error>.failure(PokemonError.timeout)
        
        // When & Then
        do {
            _ = try await useCase.execute(pokemon: pokemon)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is PokemonError)
            if case PokemonError.timeout = error {
                // Expected error
            } else {
                XCTFail("Expected timeout error")
            }
        }
        
        // Verify repository call
        XCTAssertEqual(mockRepository.fetchPokemonDetailsCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchPokemonDetailsPokemon?.id, pokemon.id)
    }
    
    func testExecuteWithDecodingError() async {
        // Given
        let pokemon = TestDataFactory.createPokemon()
        
        mockRepository.fetchPokemonDetailsResult = Result<PokemonDetails, Error>.failure(PokemonError.decodingError(DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Test error"))))
        
        // When & Then
        do {
            _ = try await useCase.execute(pokemon: pokemon)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is PokemonError)
            if case PokemonError.decodingError = error {
                // Expected error
            } else {
                XCTFail("Expected decodingError")
            }
        }
        
        // Verify repository call
        XCTAssertEqual(mockRepository.fetchPokemonDetailsCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchPokemonDetailsPokemon?.id, pokemon.id)
    }
    
    func testExecuteWithUnknownError() async {
        // Given
        let pokemon = TestDataFactory.createPokemon()
        
        mockRepository.fetchPokemonDetailsResult = Result<PokemonDetails, Error>.failure(PokemonError.unknown)
        
        // When & Then
        do {
            _ = try await useCase.execute(pokemon: pokemon)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is PokemonError)
            if case PokemonError.unknown = error {
                // Expected error
            } else {
                XCTFail("Expected unknown error")
            }
        }
        
        // Verify repository call
        XCTAssertEqual(mockRepository.fetchPokemonDetailsCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchPokemonDetailsPokemon?.id, pokemon.id)
    }
    
    // MARK: - Edge Cases
    
    func testExecuteWithZeroId() async throws {
        // Given
        let pokemon = Pokemon(id: 0)
        let expectedDetails = PokemonDetails(
            id: pokemon.id,
            name: pokemon.name,
            description: "A mouse Pokémon",
            weight: pokemon.weight,
            height: pokemon.height,
            baseExperience: pokemon.baseExperience,
            species: "Mouse Pokémon",
            types: pokemon.types,
            formsCount: 1
        )
        
        mockRepository.fetchPokemonDetailsResult = Result<PokemonDetails, Error>.success(expectedDetails)
        
        // When
        let result = try await useCase.execute(pokemon: pokemon)
        
        // Then
        XCTAssertEqual(result.id, 0)
        XCTAssertEqual(result.name, "")
        XCTAssertEqual(result.description, expectedDetails.description)
        
        // Verify repository call
        XCTAssertEqual(mockRepository.fetchPokemonDetailsCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchPokemonDetailsPokemon?.id, 0)
    }
    
    func testExecuteWithNegativeId() async throws {
        // Given
        let pokemon = Pokemon(id: -1)
        let expectedDetails = PokemonDetails(
            id: pokemon.id,
            name: pokemon.name,
            description: "A mouse Pokémon",
            weight: pokemon.weight,
            height: pokemon.height,
            baseExperience: pokemon.baseExperience,
            species: "Mouse Pokémon",
            types: pokemon.types,
            formsCount: 1
        )
        
        mockRepository.fetchPokemonDetailsResult = Result<PokemonDetails, Error>.success(expectedDetails)
        
        // When
        let result = try await useCase.execute(pokemon: pokemon)
        
        // Then
        XCTAssertEqual(result.id, -1)
        XCTAssertEqual(result.name, "")
        XCTAssertEqual(result.description, expectedDetails.description)
        
        // Verify repository call
        XCTAssertEqual(mockRepository.fetchPokemonDetailsCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchPokemonDetailsPokemon?.id, -1)
    }
    
    func testExecuteWithLargeId() async throws {
        // Given
        let pokemon = Pokemon(id: Int.max)
        let expectedDetails = PokemonDetails(
            id: pokemon.id,
            name: pokemon.name,
            description: "A mouse Pokémon",
            weight: pokemon.weight,
            height: pokemon.height,
            baseExperience: pokemon.baseExperience,
            species: "Mouse Pokémon",
            types: pokemon.types,
            formsCount: 1
        )
        
        mockRepository.fetchPokemonDetailsResult = Result<PokemonDetails, Error>.success(expectedDetails)
        
        // When
        let result = try await useCase.execute(pokemon: pokemon)
        
        // Then
        XCTAssertEqual(result.id, Int.max)
        XCTAssertEqual(result.name, "")
        XCTAssertEqual(result.description, expectedDetails.description)
        
        // Verify repository call
        XCTAssertEqual(mockRepository.fetchPokemonDetailsCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchPokemonDetailsPokemon?.id, Int.max)
    }
    
    // MARK: - Multiple Calls Tests
    
    func testExecuteMultipleTimes() async throws {
        // Given
        let pokemon1 = TestDataFactory.createPokemon(id: 1, name: "Pikachu")
        let pokemon2 = TestDataFactory.createPokemon(id: 2, name: "Charmander")
        let expectedDetails1 = PokemonDetails(
            id: pokemon1.id,
            name: pokemon1.name,
            description: "A mouse Pokémon",
            weight: pokemon1.weight,
            height: pokemon1.height,
            baseExperience: pokemon1.baseExperience,
            species: "Mouse Pokémon",
            types: pokemon1.types,
            formsCount: 1
        )
        let expectedDetails2 = PokemonDetails(
            id: pokemon2.id,
            name: pokemon2.name,
            description: "A lizard Pokémon",
            weight: pokemon2.weight,
            height: pokemon2.height,
            baseExperience: pokemon2.baseExperience,
            species: "Lizard Pokémon",
            types: pokemon2.types,
            formsCount: 1
        )
        
        mockRepository.fetchPokemonDetailsResult = .success(expectedDetails1)
        
        // When
        let result1 = try await useCase.execute(pokemon: pokemon1)
        
        // Then
        XCTAssertEqual(result1.id, expectedDetails1.id)
        XCTAssertEqual(result1.name, expectedDetails1.name)
        XCTAssertEqual(result1.description, expectedDetails1.description)
        XCTAssertEqual(mockRepository.fetchPokemonDetailsCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchPokemonDetailsPokemon?.id, pokemon1.id)
        
        // Given
        mockRepository.fetchPokemonDetailsResult = .success(expectedDetails2)
        
        // When
        let result2 = try await useCase.execute(pokemon: pokemon2)
        
        // Then
        XCTAssertEqual(result2.id, expectedDetails2.id)
        XCTAssertEqual(result2.name, expectedDetails2.name)
        XCTAssertEqual(result2.description, expectedDetails2.description)
        XCTAssertEqual(mockRepository.fetchPokemonDetailsCallCount, 2)
        XCTAssertEqual(mockRepository.lastFetchPokemonDetailsPokemon?.id, pokemon2.id)
    }
}
