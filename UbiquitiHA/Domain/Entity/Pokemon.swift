//
//  Pokemon.swift
//  UbiquitiHA
//
//  Created by Ivannikov on 02.10.2025.
//

import SwiftUI

struct Pokemon: Identifiable, Decodable {
    let id: Int
    let name: String
    let number: String
    let types: [String]
    let imgURL: String
    let height: Int
    let weight: Int
    let baseExperience: Int
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

// MARK: - Mapping

//extension Pokemon {
//    init(detail: PokemonDetailResponse) {
//        self.id = detail.id
//        self.name = detail.name.capitalized
//        self.number = String(format: "#%03d", detail.id)
//        self.types = detail.types.map { $0.type.name.capitalized }
//        self.imgURL = detail.sprites.other.officialArtwork.frontDefault
//        self.height = detail.height
//        self.weight = detail.weight
//        self.baseExperience = detail.baseExperience
//    }
//}
