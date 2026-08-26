//
//  FoundationBioGenerator.swift
//  MatchMate
//
//  Created by Omkar Chougule on 27/08/26.
//

import Foundation
import FoundationModels

public protocol BioGeneratorServiceProtocol: Sendable {
    func prewarm() async
    func generateBio(for profile: Profile) async -> String
}

/// Native Foundation Models on-device LLM service powering Apple Intelligence bio synthesis
public actor FoundationBioGenerator: BioGeneratorServiceProtocol {
    public static let shared = FoundationBioGenerator()

    private let session: LanguageModelSession
    private var cachedBios: [String: String] = [:]

    private init() {
        self.session = LanguageModelSession(
            instructions: """
            You are an expert matchmaking bio writer. Create an authentic, warm, engaging, and personal first-person "About Me" profile introduction (3-4 sentences) for a matchmaking dating application.
            Write strictly in the first person ("I am...", "I love..."). Avoid markdown formatting, quotes, bullet points, or introductory commentary.
            Highlight the member's location, interests, warmth, and what they are looking for in a relationship.
            """
        )
    }

    /// Pre-warms the on-device Foundation Model on app launch for instantaneous inference
    public func prewarm() async {
        session.prewarm()
    }

    /// Generates an engaging bio for the profile using Apple's Foundation Models on-device LLM
    public func generateBio(for profile: Profile) async -> String {
        if let existing = cachedBios[profile.id] {
            return existing
        }

        let locationText = await profile.locationShort.isEmpty ? (profile.city.isEmpty ? "nearby" : profile.city) : profile.locationShort
        let promptText = """
        Write a friendly 3-sentence matchmaking profile bio for \(await profile.fullName), a \(profile.age)-year-old \(profile.gender.isEmpty ? "person" : profile.gender) based in \(locationText).
        """

        var generatedText: String = ""
        do {
            let response = try await session.respond(to: Prompt(promptText))
            let trimmed = response.content.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if !trimmed.isEmpty {
                generatedText = trimmed
            } else {
                generatedText = synthesizeFallbackBio(for: profile)
            }
        } catch {
            // Graceful fallback if on-device model encounters an error
            generatedText = synthesizeFallbackBio(for: profile)
        }

        cachedBios[profile.id] = generatedText
        return generatedText
    }

    private func synthesizeFallbackBio(for profile: Profile) -> String {
        let name = profile.firstName.isEmpty ? profile.fullName : profile.firstName
        let location = profile.city.isEmpty ? (profile.country.isEmpty ? "nearby" : profile.country) : profile.city
        let age = profile.age

        let hashValue = abs(profile.id.hashValue)

        let introTemplates = [
            "Hi there! I'm \(name), \(age), living in \(location).",
            "Hey! I'm \(name), currently based in \(location).",
            "Greetings! I'm \(name), living and thriving in \(location).",
            "Hello! I'm \(name), \(age) years young and based in \(location)."
        ]

        let passions = [
            "I'm deeply passionate about photography, spontaneous road trips, and exploring hidden coffee shops.",
            "I love outdoor hikes, weekend cooking experiments, and listening to great podcasts on long walks.",
            "I'm an avid reader who loves art galleries, trying new cuisines, and weekend cycling by the waterfront.",
            "I enjoy indie music concerts, mindfulness, fitness, and catching beautiful sunset views after work.",
            "I'm fascinated by technology, world cinema, architectural design, and learning new languages."
        ]

        let connectionStyle = [
            "I value authentic conversations, mutual respect, good sense of humor, and building a meaningful connection.",
            "Looking for someone who appreciates thoughtful discussions, kindness, and enjoys sharing laughter and new adventures.",
            "Believer in genuine connections, shared values, positive energy, and discovering common interests.",
            "Looking to connect with warm, curious, and open-minded souls who love meaningful chats as much as spontaneous fun."
        ]

        let closerTemplates = [
            "When I'm not working, you'll probably find me planning my next travel destination or experimenting with a new recipe.",
            "On weekends, you can catch me trying out local cafes, enjoying nature, or diving into a good book.",
            "Always up for exploring new places, lively discussions, or simply enjoying good food with great company."
        ]

        let intro = introTemplates[hashValue % introTemplates.count]
        let passion = passions[(hashValue / 3) % passions.count]
        let connection = connectionStyle[(hashValue / 7) % connectionStyle.count]
        let closer = closerTemplates[(hashValue / 11) % closerTemplates.count]

        return "\(intro) \(passion) \(connection) \(closer)"
    }
}
