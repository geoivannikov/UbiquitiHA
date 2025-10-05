//
//  PokemonDetails.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 02.10.2025.
//

import SwiftUI

struct PokemonDetails {
    let id: Int
    let name: String
    let description: String
    let weight: Int
    let height: Int
    let baseExperience: Int
    let species: String
    let types: [String]
    let formsCount: Int
    let backgroundColor: Color
}

// MARK: - Init with Data

extension PokemonDetails {
    init(pokemon: Pokemon, pokemonSpeciesResponse: PokemonSpeciesResponse) {
        self.id = pokemon.id
        self.name = pokemon.name
        self.description = pokemonSpeciesResponse.flavorText
        self.weight = pokemon.weight
        self.height = pokemon.height
        self.baseExperience = pokemon.baseExperience
        self.species = pokemonSpeciesResponse.genus
        self.types = pokemon.types
        self.formsCount = pokemonSpeciesResponse.formsCount
        self.backgroundColor = pokemon.backgroundColor
    }
}

// MARK: - Empty Init

extension PokemonDetails {
    init() {
        self.id = 0
        self.name = ""
        self.description = ""
        self.weight = 0
        self.height = 0
        self.baseExperience = 0
        self.species = ""
        self.types = []
        self.formsCount = 0
        self.backgroundColor = .clear
    }
}

extension PokemonDetails {
    var isEmpty: Bool {
        description == ""
    }
}
