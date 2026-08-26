//
//  FetchProfilesUseCase.swift
//  MatchMate
//
//  Created by Omkar Chougule on 27/08/26.
//

import Foundation

public protocol FetchProfilesUseCase: Sendable {
    func execute(page: Int) async throws -> [Profile]
}

public struct DefaultFetchProfilesUseCase: FetchProfilesUseCase {
    private let repository: ProfileRepository

    public init(repository: ProfileRepository) {
        self.repository = repository
    }

    public func execute(page: Int) async throws -> [Profile] {
        try await repository.fetchProfiles(page: page)
    }
}
