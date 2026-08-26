//
//  SwiftDataProfileStorageTests.swift
//  MatchMateTests
//
//  Created by Omkar Chougule on 27/08/26.
//

import XCTest
import SwiftData
@testable import MatchMate

@MainActor
final class SwiftDataProfileStorageTests: XCTestCase {
    private var container: ModelContainer!
    private var sut: SwiftDataLocalDataSource!

    override func setUp() async throws {
        try await super.setUp()
        let schema = Schema([ProfileEntity.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [config])
        sut = SwiftDataLocalDataSource(context: container.mainContext)
    }

    override func tearDown() async throws {
        try await sut.clearAll()
        sut = nil
        container = nil
        try await super.tearDown()
    }

    func test_saveAndFetchProfiles() async throws {
        let profiles = MatchProfile.mockList
        _ = try await sut.saveProfiles(profiles, forPage: 1)

        let fetched = try await sut.fetchProfiles()
        XCTAssertEqual(fetched.count, 2)
        XCTAssertEqual(fetched.first?.id, MatchProfile.mock1.id)
    }

    func test_preserveStatus_whenProfileReSaved() async throws {
        // Initial insert
        _ = try await sut.saveProfiles([MatchProfile.mock1], forPage: 1)

        // User accepts
        _ = try await sut.updateStatus(id: MatchProfile.mock1.id, status: .accepted)

        // API refreshes same profile (defaulting to .pending)
        var freshApiProfile = MatchProfile.mock1
        freshApiProfile.status = .pending
        _ = try await sut.saveProfiles([freshApiProfile], forPage: 1)

        let fetched = try await sut.fetchProfile(id: MatchProfile.mock1.id)
        XCTAssertEqual(fetched?.status, .accepted, "Should preserve the accepted decision")
    }

    func test_updateStatus_updatesSuccessfully() async throws {
        _ = try await sut.saveProfiles([MatchProfile.mock1], forPage: 1)

        let updated = try await sut.updateStatus(id: MatchProfile.mock1.id, status: .declined)

        XCTAssertEqual(updated.status, .declined)

        let fetched = try await sut.fetchProfile(id: MatchProfile.mock1.id)
        XCTAssertEqual(fetched?.status, .declined)
    }

    func test_updateStatus_notFound_throws() async {
        do {
            _ = try await sut.updateStatus(id: "non-existent", status: .accepted)
            XCTFail("Should throw notFound error")
        } catch let error as ProfileRepositoryError {
            XCTAssertEqual(error, .notFound)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_clearAll_deletesAllProfiles() async throws {
        _ = try await sut.saveProfiles(MatchProfile.mockList, forPage: 1)
        let countBefore = try await sut.fetchProfiles().count
        XCTAssertEqual(countBefore, 2)

        try await sut.clearAll()
        let countAfter = try await sut.fetchProfiles().count
        XCTAssertEqual(countAfter, 0)
    }
}
