//
//  AppConstants.swift
//  MatchMate
//
//  Created by Omkar Chougule on 27/08/26.
//

import Foundation
import SwiftUI

// MARK: - Global Multiples of 4 Spacing Constants

public let ARTSpacing1: CGFloat = 4
public let ARTSpacing2: CGFloat = 8
public let ARTSpacing3: CGFloat = 12
public let ARTSpacing4: CGFloat = 16
public let ARTSpacing5: CGFloat = 20
public let ARTSpacing6: CGFloat = 24
public let ARTSpacing7: CGFloat = 28
public let ARTSpacing8: CGFloat = 32
public let ARTSpacing9: CGFloat = 36
public let ARTSpacing10: CGFloat = 40

/// Centralized repository for all constant values, strings, symbols, colors, spacing, and UI metrics
public enum AppConstants {
    // MARK: - Spacing

    public enum Spacing {
        public static let ARTSpacing1: CGFloat = 4
        public static let ARTSpacing2: CGFloat = 8
        public static let ARTSpacing3: CGFloat = 12
        public static let ARTSpacing4: CGFloat = 16
        public static let ARTSpacing5: CGFloat = 20
        public static let ARTSpacing6: CGFloat = 24
        public static let ARTSpacing7: CGFloat = 28
        public static let ARTSpacing8: CGFloat = 32
        public static let ARTSpacing9: CGFloat = 36
        public static let ARTSpacing10: CGFloat = 40
    }

    // MARK: - API & Networking

    public enum API {
        public static let baseURL = "https://randomuser.me/api/"
        public static let defaultPageSize = 10
        public static let defaultSeed = "matchmate"
        public static let pageParam = "page"
        public static let resultsParam = "results"
        public static let seedParam = "seed"
    }

    // MARK: - Theme Colors

    public enum Colors {
        /// Primary brand pink (e.g. #F43F5E)
        public static let primaryPink = Color(red: 0.96, green: 0.23, blue: 0.51)
        public static let softPink = Color(red: 0.96, green: 0.23, blue: 0.51).opacity(0.12)
        public static let pinkBorder = Color(red: 0.96, green: 0.23, blue: 0.51).opacity(0.4)
        public static let pureWhite = Color.white
    }

    // MARK: - User-Facing Strings

    public enum Strings {
        public enum Navigation {
            public static let matchesTitle = "Matches"
            public static let profileDetailsTitle = "Profile Details"
        }

        public enum Actions {
            public static let accept = "Accept"
            public static let decline = "Decline"
            public static let accepted = "Accepted"
            public static let declined = "Declined"
            public static let retry = "Try Again"
        }

        public enum Detail {
            public static let aboutSectionTitle = "About"
            public static let personalInfoSectionTitle = "Personal Info"
            public static let nameLabel = "Name"
            public static let genderLabel = "Gender"
            public static let emailLabel = "Email"
            public static let phoneLabel = "Phone"
            public static let mobileLabel = "Mobile"
            public static let locationLabel = "Location"
            public static let nationalityLabel = "Nationality"
            public static let registeredLabel = "Registered"
            public static let defaultBio = "Hi, I enjoy meaningful conversations, traveling, fitness, and building genuine connections with like-minded people."
        }

        public enum EmptyState {
            public static let loadingMatches = "Loading matches..."
            public static let loadingProfile = "Loading profile..."
            public static let loadingMoreProfiles = "Loading more profiles..."
            public static let noMatchesFound = "No Matches Found"
            public static let noAcceptedMatches = "No Accepted Matches"
            public static let noDeclinedMatches = "No Declined Matches"
            public static let acceptedEmptySubtitle = "Profiles you accept on the list will appear here."
            public static let declinedEmptySubtitle = "Profiles you decline on the list will appear here."
            public static let offlineTitle = "You're Offline"
            public static let offlineSubtitle = "Please check your internet connection to fetch new matches."
        }
    }

    // MARK: - SF Symbols & Icons

    public enum Icons {
        public static let back = "chevron.left"
        public static let sparkles = "sparkles"
        public static let heartFill = "heart.fill"
        public static let person = "person.fill"
        public static let gender = "figure.stand"
        public static let email = "envelope.fill"
        public static let phone = "phone.fill"
        public static let mobile = "iphone"
        public static let location = "mappin.circle.fill"
        public static let nationality = "flag.fill"
        public static let calendar = "calendar"
        public static let checkmark = "checkmark"
        public static let xmark = "xmark"
        public static let checkmarkCircle = "checkmark.circle.fill"
        public static let xmarkCircle = "xmark.circle.fill"
        public static let offline = "wifi.slash"
        public static let emptyAccepted = "heart.slash"
        public static let emptyDeclined = "xmark.circle"
        public static let retry = "arrow.clockwise"
        public static let placeholderAvatar = "person.crop.circle.fill"
    }

    // MARK: - UI Metrics & Dimensions

    public enum UI {
        public static let cardCornerRadius: CGFloat = 20
        public static let imageDimension: CGFloat = 128
        public static let imageCornerRadius: CGFloat = 22
        public static let imageBorderWidth: CGFloat = 3.0
        public static let sectionCornerRadius: CGFloat = 18
        public static let buttonCornerRadius: CGFloat = 14
        public static let buttonHeight: CGFloat = 46
        public static let shadowRadius: CGFloat = 8
        public static let shadowY: CGFloat = 3
    }
}
