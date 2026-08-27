//
//  MatchMateApp.swift
//  MatchMate
//
//  Created by Omkar Chougule on 25/08/26.
//

import SwiftUI
import SwiftData

@main
struct MatchMateApp: App {
    let container: ModelContainer = {
        let schema = Schema([ProfileEntity.self])
        return try! ModelContainer(for: schema)
    }()

    init() {
        // Pre-warm the FoundationModels bio generator model asynchronously at app launch
        Task.detached(priority: .utility) {
            await FoundationBioGenerator.shared.prewarm()
        }
    }

    var body: some Scene {
        WindowGroup {
            MatchListView(viewModel: AppComposition.makeMatchListViewModel(context: container.mainContext))
        }
        .modelContainer(container)
    }
}
