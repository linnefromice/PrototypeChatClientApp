//
//  AppButton.swift
//  PrototypeChatClientApp
//
//  Design System Button Component
//  Provides consistent button styling across the app
//

import SwiftUI

/// Design System Button Component
///
/// A fully-featured button with multiple styles and sizes.
/// Ensures consistent button appearance and behavior across the app.
///
/// Example usage:
/// ```swift
/// AppButton("Submit", style: .primary) {
///     // Handle action
/// }
///
/// AppButton("Cancel", style: .secondary, size: .small) {
///     // Handle action
/// }
/// ```
public struct AppButton: View {

    // MARK: - Style

    /// Button visual style
    public enum Style {
        /// Filled with primary brand color
        case primary

        /// Neutral background color
        case secondary

        /// Transparent background (text-only)
        case tertiary

        /// Red/error color for dangerous actions
        case destructive
    }

    // MARK: - Size

    /// Button size variant
    public enum Size {
        /// Compact size with minimal padding
        case small

        /// Standard size (default)
        case medium

        /// Large size for prominent calls-to-action
        case large
    }

    // MARK: - Properties

    private let title: String
    private let style: Style
    private let size: Size
    private let isEnabled: Bool
    private let action: () -> Void

    // MARK: - Initialization

    /// Creates a design system button
    ///
    /// - Parameters:
    ///   - title: Button label text
    ///   - style: Visual style (defaults to primary)
    ///   - size: Size variant (defaults to medium)
    ///   - isEnabled: Whether button is enabled (defaults to true)
    ///   - action: Action to perform when tapped
    public init(
        _ title: String,
        style: Style = .primary,
        size: Size = .medium,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.size = size
        self.isEnabled = isEnabled
        self.action = action
    }

    // MARK: - Body

    public var body: some View {
        Button(action: action) {
            Text(title)
                .appText(.headline, color: foregroundColor)
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
                .frame(maxWidth: .infinity)
        }
        .background(backgroundColor)
        .cornerRadius(App.Radius.md)
        .opacity(isEnabled ? 1.0 : 0.5)
        .disabled(!isEnabled)
    }

    // MARK: - Computed Properties

    private var backgroundColor: Color {
        guard isEnabled else { return App.Color.Neutral._300 }

        switch style {
        case .primary:
            return App.Color.Brand.primary
        case .secondary:
            return App.Color.Neutral._200
        case .tertiary:
            return .clear
        case .destructive:
            return App.Color.Semantic.error
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary, .destructive:
            return .white
        case .secondary, .tertiary:
            return App.Color.Brand.primary
        }
    }

    private var horizontalPadding: CGFloat {
        switch size {
        case .small:
            return App.Spacing.md
        case .medium:
            return App.Spacing.lg
        case .large:
            return App.Spacing.xl
        }
    }

    private var verticalPadding: CGFloat {
        switch size {
        case .small:
            return App.Spacing.xs
        case .medium:
            return App.Spacing.sm
        case .large:
            return App.Spacing.md
        }
    }
}

// MARK: - Previews

struct AppButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Styles
            VStack(spacing: App.Spacing.md) {
                AppButton("Primary", style: .primary) {}
                AppButton("Secondary", style: .secondary) {}
                AppButton("Tertiary", style: .tertiary) {}
                AppButton("Destructive", style: .destructive) {}
            }
            .padding()
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Button Styles")

            // Sizes
            VStack(spacing: App.Spacing.md) {
                AppButton("Small", size: .small) {}
                AppButton("Medium", size: .medium) {}
                AppButton("Large", size: .large) {}
            }
            .padding()
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Button Sizes")

            // States
            VStack(spacing: App.Spacing.md) {
                AppButton("Enabled") {}
                AppButton("Disabled", isEnabled: false) {}
            }
            .padding()
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Button States")

            // Dark mode
            VStack(spacing: App.Spacing.md) {
                AppButton("Primary", style: .primary) {}
                AppButton("Secondary", style: .secondary) {}
            }
            .padding()
            .background(Color.black)
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Dark Mode")
        }
    }
}
