//
//  APIError.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 02.10.2025.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL(String)
    case invalidResponse(URLResponse?)
    case decodingFailed(Error)
    case network(Error)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .invalidResponse(let response):
            return "Invalid server response: \(String(describing: response))"
        case .decodingFailed(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        case .network(let error):
            return "Network error: \(error.localizedDescription)"
        case .unknown:
            return "Unknown error"
        }
    }
}
