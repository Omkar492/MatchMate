//
//  ProfileRepositoryImpl.swift
//  MatchMate
//
//  Created by Omkar Chougule on 27/08/26.
//

import Foundation

public final class ProfileRepositoryImpl: ProfileRepository, @unchecked Sendable {
    private let remote: RandomUserRemoteDataSourceProtocol
    private let local: SwiftDataLocalDataSourceProtocol

    private let updateStream: AsyncStream<Profile>
    private let updateContinuation: AsyncStream<Profile>.Continuation

    public var profileUpdates: AsyncStream<Profile> {
        updateStream
    }

    public init(
        remote: RandomUserRemoteDataSourceProtocol,
        local: SwiftDataLocalDataSourceProtocol
    ) {
        self.remote = remote
        self.local = local

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
        do {
            let remoteProfiles = try await remote.fetchProfiles(page: page)
            _ = try await local.saveProfiles(remoteProfiles, forPage: page)
            return try await local.fetchProfiles()
        } catch let apiError as APIError {
            switch apiError {
            case .networkError, .invalidURL, .invalidResponse:
                return try await handleOfflineFallback()
            case .decodingError(let msg):
                throw ProfileRepositoryError.decodingError(msg)
            case .unknown:
                return try await handleOfflineFallback()
            }
        } catch let repoError as ProfileRepositoryError {
            throw repoError
        } catch {
            return try await handleOfflineFallback()
        }
    }

    public func cachedProfiles() async throws -> [Profile] {
        do {
            return try await local.fetchProfiles()
        } catch {
            throw ProfileRepositoryError.persistenceError(error.localizedDescription)
        }
    }

    public func cachedProfiles(status: MatchStatus) async throws -> [Profile] {
        do {
            return try await local.fetchProfiles(status: status)
        } catch {
            throw ProfileRepositoryError.persistenceError(error.localizedDescription)
        }
    }

    public func profile(id: String) async throws -> Profile {
        do {
            if let profile = try await local.fetchProfile(id: id) {
                return profile
            }
            throw ProfileRepositoryError.notFound
        } catch let repoError as ProfileRepositoryError {
            throw repoError
        } catch {
            throw ProfileRepositoryError.persistenceError(error.localizedDescription)
        }
    }

    public func updateStatus(id: String, status: MatchStatus) async throws -> Profile {
        do {
            let updatedProfile = try await local.updateStatus(id: id, status: status)
            updateContinuation.yield(updatedProfile)
            return updatedProfile
        } catch let repoError as ProfileRepositoryError {
            throw repoError
        } catch {
            throw ProfileRepositoryError.persistenceError(error.localizedDescription)
        }
    }

    private func handleOfflineFallback() async throws -> [Profile] {
        let cached = try await local.fetchProfiles()
        if !cached.isEmpty {
            return cached
        }
        throw ProfileRepositoryError.offlineNoCachedData
    }
}
