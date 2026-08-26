//
//  MatchDetailViewModelTests.swift
//  MatchMateTests
//
//  Created by Omkar Chougule on 27/08/26.
//

import XCTest
@testable import MatchMate

@MainActor
final class MatchDetailViewModelTests: XCTestCase {
    private var mockRepo: MockMatchRepository!
    private var sut: MatchDetailViewModel!

    override func setUp() {
        super.setUp()
        mockRepo = MockMatchRepository(initialProfiles: [MatchProfile.mock1])
        sut = MatchDetailViewModel(profile: MatchProfile.mock1, repository: mockRepo)
    }

    override func tearDown() {
        sut = nil
        mockRepo = nil
        super.tearDown()
    }

    func test_loadProfile_success_updatesProfile() async {
        var modified = MatchProfile.mock1
        modified.status = .accepted
        mockRepo.profiles = [modified]

        await sut.loadProfile()

        XCTAssertEqual(sut.profile?.status, .accepted)
        XCTAssertNil(sut.error)
    }

    func test_accept_optimisticUpdate_andPersistenceSuccess() async {
        XCTAssertEqual(sut.profile?.status, .pending)

        await sut.accept()

        XCTAssertEqual(sut.profile?.status, .accepted)
        XCTAssertEqual(mockRepo.updateStatusCallCount, 1)
        XCTAssertNil(sut.error)
    }

    func test_decline_optimisticUpdate_andPersistenceSuccess() async {
        XCTAssertEqual(sut.profile?.status, .pending)

        await sut.decline()

        XCTAssertEqual(sut.profile?.status, .declined)
        XCTAssertEqual(mockRepo.updateStatusCallCount, 1)
        XCTAssertNil(sut.error)
    }

    func test_updateStatus_failure_rollsBack() async {
        mockRepo.updateStatusResult = .failure(ProfileRepositoryError.persistenceError("Database error"))

        await sut.accept()

        XCTAssertEqual(sut.profile?.status, .pending)
        XCTAssertNotNil(sut.error)
    }

    func test_externalRepositoryUpdate_synchronizesDetailProfile() async {
        var updated = MatchProfile.mock1
        updated.status = .accepted

        mockRepo.emitUpdate(updated)

        try? await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(sut.profile?.status, .accepted)
    }
}
