//
//  AppRoute.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 02.10.2025.
//

import Foundation

enum AppRoute: Hashable {
    case detail(Pokemon)

    static func == (lhs: AppRoute, rhs: AppRoute) -> Bool {
        switch (lhs, rhs) {
        case let (.detail(lhsPokemon), .detail(rhsPokemon)):
            return lhsPokemon.id == rhsPokemon.id
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .detail(let pokemon):
            hasher.combine(pokemon.id)
        }
    }
}
