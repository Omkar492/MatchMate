//
//  MatchButtonStyles.swift
//  MatchMate
//
//  Created by Omkar Chougule on 27/08/26.
//

import SwiftUI

public struct SpringBounceButtonStyle: ButtonStyle {
    private let scaleAmount: CGFloat

    public init(scaleAmount: CGFloat = 0.88) {
        self.scaleAmount = scaleAmount
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scaleAmount : 1.0)
            .animation(.spring(response: 0.28, dampingFraction: 0.55), value: configuration.isPressed)
    }
}

public struct ModernFloatingButtonStyle: ButtonStyle {
    public let gradient: [Color]
    public let shadowColor: Color

    public init(gradient: [Color] = [.pink, .purple], shadowColor: Color = .pink.opacity(0.4)) {
        self.gradient = gradient
        self.shadowColor = shadowColor
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .background(
                LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .clipShape(Circle())
            .shadow(color: shadowColor, radius: configuration.isPressed ? 4 : 10, y: configuration.isPressed ? 2 : 5)
            .scaleEffect(configuration.isPressed ? 0.86 : 1.0)
            .animation(.spring(response: 0.28, dampingFraction: 0.55), value: configuration.isPressed)
    }
}

public struct MatchDetailActionButtonStyle: ButtonStyle {
    public let color: Color
    public let gradient: [Color]
    public let isSelected: Bool

    public init(color: Color, gradient: [Color]? = nil, isSelected: Bool) {
        self.color = color
        self.gradient = gradient ?? [color, color.opacity(0.8)]
        self.isSelected = isSelected
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.bold))
            .foregroundColor(isSelected ? .white : color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Group {
                    if isSelected {
                        LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                    } else {
                        color.opacity(0.12)
                    }
                }
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(color.opacity(isSelected ? 0.0 : 0.35), lineWidth: 1.5)
            )
            .shadow(color: isSelected ? color.opacity(0.35) : .clear, radius: 10, y: 4)
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
