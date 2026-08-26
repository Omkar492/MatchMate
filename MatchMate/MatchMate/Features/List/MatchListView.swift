//
//  MatchListView.swift
//  MatchMate
//
//  Created by Omkar Chougule on 27/08/26.
//

import SwiftUI
import SwiftData

public struct MatchListView: View {
    @Bindable public var viewModel: MatchListViewModel
    @Environment(\.modelContext) private var context
    public var detailViewModelFactory: ((String, ModelContext) -> MatchDetailViewModel)?

    public init(
        viewModel: MatchListViewModel,
        detailViewModelFactory: ((String, ModelContext) -> MatchDetailViewModel)? = nil
    ) {
        self.viewModel = viewModel
        self.detailViewModelFactory = detailViewModelFactory
    }

    public var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(.systemBackground)
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 16) {
                    // Header Title: Matches
                    Text("Matches")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    // Filter Segmented Pills (All, Accepted, Declined)
                    filterSegmentedBar
                        .padding(.horizontal, 20)

                    // Content Area
                    if viewModel.profiles.isEmpty && viewModel.isLoadingInitial {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Loading matches...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if viewModel.profiles.isEmpty && (viewModel.isOffline || viewModel.error != nil) {
                        OfflineEmptyStateView {
                            Task { await viewModel.loadInitial(forceRefresh: true) }
                        }
                    } else {
                        // Cards Feed
                        ScrollView {
                            LazyVStack(spacing: 20) {
                                ForEach(viewModel.filteredProfiles, id: \.id) { profile in
                                    NavigationLink(value: profile.id) {
                                        MatchCardView(
                                            profile: profile,
                                            onAccept: {
                                                Task { await viewModel.accept(profile.id) }
                                            },
                                            onDecline: {
                                                Task { await viewModel.decline(profile.id) }
                                            }
                                        )
                                        .id(profile.id)
                                    }
                                    .buttonStyle(.plain)
                                    .onAppear {
                                        Task {
                                            await viewModel.loadNextPageIfNeeded(currentItem: profile)
                                        }
                                    }
                                }

                                // Pagination Loader
                                if viewModel.isLoadingNextPage {
                                    HStack(spacing: 10) {
                                        ProgressView()
                                        Text("Loading more profiles...")
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 16)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 4)
                            .padding(.bottom, 24)
                        }
                        .refreshable {
                            await viewModel.loadInitial(forceRefresh: true)
                        }
                        .onAppear {
                            Task { await viewModel.refreshFromCache() }
                        }
                    }
                }

                // Error Banner Overlay
                if let error = viewModel.error, !viewModel.profiles.isEmpty {
                    ErrorBannerView(message: error.localizedDescription) {
                        viewModel.dismissError()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(), value: viewModel.error != nil)
                    .padding(.top, 8)
                    .zIndex(10)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: String.self) { profileId in
                if let factory = detailViewModelFactory {
                    MatchDetailView(viewModel: factory(profileId, context))
                } else {
                    MatchDetailView(
                        viewModel: AppComposition.makeMatchDetailViewModel(profileId: profileId, context: context)
                    )
                }
            }
            .task {
                await viewModel.loadInitial()
            }
        }
    }

    // MARK: - Filter Segmented Bar

    private var filterSegmentedBar: some View {
        HStack(spacing: 12) {
            ForEach(MatchFilter.allCases, id: \.self) { filter in
                let isSelected = viewModel.selectedFilter == filter
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.selectedFilter = filter
                    }
                } label: {
                    Text(filter.rawValue)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(isSelected ? .white : .primary.opacity(0.8))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            isSelected ? Color(red: 0.0, green: 0.65, blue: 0.78) : Color(uiColor: .systemGray6)
                        )
                        .clipShape(Capsule())
                }
                .buttonStyle(SpringBounceButtonStyle(scaleAmount: 0.95))
            }
            Spacer()
        }
    }
}
