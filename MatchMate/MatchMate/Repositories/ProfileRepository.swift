//
//  ProfileRepository.swift
//  MatchMate
//
//  Created by Omkar Chougule on 27/08/26.
//

import Foundation

public protocol ProfileRepository: AnyObject, Sendable {
    func fetchProfiles(page: Int) async throws -> [Profile]
    func cachedProfiles() async throws -> [Profile]
    func profile(id: String) async throws -> Profile
    func updateStatus(id: String, status: MatchStatus) async throws -> Profile
    var profileUpdates: AsyncStream<Profile> { get }
}

public typealias MatchRepositoryProtocol = ProfileRepository
