//
//  MatchDetailViewModel.swift
//  MatchMate
//
//  Created by Omkar Chougule on 27/08/26.
//

import Foundation
import Observation

@Observable
public final class MatchDetailViewModel {
    // MARK: - State Properties

    public var profile: Profile?
    public var error: ProfileRepositoryError?
    public var isUpdating: Bool = false
    public var generatedBio: String = ""

    public var bioText: String {
        if !generatedBio.isEmpty {
            return generatedBio
        }
        if let profile = profile {
            return "Hi, I'm \(profile.fullName). I enjoy meaningful conversations, traveling, fitness, and building genuine connections with like-minded people."
        }
        return ""
    }

    // MARK: - Dependencies

    public let profileId: String
    private let repository: ProfileRepository
    private let bioGenerator: BioGeneratorServiceProtocol
    private var updatesTask: Task<Void, Never>?

    // MARK: - Initialization

    public init(
        profileId: String,
        repository: ProfileRepository,
        bioGenerator: BioGeneratorServiceProtocol = FoundationBioGenerator.shared
    ) {
        self.profileId = profileId
        self.repository = repository
        self.bioGenerator = bioGenerator
        listenToProfileUpdates()
    }

    public convenience init(
        profile: Profile,
        repository: ProfileRepository,
        bioGenerator: BioGeneratorServiceProtocol = FoundationBioGenerator.shared
    ) {
        self.init(profileId: profile.id, repository: repository, bioGenerator: bioGenerator)
        self.profile = profile
    }

    deinit {
        updatesTask?.cancel()
    }

    // MARK: - Live Stream Listening

    private func listenToProfileUpdates() {
        updatesTask = Task { [weak self] in
            guard let self else { return }
            for await updatedProfile in self.repository.profileUpdates {
                if updatedProfile.id == self.profileId {
                    await MainActor.run {
                        self.profile = updatedProfile
                    }
                }
            }
        }
    }

    // MARK: - Actions

    @MainActor
    public func loadProfile() async {
        do {
            let fetched = try await repository.profile(id: profileId)
            self.profile = fetched
            self.generatedBio = await bioGenerator.generateBio(for: fetched)
        } catch let repoError as ProfileRepositoryError {
            self.error = repoError
        } catch {
            self.error = .unknown(error.localizedDescription)
        }
    }

    @MainActor
    public func accept() async {
        await updateStatus(to: .accepted)
    }

    @MainActor
    public func decline() async {
        await updateStatus(to: .declined)
    }

    @MainActor
    private func updateStatus(to newStatus: MatchStatus) async {
        guard var currentProfile = profile else {
            await loadProfile()
            if profile == nil { return }
            await updateStatus(to: newStatus)
            return
        }

        guard currentProfile.status != newStatus else { return }
        let oldStatus = currentProfile.status

        // 1. Optimistic UI update
        currentProfile.status = newStatus
        self.profile = currentProfile
        isUpdating = true

        // 2. Persist to SwiftData
        do {
            self.profile = try await repository.updateStatus(id: profileId, status: newStatus)
        } catch {
            // 3. Rollback on failure
            currentProfile.status = oldStatus
            self.profile = currentProfile
            self.error = .persistenceError(error.localizedDescription)
        }

        isUpdating = false
    }

    public func dismissError() {
        self.error = nil
    }
}
