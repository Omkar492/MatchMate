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
        HStack(spacing: 14) {
            switch status {
            case .pending:
                Button(action: onDecline) {
                    Text("Decline")
                        .declineActionButtonStyle()
                }
                .buttonStyle(SpringBounceButtonStyle(scaleAmount: 0.94))

                Button(action: onAccept) {
                    Text("Accept")
                        .acceptActionButtonStyle()
                }
                .buttonStyle(SpringBounceButtonStyle(scaleAmount: 0.94))

            case .accepted:
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Accepted")
                }
                .statusBannerStyle(for: .accepted)

            case .declined:
                HStack(spacing: 8) {
                    Image(systemName: "xmark.circle.fill")
                    Text("Declined")
                }
                .statusBannerStyle(for: .declined)
            }
        }
    }
}
