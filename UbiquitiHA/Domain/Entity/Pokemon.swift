//
//  Pokemon.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 02.10.2025.
//

import SwiftUI

struct Pokemon: Identifiable, Decodable {
    let id: Int
    let name: String
    let number: String
    let types: [String]
    let imageData: Data?
    let height: Int
    let weight: Int
    let baseExperience: Int
}

// MARK: - Mapping

extension Pokemon {
    init(detail: PokemonDetailResponse, imageData: Data? = nil) {
        self.id = detail.id
        self.name = detail.name.capitalized
        self.number = String(format: "#%03d", detail.id)
        self.types = detail.types.map { $0.type.name.capitalized }
        self.imageData = imageData
        self.height = detail.height
        self.weight = detail.weight
        self.baseExperience = detail.baseExperience
    }
    
    init(from model: PokemonModel) {
        self.id = model.id
        self.name = model.name
        self.number = model.number
        self.types = model.types
        self.imageData = model.imageData
        self.height = model.height
        self.weight = model.weight
        self.baseExperience = model.baseExperience
    }
    
    init(id: Int) {
        self.id = id
        self.name = ""
        self.number = ""
        self.types = []
        self.imageData = nil
        self.height = 0
        self.weight = 0
        self.baseExperience = 0
    }
}
