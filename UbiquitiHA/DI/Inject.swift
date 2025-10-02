//
//  Inject.swift
//  UbiquitiHA
//
//  Created by Ivannikov-EXTERNAL Georgiy on 02.10.2025.
//

@propertyWrapper
struct Inject<T> {
    let wrappedValue: T

    init(resolver: Resolver = DIContainer.shared) {
        self.wrappedValue = resolver.resolve()
    }
}
