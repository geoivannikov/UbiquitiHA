//
//  UbiquitiHAApp.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 02.10.2025.
//

import SwiftUI

@main
struct UbiquitiHAApp: App {
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
    }
}
