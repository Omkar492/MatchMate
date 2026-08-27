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
        VStack(spacing: ARTSpacing5) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.12))
                    .frame(width: 100, height: 100)

                Image(systemName: AppConstants.Icons.offline)
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundColor(.orange)
            }
            .padding(.bottom, ARTSpacing2)

            Text(AppConstants.Strings.EmptyState.offlineTitle)
                .font(.title2.weight(.bold))
                .foregroundColor(.primary)

            Text(AppConstants.Strings.EmptyState.offlineSubtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, ARTSpacing8)

            Button(action: onRetry) {
                HStack(spacing: ARTSpacing2) {
                    Image(systemName: AppConstants.Icons.retry)
                    Text(AppConstants.Strings.Actions.retry)
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, ARTSpacing7)
                .padding(.vertical, ARTSpacing3)
                .background(Color.accentColor)
                .clipShape(Capsule())
                .shadow(color: Color.accentColor.opacity(0.3), radius: 8, y: 4)
            }
            .buttonStyle(SpringBounceButtonStyle())
            .padding(.top, ARTSpacing3)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
