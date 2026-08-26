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
                        VStack(spacing: 20) {
                            // Hero Profile Card
                            heroProfileCard(for: profile)

                            // About Section Card
                            aboutSectionCard(for: profile)

                            // Personal Info Section Card
                            personalInfoSectionCard(for: profile)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 36)
                    }
                } else {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Loading profile...")
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
                Image(systemName: "chevron.left")
                    .circularActionHeaderStyle(size: 40)
            }

            Spacer()

            Text("Profile Details")
                .font(.headline.weight(.bold))
                .foregroundColor(.primary)

            Spacer()

            // Balance spacer
            Color.clear
                .frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(Color(uiColor: .systemGroupedBackground))
    }

    // MARK: - Hero Profile Card

    private func heroProfileCard(for profile: Profile) -> some View {
        VStack(spacing: 16) {
            // Large Image with White Border
            ProfileImageView(url: profile.largePhotoURL)
                .frame(maxWidth: .infinity)
                .frame(height: 380)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.white, lineWidth: 3.5)
                )
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)

            // Content & Action Buttons Below Image
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(profile.fullName), \(profile.age)")
                        .font(.system(.title2, design: .default).weight(.bold))
                        .foregroundColor(.primary)
                        .lineLimit(2)

                    if !profile.locationShort.isEmpty {
                        Text("\(profile.gender.isEmpty ? "" : "\(profile.gender.capitalized) • ")\(profile.locationShort)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
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
            .padding(.horizontal, 6)
            .padding(.bottom, 6)
        }
        .padding(14)
        .background(Color(uiColor: .systemBackground))
        .matchCardContainer(cornerRadius: 24, shadowRadius: 10, shadowY: 4)
        .id(profile.id)
    }

    // MARK: - About Section Card

    private func aboutSectionCard(for profile: Profile) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text("About")
                    .font(.headline.weight(.bold))
                    .foregroundColor(.primary)

                Image(systemName: "sparkles")
                    .font(.caption)
                    .foregroundColor(.pink)
            }

            Text(viewModel.bioText)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .detailSectionCard(cornerRadius: 20, padding: 20)
    }

    // MARK: - Personal Info Section Card

    private func personalInfoSectionCard(for profile: Profile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Personal Info")
                .font(.headline.weight(.bold))
                .foregroundColor(.primary)

            VStack(spacing: 14) {
                infoRow(icon: "person.fill", title: "Name", value: profile.fullName)

                if !profile.gender.isEmpty {
                    infoRow(icon: "figure.stand", title: "Gender", value: profile.gender.capitalized)
                }

                if !profile.email.isEmpty {
                    infoRow(icon: "envelope.fill", title: "Email", value: profile.email)
                }

                if !profile.phone.isEmpty {
                    infoRow(icon: "phone.fill", title: "Phone", value: profile.phone)
                }

                if !profile.cell.isEmpty {
                    infoRow(icon: "iphone", title: "Mobile", value: profile.cell)
                }

                if !profile.locationShort.isEmpty {
                    infoRow(icon: "mappin.circle.fill", title: "Location", value: profile.fullAddress.isEmpty ? profile.locationShort : profile.fullAddress)
                }

                if !profile.nationality.isEmpty {
                    infoRow(icon: "flag.fill", title: "Nationality", value: profile.nationality)
                }

                infoRow(icon: "calendar", title: "Registered", value: profile.registeredDate.formatted(date: .abbreviated, time: .omitted))
            }
        }
        .detailSectionCard(cornerRadius: 20, padding: 20)
    }

    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(.primary)
                .frame(width: 24, height: 24)

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
