//
//  PokemonListViewModelTests.swift
//  UbiquitiHATests
//
//  Created by Ivannikov Georgiy on 05.10.2025.
//

import XCTest
@testable import UbiquitiHA

final class PokemonListViewModelTests: XCTestCase {
    
    private var viewModel: PokemonListViewModel!
    private var mockUseCase: MockLoadPokemonsUseCase!
    private var mockNetworkMonitor: MockNetworkMonitor!
    
    override func setUp() {
        super.setUp()
        mockUseCase = MockLoadPokemonsUseCase()
        mockNetworkMonitor = MockNetworkMonitor()
        
        // Register mocks in DI container
        DIContainer.shared.register(LoadPokemonsUseCaseProtocol.self) {
            self.mockUseCase
        }
        DIContainer.shared.register(NetworkMonitorProtocol.self) {
            self.mockNetworkMonitor
        }
        
        viewModel = PokemonListViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        mockUseCase = nil
        mockNetworkMonitor = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        // Then
        XCTAssertEqual(viewModel.pokemons.count, 0)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.isConnected)
        XCTAssertFalse(viewModel.showNetworkStatus)
        XCTAssertEqual(viewModel.networkStatusMessage, "")
    }
    
    func testInitializationWithConnectedNetwork() {
        // Given
        mockNetworkMonitor.isConnected = true
        
        // When
        let connectedViewModel = PokemonListViewModel()
        
        // Then
        XCTAssertTrue(connectedViewModel.isConnected)
    }
    
    func testInitializationWithDisconnectedNetwork() {
        // Given
        mockNetworkMonitor.isConnected = false
        
        // When
        let disconnectedViewModel = PokemonListViewModel()
        
        // Then
        XCTAssertFalse(disconnectedViewModel.isConnected)
    }
    
    // MARK: - Load Next Page Success Tests
    
    func testLoadNextPageWithSuccess() async {
        // Given
        let expectedPokemons = TestDataFactory.createMultiplePokemons(count: 3)
        mockUseCase.executeResult = .success(expectedPokemons)
        mockNetworkMonitor.isConnected = true
        
        // When
        await viewModel.loadNextPage()
        
        // Then
        XCTAssertEqual(viewModel.pokemons.count, 3)
        XCTAssertEqual(viewModel.pokemons[0].id, expectedPokemons[0].id)
        XCTAssertEqual(viewModel.pokemons[0].name, expectedPokemons[0].name)
        XCTAssertEqual(viewModel.pokemons[1].id, expectedPokemons[1].id)
        XCTAssertEqual(viewModel.pokemons[1].name, expectedPokemons[1].name)
        XCTAssertEqual(viewModel.pokemons[2].id, expectedPokemons[2].id)
        XCTAssertEqual(viewModel.pokemons[2].name, expectedPokemons[2].name)
        XCTAssertNil(viewModel.errorMessage)
        
        // Verify use case call
        XCTAssertEqual(mockUseCase.executeCallCount, 1)
        XCTAssertEqual(mockUseCase.lastExecuteOffset, 0)
        XCTAssertEqual(mockUseCase.lastExecuteLimit, 30)
    }
    
    func testLoadNextPageWithEmptyResult() async {
        // Given
        let expectedPokemons: [Pokemon] = []
        mockUseCase.executeResult = .success(expectedPokemons)
        mockNetworkMonitor.isConnected = true
        
        // When
        await viewModel.loadNextPage()
        
        // Then
        XCTAssertEqual(viewModel.pokemons.count, 0)
        XCTAssertNil(viewModel.errorMessage)
        
        // Verify use case call
        XCTAssertEqual(mockUseCase.executeCallCount, 1)
    }
    
    func testLoadNextPageWithLargeResult() async {
        // Given
        let expectedPokemons = TestDataFactory.createMultiplePokemons(count: 100)
        mockUseCase.executeResult = .success(expectedPokemons)
        mockNetworkMonitor.isConnected = true
        
        // When
        await viewModel.loadNextPage()
        
        // Then
        XCTAssertEqual(viewModel.pokemons.count, 100)
        XCTAssertEqual(viewModel.pokemons[0].id, expectedPokemons[0].id)
        XCTAssertEqual(viewModel.pokemons[99].id, expectedPokemons[99].id)
        XCTAssertNil(viewModel.errorMessage)
        
        // Verify use case call
        XCTAssertEqual(mockUseCase.executeCallCount, 1)
    }
    
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
    
    // Etc
}
