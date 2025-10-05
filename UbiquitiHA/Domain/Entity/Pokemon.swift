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

// MARK: - UI Helpers

extension Pokemon {
    var backgroundColor: Color {
        guard let primaryType = types.first?.lowercased() else {
            return Color.gray.opacity(0.2)
        }

        let baseColor: Color = {
            switch primaryType {
            case "normal": return .gray
            case "fire": return .red
            case "water": return .blue
            case "electric": return .yellow
            case "grass": return .green
            case "ice": return .cyan
            case "fighting": return .brown
            case "poison": return .purple
            case "ground": return .orange
            case "flying": return .teal
            case "psychic": return .pink
            case "bug": return .mint
            case "rock": return .indigo
            case "ghost": return .black
            case "dragon": return .blue
            case "dark": return .black
            case "steel": return .gray
            case "fairy": return .pink
            default: return .gray
            }
        }()

        return baseColor.opacity(0.8)
    }
}
