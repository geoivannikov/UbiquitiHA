//
//  PokemonRepository.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 04.10.2025.
//

import Foundation

protocol PokemonRepositoryProtocol {
    func fetchPokemons(offset: Int, limit: Int) async throws -> [Pokemon]
    func fetchPokemonDetails(pokemon: Pokemon) async throws -> PokemonDetails
}

final class PokemonRepository: PokemonRepositoryProtocol {
    private let remoteDataSource: PokemonRemoteDataSourceProtocol
    private let localDataSource: PokemonLocalDataSourceProtocol
    
    init(remoteDataSource: PokemonRemoteDataSourceProtocol,
         localDataSource: PokemonLocalDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }
    
    // MARK: - Mapping Methods
    
    private func mapToEntity(_ model: PokemonModel) -> Pokemon {
        return Pokemon(
            id: model.id,
            name: model.name,
            number: model.number,
            types: model.types,
            imageData: model.imageData,
            height: model.height,
            weight: model.weight,
            baseExperience: model.baseExperience
        )
    }
    
    private func mapToModel(_ pokemon: Pokemon) -> PokemonModel {
        return PokemonModel(
            id: pokemon.id,
            name: pokemon.name,
            number: pokemon.number,
            types: pokemon.types,
            imageData: pokemon.imageData,
            height: pokemon.height,
            weight: pokemon.weight,
            baseExperience: pokemon.baseExperience
        )
    }
    
    // MARK: - Pokemon List Operations
    
    func fetchPokemons(offset: Int, limit: Int) async throws -> [Pokemon] {
        do {
            let response = try await remoteDataSource.fetchPokemonsList(offset: offset, limit: limit)
            let entries = response.results

            let pokemonIds = entries.compactMap { entry -> Int? in
                guard let url = URL(string: entry.url),
                      let lastPathComponent = url.pathComponents.last,
                      let id = Int(lastPathComponent) else { return nil }
                return id
            }
            
            return try await fetchPokemonsWithCache(pokemonIds: pokemonIds)
        } catch {
            print("Network error, trying to load from cache: \(error)")
            return try await fetchPokemonsFromCache(offset: offset, limit: limit)
        }
    }
    
    private func fetchPokemonsWithCache(pokemonIds: [Int]) async throws -> [Pokemon] {
        var cachedPokemons: [Int: Pokemon] = [:]
        var missingIds: [Int] = []
        
        for id in pokemonIds {
            do {
                if let cachedModel = try localDataSource.fetchPokemon(by: id) {
                    cachedPokemons[id] = mapToEntity(cachedModel)
                } else {
                    missingIds.append(id)
                }
            } catch {
                missingIds.append(id)
            }
        }

        let detailResponses: [PokemonDetailResponse] = try await withThrowingTaskGroup(of: PokemonDetailResponse?.self) { group in
            missingIds.forEach { id in
                group.addTask {
                    try? await self.remoteDataSource.fetchPokemon(id: id)
                }
            }

            return try await group.reduce(into: []) { result, next in
                if let model = next {
                    result.append(model)
                }
            }
        }

        let newPokemons: [Pokemon] = try await withThrowingTaskGroup(of: Pokemon?.self) { group in
            detailResponses.forEach { detail in
                group.addTask {
                    do {
                        let imageData = try await self.remoteDataSource.fetchPokemonImage(from: detail)
                        return Pokemon(detail: detail, imageData: imageData)
                    } catch {
                        return Pokemon(detail: detail, imageData: nil)
                    }
                }
            }

            return try await group.reduce(into: []) { result, next in
                if let pokemon = next {
                    result.append(pokemon)
                }
            }
        }
        
        for pokemon in newPokemons {
            do {
                let model = mapToModel(pokemon)
                try localDataSource.savePokemon(model)
            } catch {
                print("Failed to cache pokemon \(pokemon.id): \(error)")
            }
        }

        var result: [Pokemon] = []
        for id in pokemonIds {
            if let cachedPokemon = cachedPokemons[id] {
                result.append(cachedPokemon)
            } else if let newPokemon = newPokemons.first(where: { $0.id == id }) {
                result.append(newPokemon)
            }
        }

        return result
    }
    
    private func fetchPokemonsFromCache(offset: Int, limit: Int) async throws -> [Pokemon] {
        let allCachedPokemons = try localDataSource.fetchPokemons()
        
        let startIndex = offset
        let endIndex = min(offset + limit, allCachedPokemons.count)
        
        guard startIndex < allCachedPokemons.count else {
            return []
        }
        
        let paginatedPokemons = Array(allCachedPokemons[startIndex..<endIndex])
        return paginatedPokemons.map { mapToEntity($0) }
    }
    
    func fetchPokemonDetails(pokemon: Pokemon) async throws -> PokemonDetails {
        do {
            let speciesResponse = try await remoteDataSource.fetchPokemonDescription(name: pokemon.name)
            let pokemonDetails = PokemonDetails(pokemon: pokemon, pokemonSpeciesResponse: speciesResponse)
            
            do {
                let detailsModel = PokemonDetailsModel(
                    pokemonId: pokemon.id,
                    description: pokemonDetails.description,
                    abilities: [],
                    stats: [:]
                )
                try localDataSource.savePokemonDetails(detailsModel)
            } catch {
                print("Failed to cache pokemon details: \(error)")
            }
            
            return pokemonDetails
        } catch {
            do {
                if let cachedDetails = try localDataSource.fetchPokemonDetails(by: pokemon.id) {
                    return PokemonDetails(
                        id: pokemon.id,
                        name: pokemon.name,
                        description: cachedDetails.pokemonDescription ?? "",
                        weight: pokemon.weight,
                        height: pokemon.height,
                        baseExperience: pokemon.baseExperience,
                        species: "",
                        types: pokemon.types,
                        formsCount: 0, 
                        backgroundColor: pokemon.backgroundColor
                    )
                }
            } catch {
                print("Failed to fetch cached pokemon details: \(error)")
            }
            
            throw NSError(domain: "PokemonRepository", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "Pokemon details not found in cache and no internet connection"
            ])
        }
    }
}
