//
//  MatchRepositoryTests.swift
//  MatchMateTests
//
//  Created by Omkar Chougule on 27/08/26.
//

import XCTest
@testable import MatchMate

final class MatchRepositoryTests: XCTestCase {
    private var mockAPI: MockMatchAPIService!
    private var mockStorage: MockProfileLocalStorage!
    private var sut: ProfileRepositoryImpl!

    override func setUp() {
        super.setUp()
        mockAPI = MockMatchAPIService()
        mockStorage = MockProfileLocalStorage()
        sut = ProfileRepositoryImpl(remote: mockAPI, local: mockStorage)
    }

    override func tearDown() {
        sut = nil
        mockStorage = nil
        mockAPI = nil
        super.tearDown()
    }

    func test_fetchProfiles_onlineSuccess_persistsAndReturnsProfiles() async throws {
        mockAPI.fetchProfilesResult = .success(MatchProfile.mockList)

        let result = try await sut.fetchProfiles(page: 1)

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(mockStorage.saveCallCount, 1)
        XCTAssertEqual(mockStorage.storedProfiles.count, 2)
    }

    func test_fetchProfiles_preservesDecisions_whenRefetched() async throws {
        // First load
        mockAPI.fetchProfilesResult = .success([MatchProfile.mock1])
        _ = try await sut.fetchProfiles(page: 1)

        // Accept user
        _ = try await sut.updateStatus(id: MatchProfile.mock1.id, status: .accepted)
        XCTAssertEqual(mockStorage.storedProfiles.first?.status, .accepted)

        // Refetch from API (API returns pending by default)
        mockAPI.fetchProfilesResult = .success([MatchProfile.mock1])
        let refetched = try await sut.fetchProfiles(page: 1)

        // Should retain .accepted decision
        XCTAssertEqual(refetched.first(where: { $0.id == MatchProfile.mock1.id })?.status, .accepted)
    }

    func test_fetchProfiles_networkFailureWithCache_returnsCachedProfiles() async throws {
        // Pre-populate storage
        mockStorage.storedProfiles = MatchProfile.mockList
        mockAPI.fetchProfilesResult = .failure(APIError.networkError("No internet"))

        let result = try await sut.fetchProfiles(page: 1)

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.first?.id, MatchProfile.mock1.id)
    }

    func test_fetchProfiles_networkFailureWithoutCache_throwsOfflineNoCachedData() async {
        mockStorage.storedProfiles = []
        mockAPI.fetchProfilesResult = .failure(APIError.networkError("No internet"))

        do {
            _ = try await sut.fetchProfiles(page: 1)
            XCTFail("Should have thrown offline error")
        } catch let error as ProfileRepositoryError {
            XCTAssertEqual(error, .offlineNoCachedData)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_updateStatus_updatesStorageAndYieldsToStream() async throws {
        mockStorage.storedProfiles = [MatchProfile.mock1]

        let expectation = expectation(description: "Stream emits updated profile")
        var streamedProfile: Profile?

        Task {
            for await profile in self.sut.profileUpdates {
                streamedProfile = profile
                expectation.fulfill()
                break
            }
        }

        let updated = try await sut.updateStatus(id: MatchProfile.mock1.id, status: .accepted)

        XCTAssertEqual(updated.status, .accepted)
        XCTAssertEqual(mockStorage.storedProfiles.first?.status, .accepted)

        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(streamedProfile?.id, MatchProfile.mock1.id)
        XCTAssertEqual(streamedProfile?.status, .accepted)
    }
}
