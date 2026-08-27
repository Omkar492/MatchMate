//
//  SwiftDataLocalDataSource.swift
//  MatchMate
//
//  Created by Omkar Chougule on 27/08/26.
//

import Foundation
import SwiftData

public protocol SwiftDataLocalDataSourceProtocol: Sendable {
    func saveProfiles(_ profiles: [Profile], forPage page: Int) async throws -> [Profile]
    func fetchProfiles() async throws -> [Profile]
    func fetchProfiles(status: MatchStatus) async throws -> [Profile]
    func fetchProfile(id: String) async throws -> Profile?
    func updateStatus(id: String, status: MatchStatus) async throws -> Profile
    func clearAll() async throws
}

extension SwiftDataLocalDataSourceProtocol {
    public func fetchProfiles(status: MatchStatus) async throws -> [Profile] {
        let all = try await fetchProfiles()
        return all.filter { $0.status == status }
    }
}

@MainActor
public final class SwiftDataLocalDataSource: SwiftDataLocalDataSourceProtocol {
    private let context: ModelContext

    public init(context: ModelContext) {
        self.context = context
    }

    public func saveProfiles(_ profiles: [Profile], forPage page: Int) async throws -> [Profile] {
        var resultProfiles: [Profile] = []

        for (index, profile) in profiles.enumerated() {
            let profileId = profile.id
            let descriptor = FetchDescriptor<ProfileEntity>(
                predicate: #Predicate<ProfileEntity> { entity in
                    entity.id == profileId
                }
            )

            let existingEntities = try context.fetch(descriptor)
            let calculatedOrder = (page - 1) * 100 + index

            if let existing = existingEntities.first {
                // Update profile attributes while preserving previously saved accept/decline decisions
                existing.update(from: profile, preserveDecision: true)
                if existing.orderIndex == 0 && calculatedOrder > 0 {
                    existing.orderIndex = calculatedOrder
                }
                resultProfiles.append(existing.toDomain())
            } else {
                var newProfile = profile
                newProfile.pageIndex = page
                let entity = ProfileEntity(from: newProfile)
                entity.orderIndex = calculatedOrder
                context.insert(entity)
                resultProfiles.append(entity.toDomain())
            }
        }

        try context.save()
        return resultProfiles
    }

    public func fetchProfiles() async throws -> [Profile] {
        var descriptor = FetchDescriptor<ProfileEntity>(
            sortBy: [
                SortDescriptor(\.orderIndex, order: .forward),
                SortDescriptor(\.pageIndex, order: .forward)
            ]
        )
        descriptor.includePendingChanges = true

        let entities = try context.fetch(descriptor)
        return entities.map { $0.toDomain() }
    }

    public func fetchProfiles(status: MatchStatus) async throws -> [Profile] {
        let raw = status.rawValue
        var descriptor = FetchDescriptor<ProfileEntity>(
            predicate: #Predicate<ProfileEntity> { entity in
                entity.statusRaw == raw
            },
            sortBy: [
                SortDescriptor(\.orderIndex, order: .forward),
                SortDescriptor(\.updatedAt, order: .reverse)
            ]
        )
        descriptor.includePendingChanges = true

        let entities = try context.fetch(descriptor)
        return entities.map { $0.toDomain() }
    }

    public func fetchProfile(id: String) async throws -> Profile? {
        let descriptor = FetchDescriptor<ProfileEntity>(
            predicate: #Predicate<ProfileEntity> { entity in
                entity.id == id
            }
        )

        let entities = try context.fetch(descriptor)
        return entities.first?.toDomain()
    }

    public func updateStatus(id: String, status: MatchStatus) async throws -> Profile {
        let descriptor = FetchDescriptor<ProfileEntity>(
            predicate: #Predicate<ProfileEntity> { entity in
                entity.id == id
            }
        )

        let entities = try context.fetch(descriptor)
        guard let entity = entities.first else {
            throw ProfileRepositoryError.notFound
        }

        entity.statusRaw = status.rawValue
        entity.updatedAt = Date()
        try context.save()

        return entity.toDomain()
    }

    public func clearAll() async throws {
        try context.delete(model: ProfileEntity.self)
        try context.save()
    }
}
