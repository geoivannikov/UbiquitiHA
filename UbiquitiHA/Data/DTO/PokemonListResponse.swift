//
//  PokemonListResponse.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 02.10.2025.
//

// MARK: - Pokemon List Response

struct PokemonListResponse: Codable {
    let results: [PokemonEntry]
}

struct PokemonEntry: Codable {
    let name: String
    let url: String
}
