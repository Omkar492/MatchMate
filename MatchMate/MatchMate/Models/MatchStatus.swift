//
//  MatchStatus.swift
//  MatchMate
//
//  The user's decision about a match. There is exactly one value per profile
//  id — the single source of truth shared by the list and detail screens.
//

import Foundation

enum MatchStatus: String, Codable, Hashable, Sendable {
    case pending
    case accepted
    case declined
}
