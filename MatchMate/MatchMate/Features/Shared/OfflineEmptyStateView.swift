//
//  OfflineEmptyStateView.swift
//  MatchMate
//
//  Created by Omkar Chougule on 27/08/26.
//

import SwiftUI

public struct OfflineEmptyStateView: View {
    public var onRetry: () -> Void

    public init(onRetry: @escaping () -> Void) {
        self.onRetry = onRetry
    }

    public var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.12))
                    .frame(width: 100, height: 100)

                Image(systemName: "wifi.slash")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundColor(.orange)
            }
            .padding(.bottom, 8)

            Text("No Matches Available")
                .font(.title2.weight(.bold))
                .foregroundColor(.primary)

            Text("You appear to be offline and no cached matches were found. Please check your internet connection and try again.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button(action: onRetry) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text("Retry Connection")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(Color.accentColor)
                .clipShape(Capsule())
                .shadow(color: Color.accentColor.opacity(0.3), radius: 8, y: 4)
            }
            .buttonStyle(SpringBounceButtonStyle())
            .padding(.top, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
