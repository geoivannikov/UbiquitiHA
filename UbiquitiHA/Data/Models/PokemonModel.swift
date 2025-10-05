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
    var typesData: String = "[]"
    var imageData: Data?
    var height: Int
    var weight: Int
    var baseExperience: Int
    
    init(id: Int, name: String, number: String, types: [String], imageData: Data? = nil,
         height: Int, weight: Int, baseExperience: Int) {
        self.id = id
        self.name = name
        self.number = number
        self.typesData = (try? JSONEncoder().encode(types).base64EncodedString()) ?? "[]"
        self.imageData = imageData
        self.height = height
        self.weight = weight
        self.baseExperience = baseExperience
    }
    
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
