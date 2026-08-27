//
//  ProfileImageView.swift
//  MatchMate
//
//  Created by Omkar Chougule on 27/08/26.
//

import SwiftUI
import Kingfisher

public struct ProfileImageView: View {
    public let url: URL?

    public init(url: URL?) {
        self.url = url
    }

    public var body: some View {
        Group {
            if let url = url, !url.absoluteString.isEmpty {
                KFImage(url)
                    .placeholder {
                        placeholderView
                    }
                    .resizable()
                    .scaledToFill()
                    .clipped()
            } else {
                placeholderView
            }
        }
    }

    private var placeholderView: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.92, blue: 0.94),
                    Color(red: 0.95, green: 0.85, blue: 0.89)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 6) {
                Image(systemName: AppConstants.Icons.placeholderAvatar)
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(AppConstants.Colors.primaryPink.opacity(0.4))

                ProgressView()
                    .tint(AppConstants.Colors.primaryPink)
                    .scaleEffect(0.8)
            }
        }
    }
}
