//
//  MatchCardView.swift
//  MatchMate
//
//  Created by Omkar Chougule on 27/08/26.
//

import SwiftUI

public struct MatchCardView: View {
    public let profile: Profile
    public var onAccept: () -> Void
    public var onDecline: () -> Void

    public init(
        profile: Profile,
        onAccept: @escaping () -> Void,
        onDecline: @escaping () -> Void
    ) {
        self.profile = profile
        self.onAccept = onAccept
        self.onDecline = onDecline
    }

    public var body: some View {
        VStack(spacing: 16) {
            // Large Image with White Border
            ProfileImageView(url: profile.largePhotoURL)
                .frame(maxWidth: 380)
                .frame(height: 380)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.white, lineWidth: 3.5)
                )
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)

            // Details and Action Buttons Below Image
            VStack(alignment: .leading, spacing: 14) {
                // Name & Age + Subtitle
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(profile.fullName), \(profile.age)")
                        .font(.system(.title2, design: .default).weight(.bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    if !profile.locationShort.isEmpty {
                        Text("\(profile.gender.isEmpty ? "" : "\(profile.gender.capitalized) • ")\(profile.locationShort)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }

                // Action Buttons Component
                MatchDecisionButtonsView(
                    status: profile.status,
                    onAccept: onAccept,
                    onDecline: onDecline
                )
            }
            .padding(.horizontal, 6)
            .padding(.bottom, 6)
        }
        .padding(14)
        .background(Color(uiColor: .systemBackground))
        .matchCardContainer(cornerRadius: 24, shadowRadius: 10, shadowY: 4)
        .id(profile.id)
    }
}
