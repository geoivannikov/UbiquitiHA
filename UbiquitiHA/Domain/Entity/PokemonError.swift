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
    case networkError(URLError)
    case decodingError(DecodingError)
    case serverError(Int)
    case timeout
    case unknown

    var errorDescription: String? {
        switch self {
        case .noCache:
            return "Data not found in cache. API request failed"
        case .noConnection:
            return "No internet connection. Please check your connection"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Data decoding failed: \(error.localizedDescription)"
        case .serverError(let code):
            return "Server error (\(code)). Please try again later."
        case .timeout:
            return "Request timed out. Please try again."
        case .unknown:
            return "Unknown error"
        }
    }
}
