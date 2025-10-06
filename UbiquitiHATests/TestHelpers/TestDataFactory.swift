//
//  TestDataFactory.swift
//  UbiquitiHATests
//
//  Created by Ivannikov Georgiy on 04.10.2025.
//

import Foundation
@testable import UbiquitiHA

struct TestDataFactory {
    
    // MARK: - PokemonModel factory methods
    
    static func createPokemonModel(
        id: Int = 1,
        name: String = "Pikachu",
        number: String = "#001",
        types: [String] = ["Electric"],
        imageData: Data? = nil,
        height: Int = 4,
        weight: Int = 60,
        baseExperience: Int = 112
    ) -> PokemonModel {
        return PokemonModel(
            id: id,
            name: name,
            number: number,
            types: types,
            imageData: imageData,
            height: height,
            weight: weight,
            baseExperience: baseExperience
        )
    }
    
    static func createMultiplePokemonModels(count: Int) -> [PokemonModel] {
        return (1...count).map { index in
            createPokemonModel(
                id: index,
                name: "Pokemon\(index)",
                number: String(format: "#%03d", index),
                types: ["Normal"]
            )
        }
    }
    
    // MARK: - PokemonDescriptionModel factory methods
    
    static func createPokemonDescriptionModel(
        pokemonId: Int = 1,
        description: String = "A mouse Pokémon"
    ) -> PokemonDescriptionModel {
        return PokemonDescriptionModel(
            pokemonId: pokemonId,
            description: description
        )
    }
    
    static func createMultiplePokemonDescriptionModels(count: Int) -> [PokemonDescriptionModel] {
        return (1...count).map { index in
            createPokemonDescriptionModel(
                pokemonId: index,
                description: "Description for Pokemon \(index)"
            )
        }
    }
    
    // MARK: - Pokemon entity factory methods
    
    static func createPokemon(
        id: Int = 1,
        name: String = "Pikachu",
        number: String = "#001",
        types: [String] = ["Electric"],
        imageData: Data? = nil,
        height: Int = 4,
        weight: Int = 60,
        baseExperience: Int = 112
    ) -> Pokemon {
        return Pokemon(
            id: id,
            name: name,
            number: number,
            types: types,
            imageData: imageData,
            height: height,
            weight: weight,
            baseExperience: baseExperience
        )
    }
    
    static func createMultiplePokemons(count: Int) -> [Pokemon] {
        return (1...count).map { index in
            createPokemon(
                id: index,
                name: "Pokemon\(index)",
                number: String(format: "#%03d", index),
                types: ["Normal"]
            )
        }
    }
    
    // MARK: - Sample data for testing
    
    static let samplePokemonModels: [PokemonModel] = [
        createPokemonModel(id: 1, name: "Bulbasaur", types: ["Grass", "Poison"]),
        createPokemonModel(id: 2, name: "Ivysaur", types: ["Grass", "Poison"]),
        createPokemonModel(id: 3, name: "Venusaur", types: ["Grass", "Poison"]),
        createPokemonModel(id: 4, name: "Charmander", types: ["Fire"]),
        createPokemonModel(id: 5, name: "Charmeleon", types: ["Fire"])
    ]
    
    static let samplePokemonDescriptionModels: [PokemonDescriptionModel] = [
        createPokemonDescriptionModel(pokemonId: 1, description: "A seed Pokémon"),
        createPokemonDescriptionModel(pokemonId: 2, description: "A seed Pokémon"),
        createPokemonDescriptionModel(pokemonId: 3, description: "A seed Pokémon"),
        createPokemonDescriptionModel(pokemonId: 4, description: "A lizard Pokémon"),
        createPokemonDescriptionModel(pokemonId: 5, description: "A flame Pokémon")
    ]
}