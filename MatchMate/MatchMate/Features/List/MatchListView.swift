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

    public init(
        viewModel: MatchListViewModel
    ) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: ARTSpacing4) {
                    // Header Title: Matches
                    HStack(spacing: ARTSpacing2) {
                        Text(AppConstants.Strings.Navigation.matchesTitle)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary)

                        Image(systemName: AppConstants.Icons.heartFill)
                            .font(.system(size: 20))
                            .foregroundColor(AppConstants.Colors.primaryPink)
                    }
                    .padding(.horizontal, ARTSpacing5)
                    .padding(.top, ARTSpacing2)

                    // Filter Segmented Pills (All, Accepted, Declined)
                    filterSegmentedBar
                        .padding(.horizontal, ARTSpacing5)

                    // Content Area
                    if viewModel.displayedProfiles.isEmpty {
                        emptyStateView
                    } else {
                        // Cards Feed
                        ScrollView {
                            LazyVStack(spacing: ARTSpacing4) {
                                ForEach(viewModel.displayedProfiles, id: \.id) { profile in
                                    NavigationLink(value: profile.id) {
                                        MatchCardView(
                                            profile: profile,
                                            onAccept: {
                                                Task { await viewModel.accept(id: profile.id) }
                                            },
                                            onDecline: {
                                                Task { await viewModel.decline(id: profile.id) }
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

                                // Pagination Loader (Only on All tab)
                                if viewModel.selectedFilter == .all && viewModel.isLoadingNextPage {
                                    HStack(spacing: ARTSpacing2) {
                                        ProgressView()
                                            .tint(AppConstants.Colors.primaryPink)
                                        Text(AppConstants.Strings.EmptyState.loadingMoreProfiles)
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, ARTSpacing4)
                                }
                            }
                            .padding(.horizontal, ARTSpacing5)
                            .padding(.top, ARTSpacing1)
                            .padding(.bottom, ARTSpacing6)
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
                if let error = viewModel.error, !viewModel.displayedProfiles.isEmpty {
                    ErrorBannerView(message: error.localizedDescription) {
                        viewModel.dismissError()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(), value: viewModel.error != nil)
                    .padding(.top, ARTSpacing2)
                    .zIndex(10)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: String.self) { profileId in
                MatchDetailView(
                    viewModel: AppComposition.makeMatchDetailViewModel(profileId: profileId, context: context)
                )
            }
            .task {
                await viewModel.loadInitial()
            }
        }
    }

    // MARK: - Empty State View

    @ViewBuilder
    private var emptyStateView: some View {
        if viewModel.allProfiles.isEmpty && viewModel.isLoadingInitial {
            VStack(spacing: ARTSpacing4) {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(AppConstants.Colors.primaryPink)
                Text(AppConstants.Strings.EmptyState.loadingMatches)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.allProfiles.isEmpty && (viewModel.isOffline || viewModel.error != nil) {
            OfflineEmptyStateView {
                Task { await viewModel.loadInitial(forceRefresh: true) }
            }
        } else {
            VStack(spacing: ARTSpacing3) {
                Image(systemName: viewModel.selectedFilter == .accepted ? AppConstants.Icons.emptyAccepted : AppConstants.Icons.emptyDeclined)
                    .font(.system(size: 46))
                    .foregroundColor(AppConstants.Colors.primaryPink.opacity(0.6))
                    .padding(.top, 60)

                Text(viewModel.selectedFilter == .accepted ? AppConstants.Strings.EmptyState.noAcceptedMatches : AppConstants.Strings.EmptyState.noDeclinedMatches)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.primary)

                Text(viewModel.selectedFilter == .accepted ? AppConstants.Strings.EmptyState.acceptedEmptySubtitle : AppConstants.Strings.EmptyState.declinedEmptySubtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, ARTSpacing10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - Filter Segmented Bar

    private var filterSegmentedBar: some View {
        HStack(spacing: ARTSpacing2) {
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
                        .padding(.horizontal, ARTSpacing4)
                        .padding(.vertical, ARTSpacing2)
                        .background(
                            isSelected ? AppConstants.Colors.primaryPink : Color.white
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .strokeBorder(isSelected ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: isSelected ? AppConstants.Colors.primaryPink.opacity(0.28) : Color.black.opacity(0.04), radius: 5, y: 2)
                }
                .buttonStyle(SpringBounceButtonStyle(scaleAmount: 0.95))
            }
            Spacer()
        }
    }
}
