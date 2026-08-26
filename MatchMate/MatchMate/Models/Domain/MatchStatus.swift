//
//  MatchStatus.swift
//  MatchMate
//
//  Created by Omkar Chougule on 27/08/26.
//

import SwiftUI

public enum MatchStatus: String, Codable, CaseIterable, Sendable {
    case pending = "pending"
    case accepted = "accepted"
    case declined = "declined"

    public var title: String {
        switch self {
        case .pending:
            return "Pending"
        case .accepted:
            return "Accepted"
        case .declined:
            return "Declined"
        }
    }

    public var iconName: String {
        switch self {
        case .pending:
            return "clock.fill"
        case .accepted:
            return "checkmark.circle.fill"
        case .declined:
            return "xmark.circle.fill"
        }
    }

    public var primaryColor: Color {
        switch self {
        case .pending:
            return .orange
        case .accepted:
            return .teal
        case .declined:
            return .pink
        }
    }
}
