//
//  FoundationBioGeneratorGuardrailTests.swift
//  MatchMateTests
//
//  Created by Omkar Chougule on 27/08/26.
//

import XCTest
@testable import MatchMate

final class FoundationBioGeneratorGuardrailTests: XCTestCase {

    // MARK: - Guardrail 1: Missing Location Graceful Handling

    func test_bioGenerator_handlesMissingLocationGracefully() async {
        let profile = MatchProfile(
            id: "guardrail-missing-location-1",
            firstName: "Alex",
            lastName: "Smith",
            age: 28,
            city: "",
            country: ""
        )

        let bio = await FoundationBioGenerator.shared.generateBio(for: profile)

        XCTAssertFalse(bio.isEmpty, "Bio should never be empty")
        XCTAssertFalse(bio.contains("based in ."), "Bio should not contain broken grammar when location is empty")
        XCTAssertTrue(bio.contains("Alex"), "Bio should include the member's name")
    }

    // MARK: - Guardrail 2: Missing Name Fallback

    func test_bioGenerator_handlesMissingFirstNameGracefully() async {
        let profile = MatchProfile(
            id: "guardrail-missing-name-2",
            firstName: "",
            lastName: "Johnson",
            age: 31,
            city: "London",
            country: "UK"
        )

        let bio = await FoundationBioGenerator.shared.generateBio(for: profile)

        XCTAssertFalse(bio.isEmpty, "Bio should not be empty")
        XCTAssertTrue(bio.contains("Johnson"), "Bio should fall back to full name when first name is empty")
    }

    // MARK: - Guardrail 3: First-Person Tone & Persona Constraint

    func test_bioGenerator_enforcesFirstPersonTone() async {
        let profile = MatchProfile(
            id: "guardrail-first-person-3",
            firstName: "Sophia",
            lastName: "Miller",
            age: 26,
            city: "New York",
            country: "USA"
        )

        let bio = await FoundationBioGenerator.shared.generateBio(for: profile)

        let isFirstPerson = bio.contains("I'm") || bio.contains("I am") || bio.contains("I ") || bio.contains("Hi") || bio.contains("Hey") || bio.contains("Hello")
        XCTAssertTrue(isFirstPerson, "Generated bio must be written in the first person")
    }

    // MARK: - Guardrail 4: Resource Caching Prevents Duplicate Invocations

    func test_bioGenerator_returnsCachedBioOnSubsequentCalls() async {
        let profile = MatchProfile(
            id: "guardrail-cache-test-4",
            firstName: "Liam",
            lastName: "Davis",
            age: 34,
            city: "Dublin",
            country: "Ireland"
        )

        let firstRun = await FoundationBioGenerator.shared.generateBio(for: profile)
        let secondRun = await FoundationBioGenerator.shared.generateBio(for: profile)

        XCTAssertEqual(firstRun, secondRun, "Subsequent calls for the same profile ID must return the cached bio")
    }

    // MARK: - Guardrail 5: Prewarm Safety

    func test_bioGenerator_prewarmExecutesSafely() async {
        await FoundationBioGenerator.shared.prewarm()
        // Successful completion without throwing/crashing confirms prewarm safety
        XCTAssertTrue(true)
    }
}
