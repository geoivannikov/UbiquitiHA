//
//  PokemonModel.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 04.10.2025.
//

import Foundation
import SwiftData

@Model
final class PokemonModel: DatabaseModel {
    @Attribute(.unique) var id: Int
    var name: String
    var number: String
    var types: [String]
    var imageData: Data?
    var height: Int
    var weight: Int
    var baseExperience: Int
    
    init(id: Int, name: String, number: String, types: [String], imageData: Data? = nil,
         height: Int, weight: Int, baseExperience: Int) {
        self.id = id
        self.name = name
        self.number = number
        self.types = types
        self.imageData = imageData
        self.height = height
        self.weight = weight
        self.baseExperience = baseExperience
    }
}

// MARK: - Mapping

extension PokemonModel {
    convenience init(from pokemon: Pokemon) {
        self.init(
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
}
