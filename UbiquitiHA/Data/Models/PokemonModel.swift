//
//  PokemonModel.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 04.10.2025.
//

import Foundation
import SwiftData

@Model
final class PokemonModel: DatabaseModel {
    @Attribute(.unique) var id: Int
    var name: String
    var number: String
    var types: [String]
    var imageData: Data?
    var height: Int
    var weight: Int
    var baseExperience: Int
    var createdAt: Date
    var updatedAt: Date
    
    init(id: Int, name: String, number: String, types: [String], imageData: Data? = nil,
         height: Int, weight: Int, baseExperience: Int) {
        self.id = id
        self.name = name
        self.number = number
        self.types = types
        self.imageData = imageData
        self.height = height
        self.weight = weight
        self.baseExperience = baseExperience
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    func updateTimestamp() {
        self.updatedAt = Date()
    }
}
