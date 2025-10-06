//
//  PokemonDetailsModel.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 04.10.2025.
//

import Foundation
import SwiftData

@Model
final class PokemonDescriptionModel: DatabaseModel {
    @Attribute(.unique) var pokemonId: Int
    var pokemonDescription: String
    var weight: Int
    var height: Int
    var baseExperience: Int
    var species: String
    var formsCount: Int
    var typesData: String = "[]"
    
    init(pokemonId: Int, description: String, weight: Int, height: Int, baseExperience: Int, species: String, formsCount: Int, types: [String]) {
        self.pokemonId = pokemonId
        self.pokemonDescription = description
        self.weight = weight
        self.height = height
        self.typesData = (try? JSONEncoder().encode(types).base64EncodedString()) ?? "[]"
        self.baseExperience = baseExperience
        self.species = species
        self.formsCount = formsCount
    }
}

extension PokemonDescriptionModel {
    var types: [String] {
        get {
            guard let data = Data(base64Encoded: typesData),
                  let decoded = try? JSONDecoder().decode([String].self, from: data) else {
                return []
            }
            return decoded
        }
        set {
            typesData = (try? JSONEncoder().encode(newValue).base64EncodedString()) ?? "[]"
        }
    }
}

// MARK: - Mapping

extension PokemonDescriptionModel {
    convenience init(details: PokemonDetails) {
        self.init(pokemonId: details.id,
                  description: details.description,
                  weight: details.weight,
                  height: details.height,
                  baseExperience: details.baseExperience,
                  species: details.species,
                  formsCount: details.formsCount,
                  types: details.types)
    }
}
