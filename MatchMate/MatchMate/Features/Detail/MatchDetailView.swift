//
//  MatchDetailView.swift
//  MatchMate
//
//  Created by Omkar Chougule on 27/08/26.
//

import SwiftUI

public struct MatchDetailView: View {
    @Bindable public var viewModel: MatchDetailViewModel
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: MatchDetailViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack(alignment: .top) {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Custom Header: Back Button & Title
                topHeaderBar

                if let profile = viewModel.profile {
                    ScrollView {
                        VStack(spacing: ARTSpacing4) {
                            // Hero Profile Card
                            heroProfileCard(for: profile)

                            // About Section Card
                            aboutSectionCard(for: profile)

                            // Personal Info Section Card
                            personalInfoSectionCard(for: profile)
                        }
                        .padding(.horizontal, ARTSpacing5)
                        .padding(.top, ARTSpacing2)
                        .padding(.bottom, ARTSpacing9)
                    }
                } else {
                    VStack(spacing: ARTSpacing4) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(AppConstants.Colors.primaryPink)
                        Text(AppConstants.Strings.EmptyState.loadingProfile)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .navigationBarHidden(true)
        .overlay(alignment: .top) {
            if let error = viewModel.error {
                ErrorBannerView(message: error.localizedDescription) {
                    viewModel.dismissError()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(), value: viewModel.error != nil)
                .padding(.top, 60)
            }
        }
        .task {
            await viewModel.loadProfile()
        }
    }

    // MARK: - Top Header Bar

    private var topHeaderBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: AppConstants.Icons.back)
                    .circularActionHeaderStyle(size: ARTSpacing10)
            }

            Spacer()

            Text(AppConstants.Strings.Navigation.profileDetailsTitle)
                .font(.headline.weight(.bold))
                .foregroundColor(.primary)

            Spacer()

            Color.clear
                .frame(width: ARTSpacing10, height: ARTSpacing10)
        }
        .padding(.horizontal, ARTSpacing5)
        .padding(.top, ARTSpacing3)
        .padding(.bottom, ARTSpacing2)
        .background(Color(uiColor: .systemGroupedBackground))
    }

    // MARK: - Hero Profile Card

    private func heroProfileCard(for profile: Profile) -> some View {
        VStack(spacing: ARTSpacing4) {
            // Large Hero Image with White Border
            ProfileImageView(url: profile.largePhotoURL)
                .frame(maxWidth: .infinity)
                .frame(height: 380)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.imageCornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.UI.imageCornerRadius, style: .continuous)
                        .strokeBorder(Color.white, lineWidth: AppConstants.UI.imageBorderWidth)
                )
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)

            // Content & Action Buttons Below Image
            VStack(alignment: .leading, spacing: ARTSpacing3) {
                VStack(alignment: .leading, spacing: ARTSpacing1) {
                    Text("\(profile.fullName), \(profile.age)")
                        .font(.system(.title2, design: .default).weight(.bold))
                        .foregroundColor(.primary)
                        .lineLimit(2)

                    if !profile.locationShort.isEmpty {
                        HStack(spacing: ARTSpacing1) {
                            Image(systemName: AppConstants.Icons.location)
                                .font(.caption)
                                .foregroundColor(AppConstants.Colors.primaryPink)

                            Text("\(profile.gender.isEmpty ? "" : "\(profile.gender.capitalized) • ")\(profile.locationShort)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }

                // Action Buttons on Hero Card
                MatchDecisionButtonsView(
                    status: profile.status,
                    onAccept: {
                        Task { await viewModel.accept() }
                    },
                    onDecline: {
                        Task { await viewModel.decline() }
                    }
                )
            }
            .padding(.horizontal, ARTSpacing1)
            .padding(.bottom, ARTSpacing1)
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

    // MARK: - About Section Card

    private func aboutSectionCard(for profile: Profile) -> some View {
        VStack(alignment: .leading, spacing: ARTSpacing2) {
            HStack(spacing: ARTSpacing1) {
                Text(AppConstants.Strings.Detail.aboutSectionTitle)
                    .font(.headline.weight(.bold))
                    .foregroundColor(.primary)

                Image(systemName: AppConstants.Icons.sparkles)
                    .font(.caption)
                    .foregroundColor(AppConstants.Colors.primaryPink)
            }

            Text(viewModel.bioText)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineSpacing(ARTSpacing1)
        }
        .detailSectionCard(cornerRadius: AppConstants.UI.sectionCornerRadius, padding: ARTSpacing4)
    }

    // MARK: - Personal Info Section Card

    private func personalInfoSectionCard(for profile: Profile) -> some View {
        VStack(alignment: .leading, spacing: ARTSpacing4) {
            Text(AppConstants.Strings.Detail.personalInfoSectionTitle)
                .font(.headline.weight(.bold))
                .foregroundColor(.primary)

            VStack(spacing: ARTSpacing3) {
                infoRow(icon: AppConstants.Icons.person, title: AppConstants.Strings.Detail.nameLabel, value: profile.fullName)

                if !profile.gender.isEmpty {
                    infoRow(icon: AppConstants.Icons.gender, title: AppConstants.Strings.Detail.genderLabel, value: profile.gender.capitalized)
                }

                if !profile.email.isEmpty {
                    infoRow(icon: AppConstants.Icons.email, title: AppConstants.Strings.Detail.emailLabel, value: profile.email)
                }

                if !profile.phone.isEmpty {
                    infoRow(icon: AppConstants.Icons.phone, title: AppConstants.Strings.Detail.phoneLabel, value: profile.phone)
                }

                if !profile.cell.isEmpty {
                    infoRow(icon: AppConstants.Icons.mobile, title: AppConstants.Strings.Detail.mobileLabel, value: profile.cell)
                }

                if !profile.locationShort.isEmpty {
                    infoRow(icon: AppConstants.Icons.location, title: AppConstants.Strings.Detail.locationLabel, value: profile.fullAddress.isEmpty ? profile.locationShort : profile.fullAddress)
                }

                if !profile.nationality.isEmpty {
                    infoRow(icon: AppConstants.Icons.nationality, title: AppConstants.Strings.Detail.nationalityLabel, value: profile.nationality)
                }

                infoRow(icon: AppConstants.Icons.calendar, title: AppConstants.Strings.Detail.registeredLabel, value: profile.registeredDate.formatted(date: .abbreviated, time: .omitted))
            }
        }
        .detailSectionCard(cornerRadius: AppConstants.UI.sectionCornerRadius, padding: ARTSpacing4)
    }

    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: ARTSpacing3) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(AppConstants.Colors.primaryPink)
                .frame(width: ARTSpacing6, height: ARTSpacing6)

            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)

            Spacer()

            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
    }
}
