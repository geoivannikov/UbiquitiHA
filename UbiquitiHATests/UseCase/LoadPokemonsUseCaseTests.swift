//
//  LoadPokemonsUseCaseTests.swift
//  UbiquitiHATests
//
//  Created by Ivannikov Georgiy on 05.10.2025.
//

import XCTest
@testable import UbiquitiHA

final class LoadPokemonsUseCaseTests: XCTestCase {
    
    private var useCase: LoadPokemonsUseCase!
    private var mockRepository: MockPokemonListRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockPokemonListRepository()
        useCase = LoadPokemonsUseCase(repository: mockRepository)
    }
    
    override func tearDown() {
        useCase = nil
        mockRepository = nil
        super.tearDown()
    }
    
    // MARK: - Success Tests
    
    func testExecuteWithSuccess() async throws {
        // Given
        let offset = 0
        let limit = 20
        let expectedPokemons = TestDataFactory.createMultiplePokemons(count: 3)
        
        mockRepository.fetchPokemonsResult = .success(expectedPokemons)
        
        // When
        let result = try await useCase.execute(offset: offset, limit: limit)
        
        // Then
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0].id, expectedPokemons[0].id)
        XCTAssertEqual(result[0].name, expectedPokemons[0].name)
        XCTAssertEqual(result[1].id, expectedPokemons[1].id)
        XCTAssertEqual(result[1].name, expectedPokemons[1].name)
        XCTAssertEqual(result[2].id, expectedPokemons[2].id)
        XCTAssertEqual(result[2].name, expectedPokemons[2].name)
        
        // Verify repository call
        XCTAssertEqual(mockRepository.fetchPokemonsCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchPokemonsOffset, offset)
        XCTAssertEqual(mockRepository.lastFetchPokemonsLimit, limit)
    }
    
    func testExecuteWithEmptyResult() async throws {
        // Given
        let offset = 0
        let limit = 20
        let expectedPokemons: [Pokemon] = []
        
        mockRepository.fetchPokemonsResult = .success(expectedPokemons)
        
        // When
        let result = try await useCase.execute(offset: offset, limit: limit)
        
        // Then
        XCTAssertEqual(result.count, 0)
        
        // Verify repository call
        XCTAssertEqual(mockRepository.fetchPokemonsCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchPokemonsOffset, offset)
        XCTAssertEqual(mockRepository.lastFetchPokemonsLimit, limit)
    }
    
    func testExecuteWithLargeResult() async throws {
        // Given
        let offset = 0
        let limit = 100
        let expectedPokemons = TestDataFactory.createMultiplePokemons(count: 100)
        
        mockRepository.fetchPokemonsResult = .success(expectedPokemons)
        
        // When
        let result = try await useCase.execute(offset: offset, limit: limit)
        
        // Then
        XCTAssertEqual(result.count, 100)
        XCTAssertEqual(result[0].id, expectedPokemons[0].id)
        XCTAssertEqual(result[99].id, expectedPokemons[99].id)
        
        // Verify repository call
        XCTAssertEqual(mockRepository.fetchPokemonsCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchPokemonsOffset, offset)
        XCTAssertEqual(mockRepository.lastFetchPokemonsLimit, limit)
    }
    
    // MARK: - Error Tests
    
    func testExecuteWithNoCacheError() async {
        // Given
        let offset = 0
        let limit = 20
        
        mockRepository.fetchPokemonsResult = .failure(PokemonError.noCache)
        
        // When & Then
        do {
            _ = try await useCase.execute(offset: offset, limit: limit)
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
        XCTAssertEqual(mockRepository.fetchPokemonsCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchPokemonsOffset, offset)
        XCTAssertEqual(mockRepository.lastFetchPokemonsLimit, limit)
    }
    
    func testExecuteWithNetworkError() async {
        // Given
        let offset = 0
        let limit = 20
        
        mockRepository.fetchPokemonsResult = .failure(PokemonError.networkError(URLError(.notConnectedToInternet)))
        
        // When & Then
        do {
            _ = try await useCase.execute(offset: offset, limit: limit)
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
        XCTAssertEqual(mockRepository.fetchPokemonsCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchPokemonsOffset, offset)
        XCTAssertEqual(mockRepository.lastFetchPokemonsLimit, limit)
    }
    
    func testExecuteWithServerError() async {
        // Given
        let offset = 0
        let limit = 20
        
        mockRepository.fetchPokemonsResult = .failure(PokemonError.serverError(500))
        
        // When & Then
        do {
            _ = try await useCase.execute(offset: offset, limit: limit)
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
        XCTAssertEqual(mockRepository.fetchPokemonsCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchPokemonsOffset, offset)
        XCTAssertEqual(mockRepository.lastFetchPokemonsLimit, limit)
    }
    
    func testExecuteWithTimeoutError() async {
        // Given
        let offset = 0
        let limit = 20
        
        mockRepository.fetchPokemonsResult = .failure(PokemonError.timeout)
        
        // When & Then
        do {
            _ = try await useCase.execute(offset: offset, limit: limit)
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
        XCTAssertEqual(mockRepository.fetchPokemonsCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchPokemonsOffset, offset)
        XCTAssertEqual(mockRepository.lastFetchPokemonsLimit, limit)
    }
    
    func testExecuteWithDecodingError() async {
        // Given
        let offset = 0
        let limit = 20
        
        mockRepository.fetchPokemonsResult = .failure(PokemonError.decodingError(DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Test error"))))
        
        // When & Then
        do {
            _ = try await useCase.execute(offset: offset, limit: limit)
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
        XCTAssertEqual(mockRepository.fetchPokemonsCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchPokemonsOffset, offset)
        XCTAssertEqual(mockRepository.lastFetchPokemonsLimit, limit)
    }
    
    func testExecuteWithUnknownError() async {
        // Given
        let offset = 0
        let limit = 20
        
        mockRepository.fetchPokemonsResult = .failure(PokemonError.unknown)
        
        // When & Then
        do {
            _ = try await useCase.execute(offset: offset, limit: limit)
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
        XCTAssertEqual(mockRepository.fetchPokemonsCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchPokemonsOffset, offset)
        XCTAssertEqual(mockRepository.lastFetchPokemonsLimit, limit)
    }
    
    // MARK: - Edge Cases
    
    func testExecuteWithZeroOffset() async throws {
        // Given
        let offset = 0
        let limit = 20
        let expectedPokemons = TestDataFactory.createMultiplePokemons(count: 3)
        
        mockRepository.fetchPokemonsResult = .success(expectedPokemons)
        
        // When
        let result = try await useCase.execute(offset: offset, limit: limit)
        
        // Then
        XCTAssertEqual(result.count, 3)
        
        // Verify repository call
        XCTAssertEqual(mockRepository.fetchPokemonsCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchPokemonsOffset, 0)
        XCTAssertEqual(mockRepository.lastFetchPokemonsLimit, limit)
    }
    
    func testExecuteWithZeroLimit() async throws {
        // Given
        let offset = 0
        let limit = 0
        let expectedPokemons: [Pokemon] = []
        
        mockRepository.fetchPokemonsResult = .success(expectedPokemons)
        
        // When
        let result = try await useCase.execute(offset: offset, limit: limit)
        
        // Then
        XCTAssertEqual(result.count, 0)
        
        // Verify repository call
        XCTAssertEqual(mockRepository.fetchPokemonsCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchPokemonsOffset, offset)
        XCTAssertEqual(mockRepository.lastFetchPokemonsLimit, 0)
    }
    
    func testExecuteWithLargeOffset() async throws {
        // Given
        let offset = 1000
        let limit = 20
        let expectedPokemons = TestDataFactory.createMultiplePokemons(count: 3)
        
        mockRepository.fetchPokemonsResult = .success(expectedPokemons)
        
        // When
        let result = try await useCase.execute(offset: offset, limit: limit)
        
        // Then
        XCTAssertEqual(result.count, 3)
        
        // Verify repository call
        XCTAssertEqual(mockRepository.fetchPokemonsCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchPokemonsOffset, 1000)
        XCTAssertEqual(mockRepository.lastFetchPokemonsLimit, limit)
    }
    
    func testExecuteWithLargeLimit() async throws {
        // Given
        let offset = 0
        let limit = 1000
        let expectedPokemons = TestDataFactory.createMultiplePokemons(count: 1000)
        
        mockRepository.fetchPokemonsResult = .success(expectedPokemons)
        
        // When
        let result = try await useCase.execute(offset: offset, limit: limit)
        
        // Then
        XCTAssertEqual(result.count, 1000)
        
        // Verify repository call
        XCTAssertEqual(mockRepository.fetchPokemonsCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchPokemonsOffset, offset)
        XCTAssertEqual(mockRepository.lastFetchPokemonsLimit, 1000)
    }
    
    func testExecuteWithNegativeOffset() async throws {
        // Given
        let offset = -1
        let limit = 20
        let expectedPokemons = TestDataFactory.createMultiplePokemons(count: 3)
        
        mockRepository.fetchPokemonsResult = .success(expectedPokemons)
        
        // When
        let result = try await useCase.execute(offset: offset, limit: limit)
        
        // Then
        XCTAssertEqual(result.count, 3)
        
        // Verify repository call
        XCTAssertEqual(mockRepository.fetchPokemonsCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchPokemonsOffset, -1)
        XCTAssertEqual(mockRepository.lastFetchPokemonsLimit, limit)
    }
    
    func testExecuteWithNegativeLimit() async throws {
        // Given
        let offset = 0
        let limit = -1
        let expectedPokemons = TestDataFactory.createMultiplePokemons(count: 3)
        
        mockRepository.fetchPokemonsResult = .success(expectedPokemons)
        
        // When
        let result = try await useCase.execute(offset: offset, limit: limit)
        
        // Then
        XCTAssertEqual(result.count, 3)
        
        // Verify repository call
        XCTAssertEqual(mockRepository.fetchPokemonsCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchPokemonsOffset, offset)
        XCTAssertEqual(mockRepository.lastFetchPokemonsLimit, -1)
    }
    
    // MARK: - Multiple Calls Tests
    
    func testExecuteMultipleTimes() async throws {
        // Given
        let offset1 = 0
        let limit1 = 20
        let offset2 = 20
        let limit2 = 20
        let expectedPokemons1 = TestDataFactory.createMultiplePokemons(count: 3)
        let expectedPokemons2 = TestDataFactory.createMultiplePokemons(count: 3)
        
        mockRepository.fetchPokemonsResult = .success(expectedPokemons1)
        
        // When
        let result1 = try await useCase.execute(offset: offset1, limit: limit1)
        
        // Then
        XCTAssertEqual(result1.count, 3)
        XCTAssertEqual(mockRepository.fetchPokemonsCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchPokemonsOffset, offset1)
        XCTAssertEqual(mockRepository.lastFetchPokemonsLimit, limit1)
        
        // Given
        mockRepository.fetchPokemonsResult = .success(expectedPokemons2)
        
        // When
        let result2 = try await useCase.execute(offset: offset2, limit: limit2)
        
        // Then
        XCTAssertEqual(result2.count, 3)
        XCTAssertEqual(mockRepository.fetchPokemonsCallCount, 2)
        XCTAssertEqual(mockRepository.lastFetchPokemonsOffset, offset2)
        XCTAssertEqual(mockRepository.lastFetchPokemonsLimit, limit2)
    }
}