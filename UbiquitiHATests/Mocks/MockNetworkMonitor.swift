//
//  MockNetworkMonitor.swift
//  UbiquitiHATests
//
//  Created by Ivannikov Georgiy on 05.10.2025.
//

import Foundation
@testable import UbiquitiHA

final class MockNetworkMonitor: NetworkMonitorProtocol {
    var isConnected: Bool = true
    
    private var callbacks: [UUID: (Bool) -> Void] = [:]
    
    func onConnectionChange(_ callback: @escaping (Bool) -> Void) -> UUID {
        let id = UUID()
        callbacks[id] = callback
        return id
    }
    
    func removeCallback(_ id: UUID) {
        callbacks.removeValue(forKey: id)
    }
    
    // MARK: - Helper Methods
    
    func simulateConnectionChange(_ connected: Bool) {
        isConnected = connected
        callbacks.values.forEach { callback in
            callback(connected)
        }
    }
    
    func reset() {
        isConnected = true
        callbacks.removeAll()
    }
}