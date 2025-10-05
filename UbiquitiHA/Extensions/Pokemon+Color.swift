//
//  Pokemon+Color.swift
//  UbiquitiHA
//
//  Created by Ivannikov-EXTERNAL Georgiy on 06.10.2025.
//

import SwiftUI

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
            default: return .yellow
            }
        }()

        return baseColor.opacity(0.8)
    }
}
