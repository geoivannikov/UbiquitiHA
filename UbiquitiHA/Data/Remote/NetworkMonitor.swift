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
    func onConnectionChange(_ callback: @escaping (Bool) -> Void)
}

final class NetworkMonitor: NetworkMonitorProtocol, ObservableObject {
    static let shared = NetworkMonitor()
    
    var isConnected = false
    
    private let monitor = NWPathMonitor()
    private var callbacks: [(Bool) -> Void] = []
    
    init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            let isConnected = path.status == .satisfied
            self?.isConnected = isConnected
            
            self?.callbacks.forEach { callback in
                callback(isConnected)
            }
        }
        monitor.start(queue: DispatchQueue.global())
    }
    
    func onConnectionChange(_ callback: @escaping (Bool) -> Void) {
        callbacks.append(callback)
    }
}
