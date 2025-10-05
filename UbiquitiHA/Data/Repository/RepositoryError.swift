//
//  RepositoryError.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 05.10.2025.
//

import Foundation

enum RepositoryError: Error, LocalizedError {
    case apiFailedNoCache
    case unknown

    var errorDescription: String? {
        switch self {
        case .apiFailedNoCache:
            return "Data not found in cache and API request failed"
        case .unknown:
            return "Unknown error"
        }
    }
}
