//
//  UbiquitiHAApp.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 02.10.2025.
//

import SwiftUI
import SwiftData

@main
struct UbiquitiHAApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PokemonModel.self,
            PokemonDescriptionModel.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            let coordinator = Coordinator()
            RootView()
                .environmentObject(coordinator)
        }
    }
    
    init() {
        setupDependencies()
    }
    
    private func setupDependencies() {
        DIContainer.shared.register(NetworkMonitorProtocol.self) {
            NetworkMonitor.shared
        }
        
        DIContainer.shared.register(DatabaseServiceProtocol.self) {
            DatabaseService(container: sharedModelContainer)
        }

        DIContainer.shared.register(NetworkServiceProtocol.self) {
            NetworkService()
        }
        
        DIContainer.shared.register(PokemonRemoteDataSourceProtocol.self) {
            PokemonRemoteDataSource(networkService: DIContainer.shared.resolve())
        }
        
        DIContainer.shared.register(PokemonCacheServiceProtocol.self) {
            PokemonCacheService(databaseService: DIContainer.shared.resolve())
        }
        
        DIContainer.shared.register(PokemonListRepositoryProtocol.self) {
            PokemonListRepository(remoteDataSource: DIContainer.shared.resolve(),
                                  cacheService: DIContainer.shared.resolve(),
                                  networkMonitor: DIContainer.shared.resolve()
            )
        }
        
        DIContainer.shared.register(PokemonDetailsRepositoryProtocol.self) {
            PokemonDetailsRepository(remoteDataSource: DIContainer.shared.resolve(),
                                     cacheService: DIContainer.shared.resolve(),
                                     networkMonitor: DIContainer.shared.resolve())
        }
        
        DIContainer.shared.register(LoadPokemonsUseCaseProtocol.self) {
            LoadPokemonsUseCase(repository: DIContainer.shared.resolve())
        }
        
        DIContainer.shared.register(LoadPokemonDescriptionUseCaseProtocol.self) {
            LoadPokemonDescriptionUseCase(repository: DIContainer.shared.resolve())
        }
    }
}
