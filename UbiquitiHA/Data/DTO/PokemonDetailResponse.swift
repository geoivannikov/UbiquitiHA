//
//  PokemonDetailResponse.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 02.10.2025.
//

struct PokemonDetailResponse: Codable {
    let id: Int
    let name: String
    let types: [PokemonTypeEntry]
    let sprites: PokemonSprites
    let height: Int
    let weight: Int
    let baseExperience: Int
    let forms: [NamedAPIResource]

    enum CodingKeys: String, CodingKey {
        case id, name, types, sprites, height, weight, forms
        case baseExperience = "base_experience"
    }
}

// MARK: - Type Info

struct PokemonTypeEntry: Codable {
    let type: NamedAPIResource
}

// MARK: - Sprites

struct PokemonSprites: Codable {
    let other: OtherSprites

    struct OtherSprites: Codable {
        let officialArtwork: Artwork

        enum CodingKeys: String, CodingKey {
            case officialArtwork = "official-artwork"
        }
    }

    struct Artwork: Codable {
        let frontDefault: String

        enum CodingKeys: String, CodingKey {
            case frontDefault = "front_default"
        }
    }
}

// MARK: - Shared Resource

struct NamedAPIResource: Codable {
    let name: String
    let url: String?

    init(name: String, url: String? = nil) {
        self.name = name
        self.url = url
    }
}
