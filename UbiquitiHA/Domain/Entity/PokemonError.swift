//
//  PokemonError.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 05.10.2025.
//

import Foundation

enum PokemonError: Error, LocalizedError {
    case noConnection
    case noCache
    case unknown

    var errorDescription: String? {
        switch self {
        case .noCache:
            return "Data not found in cache. API request failed"
        case .noConnection:
            return "No internet connection. Please check your connection"
        case .unknown:
            return "Unknown error"
        }
    }
}
