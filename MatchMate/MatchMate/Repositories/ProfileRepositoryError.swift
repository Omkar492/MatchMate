//
//  ProfileRepositoryError.swift
//  MatchMate
//
//  Created by Omkar Chougule on 27/08/26.
//

import Foundation

public enum ProfileRepositoryError: LocalizedError, Equatable, Sendable {
    case networkError(String)
    case persistenceError(String)
    case decodingError(String)
    case offlineNoCachedData
    case notFound
    case unknown(String)

    public var errorDescription: String? {
        switch self {
        case .networkError(let msg):
            return "Network connection issue: \(msg)"
        case .persistenceError(let msg):
            return "Local database error: \(msg)"
        case .decodingError(let msg):
            return "Data parsing error: \(msg)"
        case .offlineNoCachedData:
            return "You are offline and no cached matches were found."
        case .notFound:
            return "Match profile could not be found."
        case .unknown(let msg):
            return "An unexpected error occurred: \(msg)"
        }
    }
}
