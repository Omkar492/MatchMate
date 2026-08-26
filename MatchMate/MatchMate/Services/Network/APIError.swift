//
//  APIError.swift
//  MatchMate
//
//  Created by Omkar Chougule on 27/08/26.
//

import Foundation

public enum APIError: LocalizedError, Equatable, Sendable {
    case invalidURL
    case networkError(String)
    case invalidResponse(statusCode: Int)
    case decodingError(String)
    case unknown

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL is invalid."
        case .networkError(let message):
            return "Network connection failed: \(message)"
        case .invalidResponse(let statusCode):
            return "Server responded with status code: \(statusCode)"
        case .decodingError(let message):
            return "Failed to parse data: \(message)"
        case .unknown:
            return "An unexpected error occurred."
        }
    }
}
