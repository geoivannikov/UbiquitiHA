//
//  NetworkMonitor.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 04.10.2025.
//

import Foundation
import Network

protocol NetworkMonitorProtocol {
    var isConnected: Bool { get }
    func onConnectionChange(_ callback: @escaping (Bool) -> Void) -> UUID
    func removeCallback(_ id: UUID)
}

final class NetworkMonitor: NetworkMonitorProtocol, ObservableObject {
    static let shared = NetworkMonitor()
    
    var isConnected = false
    
    private let monitor = NWPathMonitor()
    private var callbacks: [UUID: (Bool) -> Void] = [:]
    
    init() {
        startMonitoring()
    }
    
    deinit {
        monitor.cancel()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            let isConnected = path.status == .satisfied
            self?.isConnected = isConnected
            
            self?.callbacks.values.forEach { callback in
                callback(isConnected)
            }
        }
        monitor.start(queue: DispatchQueue.global())
    }
    
    func onConnectionChange(_ callback: @escaping (Bool) -> Void) -> UUID {
        let id = UUID()
        callbacks[id] = callback
        return id
    }
    
    func removeCallback(_ id: UUID) {
        callbacks.removeValue(forKey: id)
    }
}
