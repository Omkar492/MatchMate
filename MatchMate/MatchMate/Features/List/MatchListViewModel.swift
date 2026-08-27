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
    // MARK: - State Properties

    public var allProfiles: [Profile] = []
    public var acceptedProfiles: [Profile] = []
    public var declinedProfiles: [Profile] = []

    public var selectedFilter: MatchFilter = .all {
        didSet {
            if selectedFilter != .all {
                Task { @MainActor in
                    await loadDecidedProfilesFromSwiftData()
                }
            }
        }
    }

    public var isLoadingInitial: Bool = false
    public var isLoadingNextPage: Bool = false
    public var isRefreshing: Bool = false
    public var error: ProfileRepositoryError?
    public var isOffline: Bool = false
    public var hasMorePages: Bool = true

    /// Active profiles to display in the UI based on selected filter
    public var displayedProfiles: [Profile] {
        switch selectedFilter {
        case .all:
            return allProfiles
        case .accepted:
            return acceptedProfiles
        case .declined:
            return declinedProfiles
        }
    }

    public var filteredProfiles: [Profile] {
        displayedProfiles
    }

    public var profiles: [Profile] {
        get { allProfiles }
        set { allProfiles = newValue }
    }

    // MARK: - Dependencies

    private let repository: ProfileRepository
    private var currentPage: Int = 1
    private var updatesTask: Task<Void, Never>?

    // MARK: - Initialization

    public init(repository: ProfileRepository) {
        self.repository = repository
        listenToProfileUpdates()
    }

    deinit {
        updatesTask?.cancel()
    }

    // MARK: - Live Stream Listening

    private func listenToProfileUpdates() {
        updatesTask = Task { [weak self] in
            guard let self else { return }
            for await updatedProfile in self.repository.profileUpdates {
                await MainActor.run {
                    if let index = self.allProfiles.firstIndex(where: { $0.id == updatedProfile.id }) {
                        self.allProfiles[index] = updatedProfile
                    }
                    Task { await self.loadDecidedProfilesFromSwiftData() }
                }
            }
        }
    }

    // MARK: - Actions

    @MainActor
    public func loadInitial(forceRefresh: Bool = false) async {
        if selectedFilter != .all {
            await loadDecidedProfilesFromSwiftData()
            return
        }

        if !forceRefresh && !allProfiles.isEmpty {
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
            self.allProfiles = try await repository.fetchProfiles(page: 1)
            self.isOffline = false
            await loadDecidedProfilesFromSwiftData()
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
        guard selectedFilter == .all else { return }
        guard !isLoadingInitial, !isLoadingNextPage, hasMorePages else { return }

        guard let index = allProfiles.firstIndex(where: { $0.id == currentItem.id }) else { return }
        let thresholdIndex = max(0, allProfiles.count - 4)
        guard index >= thresholdIndex else { return }

        isLoadingNextPage = true
        let nextPage = currentPage + 1

        do {
            let fetched = try await repository.fetchProfiles(page: nextPage)
            if fetched.count > self.allProfiles.count {
                self.allProfiles = fetched
                self.currentPage = nextPage
                await loadDecidedProfilesFromSwiftData()
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
    public func accept(id: String) async {
        await optimisticallyUpdateStatus(id: id, newStatus: .accepted)
    }

    @MainActor
    public func decline(id: String) async {
        await optimisticallyUpdateStatus(id: id, newStatus: .declined)
    }

    @MainActor
    private func optimisticallyUpdateStatus(id: String, newStatus: MatchStatus) async {
        guard let index = allProfiles.firstIndex(where: { $0.id == id }) else { return }
        let oldStatus = allProfiles[index].status
        guard oldStatus != newStatus else { return }

        // 1. Optimistic in-memory update
        allProfiles[index].status = newStatus

        // 2. Persist to SwiftData
        do {
            _ = try await repository.updateStatus(id: id, status: newStatus)
            await loadDecidedProfilesFromSwiftData()
        } catch {
            // 3. Rollback on failure
            allProfiles[index].status = oldStatus
            self.error = .persistenceError(error.localizedDescription)
        }
    }

    @MainActor
    public func loadDecidedProfilesFromSwiftData() async {
        do {
            async let acceptedTask = repository.cachedProfiles(status: .accepted)
            async let declinedTask = repository.cachedProfiles(status: .declined)

            let (accepted, declined) = try await (acceptedTask, declinedTask)
            self.acceptedProfiles = accepted
            self.declinedProfiles = declined
        } catch {
            // SwiftData error
        }
    }

    @MainActor
    public func refreshFromCache() async {
        do {
            let cached = try await repository.cachedProfiles()
            if !cached.isEmpty {
                self.allProfiles = cached
                self.isOffline = false
            }
            await loadDecidedProfilesFromSwiftData()
        } catch {
            // Cache query error
        }
    }

    public func dismissError() {
        self.error = nil
    }
}
