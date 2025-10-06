//
//  PokemonDetailResponseTests.swift
//  UbiquitiHATests
//
//  Created by Ivannikov Georgiy on 05.10.2025.
//

import XCTest
@testable import UbiquitiHA

final class PokemonDetailResponseTests: XCTestCase {
    
    // MARK: - Test Data
    
    private func createValidJSON() -> [String: Any] {
        return [
            "id": 1,
            "name": "pikachu",
            "types": [
                [
                    "type": [
                        "name": "electric",
                        "url": "https://pokeapi.co/api/v2/type/13/"
                    ]
                ]
            ],
            "sprites": [
                "other": [
                    "official-artwork": [
                        "front_default": "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png"
                    ]
                ]
            ],
            "height": 4,
            "weight": 60,
            "base_experience": 112,
            "forms": [
                [
                    "name": "pikachu",
                    "url": "https://pokeapi.co/api/v2/pokemon-form/25/"
                ]
            ]
        ]
    }
    
    // MARK: - Decoding Tests
    
    func testDecodingValidResponse() throws {
        let json = createValidJSON()
        let data = try JSONSerialization.data(withJSONObject: json)
        let response = try JSONDecoder().decode(PokemonDetailResponse.self, from: data)
        
        XCTAssertEqual(response.id, 1)
        XCTAssertEqual(response.name, "pikachu")
        XCTAssertEqual(response.height, 4)
        XCTAssertEqual(response.weight, 60)
        XCTAssertEqual(response.baseExperience, 112)
        XCTAssertEqual(response.types.count, 1)
        XCTAssertEqual(response.types.first?.type.name, "electric")
        XCTAssertEqual(response.sprites.other.officialArtwork.frontDefault, "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png")
        XCTAssertEqual(response.forms.count, 1)
        XCTAssertEqual(response.forms.first?.name, "pikachu")
    }
    
    func testDecodingWithMultipleTypes() throws {
        var json = createValidJSON()
        json["types"] = [
            [
                "type": [
                    "name": "electric",
                    "url": "https://pokeapi.co/api/v2/type/13/"
                ]
            ],
            [
                "type": [
                    "name": "flying",
                    "url": "https://pokeapi.co/api/v2/type/3/"
                ]
            ]
        ]
        
        let data = try JSONSerialization.data(withJSONObject: json)
        let response = try JSONDecoder().decode(PokemonDetailResponse.self, from: data)
        
        XCTAssertEqual(response.types.count, 2)
        XCTAssertEqual(response.types[0].type.name, "electric")
        XCTAssertEqual(response.types[1].type.name, "flying")
    }
    
    // MARK: - Encoding Tests
    
    func testEncodingValidResponse() throws {
        let response = PokemonDetailResponse(
            id: 1,
            name: "pikachu",
            types: [
                PokemonTypeEntry(type: NamedAPIResource(name: "electric", url: "https://pokeapi.co/api/v2/type/13/"))
            ],
            sprites: PokemonSprites(
                other: PokemonSprites.OtherSprites(
                    officialArtwork: PokemonSprites.Artwork(
                        frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png"
                    )
                )
            ),
            height: 4,
            weight: 60,
            baseExperience: 112,
            forms: [
                NamedAPIResource(name: "pikachu", url: "https://pokeapi.co/api/v2/pokemon-form/25/")
            ]
        )
        
        let data = try JSONEncoder().encode(response)
        let decoded = try JSONDecoder().decode(PokemonDetailResponse.self, from: data)
        
        XCTAssertEqual(decoded.id, response.id)
        XCTAssertEqual(decoded.name, response.name)
        XCTAssertEqual(decoded.height, response.height)
        XCTAssertEqual(decoded.weight, response.weight)
        XCTAssertEqual(decoded.baseExperience, response.baseExperience)
    }
    
    // MARK: - PokemonTypeEntry Tests
    
    func testPokemonTypeEntryDecoding() throws {
        let json = [
            "type": [
                "name": "electric",
                "url": "https://pokeapi.co/api/v2/type/13/"
            ]
        ]
        
        let data = try JSONSerialization.data(withJSONObject: json)
        let typeEntry = try JSONDecoder().decode(PokemonTypeEntry.self, from: data)
        
        XCTAssertEqual(typeEntry.type.name, "electric")
        XCTAssertEqual(typeEntry.type.url, "https://pokeapi.co/api/v2/type/13/")
    }
    
    // MARK: - PokemonSprites Tests
    
    func testPokemonSpritesDecoding() throws {
        let json = [
            "other": [
                "official-artwork": [
                    "front_default": "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png"
                ]
            ]
        ]
        
        let data = try JSONSerialization.data(withJSONObject: json)
        let sprites = try JSONDecoder().decode(PokemonSprites.self, from: data)
        
        XCTAssertEqual(sprites.other.officialArtwork.frontDefault, "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png")
    }
    
    // MARK: - NamedAPIResource Tests
    
    func testNamedAPIResourceInitialization() {
        let resource = NamedAPIResource(name: "electric", url: "https://pokeapi.co/api/v2/type/13/")
        
        XCTAssertEqual(resource.name, "electric")
        XCTAssertEqual(resource.url, "https://pokeapi.co/api/v2/type/13/")
    }
    
    func testNamedAPIResourceWithoutURL() {
        let resource = NamedAPIResource(name: "electric")
        
        XCTAssertEqual(resource.name, "electric")
        XCTAssertNil(resource.url)
    }
    
    func testNamedAPIResourceDecoding() throws {
        let json = [
            "name": "electric",
            "url": "https://pokeapi.co/api/v2/type/13/"
        ]
        
        let data = try JSONSerialization.data(withJSONObject: json)
        let resource = try JSONDecoder().decode(NamedAPIResource.self, from: data)
        
        XCTAssertEqual(resource.name, "electric")
        XCTAssertEqual(resource.url, "https://pokeapi.co/api/v2/type/13/")
    }
}
