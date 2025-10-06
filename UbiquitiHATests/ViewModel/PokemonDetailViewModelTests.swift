//
//  PokemonDetailViewModelTests.swift
//  UbiquitiHATests
//
//  Created by Ivannikov Georgiy on 05.10.2025.
//

import XCTest
import SwiftUI
@testable import UbiquitiHA

final class PokemonDetailViewModelTests: XCTestCase {
    
    private var viewModel: PokemonDetailViewModel!
    private var mockUseCase: MockLoadPokemonDescriptionUseCase!
    private var pokemon: Pokemon!
    
    override func setUp() {
        super.setUp()
        pokemon = TestDataFactory.createPokemon()
        mockUseCase = MockLoadPokemonDescriptionUseCase()
        
        // Register mock in DI container
        DIContainer.shared.register(LoadPokemonDescriptionUseCaseProtocol.self) {
            self.mockUseCase
        }
        
        viewModel = PokemonDetailViewModel(pokemon: pokemon)
    }
    
    override func tearDown() {
        viewModel = nil
        mockUseCase = nil
        pokemon = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        // Then
        XCTAssertEqual(viewModel.details.id, 0)
        XCTAssertEqual(viewModel.details.name, "")
        XCTAssertEqual(viewModel.details.description, "")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.backgroundColor, pokemon.backgroundColor)
    }
    
    func testInitializationWithDifferentPokemon() {
        // Given
        let differentPokemon = TestDataFactory.createPokemon(id: 2, name: "Charmander")
        
        // When
        let differentViewModel = PokemonDetailViewModel(pokemon: differentPokemon)
        
        // Then
        XCTAssertEqual(differentViewModel.backgroundColor, differentPokemon.backgroundColor)
    }
    
    // MARK: - Load Success Tests
    
    func testLoadWithSuccess() async {
        // Given
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
        
        mockUseCase.executeResult = .success(expectedDetails)
        
        // When
        await viewModel.load()
        
        // Then
        XCTAssertEqual(viewModel.details.id, expectedDetails.id)
        XCTAssertEqual(viewModel.details.name, expectedDetails.name)
        XCTAssertEqual(viewModel.details.description, expectedDetails.description)
        XCTAssertEqual(viewModel.details.species, expectedDetails.species)
        XCTAssertEqual(viewModel.details.types, expectedDetails.types)
        XCTAssertEqual(viewModel.details.weight, expectedDetails.weight)
        XCTAssertEqual(viewModel.details.height, expectedDetails.height)
        XCTAssertEqual(viewModel.details.baseExperience, expectedDetails.baseExperience)
        XCTAssertEqual(viewModel.details.formsCount, expectedDetails.formsCount)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        
        // Verify use case call
        XCTAssertEqual(mockUseCase.executeCallCount, 1)
        XCTAssertEqual(mockUseCase.lastExecutePokemon?.id, pokemon.id)
    }
    
    func testLoadWithEmptyDetails() async {
        // Given
        let emptyDetails = PokemonDetails()
        
        mockUseCase.executeResult = .success(emptyDetails)
        
        // When
        await viewModel.load()
        
        // Then
        XCTAssertEqual(viewModel.details.id, 0)
        XCTAssertEqual(viewModel.details.name, "")
        XCTAssertEqual(viewModel.details.description, "")
        XCTAssertNil(viewModel.errorMessage)
        
        // Verify use case call
        XCTAssertEqual(mockUseCase.executeCallCount, 1)
    }
    
    func testLoadWithLongDescription() async {
        // Given
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
        
        mockUseCase.executeResult = .success(expectedDetails)
        
        // When
        await viewModel.load()
        
        // Then
        XCTAssertEqual(viewModel.details.description, longDescription)
        XCTAssertNil(viewModel.errorMessage)
        
        // Verify use case call
        XCTAssertEqual(mockUseCase.executeCallCount, 1)
    }
    
    func testLoadWithSpecialCharacters() async {
        // Given
        let pokemonWithSpecialName = TestDataFactory.createPokemon(name: "nidoran-f")
        // Register mock in DI container
        DIContainer.shared.register(LoadPokemonDescriptionUseCaseProtocol.self) {
            self.mockUseCase
        }
        
        let viewModelWithSpecialName = PokemonDetailViewModel(pokemon: pokemonWithSpecialName)
        
        let expectedDetails = PokemonDetails(
            id: pokemonWithSpecialName.id,
            name: pokemonWithSpecialName.name,
            description: "A poison Pokémon",
            weight: pokemonWithSpecialName.weight,
            height: pokemonWithSpecialName.height,
            baseExperience: pokemonWithSpecialName.baseExperience,
            species: "Poison Pin Pokémon",
            types: pokemonWithSpecialName.types,
            formsCount: 1
        )
        
        mockUseCase.executeResult = .success(expectedDetails)
        
        // When
        await viewModelWithSpecialName.load()
        
        // Then
        XCTAssertEqual(viewModelWithSpecialName.details.name, "nidoran-f")
        XCTAssertEqual(viewModelWithSpecialName.details.description, "A poison Pokémon")
        XCTAssertEqual(viewModelWithSpecialName.details.species, "Poison Pin Pokémon")
        XCTAssertNil(viewModelWithSpecialName.errorMessage)
        
        // Verify use case call
        XCTAssertEqual(mockUseCase.executeCallCount, 1)
        XCTAssertEqual(mockUseCase.lastExecutePokemon?.name, "nidoran-f")
    }
    
    // MARK: - Load Error Tests
    
    func testLoadWithNoCacheError() async {
        // Given
        mockUseCase.executeResult = .failure(PokemonError.noCache)
        
        // When
        await viewModel.load()
        
        // Then
        XCTAssertEqual(viewModel.details.id, 0)
        XCTAssertEqual(viewModel.details.name, "")
        XCTAssertEqual(viewModel.details.description, "")
        XCTAssertNotNil(viewModel.errorMessage)
        
        // Verify use case call
        XCTAssertEqual(mockUseCase.executeCallCount, 1)
    }
    
    func testLoadWithNetworkError() async {
        // Given
        mockUseCase.executeResult = .failure(PokemonError.networkError(URLError(.notConnectedToInternet)))
        
        // When
        await viewModel.load()
        
        // Then
        XCTAssertEqual(viewModel.details.id, 0)
        XCTAssertEqual(viewModel.details.name, "")
        XCTAssertEqual(viewModel.details.description, "")
        XCTAssertNotNil(viewModel.errorMessage)
        
        // Verify use case call
        XCTAssertEqual(mockUseCase.executeCallCount, 1)
    }
    
    // MARK: - Loading State Tests
    
    func testLoadSetsLoadingState() async {
        // Given
        let expectation = XCTestExpectation(description: "Loading state changes")
        mockUseCase.executeResult = .success(PokemonDetails())
        
        // When
        Task {
            await viewModel.load()
            expectation.fulfill()
        }
        
        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(mockUseCase.executeCallCount, 1)
    }
    
    // MARK: - Error Message Tests
    
    func testErrorMessageCanBeSet() {
        // Given
        let errorMessage = "Test error message"
        
        // When
        viewModel.errorMessage = errorMessage
        
        // Then
        XCTAssertEqual(viewModel.errorMessage, errorMessage)
    }
    
    func testErrorMessageCanBeCleared() {
        // Given
        viewModel.errorMessage = "Test error message"
        
        // When
        viewModel.errorMessage = nil
        
        // Then
        XCTAssertNil(viewModel.errorMessage)
    }
    
    // MARK: - Background Color Tests
    
    func testBackgroundColor() {
        // Given
        let pokemon = TestDataFactory.createPokemon()
        let viewModel = PokemonDetailViewModel(pokemon: pokemon)
        
        // Then
        XCTAssertEqual(viewModel.backgroundColor, pokemon.backgroundColor)
    }
    
    func testBackgroundColorWithDifferentPokemon() {
        // Given
        let pokemon1 = TestDataFactory.createPokemon(id: 1, name: "Pikachu")
        let pokemon2 = TestDataFactory.createPokemon(id: 2, name: "Charmander")
        let viewModel1 = PokemonDetailViewModel(pokemon: pokemon1)
        let viewModel2 = PokemonDetailViewModel(pokemon: pokemon2)
        
        // Then
        XCTAssertEqual(viewModel1.backgroundColor, pokemon1.backgroundColor)
        XCTAssertEqual(viewModel2.backgroundColor, pokemon2.backgroundColor)
    }
    
    // MARK: - Edge Cases
    
    func testLoadWithZeroIdPokemon() async {
        // Given
        let zeroIdPokemon = Pokemon(id: 0)
        // Register mock in DI container
        DIContainer.shared.register(LoadPokemonDescriptionUseCaseProtocol.self) {
            self.mockUseCase
        }
        
        let viewModel = PokemonDetailViewModel(pokemon: zeroIdPokemon)
        
        let expectedDetails = PokemonDetails(
            id: zeroIdPokemon.id,
            name: zeroIdPokemon.name,
            description: "A mouse Pokémon",
            weight: zeroIdPokemon.weight,
            height: zeroIdPokemon.height,
            baseExperience: zeroIdPokemon.baseExperience,
            species: "Mouse Pokémon",
            types: zeroIdPokemon.types,
            formsCount: 1
        )
        
        mockUseCase.executeResult = .success(expectedDetails)
        
        // When
        await viewModel.load()
        
        // Then
        XCTAssertEqual(viewModel.details.id, 0)
        XCTAssertEqual(viewModel.details.name, "")
        XCTAssertEqual(viewModel.details.description, "A mouse Pokémon")
        XCTAssertNil(viewModel.errorMessage)
        
        // Verify use case call
        XCTAssertEqual(mockUseCase.executeCallCount, 1)
        XCTAssertEqual(mockUseCase.lastExecutePokemon?.id, 0)
    }
    
    func testLoadWithNegativeIdPokemon() async {
        // Given
        let negativeIdPokemon = Pokemon(id: -1)
        // Register mock in DI container
        DIContainer.shared.register(LoadPokemonDescriptionUseCaseProtocol.self) {
            self.mockUseCase
        }
        
        let viewModel = PokemonDetailViewModel(pokemon: negativeIdPokemon)
        
        let expectedDetails = PokemonDetails(
            id: negativeIdPokemon.id,
            name: negativeIdPokemon.name,
            description: "A mouse Pokémon",
            weight: negativeIdPokemon.weight,
            height: negativeIdPokemon.height,
            baseExperience: negativeIdPokemon.baseExperience,
            species: "Mouse Pokémon",
            types: negativeIdPokemon.types,
            formsCount: 1
        )
        
        mockUseCase.executeResult = .success(expectedDetails)
        
        // When
        await viewModel.load()
        
        // Then
        XCTAssertEqual(viewModel.details.id, -1)
        XCTAssertEqual(viewModel.details.name, "")
        XCTAssertEqual(viewModel.details.description, "A mouse Pokémon")
        XCTAssertNil(viewModel.errorMessage)
        
        // Verify use case call
        XCTAssertEqual(mockUseCase.executeCallCount, 1)
        XCTAssertEqual(mockUseCase.lastExecutePokemon?.id, -1)
    }
    
    func testLoadWithLargeIdPokemon() async {
        // Given
        let largeIdPokemon = Pokemon(id: Int.max)
        // Register mock in DI container
        DIContainer.shared.register(LoadPokemonDescriptionUseCaseProtocol.self) {
            self.mockUseCase
        }
        
        let viewModel = PokemonDetailViewModel(pokemon: largeIdPokemon)
        
        let expectedDetails = PokemonDetails(
            id: largeIdPokemon.id,
            name: largeIdPokemon.name,
            description: "A mouse Pokémon",
            weight: largeIdPokemon.weight,
            height: largeIdPokemon.height,
            baseExperience: largeIdPokemon.baseExperience,
            species: "Mouse Pokémon",
            types: largeIdPokemon.types,
            formsCount: 1
        )
        
        mockUseCase.executeResult = .success(expectedDetails)
        
        // When
        await viewModel.load()
        
        // Then
        XCTAssertEqual(viewModel.details.id, Int.max)
        XCTAssertEqual(viewModel.details.name, "")
        XCTAssertEqual(viewModel.details.description, "A mouse Pokémon")
        XCTAssertNil(viewModel.errorMessage)
        
        // Verify use case call
        XCTAssertEqual(mockUseCase.executeCallCount, 1)
        XCTAssertEqual(mockUseCase.lastExecutePokemon?.id, Int.max)
    }
}
