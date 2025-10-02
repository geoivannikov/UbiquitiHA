//
//  PokemonSpeciesResponse.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 02.10.2025.
//

import Foundation

struct PokemonSpeciesResponse: Codable {
    let flavorText: String
    let genus: String
    let formsCount: Int

    enum CodingKeys: String, CodingKey {
        case flavorTextEntries = "flavor_text_entries"
        case genera
        case varieties
    }

    // MARK: - Nested types

    private struct FlavorTextEntry: Codable {
        let flavor_text: String
        let language: NamedAPIResource
    }

    private struct GenusEntry: Codable {
        let genus: String
        let language: NamedAPIResource
    }

    private struct Variety: Codable {
        let is_default: Bool
    }

    private struct NamedAPIResource: Codable {
        let name: String
    }

    // MARK: - Init

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Flavor Text
        let flavorEntries = try container.decode([FlavorTextEntry].self, forKey: .flavorTextEntries)
        self.flavorText = flavorEntries
            .first(where: { $0.language.name == "en" })?
            .flavor_text
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\u{000c}", with: " ") ?? "No description available."

        // Genus
        let genusEntries = try container.decode([GenusEntry].self, forKey: .genera)
        self.genus = genusEntries
            .first(where: { $0.language.name == "en" })?
            .genus ?? "Unknown"

        // Varieties count
        let varieties = try container.decode([Variety].self, forKey: .varieties)
        self.formsCount = varieties.count
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(
            [FlavorTextEntry(flavor_text: flavorText, language: .init(name: "en"))],
            forKey: .flavorTextEntries
        )
        try container.encode(
            [GenusEntry(genus: genus, language: .init(name: "en"))],
            forKey: .genera
        )
        try container.encode(
            Array(repeating: Variety(is_default: true), count: formsCount),
            forKey: .varieties
        )
    }
    
    init(flavorText: String, genus: String, formsCount: Int) {
        self.flavorText = flavorText
        self.genus = genus
        self.formsCount = formsCount
    }
}
