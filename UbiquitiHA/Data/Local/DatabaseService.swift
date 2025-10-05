//
//  DatabaseServiceProtocol.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 04.10.2025.
//

import Foundation
import SwiftData

protocol DatabaseServiceProtocol {
    func create<T: DatabaseModel>(_ model: T) async throws
    func fetch<T: DatabaseModel>(of type: T.Type,
                                 sortDescriptors: [SortDescriptor<T>]) async throws -> [T]
    func update(_ block: (_ ctx: ModelContext) throws -> Void) async throws
    func delete<T: DatabaseModel>(_ model: T) async throws
}

final class DatabaseService: DatabaseServiceProtocol {
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
    }

    // MARK: - Background actors

    actor Reader {
        private let ctx: ModelContext
        init(container: ModelContainer) {
            ctx = ModelContext(container)
            ctx.autosaveEnabled = false
        }

        func fetch<T: DatabaseModel>(of type: T.Type,
                                     sort: [SortDescriptor<T>]) throws -> [T] {
            let fd = FetchDescriptor<T>(sortBy: sort)
            return try ctx.fetch(fd)
        }
    }

    actor Writer {
        private let ctx: ModelContext
        init(container: ModelContainer) {
            ctx = ModelContext(container)
            ctx.autosaveEnabled = false
        }

        func insert<T: DatabaseModel>(_ model: T) throws {
            ctx.insert(model)
            try ctx.save()
        }

        func delete<T: DatabaseModel>(_ model: T) throws {
            ctx.delete(model)
            try ctx.save()
        }

        func perform(_ block: (_ ctx: ModelContext) throws -> Void) throws {
            try block(ctx)
            try ctx.save()
        }
    }

    private lazy var reader = Reader(container: container)
    private lazy var writer = Writer(container: container)

    // MARK: - API

    func create<T: DatabaseModel>(_ model: T) async throws {
        try await writer.insert(model)
    }

    func fetch<T: DatabaseModel>(of type: T.Type,
                                 sortDescriptors: [SortDescriptor<T>] = []) async throws -> [T] {
        try await reader.fetch(of: type, sort: sortDescriptors)
    }

    func update(_ block: (_ ctx: ModelContext) throws -> Void) async throws {
        try await writer.perform(block)
    }

    func delete<T: DatabaseModel>(_ model: T) async throws {
        try await writer.delete(model)
    }
}
