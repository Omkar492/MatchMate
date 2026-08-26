//
//  MatchListView.swift
//  MatchMate
//
//  The app's root screen: a scrollable list of match cards. Tapping a card
//  pushes the detail screen with a zoom transition that grows out of the card
//  (`matchedTransitionSource` here + `navigationTransition(.zoom)` on the
//  destination). The same view model instance is handed to the detail so both
//  screens stay in sync.
//

import SwiftUI

struct MatchesListView: View {
    private let users: [MatchUser] = MatchUser.sampleData

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(users) { user in
                        MatchCardView(user: user)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Matches")
        }
    }
}

#Preview {
    MatchesListView()
}
