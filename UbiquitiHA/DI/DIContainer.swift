//
//  DIContainer.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 02.10.2025.
//

import Foundation

enum Lifecycle {
    case singleton
    case transient
}

protocol Resolver {
    func resolve<T>() -> T
}

final class DIContainer: Resolver {
    static let shared = DIContainer()
    
    private var factories: [ObjectIdentifier: () -> Any] = [:]
    private var lifecycles: [ObjectIdentifier: Lifecycle] = [:]
    private var singletons: [ObjectIdentifier: Any] = [:]
    private var resolvingStack: Set<ObjectIdentifier> = []
    
    func register<T>(_ type: T.Type, lifecycle: Lifecycle = .transient, factory: @escaping () -> T) {
        let identifier = ObjectIdentifier(type)
        factories[identifier] = factory
        lifecycles[identifier] = lifecycle
    }
    
    func resolve<T>() -> T {
        let identifier = ObjectIdentifier(T.self)
        
        if resolvingStack.contains(identifier) {
            let stackDescription = resolvingStack.map { "\($0)" }.joined(separator: " -> ")
            fatalError("Circular dependency detected: \(stackDescription) -> \(T.self)")
        }
        
        guard let factory = factories[identifier] else {
            fatalError("No registration for type \(T.self)")
        }
        
        if lifecycles[identifier] == .singleton {
            if let cached = singletons[identifier] as? T {
                return cached
            }
        }
        
        resolvingStack.insert(identifier)
        defer { resolvingStack.remove(identifier) }
        
        guard let instance = factory() as? T else {
            fatalError("Factory for \(T.self) returned wrong type")
        }
        
        if lifecycles[identifier] == .singleton {
            singletons[identifier] = instance
        }
        
        return instance
    }
    
    func reset() {
        factories.removeAll()
        lifecycles.removeAll()
        singletons.removeAll()
        resolvingStack.removeAll()
    }
}
