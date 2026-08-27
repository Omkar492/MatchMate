//
//  MatchListViewModelTests.swift
//  MatchMateTests
//
//  Created by Omkar Chougule on 27/08/26.
//

import XCTest
@testable import MatchMate

@MainActor
final class MatchListViewModelTests: XCTestCase {
    private var mockRepo: MockMatchRepository!
    private var sut: MatchListViewModel!

    override func setUp() {
        super.setUp()
        mockRepo = MockMatchRepository(initialProfiles: MatchProfile.mockList)
        sut = MatchListViewModel(repository: mockRepo)
    }

    override func tearDown() {
        sut = nil
        mockRepo = nil
        super.tearDown()
    }

    func test_loadInitial_success_populatesProfiles() async {
        mockRepo.fetchResult = .success(MatchProfile.mockList)

        await sut.loadInitial(forceRefresh: true)

        XCTAssertEqual(sut.allProfiles.count, 2)
        XCTAssertEqual(sut.allProfiles.first?.id, MatchProfile.mock1.id)
        XCTAssertNil(sut.error)
        XCTAssertFalse(sut.isOffline)
        XCTAssertFalse(sut.isLoadingInitial)
    }

    func test_loadInitial_offlineNoCache_setsOfflineError() async {
        mockRepo.profiles = []
        mockRepo.fetchResult = .failure(ProfileRepositoryError.offlineNoCachedData)

        await sut.loadInitial(forceRefresh: true)

        XCTAssertTrue(sut.allProfiles.isEmpty)
        XCTAssertTrue(sut.isOffline)
        XCTAssertEqual(sut.error, ProfileRepositoryError.offlineNoCachedData)
    }

    func test_loadNextPageIfNeeded_whenAtBottom_fetchesNextPage() async {
        mockRepo.fetchResult = .success(MatchProfile.mockList)
        await sut.loadInitial(forceRefresh: true)

        let page2Profiles = [
            MatchProfile(id: "p3", firstName: "Alice", lastName: "Wonder", age: 24, status: .pending, pageIndex: 2),
            MatchProfile(id: "p4", firstName: "Bob", lastName: "Ross", age: 35, status: .pending, pageIndex: 2)
        ]
        mockRepo.fetchResult = .success(MatchProfile.mockList + page2Profiles)

        guard let lastProfile = sut.allProfiles.last else {
            XCTFail("Profiles should not be empty")
            return
        }

        await sut.loadNextPageIfNeeded(currentItem: lastProfile)

        XCTAssertEqual(sut.allProfiles.count, 4)
        XCTAssertEqual(sut.allProfiles.last?.id, "p4")
    }

    func test_loadNextPageIfNeeded_whenNotAtBottom_doesNotTrigger() async {
        let p1 = MatchProfile(id: "p1", firstName: "A", lastName: "B", age: 20, status: .pending, pageIndex: 1)
        let p2 = MatchProfile(id: "p2", firstName: "C", lastName: "D", age: 21, status: .pending, pageIndex: 1)
        let p3 = MatchProfile(id: "p3", firstName: "E", lastName: "F", age: 22, status: .pending, pageIndex: 1)
        let p4 = MatchProfile(id: "p4", firstName: "G", lastName: "H", age: 23, status: .pending, pageIndex: 1)
        let p5 = MatchProfile(id: "p5", firstName: "I", lastName: "J", age: 24, status: .pending, pageIndex: 1)
        let p6 = MatchProfile(id: "p6", firstName: "K", lastName: "L", age: 25, status: .pending, pageIndex: 1)

        mockRepo.fetchResult = .success([p1, p2, p3, p4, p5, p6])
        await sut.loadInitial(forceRefresh: true)

        let initialCallCount = mockRepo.fetchCallCount

        // Trigger on the first item (far from the bottom threshold of 4 items)
        await sut.loadNextPageIfNeeded(currentItem: p1)

        XCTAssertEqual(mockRepo.fetchCallCount, initialCallCount)
    }

    func test_accept_optimisticUpdate_andPersistenceSuccess() async {
        mockRepo.fetchResult = .success(MatchProfile.mockList)
        await sut.loadInitial(forceRefresh: true)

        let targetId = MatchProfile.mock1.id
        XCTAssertEqual(sut.allProfiles.first(where: { $0.id == targetId })?.status, .pending)

        await sut.accept(id: targetId)

        XCTAssertEqual(sut.allProfiles.first(where: { $0.id == targetId })?.status, .accepted)
        XCTAssertEqual(mockRepo.updateStatusCallCount, 1)
        XCTAssertNil(sut.error)
    }

    func test_decline_optimisticUpdate_andPersistenceSuccess() async {
        mockRepo.fetchResult = .success(MatchProfile.mockList)
        await sut.loadInitial(forceRefresh: true)

        let targetId = MatchProfile.mock1.id
        XCTAssertEqual(sut.allProfiles.first(where: { $0.id == targetId })?.status, .pending)

        await sut.decline(id: targetId)

        XCTAssertEqual(sut.allProfiles.first(where: { $0.id == targetId })?.status, .declined)
        XCTAssertEqual(mockRepo.updateStatusCallCount, 1)
        XCTAssertNil(sut.error)
    }

    func test_accept_failure_rollsBackStatus() async {
        mockRepo.fetchResult = .success(MatchProfile.mockList)
        await sut.loadInitial(forceRefresh: true)

        let targetId = MatchProfile.mock1.id
        mockRepo.updateStatusResult = .failure(ProfileRepositoryError.persistenceError("Disk full"))

        await sut.accept(id: targetId)

        // Status should be rolled back to pending
        XCTAssertEqual(sut.allProfiles.first(where: { $0.id == targetId })?.status, .pending)
        XCTAssertNotNil(sut.error)
    }

    func test_repositoryProfileUpdate_automaticallySyncsList() async {
        mockRepo.fetchResult = .success(MatchProfile.mockList)
        await sut.loadInitial(forceRefresh: true)

        var updatedMock = MatchProfile.mock1
        updatedMock.status = .accepted

        mockRepo.emitUpdate(updatedMock)

        // Give the async stream a moment to dispatch
        try? await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(sut.allProfiles.first(where: { $0.id == MatchProfile.mock1.id })?.status, .accepted)
    }
}
