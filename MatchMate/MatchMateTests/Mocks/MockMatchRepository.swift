//
//  MockMatchRepository.swift
//  MatchMateTests
//
//  Created by Omkar Chougule on 27/08/26.
//

import Foundation
@testable import MatchMate

public final class MockMatchRepository: ProfileRepository, @unchecked Sendable {
    public var profiles: [Profile] = []
    public var fetchResult: Result<[Profile], Error> = .success([])
    public var updateStatusResult: Result<Profile, Error>?
    public var fetchCallCount = 0
    public var updateStatusCallCount = 0

    private let updateStream: AsyncStream<Profile>
    private let updateContinuation: AsyncStream<Profile>.Continuation

    public var profileUpdates: AsyncStream<Profile> {
        updateStream
    }

    public init(initialProfiles: [Profile] = []) {
        self.profiles = initialProfiles
        self.fetchResult = .success(initialProfiles)

        var continuation: AsyncStream<Profile>.Continuation!
        self.updateStream = AsyncStream { cont in
            continuation = cont
        }
        self.updateContinuation = continuation
    }

    deinit {
        updateContinuation.finish()
    }

    public func fetchProfiles(page: Int) async throws -> [Profile] {
        fetchCallCount += 1
        switch fetchResult {
        case .success(let items):
            return items
        case .failure(let error):
            throw error
        }
    }

    public func cachedProfiles() async throws -> [Profile] {
        profiles
    }

    public func profile(id: String) async throws -> Profile {
        if let p = profiles.first(where: { $0.id == id }) {
            return p
        }
        throw ProfileRepositoryError.notFound
    }

    public func updateStatus(id: String, status: MatchStatus) async throws -> Profile {
        updateStatusCallCount += 1
        if let customResult = updateStatusResult {
            switch customResult {
            case .success(let updated):
                updateContinuation.yield(updated)
                return updated
            case .failure(let error):
                throw error
            }
        }

        guard let index = profiles.firstIndex(where: { $0.id == id }) else {
            throw ProfileRepositoryError.notFound
        }
        profiles[index].status = status
        let updated = profiles[index]
        updateContinuation.yield(updated)
        return updated
    }

    public func emitUpdate(_ profile: Profile) {
        updateContinuation.yield(profile)
    }
}
