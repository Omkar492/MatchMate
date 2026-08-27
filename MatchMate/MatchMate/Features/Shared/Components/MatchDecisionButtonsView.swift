//
//  MatchDecisionButtonsView.swift
//  MatchMate
//
//  Created by Omkar Chougule on 27/08/26.
//

import SwiftUI

public struct MatchDecisionButtonsView: View {
    public let status: MatchStatus
    public var onAccept: () -> Void
    public var onDecline: () -> Void

    public init(
        status: MatchStatus,
        onAccept: @escaping () -> Void,
        onDecline: @escaping () -> Void
    ) {
        self.status = status
        self.onAccept = onAccept
        self.onDecline = onDecline
    }

    public var body: some View {
        HStack(spacing: ARTSpacing3) {
            switch status {
            case .pending:
                // Decline Button: White fill, Pink text + Xmark icon
                Button(action: onDecline) {
                    HStack(spacing: ARTSpacing1) {
                        Image(systemName: AppConstants.Icons.xmark)
                            .font(.system(size: 14, weight: .bold))
                        Text(AppConstants.Strings.Actions.decline)
                    }
                    .declineActionButtonStyle()
                }
                .buttonStyle(SpringBounceButtonStyle(scaleAmount: 0.94))

                // Accept Button: Pink fill, White text + Heart icon
                Button(action: onAccept) {
                    HStack(spacing: ARTSpacing1) {
                        Image(systemName: AppConstants.Icons.heartFill)
                            .font(.system(size: 14, weight: .bold))
                        Text(AppConstants.Strings.Actions.accept)
                    }
                    .acceptActionButtonStyle()
                }
                .buttonStyle(SpringBounceButtonStyle(scaleAmount: 0.94))

            case .accepted:
                HStack(spacing: ARTSpacing1) {
                    Image(systemName: AppConstants.Icons.heartFill)
                        .font(.system(size: 14, weight: .bold))
                    Text(AppConstants.Strings.Actions.accepted)
                }
                .statusBannerStyle(for: .accepted)

            case .declined:
                HStack(spacing: ARTSpacing1) {
                    Image(systemName: AppConstants.Icons.xmark)
                        .font(.system(size: 14, weight: .bold))
                    Text(AppConstants.Strings.Actions.declined)
                }
                .statusBannerStyle(for: .declined)
            }
        }
    }
}
