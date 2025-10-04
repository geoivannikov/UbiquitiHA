//
//  DIContainer.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 02.10.2025.
//

protocol Resolver {
    func resolve<T>() -> T
}

final class DIContainer: Resolver {
    static let shared = DIContainer()
    
    private var factories: [ObjectIdentifier: () -> Any] = [:]
    
    func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        factories[ObjectIdentifier(type)] = factory
    }
    
    func resolve<T>() -> T {
        guard let factory = factories[ObjectIdentifier(T.self)],
              let instance = factory() as? T else {
            fatalError("No registration for type \(T.self)")
        }
        return instance
    }
    
    func reset() {
        factories.removeAll()
    }
    
    func registerAll() {
        DIContainer.shared.register(NetworkServiceProtocol.self) {
            NetworkService()
        }
        
        DIContainer.shared.register(PokemonRemoteDataSourceProtocol.self) {
            PokemonRemoteDataSource(networkService: DIContainer.shared.resolve())
        }
        
        DIContainer.shared.register(LoadPokemonsUseCaseProtocol.self) {
            LoadPokemonsUseCase(remoteDataSource: DIContainer.shared.resolve())
        }
        
        DIContainer.shared.register(LoadPokemonDescriptionUseCaseProtocol.self) {
            LoadPokemonDescriptionUseCase(remoteDataSource: DIContainer.shared.resolve())
        }
    }
}
