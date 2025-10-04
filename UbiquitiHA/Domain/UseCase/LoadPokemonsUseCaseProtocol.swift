//
//  LoadPokemonsUseCaseProtocol.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 02.10.2025.
//

import Foundation

protocol LoadPokemonsUseCaseProtocol {
    func execute(offset: Int, limit: Int) async throws -> [Pokemon]
}

final class LoadPokemonsUseCase: LoadPokemonsUseCaseProtocol {
    private let remoteDataSource: PokemonRemoteDataSourceProtocol

    init(remoteDataSource: PokemonRemoteDataSourceProtocol = DIContainer.shared.resolve()) {
        self.remoteDataSource = remoteDataSource
    }

    func execute(offset: Int, limit: Int) async throws -> [Pokemon] {
        let response = try await remoteDataSource.fetchPokemonsList(offset: offset, limit: limit)
        let entries = response.results

        let detailResponses: [PokemonDetailResponse] = try await withThrowingTaskGroup(of: PokemonDetailResponse?.self) { group in
            entries.forEach { entry in
                group.addTask {
                    try? await self.remoteDataSource.fetchPokemon(url: entry.url)
                }
            }

            return try await group.reduce(into: []) { result, next in
                if let model = next {
                    result.append(model)
                }
            }
        }

        // Загружаем изображения параллельно через remoteDataSource
        let pokemonsWithImages: [Pokemon] = try await withThrowingTaskGroup(of: Pokemon?.self) { group in
            detailResponses.forEach { detail in
                group.addTask {
                    do {
                        let imageData = try await self.remoteDataSource.fetchImageData(from: detail.sprites.other.officialArtwork.frontDefault)
                        return Pokemon(detail: detail, imageData: imageData)
                    } catch {
                        print("Failed to load image: \(detail.sprites.other.officialArtwork.frontDefault) - \(error.localizedDescription)")
                        return Pokemon(detail: detail, imageData: nil)
                    }
                }
            }

            return try await group.reduce(into: []) { result, next in
                if let pokemon = next {
                    result.append(pokemon)
                }
            }
        }

        return pokemonsWithImages
    }
}
