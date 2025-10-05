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
    func savePokemonDetails(_ details: PokemonDetailsModel) throws
    func fetchPokemonDetails(by pokemonId: Int) throws -> PokemonDetailsModel?
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
        return pokemons.lazy.first { $0.id == id }
    }
    
    // MARK: - PokemonDetails Methods
    
    func savePokemonDetails(_ details: PokemonDetailsModel) throws {
        try databaseService.create(details)
    }
    
    func fetchPokemonDetails(by pokemonId: Int) throws -> PokemonDetailsModel? {
        let details = try databaseService.fetch(of: PokemonDetailsModel.self, sortDescriptors: [])
        return details.lazy.first { $0.pokemonId == pokemonId }
    }
}
