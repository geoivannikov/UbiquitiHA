//
//  PokemonListRepositoryTests.swift
//  UbiquitiHATests
//
//  Created by Ivannikov Georgiy on 05.10.2025.
//

import XCTest
@testable import UbiquitiHA

final class PokemonListRepositoryTests: XCTestCase {
    
    private var repository: PokemonListRepository!
    private var mockRemoteDataSource: MockPokemonRemoteDataSource!
    private var mockCacheService: MockPokemonCacheService!
    private var mockNetworkMonitor: MockNetworkMonitor!
    
    override func setUp() {
        super.setUp()
        mockRemoteDataSource = MockPokemonRemoteDataSource()
        mockCacheService = MockPokemonCacheService()
        mockNetworkMonitor = MockNetworkMonitor()
        
        repository = PokemonListRepository(
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
    
    func testFetchPokemonsWhenConnectedAndAPISuccess() async throws {
        // Given
        let offset = 0
        let limit = 20
        let pokemonListResponse = PokemonListResponse(
            results: [
                PokemonEntry(name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/"),
                PokemonEntry(name: "ivysaur", url: "https://pokeapi.co/api/v2/pokemon/2/"),
                PokemonEntry(name: "venusaur", url: "https://pokeapi.co/api/v2/pokemon/3/")
            ]
        )
        
        let pokemonDetailResponse1 = PokemonDetailResponse(
            id: 1,
            name: "bulbasaur",
            types: [PokemonTypeEntry(type: NamedAPIResource(name: "grass", url: "https://pokeapi.co/api/v2/type/12/"))],
            sprites: PokemonSprites(
                other: PokemonSprites.OtherSprites(
                    officialArtwork: PokemonSprites.Artwork(
                        frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png"
                    )
                )
            ),
            height: 7,
            weight: 69,
            baseExperience: 64,
            forms: [NamedAPIResource(name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon-form/1/")]
        )
        
        let pokemonDetailResponse2 = PokemonDetailResponse(
            id: 2,
            name: "ivysaur",
            types: [PokemonTypeEntry(type: NamedAPIResource(name: "grass", url: "https://pokeapi.co/api/v2/type/12/"))],
            sprites: PokemonSprites(
                other: PokemonSprites.OtherSprites(
                    officialArtwork: PokemonSprites.Artwork(
                        frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/2.png"
                    )
                )
            ),
            height: 10,
            weight: 130,
            baseExperience: 142,
            forms: [NamedAPIResource(name: "ivysaur", url: "https://pokeapi.co/api/v2/pokemon-form/2/")]
        )
        
        let pokemonDetailResponse3 = PokemonDetailResponse(
            id: 3,
            name: "venusaur",
            types: [PokemonTypeEntry(type: NamedAPIResource(name: "grass", url: "https://pokeapi.co/api/v2/type/12/"))],
            sprites: PokemonSprites(
                other: PokemonSprites.OtherSprites(
                    officialArtwork: PokemonSprites.Artwork(
                        frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/3.png"
                    )
                )
            ),
            height: 20,
            weight: 1000,
            baseExperience: 236,
            forms: [NamedAPIResource(name: "venusaur", url: "https://pokeapi.co/api/v2/pokemon-form/3/")]
        )
        
        mockNetworkMonitor.isConnected = true
        mockRemoteDataSource.fetchPokemonsListResult = .success(pokemonListResponse)
        mockRemoteDataSource.fetchPokemonResult = .success(pokemonDetailResponse1)
        mockRemoteDataSource.fetchPokemonImageResult = .success("test image data".data(using: .utf8)!)
        
        // When
        let result = try await repository.fetchPokemons(offset: offset, limit: limit)
        
        // Then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].id, 1)
        XCTAssertEqual(result[0].name, "Bulbasaur")
        XCTAssertEqual(result[0].number, "#001")
        XCTAssertEqual(result[0].types, ["Grass"])
        XCTAssertEqual(result[0].height, 7)
        XCTAssertEqual(result[0].weight, 69)
        XCTAssertEqual(result[0].baseExperience, 64)
        
        // Verify API calls
        XCTAssertEqual(mockRemoteDataSource.fetchPokemonsListCallCount, 1)
        XCTAssertEqual(mockRemoteDataSource.lastFetchPokemonsListOffset, offset)
        XCTAssertEqual(mockRemoteDataSource.lastFetchPokemonsListLimit, limit)
        
        // Verify cache save
        XCTAssertEqual(mockCacheService.savePokemonCallCount, 3)
    }
    
    func testFetchPokemonsWhenConnectedAndAPIFailureThenCacheSuccess() async throws {
        // Given
        let offset = 0
        let limit = 20
        let cachedPokemons = TestDataFactory.createMultiplePokemons(count: 3)
        
        mockNetworkMonitor.isConnected = true
        mockRemoteDataSource.fetchPokemonsListResult = .failure(PokemonError.networkError(URLError(.notConnectedToInternet)))
        mockCacheService.fetchPokemonsFromCacheResult = .success(cachedPokemons)
        
        // When
        let result = try await repository.fetchPokemons(offset: offset, limit: limit)
        
        // Then
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0].id, cachedPokemons[0].id)
        XCTAssertEqual(result[0].name, cachedPokemons[0].name)
        
        // Verify API call was attempted
        XCTAssertEqual(mockRemoteDataSource.fetchPokemonsListCallCount, 1)
        
        // Verify cache fallback
        XCTAssertEqual(mockCacheService.fetchPokemonsFromCacheCallCount, 1)
        XCTAssertEqual(mockCacheService.lastFetchPokemonsFromCacheOffset, offset)
        XCTAssertEqual(mockCacheService.lastFetchPokemonsFromCacheLimit, limit)
    }
    
    func testFetchPokemonsWhenConnectedAndAPIFailureThenCacheFailure() async {
        // Given
        let offset = 0
        let limit = 20
        
        mockNetworkMonitor.isConnected = true
        mockRemoteDataSource.fetchPokemonsListResult = .failure(PokemonError.networkError(URLError(.notConnectedToInternet)))
        mockCacheService.fetchPokemonsFromCacheResult = .failure(PokemonError.noCache)
        
        // When & Then
        do {
            _ = try await repository.fetchPokemons(offset: offset, limit: limit)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is PokemonError)
        }
        
        // Verify API call was attempted
        XCTAssertEqual(mockRemoteDataSource.fetchPokemonsListCallCount, 1)
        
        // Verify cache fallback was attempted
        XCTAssertEqual(mockCacheService.fetchPokemonsFromCacheCallCount, 1)
    }
    
    // MARK: - Network Disconnected Tests
    
    func testFetchPokemonsWhenDisconnectedAndCacheSuccess() async throws {
        // Given
        let offset = 0
        let limit = 20
        let cachedPokemons = TestDataFactory.createMultiplePokemons(count: 3)
        
        mockNetworkMonitor.isConnected = false
        mockCacheService.fetchPokemonsFromCacheResult = .success(cachedPokemons)
        
        // When
        let result = try await repository.fetchPokemons(offset: offset, limit: limit)
        
        // Then
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0].id, cachedPokemons[0].id)
        XCTAssertEqual(result[0].name, cachedPokemons[0].name)
        
        // Verify no API calls were made
        XCTAssertEqual(mockRemoteDataSource.fetchPokemonsListCallCount, 0)
        
        // Verify cache was used
        XCTAssertEqual(mockCacheService.fetchPokemonsFromCacheCallCount, 1)
        XCTAssertEqual(mockCacheService.lastFetchPokemonsFromCacheOffset, offset)
        XCTAssertEqual(mockCacheService.lastFetchPokemonsFromCacheLimit, limit)
    }
    
    func testFetchPokemonsWhenDisconnectedAndCacheFailure() async {
        // Given
        let offset = 0
        let limit = 20
        
        mockNetworkMonitor.isConnected = false
        mockCacheService.fetchPokemonsFromCacheResult = .failure(PokemonError.noCache)
        
        // When & Then
        do {
            _ = try await repository.fetchPokemons(offset: offset, limit: limit)
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
        XCTAssertEqual(mockRemoteDataSource.fetchPokemonsListCallCount, 0)
        
        // Verify cache was attempted
        XCTAssertEqual(mockCacheService.fetchPokemonsFromCacheCallCount, 1)
    }
    
    func testFetchPokemonsWhenDisconnectedAndCacheEmptyAtOffsetZero() async {
        // Given
        let offset = 0
        let limit = 20
        
        mockNetworkMonitor.isConnected = false
        mockCacheService.fetchPokemonsFromCacheResult = .success([])
        
        // When & Then
        do {
            _ = try await repository.fetchPokemons(offset: offset, limit: limit)
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
        XCTAssertEqual(mockRemoteDataSource.fetchPokemonsListCallCount, 0)
        
        // Verify cache was attempted
        XCTAssertEqual(mockCacheService.fetchPokemonsFromCacheCallCount, 1)
    }
    
    func testFetchPokemonsWhenDisconnectedAndCacheEmptyAtNonZeroOffset() async throws {
        // Given
        let offset = 20
        let limit = 20
        
        mockNetworkMonitor.isConnected = false
        mockCacheService.fetchPokemonsFromCacheResult = .success([])
        
        // When
        let result = try await repository.fetchPokemons(offset: offset, limit: limit)
        
        // Then
        XCTAssertEqual(result.count, 0)
        
        // Verify no API calls were made
        XCTAssertEqual(mockRemoteDataSource.fetchPokemonsListCallCount, 0)
        
        // Verify cache was attempted
        XCTAssertEqual(mockCacheService.fetchPokemonsFromCacheCallCount, 1)
    }
    
    // MARK: - Edge Cases
    
    func testFetchPokemonsWithZeroLimit() async throws {
        // Given
        let offset = 0
        let limit = 0
        let pokemonListResponse = PokemonListResponse(results: [])
        
        mockNetworkMonitor.isConnected = true
        mockRemoteDataSource.fetchPokemonsListResult = .success(pokemonListResponse)
        
        // When
        let result = try await repository.fetchPokemons(offset: offset, limit: limit)
        
        // Then
        XCTAssertEqual(result.count, 0)
        
        // Verify API call
        XCTAssertEqual(mockRemoteDataSource.fetchPokemonsListCallCount, 1)
        XCTAssertEqual(mockRemoteDataSource.lastFetchPokemonsListOffset, offset)
        XCTAssertEqual(mockRemoteDataSource.lastFetchPokemonsListLimit, limit)
    }
    
    func testFetchPokemonsWithLargeOffset() async throws {
        // Given
        let offset = 1000
        let limit = 20
        let pokemonListResponse = PokemonListResponse(results: [])
        
        mockNetworkMonitor.isConnected = true
        mockRemoteDataSource.fetchPokemonsListResult = .success(pokemonListResponse)
        
        // When
        let result = try await repository.fetchPokemons(offset: offset, limit: limit)
        
        // Then
        XCTAssertEqual(result.count, 0)
        
        // Verify API call
        XCTAssertEqual(mockRemoteDataSource.fetchPokemonsListCallCount, 1)
        XCTAssertEqual(mockRemoteDataSource.lastFetchPokemonsListOffset, offset)
        XCTAssertEqual(mockRemoteDataSource.lastFetchPokemonsListLimit, limit)
    }
    
    // MARK: - Error Handling Tests
    
    func testFetchPokemonsWithDecodingError() async throws {
        // Given
        let offset = 0
        let limit = 20
        let cachedPokemons = TestDataFactory.createMultiplePokemons(count: 3)
        
        mockNetworkMonitor.isConnected = true
        mockRemoteDataSource.fetchPokemonsListResult = .failure(PokemonError.decodingError(DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Test error"))))
        mockCacheService.fetchPokemonsFromCacheResult = .success(cachedPokemons)
        
        // When
        let result = try await repository.fetchPokemons(offset: offset, limit: limit)
        
        // Then
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0].id, cachedPokemons[0].id)
        
        // Verify API call was attempted
        XCTAssertEqual(mockRemoteDataSource.fetchPokemonsListCallCount, 1)
        
        // Verify cache fallback
        XCTAssertEqual(mockCacheService.fetchPokemonsFromCacheCallCount, 1)
    }
    
    func testFetchPokemonsWithServerError() async throws {
        // Given
        let offset = 0
        let limit = 20
        let cachedPokemons = TestDataFactory.createMultiplePokemons(count: 3)
        
        mockNetworkMonitor.isConnected = true
        mockRemoteDataSource.fetchPokemonsListResult = .failure(PokemonError.serverError(500))
        mockCacheService.fetchPokemonsFromCacheResult = .success(cachedPokemons)
        
        // When
        let result = try await repository.fetchPokemons(offset: offset, limit: limit)
        
        // Then
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0].id, cachedPokemons[0].id)
        
        // Verify API call was attempted
        XCTAssertEqual(mockRemoteDataSource.fetchPokemonsListCallCount, 1)
        
        // Verify cache fallback
        XCTAssertEqual(mockCacheService.fetchPokemonsFromCacheCallCount, 1)
    }
    
    func testFetchPokemonsWithTimeoutError() async throws {
        // Given
        let offset = 0
        let limit = 20
        let cachedPokemons = TestDataFactory.createMultiplePokemons(count: 3)
        
        mockNetworkMonitor.isConnected = true
        mockRemoteDataSource.fetchPokemonsListResult = .failure(PokemonError.timeout)
        mockCacheService.fetchPokemonsFromCacheResult = .success(cachedPokemons)
        
        // When
        let result = try await repository.fetchPokemons(offset: offset, limit: limit)
        
        // Then
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0].id, cachedPokemons[0].id)
        
        // Verify API call was attempted
        XCTAssertEqual(mockRemoteDataSource.fetchPokemonsListCallCount, 1)
        
        // Verify cache fallback
        XCTAssertEqual(mockCacheService.fetchPokemonsFromCacheCallCount, 1)
    }
}
