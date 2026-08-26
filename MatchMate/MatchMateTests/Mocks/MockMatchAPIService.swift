//
//  MockMatchAPIService.swift
//  MatchMateTests
//
//  Created by Omkar Chougule on 27/08/26.
//

import Foundation
@testable import MatchMate

public final class MockMatchAPIService: RandomUserRemoteDataSourceProtocol, @unchecked Sendable {
    public var fetchProfilesResult: Result<[Profile], Error> = .success([])
    public var lastRequestedPage: Int?
    public var fetchCallCount = 0

    public init(fetchProfilesResult: Result<[Profile], Error> = .success([])) {
        self.fetchProfilesResult = fetchProfilesResult
    }

    public func fetchProfiles(page: Int, resultsPerPage: Int, seed: String) async throws -> [Profile] {
        fetchCallCount += 1
        lastRequestedPage = page
        switch fetchProfilesResult {
        case .success(let profiles):
            return profiles
        case .failure(let error):
            throw error
        }
    }
}
