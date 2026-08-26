//
//  MockProfileLocalStorage.swift
//  MatchMateTests
//
//  Created by Omkar Chougule on 27/08/26.
//

import Foundation
@testable import MatchMate

public final class MockProfileLocalStorage: SwiftDataLocalDataSourceProtocol, @unchecked Sendable {
    public var storedProfiles: [Profile] = []
    public var shouldThrowError: Error?
    public var saveCallCount = 0
    public var updateStatusCallCount = 0

    public init(storedProfiles: [Profile] = []) {
        self.storedProfiles = storedProfiles
    }

    public func saveProfiles(_ profiles: [Profile], forPage page: Int) async throws -> [Profile] {
        if let error = shouldThrowError {
            throw error
        }
        saveCallCount += 1

        for profile in profiles {
            if let index = storedProfiles.firstIndex(where: { $0.id == profile.id }) {
                // Preserve decision
                var existing = storedProfiles[index]
                if existing.status == .pending {
                    existing.status = profile.status
                }
                existing.pageIndex = page
                storedProfiles[index] = existing
            } else {
                var newProfile = profile
                newProfile.pageIndex = page
                storedProfiles.append(newProfile)
            }
        }
        return storedProfiles
    }

    public func fetchProfiles() async throws -> [Profile] {
        if let error = shouldThrowError {
            throw error
        }
        return storedProfiles
    }

    public func fetchProfile(id: String) async throws -> Profile? {
        if let error = shouldThrowError {
            throw error
        }
        return storedProfiles.first(where: { $0.id == id })
    }

    public func updateStatus(id: String, status: MatchStatus) async throws -> Profile {
        if let error = shouldThrowError {
            throw error
        }
        updateStatusCallCount += 1
        guard let index = storedProfiles.firstIndex(where: { $0.id == id }) else {
            throw ProfileRepositoryError.notFound
        }
        storedProfiles[index].status = status
        return storedProfiles[index]
    }

    public func clearAll() async throws {
        if let error = shouldThrowError {
            throw error
        }
        storedProfiles.removeAll()
    }
}
