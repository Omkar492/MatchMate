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
        VStack(spacing: ARTSpacing4) {
            // Top Section: 128x128 Crisp Image with Curved Edges & Shadow Effect
            HStack(spacing: ARTSpacing4) {
                ProfileImageView(url: profile.displayPhotoURL)
                    .frame(width: AppConstants.UI.imageDimension, height: AppConstants.UI.imageDimension)
                    .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.imageCornerRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppConstants.UI.imageCornerRadius, style: .continuous)
                            .strokeBorder(Color.white, lineWidth: AppConstants.UI.imageBorderWidth)
                    )
                    .shadow(color: AppConstants.Colors.primaryPink.opacity(0.18), radius: 8, x: 0, y: 4)

                // Profile Info alongside image
                VStack(alignment: .leading, spacing: ARTSpacing1) {
                    Text("\(profile.fullName), \(profile.age)")
                        .font(.system(.title3, design: .default).weight(.bold))
                        .foregroundColor(.primary)
                        .lineLimit(2)

                    if !profile.locationShort.isEmpty {
                        HStack(spacing: ARTSpacing1) {
                            Image(systemName: AppConstants.Icons.location)
                                .font(.caption2)
                                .foregroundColor(AppConstants.Colors.primaryPink)

                            Text(profile.locationShort)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }

                    if !profile.gender.isEmpty {
                        Text(profile.gender.capitalized)
                            .font(.caption.weight(.medium))
                            .foregroundColor(AppConstants.Colors.primaryPink)
                            .padding(.horizontal, ARTSpacing2)
                            .padding(.vertical, ARTSpacing1)
                            .background(AppConstants.Colors.softPink)
                            .clipShape(Capsule())
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, ARTSpacing1)

            // Bottom Section: Themed Action Buttons (Pink Accept + White Decline)
            MatchDecisionButtonsView(
                status: profile.status,
                onAccept: onAccept,
                onDecline: onDecline
            )
        }
        .padding(ARTSpacing4)
        .background(Color(uiColor: .systemBackground))
        .matchCardContainer(
            cornerRadius: AppConstants.UI.cardCornerRadius,
            shadowRadius: AppConstants.UI.shadowRadius,
            shadowY: AppConstants.UI.shadowY
        )
        .id(profile.id)
    }
}
