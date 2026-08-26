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

    public let profileId: String
    private let repository: ProfileRepository
    private let updateStatus: UpdateMatchStatusUseCase
    private let bioGenerator: BioGeneratorServiceProtocol
    private var updatesTask: Task<Void, Never>?

    public init(
        profileId: String,
        repository: ProfileRepository,
        updateStatus: UpdateMatchStatusUseCase,
        bioGenerator: BioGeneratorServiceProtocol = FoundationBioGenerator.shared
    ) {
        self.profileId = profileId
        self.repository = repository
        self.updateStatus = updateStatus
        self.bioGenerator = bioGenerator
        listenToProfileUpdates()
    }

    public convenience init(
        profile: Profile,
        repository: ProfileRepository,
        updateStatus: UpdateMatchStatusUseCase? = nil,
        bioGenerator: BioGeneratorServiceProtocol = FoundationBioGenerator.shared
    ) {
        let useCase = updateStatus ?? DefaultUpdateMatchStatusUseCase(repository: repository)
        self.init(
            profileId: profile.id,
            repository: repository,
            updateStatus: useCase,
            bioGenerator: bioGenerator
        )
        self.profile = profile
    }

    deinit {
        updatesTask?.cancel()
    }

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
        await update(status: .accepted)
    }

    @MainActor
    public func decline() async {
        await update(status: .declined)
    }

    @MainActor
    public func update(status newStatus: MatchStatus) async {
        guard var currentProfile = profile else {
            // If profile not loaded yet, fetch first
            await loadProfile()
            if profile == nil { return }
            await update(status: newStatus)
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
            let updated = try await updateStatus.execute(id: profileId, status: newStatus)
            self.profile = updated
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
