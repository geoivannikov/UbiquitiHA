//
//  PokemonDescriptionModel.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 04.10.2025.
//

import Foundation
import SwiftData

@Model
final class PokemonDescriptionModel: DatabaseModel {
    @Attribute(.unique) var pokemonId: Int
    var pokemonDescription: String?
    
    init(pokemonId: Int, description: String? = nil) {
        self.pokemonId = pokemonId
        self.pokemonDescription = description
    }
}
