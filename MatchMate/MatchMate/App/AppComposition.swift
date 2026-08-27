//
//  AppComposition.swift
//  MatchMate
//
//  Created by Omkar Chougule on 27/08/26.
//

import Foundation
import SwiftData

/// Composition root for protocol-based dependency injection
enum AppComposition {
    @MainActor
    static func makeMatchListViewModel(context: ModelContext) -> MatchListViewModel {
        let remote = RandomUserRemoteDataSource(session: .shared)
        let local = SwiftDataLocalDataSource(context: context)
        let repository = ProfileRepositoryImpl(remote: remote, local: local)
        return MatchListViewModel(repository: repository)
    }

    @MainActor
    static func makeMatchDetailViewModel(profileId: String, context: ModelContext) -> MatchDetailViewModel {
        let remote = RandomUserRemoteDataSource(session: .shared)
        let local = SwiftDataLocalDataSource(context: context)
        let repository = ProfileRepositoryImpl(remote: remote, local: local)
        return MatchDetailViewModel(profileId: profileId, repository: repository)
    }
}
