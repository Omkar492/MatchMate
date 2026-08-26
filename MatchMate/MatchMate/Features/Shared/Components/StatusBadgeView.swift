//
//  StatusBadgeView.swift
//  MatchMate
//
//  Created by Omkar Chougule on 27/08/26.
//

import SwiftUI

public struct StatusBadgeView: View {
    public let status: MatchStatus

    public init(status: MatchStatus) {
        self.status = status
    }

    public var body: some View {
        HStack(spacing: 6) {
            Image(systemName: status.iconName)
                .font(.caption.weight(.bold))
            Text(status.title)
                .font(.subheadline.weight(.heavy))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 18)
        .padding(.vertical, 9)
        .background(
            Group {
                switch status {
                case .pending:
                    LinearGradient(colors: [.orange, .yellow], startPoint: .leading, endPoint: .trailing)
                case .accepted:
                    LinearGradient(colors: [Color(red: 0.1, green: 0.8, blue: 0.6), Color(red: 0.05, green: 0.65, blue: 0.75)], startPoint: .leading, endPoint: .trailing)
                case .declined:
                    LinearGradient(colors: [Color(red: 0.95, green: 0.35, blue: 0.45), Color(red: 0.85, green: 0.2, blue: 0.3)], startPoint: .leading, endPoint: .trailing)
                }
            }
        )
        .clipShape(Capsule())
        .shadow(color: status.primaryColor.opacity(0.35), radius: 8, y: 3)
    }
}
