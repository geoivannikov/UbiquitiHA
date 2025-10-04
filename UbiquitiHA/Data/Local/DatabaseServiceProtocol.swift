//
//  DatabaseServiceProtocol.swift
//  UbiquitiHA
//
//  Created by Ivannikov-EXTERNAL Georgiy on 04.10.2025.
//

import Foundation
import SwiftData

protocol DatabaseServiceProtocol {
    func create<T: DatabaseModel>(_ model: T) throws
    func fetch<T: DatabaseModel>(of type: T.Type, sortDescriptors: [SortDescriptor<T>]) throws -> [T]
    func update(_ block: () throws -> Void) throws
    func delete<T: DatabaseModel>(_ model: T) throws
    func deleteAll<T: DatabaseModel>(of type: T.Type) throws
}

final class DatabaseService: DatabaseServiceProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func create<T: DatabaseModel>(_ model: T) throws {
        context.insert(model)
        try context.save()
    }

    func fetch<T: DatabaseModel>(of type: T.Type, sortDescriptors: [SortDescriptor<T>] = []) throws -> [T] {
        let descriptor = FetchDescriptor<T>(sortBy: sortDescriptors)
        return try context.fetch(descriptor)
    }
    
    func update(_ block: () throws -> Void) throws {
        try block()
        try context.save()
    }
    
    func delete<T: DatabaseModel>(_ model: T) throws {
        context.delete(model)
        try context.save()
    }

    func deleteAll<T: DatabaseModel>(of type: T.Type) throws {
        try fetch(of: type).forEach { context.delete($0) }
        try context.save()
    }
}
