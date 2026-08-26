//
//  MatchListViewModel.swift
//  MatchMate
//
//  Created by Omkar Chougule on 27/08/26.
//

import Foundation
import Observation

public enum MatchFilter: String, CaseIterable, Sendable {
    case all = "All"
    case accepted = "Accepted"
    case declined = "Declined"
}

@Observable
public final class MatchListViewModel {
    public var profiles: [Profile] = []
    public var selectedFilter: MatchFilter = .all
    public var isLoadingInitial: Bool = false
    public var isLoadingNextPage: Bool = false
    public var isRefreshing: Bool = false
    public var error: ProfileRepositoryError?
    public var isOffline: Bool = false
    public var hasMorePages: Bool = true

    public var filteredProfiles: [Profile] {
        switch selectedFilter {
        case .all:
            return profiles
        case .accepted:
            return profiles.filter { $0.status == .accepted }
        case .declined:
            return profiles.filter { $0.status == .declined }
        }
    }

    public var isLoadingPage: Bool {
        isLoadingInitial || isLoadingNextPage
    }

    private let fetchProfiles: FetchProfilesUseCase
    private let updateStatus: UpdateMatchStatusUseCase
    private let repository: ProfileRepository
    private var currentPage: Int = 1
    private var updatesTask: Task<Void, Never>?

    public init(
        fetchProfiles: FetchProfilesUseCase,
        updateStatus: UpdateMatchStatusUseCase,
        repository: ProfileRepository
    ) {
        self.fetchProfiles = fetchProfiles
        self.updateStatus = updateStatus
        self.repository = repository
        listenToProfileUpdates()
    }

    public convenience init(repository: ProfileRepository) {
        self.init(
            fetchProfiles: DefaultFetchProfilesUseCase(repository: repository),
            updateStatus: DefaultUpdateMatchStatusUseCase(repository: repository),
            repository: repository
        )
    }

    deinit {
        updatesTask?.cancel()
    }

    private func listenToProfileUpdates() {
        updatesTask = Task { [weak self] in
            guard let self else { return }
            for await updatedProfile in self.repository.profileUpdates {
                await MainActor.run {
                    if let index = self.profiles.firstIndex(where: { $0.id == updatedProfile.id }) {
                        self.profiles[index] = updatedProfile
                    }
                }
            }
        }
    }

    @MainActor
    public func loadInitial(forceRefresh: Bool = false) async {
        if !forceRefresh && !profiles.isEmpty {
            await refreshFromCache()
            return
        }

        if forceRefresh {
            isRefreshing = true
        } else {
            isLoadingInitial = true
        }
        error = nil
        currentPage = 1
        hasMorePages = true

        do {
            let fetched = try await fetchProfiles.execute(page: 1)
            self.profiles = fetched
            self.isOffline = false
        } catch let repoError as ProfileRepositoryError {
            self.error = repoError
            if case .offlineNoCachedData = repoError {
                self.isOffline = true
            } else {
                await refreshFromCache()
            }
        } catch {
            self.error = .unknown(error.localizedDescription)
            await refreshFromCache()
        }

        isLoadingInitial = false
        isRefreshing = false
    }

    @MainActor
    public func loadNextPageIfNeeded(currentItem: Profile) async {
        guard !isLoadingInitial, !isLoadingNextPage, hasMorePages else { return }

        // Find index of current item in profiles
        guard let index = profiles.firstIndex(where: { $0.id == currentItem.id }) else { return }

        // Trigger pagination smoothly when within the last 4 items
        let thresholdIndex = max(0, profiles.count - 4)
        guard index >= thresholdIndex else { return }

        isLoadingNextPage = true
        let nextPage = currentPage + 1

        do {
            let fetched = try await fetchProfiles.execute(page: nextPage)
            if fetched.count > self.profiles.count {
                self.profiles = fetched
                self.currentPage = nextPage
            } else {
                self.hasMorePages = false
            }
        } catch let repoError as ProfileRepositoryError {
            self.error = repoError
            if case .offlineNoCachedData = repoError {
                self.hasMorePages = false
            }
        } catch {
            self.error = .unknown(error.localizedDescription)
        }

        isLoadingNextPage = false
    }

    @MainActor
    public func loadNextPageIfNeeded(currentProfile: Profile) async {
        await loadNextPageIfNeeded(currentItem: currentProfile)
    }

    @MainActor
    public func accept(_ id: String) async {
        await optimisticallyUpdateStatus(id: id, newStatus: .accepted)
    }

    @MainActor
    public func accept(id: String) async {
        await accept(id)
    }

    @MainActor
    public func decline(_ id: String) async {
        await optimisticallyUpdateStatus(id: id, newStatus: .declined)
    }

    @MainActor
    public func decline(id: String) async {
        await decline(id)
    }

    @MainActor
    private func optimisticallyUpdateStatus(id: String, newStatus: MatchStatus) async {
        guard let index = profiles.firstIndex(where: { $0.id == id }) else { return }
        let oldStatus = profiles[index].status
        guard oldStatus != newStatus else { return }

        // 1. Optimistic UI update
        profiles[index].status = newStatus

        // 2. Persist to SwiftData
        do {
            _ = try await updateStatus.execute(id: id, status: newStatus)
        } catch {
            // 3. Rollback on failure
            profiles[index].status = oldStatus
            self.error = .persistenceError(error.localizedDescription)
        }
    }

    @MainActor
    public func refreshFromCache() async {
        do {
            let cached = try await repository.cachedProfiles()
            if !cached.isEmpty {
                self.profiles = cached
                self.isOffline = false
            }
        } catch {
            // Cache fetch error
        }
    }

    public func dismissError() {
        self.error = nil
    }
}
