//
//  PokemonLocalDataSource.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 04.10.2025.
//

import Foundation
import SwiftData

protocol PokemonLocalDataSourceProtocol {
    func savePokemon(_ pokemon: PokemonModel) throws
    func fetchPokemons() throws -> [PokemonModel]
    func fetchPokemon(by id: Int) throws -> PokemonModel?
    func deletePokemon(id: Int) throws
    func deleteAllPokemons() throws
    
    func savePokemonDetails(_ details: PokemonDetailsModel) throws
    func fetchPokemonDetails(by pokemonId: Int) throws -> PokemonDetailsModel?
    func updatePokemonDetails(_ details: PokemonDetailsModel) throws
    func deletePokemonDetails(pokemonId: Int) throws
}

final class PokemonLocalDataSource: PokemonLocalDataSourceProtocol {
    private let databaseService: DatabaseServiceProtocol
    
    init(databaseService: DatabaseServiceProtocol) {
        self.databaseService = databaseService
    }
    
    // MARK: - Pokemon Methods
    
    func savePokemon(_ pokemon: PokemonModel) throws {
        try databaseService.create(pokemon)
    }
    
    func fetchPokemons() throws -> [PokemonModel] {
        try databaseService.fetch(of: PokemonModel.self, sortDescriptors: [])
    }
    
    func fetchPokemon(by id: Int) throws -> PokemonModel? {
        let pokemons = try fetchPokemons()
        return pokemons.first { $0.id == id }
    }
    
    func deletePokemon(id: Int) throws {
        if let pokemon = try fetchPokemon(by: id) {
            try databaseService.delete(pokemon)
        }
    }
    
    func deleteAllPokemons() throws {
        try databaseService.deleteAll(of: PokemonModel.self)
    }
    
    // MARK: - PokemonDetails Methods
    
    func savePokemonDetails(_ details: PokemonDetailsModel) throws {
        try databaseService.create(details)
    }
    
    func fetchPokemonDetails(by pokemonId: Int) throws -> PokemonDetailsModel? {
        let details = try databaseService.fetch(of: PokemonDetailsModel.self, sortDescriptors: [])
        return details.first { $0.pokemonId == pokemonId }
    }
    
    func updatePokemonDetails(_ details: PokemonDetailsModel) throws {
        try databaseService.update {
            details.updateTimestamp()
        }
    }
    
    func deletePokemonDetails(pokemonId: Int) throws {
        if let details = try fetchPokemonDetails(by: pokemonId) {
            try databaseService.delete(details)
        }
    }
}
