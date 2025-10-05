//
//  NetworkService.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 02.10.2025.
//

import Foundation

protocol NetworkServiceProtocol {
    func fetch<T: Decodable>(urlString: String, as type: T.Type) async throws -> T
    func fetch<T: Decodable>(url: URL, as type: T.Type) async throws -> T
    func fetchData(from urlString: String) async throws -> Data
    func fetchData(from url: URL) async throws -> Data
}

final class NetworkService: NetworkServiceProtocol {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetch<T: Decodable>(urlString: String, as type: T.Type) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw PokemonError.unknown
        }
        return try await fetch(url: url, as: type)
    }
    
    func fetch<T: Decodable>(url: URL, as type: T.Type) async throws -> T {
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw PokemonError.serverError((response as? HTTPURLResponse)?.statusCode ?? 0)
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw PokemonError.decodingError(error as! DecodingError)
        }
    }
    
    func fetchData(from urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw PokemonError.unknown
        }
        return try await fetchData(from: url)
    }
    
    func fetchData(from url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw PokemonError.serverError((response as? HTTPURLResponse)?.statusCode ?? 0)
        }
        
        return data
    }
}