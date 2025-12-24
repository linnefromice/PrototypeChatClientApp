//
//  AppGradient.swift
//  PrototypeChatClientApp
//
//  Design System Gradient Definitions
//  Provides gradient definitions for backgrounds and decorative elements
//

import SwiftUI

extension App {
    /// Design System Gradient Definitions
    ///
    /// Provides reusable gradient definitions for various UI elements.
    /// Supports both linear and radial gradients with dark mode adaptation.
    ///
    /// Usage:
    /// ```swift
    /// Rectangle()
    ///     .fill(App.Gradient.brand)
    ///
    /// Circle()
    ///     .fill(App.Gradient.reward)
    /// ```
    public struct Gradient {

        // MARK: - Brand Gradients

        /// Primary brand gradient (linear)
        public static let brand = LinearGradient(
            gradient: SwiftUI.Gradient(colors: [
                SwiftUI.Color.hex(0x0066CC),
                SwiftUI.Color.hex(0x663399)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        /// Subtle brand background gradient
        public static func brandBackground(colorScheme: ColorScheme) -> LinearGradient {
            LinearGradient(
                gradient: SwiftUI.Gradient(colors: colorScheme == .dark ? [
                    SwiftUI.Color.dynamicColor(dark: .gray1000, light: .white1000),
                    SwiftUI.Color.dynamicColor(dark: .gray900, light: .gray100)
                ] : [
                    SwiftUI.Color.dynamicColor(dark: .gray1000, light: .white1000),
                    SwiftUI.Color.dynamicColor(dark: .gray900, light: .gray100)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        }

        // MARK: - Functional Gradients

        /// Reward/premium gradient (magenta to purple)
        public static let reward = LinearGradient(
            gradient: SwiftUI.Gradient(colors: [
                SwiftUI.Color.constantColor(.systemMagenta100),
                SwiftUI.Color.constantColor(.systemPurple100)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        /// Coin/currency gradient (orange to yellow)
        public static let coin = LinearGradient(
            gradient: SwiftUI.Gradient(colors: [
                SwiftUI.Color.constantColor(.systemOrange100),
                SwiftUI.Color.constantColor(.systemYellow100)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        /// Success gradient (green variants)
        public static let success = LinearGradient(
            gradient: SwiftUI.Gradient(colors: [
                SwiftUI.Color.constantColor(.systemGreen100Light),
                SwiftUI.Color.constantColor(.systemGreen100)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        /// Error/danger gradient (red variants)
        public static let error = LinearGradient(
            gradient: SwiftUI.Gradient(colors: [
                SwiftUI.Color.constantColor(.systemRed100),
                SwiftUI.Color.hex(0xCC0000) // Darker red
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        // MARK: - Utility Gradients

        /// Shimmer loading gradient (animated placeholders)
        public static func shimmer(colorScheme: ColorScheme) -> LinearGradient {
            LinearGradient(
                gradient: SwiftUI.Gradient(colors: colorScheme == .dark ? [
                    SwiftUI.Color.constantColor(.gray900),
                    SwiftUI.Color.constantColor(.gray800),
                    SwiftUI.Color.constantColor(.gray900)
                ] : [
                    SwiftUI.Color.constantColor(.gray200),
                    SwiftUI.Color.constantColor(.gray100),
                    SwiftUI.Color.constantColor(.gray200)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        }

        /// Glassmorphism overlay gradient
        public static func glass(colorScheme: ColorScheme) -> LinearGradient {
            LinearGradient(
                gradient: SwiftUI.Gradient(stops: [
                    .init(color: SwiftUI.Color.constantColor(
                        colorScheme == .dark ? .white200 : .white400
                    ), location: 0),
                    .init(color: SwiftUI.Color.constantColor(
                        colorScheme == .dark ? .white100 : .white200
                    ), location: 1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        /// Scrim overlay gradient (fade to black/white)
        public static func scrim(colorScheme: ColorScheme, direction: ScrimDirection = .bottom) -> LinearGradient {
            let colors: [SwiftUI.Color] = colorScheme == .dark ? [
                .clear,
                SwiftUI.Color.constantColor(.black700)
            ] : [
                .clear,
                SwiftUI.Color.constantColor(.white700)
            ]

            let (start, end) = direction.points

            return LinearGradient(
                gradient: SwiftUI.Gradient(colors: colors),
                startPoint: start,
                endPoint: end
            )
        }
    }
}

// MARK: - Scrim Direction

extension App.Gradient {
    /// Scrim gradient direction
    public enum ScrimDirection {
        case top
        case bottom
        case leading
        case trailing

        var points: (UnitPoint, UnitPoint) {
            switch self {
            case .top: return (.bottom, .top)
            case .bottom: return (.top, .bottom)
            case .leading: return (.trailing, .leading)
            case .trailing: return (.leading, .trailing)
            }
        }
    }
}

// MARK: - Gradient Modifier Helpers

extension View {
    /// Apply gradient background with automatic color scheme detection
    ///
    /// Usage:
    /// ```swift
    /// VStack {
    ///     Text("Content")
    /// }
    /// .gradientBackground { colorScheme in
    ///     App.Gradient.brandBackground(colorScheme: colorScheme)
    /// }
    /// ```
    public func gradientBackground<G: ShapeStyle>(
        _ gradient: @escaping (ColorScheme) -> G
    ) -> some View {
        self.modifier(GradientBackgroundModifier(gradient: gradient))
    }
}

/// Modifier that applies gradient background with color scheme awareness
struct GradientBackgroundModifier<G: ShapeStyle>: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    let gradient: (ColorScheme) -> G

    func body(content: Content) -> some View {
        content
            .background(gradient(colorScheme))
    }
}
