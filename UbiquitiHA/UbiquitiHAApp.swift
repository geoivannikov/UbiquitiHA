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
            RootView().environmentObject(coordinator)
        }
    }
    
    init() {
        setupDependencies()
    }
    
    private func setupDependencies() {
        DIContainer.shared.registerAll()
        DIContainer.shared.register(DatabaseServiceProtocol.self) {
            DatabaseService(context: sharedModelContainer.mainContext)
        }
    }
}
