//
//  PokemonDetailsModel.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 04.10.2025.
//

import Foundation
import SwiftData

@Model
final class PokemonDetailsModel: DatabaseModel {
    @Attribute(.unique) var pokemonId: Int
    var pokemonDescription: String?
    var abilities: [String]
    var stats: [String: Int]
    
    init(pokemonId: Int, description: String? = nil, abilities: [String] = [], 
         stats: [String: Int] = [:]) {
        self.pokemonId = pokemonId
        self.pokemonDescription = description
        self.abilities = abilities
        self.stats = stats
    }
}
