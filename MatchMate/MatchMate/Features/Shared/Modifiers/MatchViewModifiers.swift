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

    public init(
        cornerRadius: CGFloat = AppConstants.UI.cardCornerRadius,
        shadowRadius: CGFloat = AppConstants.UI.shadowRadius,
        shadowY: CGFloat = AppConstants.UI.shadowY
    ) {
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.shadowY = shadowY
    }

    public func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: Color.black.opacity(0.06), radius: shadowRadius, x: 0, y: shadowY)
    }
}

// MARK: - Detail Section Card Modifier
public struct DetailSectionCardModifier: ViewModifier {
    public var cornerRadius: CGFloat
    public var padding: CGFloat

    public init(cornerRadius: CGFloat = AppConstants.UI.sectionCornerRadius, padding: CGFloat = 18) {
        self.cornerRadius = cornerRadius
        self.padding = padding
    }

    public func body(content: Content) -> some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: Color.black.opacity(0.04), radius: 6, y: 2)
    }
}

// MARK: - Action Button Modifiers

public struct DeclineActionButtonModifier: ViewModifier {
    public init() {}

    public func body(content: Content) -> some View {
        content
            .font(.system(.subheadline, design: .default).weight(.bold))
            .foregroundColor(AppConstants.Colors.primaryPink)
            .frame(maxWidth: .infinity)
            .frame(height: AppConstants.UI.buttonHeight)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.buttonCornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.UI.buttonCornerRadius, style: .continuous)
                    .strokeBorder(AppConstants.Colors.pinkBorder, lineWidth: 1.5)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 4, y: 2)
    }
}

public struct AcceptActionButtonModifier: ViewModifier {
    public init() {}

    public func body(content: Content) -> some View {
        content
            .font(.system(.subheadline, design: .default).weight(.bold))
            .foregroundColor(Color.white)
            .frame(maxWidth: .infinity)
            .frame(height: AppConstants.UI.buttonHeight)
            .background(AppConstants.Colors.primaryPink)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.buttonCornerRadius, style: .continuous))
            .shadow(color: AppConstants.Colors.primaryPink.opacity(0.35), radius: 6, x: 0, y: 3)
    }
}

public struct StatusBannerModifier: ViewModifier {
    public let status: MatchStatus

    public init(status: MatchStatus) {
        self.status = status
    }

    public func body(content: Content) -> some View {
        let isAccepted = status == .accepted
        let foregroundColor: Color = isAccepted ? AppConstants.Colors.primaryPink : Color.secondary
        let backgroundColor: Color = isAccepted ? AppConstants.Colors.softPink : Color(uiColor: .secondarySystemBackground)
        let borderColor: Color = isAccepted ? AppConstants.Colors.pinkBorder : Color.gray.opacity(0.25)

        content
            .font(.system(.subheadline, design: .default).weight(.bold))
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: AppConstants.UI.buttonHeight)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.buttonCornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.UI.buttonCornerRadius, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: 1.2)
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
            .foregroundColor(AppConstants.Colors.primaryPink)
            .frame(width: size, height: size)
            .background(Color(uiColor: .systemBackground))
            .clipShape(Circle())
            .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
    }
}

// MARK: - View Extensions for ViewModifiers

extension View {
    public func matchCardContainer(
        cornerRadius: CGFloat = AppConstants.UI.cardCornerRadius,
        shadowRadius: CGFloat = AppConstants.UI.shadowRadius,
        shadowY: CGFloat = AppConstants.UI.shadowY
    ) -> some View {
        modifier(MatchCardContainerModifier(
            cornerRadius: cornerRadius,
            shadowRadius: shadowRadius,
            shadowY: shadowY
        ))
    }

    public func detailSectionCard(
        cornerRadius: CGFloat = AppConstants.UI.sectionCornerRadius,
        padding: CGFloat = 18
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
