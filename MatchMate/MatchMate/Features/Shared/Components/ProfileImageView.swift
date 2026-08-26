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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            } else {
                placeholderView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var placeholderView: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.88, green: 0.88, blue: 0.92),
                    Color(red: 0.78, green: 0.78, blue: 0.84)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 8) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 64, weight: .light))
                    .foregroundColor(Color.white.opacity(0.65))

                ProgressView()
                    .tint(.white)
                    .scaleEffect(0.9)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
