//
//  MatchViewModifiers.swift
//  MatchMate
//
//  Created by Omkar Chougule on 27/08/26.
//

import SwiftUI

// MARK: - Card Container Modifier
public struct MatchCardContainerModifier: ViewModifier {
    public var cornerRadius: CGFloat
    public var shadowRadius: CGFloat
    public var shadowY: CGFloat

    public init(cornerRadius: CGFloat = 24, shadowRadius: CGFloat = 12, shadowY: CGFloat = 6) {
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.shadowY = shadowY
    }

    public func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: Color.black.opacity(0.12), radius: shadowRadius, x: 0, y: shadowY)
    }
}

// MARK: - Detail Section Card Modifier
public struct DetailSectionCardModifier: ViewModifier {
    public var cornerRadius: CGFloat
    public var padding: CGFloat

    public init(cornerRadius: CGFloat = 20, padding: CGFloat = 20) {
        self.cornerRadius = cornerRadius
        self.padding = padding
    }

    public func body(content: Content) -> some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: Color.black.opacity(0.04), radius: 8, y: 3)
    }
}

// MARK: - Action Button Modifiers

public struct DeclineActionButtonModifier: ViewModifier {
    public init() {}

    public func body(content: Content) -> some View {
        content
            .font(.headline.weight(.semibold))
            .foregroundColor(Color.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color.gray.opacity(0.35), lineWidth: 1.2)
            )
    }
}

public struct AcceptActionButtonModifier: ViewModifier {
    public init() {}

    public func body(content: Content) -> some View {
        content
            .font(.headline.weight(.semibold))
            .foregroundColor(.green)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color.green.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color.green, lineWidth: 1.5)
            )
    }
}

public struct StatusBannerModifier: ViewModifier {
    public let status: MatchStatus

    public init(status: MatchStatus) {
        self.status = status
    }

    public func body(content: Content) -> some View {
        let isAccepted = status == .accepted
        let color: Color = isAccepted ? .green : Color(red: 0.95, green: 0.35, blue: 0.45)

        content
            .font(.headline.weight(.bold))
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(color.opacity(0.18))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(color.opacity(0.8), lineWidth: 1.5)
            )
    }
}

public struct CircularActionButtonModifier: ViewModifier {
    public var size: CGFloat

    public init(size: CGFloat = 40) {
        self.size = size
    }

    public func body(content: Content) -> some View {
        content
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.primary)
            .frame(width: size, height: size)
            .background(Color(uiColor: .systemBackground))
            .clipShape(Circle())
            .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
    }
}

// MARK: - View Extensions for ViewModifiers

extension View {
    public func matchCardContainer(
        cornerRadius: CGFloat = 24,
        shadowRadius: CGFloat = 12,
        shadowY: CGFloat = 6
    ) -> some View {
        modifier(MatchCardContainerModifier(
            cornerRadius: cornerRadius,
            shadowRadius: shadowRadius,
            shadowY: shadowY
        ))
    }

    public func detailSectionCard(
        cornerRadius: CGFloat = 20,
        padding: CGFloat = 20
    ) -> some View {
        modifier(DetailSectionCardModifier(
            cornerRadius: cornerRadius,
            padding: padding
        ))
    }

    public func declineActionButtonStyle() -> some View {
        modifier(DeclineActionButtonModifier())
    }

    public func acceptActionButtonStyle() -> some View {
        modifier(AcceptActionButtonModifier())
    }

    public func statusBannerStyle(for status: MatchStatus) -> some View {
        modifier(StatusBannerModifier(status: status))
    }

    public func circularActionHeaderStyle(size: CGFloat = 40) -> some View {
        modifier(CircularActionButtonModifier(size: size))
    }
}
