//
//  InMemoryStore.swift
//  MissionControlTests
//


import Foundation
@testable import MissionControl

final class InMemoryStore<Entity: PersistableEntity>: PersistenceStore {
    private var items: [Entity]

    init(items: [Entity] = []) {
        self.items = items
    }

    func loadAll() -> [Entity] {
        items
    }

    func save(_ items: [Entity]) {
        self.items = items
    }
}
