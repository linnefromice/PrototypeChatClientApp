//
//  AppCard.swift
//  PrototypeChatClientApp
//
//  Design System Card Component
//  Container component with consistent card styling
//

import SwiftUI

/// Design System Card Component
///
/// A container View that provides card-like styling.
/// Wraps content with background, padding, rounding, and shadow.
///
/// Example usage:
/// ```swift
/// AppCard {
///     VStack(alignment: .leading, spacing: App.Spacing.sm) {
///         Text("Card Title")
///             .appText(.headline)
///         Text("Card content")
///             .appText(.body, color: App.Color.Text.secondary)
///     }
/// }
/// ```
public struct AppCard<Content: View>: View {

    // MARK: - Properties

    private let content: Content
    private let backgroundColor: SwiftUI.Color
    private let cornerRadius: CGFloat
    private let shadow: App.Shadow
    private let padding: CGFloat

    // MARK: - Initialization

    /// Creates a design system card
    ///
    /// - Parameters:
    ///   - backgroundColor: Card background color (defaults to elevated background)
    ///   - cornerRadius: Corner radius (defaults to large radius)
    ///   - shadow: Shadow style (defaults to medium shadow)
    ///   - padding: Internal padding (defaults to medium spacing)
    ///   - content: Card content builder
    public init(
        backgroundColor: SwiftUI.Color = App.Color.Background.elevated,
        cornerRadius: CGFloat = App.Radius.lg,
        shadow: App.Shadow = .md,
        padding: CGFloat = App.Spacing.md,
        @ViewBuilder content: () -> Content
    ) {
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.shadow = shadow
        self.padding = padding
        self.content = content()
    }

    // MARK: - Body

    public var body: some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .appShadow(shadow)
    }
}

// MARK: - Previews

struct AppCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Basic card
            AppCard {
                VStack(alignment: .leading, spacing: App.Spacing.sm) {
                    Text("Welcome")
                        .appText(.headline)
                    Text("This is a card component with default styling.")
                        .appText(.body, color: App.Color.Text.secondary)
                }
            }
            .padding()
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Basic Card")

            // Custom styled card
            AppCard(
                backgroundColor: App.Color.Brand.primary.opacity(0.1),
                cornerRadius: App.Radius.xl,
                shadow: .lg,
                padding: App.Spacing.lg
            ) {
                HStack(spacing: App.Spacing.md) {
                    Image(systemName: "star.fill")
                        .foregroundColor(App.Color.Brand.primary)
                    VStack(alignment: .leading) {
                        Text("Featured")
                            .appText(.headline, color: App.Color.Brand.primary)
                        Text("Custom styled card")
                            .appText(.callout, color: App.Color.Text.secondary)
                    }
                }
            }
            .padding()
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Custom Card")

            // Multiple cards
            VStack(spacing: App.Spacing.md) {
                AppCard {
                    Text("Card 1")
                        .appText(.body)
                }

                AppCard {
                    Text("Card 2")
                        .appText(.body)
                }

                AppCard {
                    Text("Card 3")
                        .appText(.body)
                }
            }
            .padding()
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Multiple Cards")

            // Dark mode
            AppCard {
                VStack(alignment: .leading, spacing: App.Spacing.sm) {
                    Text("Dark Mode Card")
                        .appText(.headline)
                    Text("Automatically adapts to dark mode.")
                        .appText(.body, color: App.Color.Text.secondary)
                }
            }
            .padding()
            .background(Color.black)
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Dark Mode")
        }
    }
}
