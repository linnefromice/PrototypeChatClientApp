//
//  AppCardModifier.swift
//  PrototypeChatClientApp
//
//  Design System Card Modifier
//  Applies card-like styling with background, rounding, and shadow
//

import SwiftUI

/// Card style modifier for design system
///
/// Applies background color, corner radius, and shadow to create card-like containers.
/// Provides consistent elevated surface appearance across the app.
///
/// Usage:
/// ```swift
/// VStack {
///     Text("Card content")
/// }
/// .appCard()
/// ```
public struct AppCardModifier: ViewModifier {
    let backgroundColor: SwiftUI.Color
    let cornerRadius: CGFloat
    let shadow: App.Shadow

    public func body(content: Content) -> some View {
        content
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .appShadow(shadow)
    }
}

// MARK: - View Extension

extension View {
    /// Applies design system card styling
    ///
    /// Creates a card-like container with background, rounded corners, and shadow.
    ///
    /// - Parameters:
    ///   - backgroundColor: Card background color (defaults to elevated background)
    ///   - cornerRadius: Corner radius value (defaults to large radius)
    ///   - shadow: Shadow style (defaults to medium shadow)
    ///
    /// - Returns: View styled as a card
    ///
    /// Examples:
    /// ```swift
    /// // Default card style
    /// VStack {
    ///     Text("Hello")
    /// }
    /// .appCard()
    ///
    /// // Custom styling
    /// HStack {
    ///     Image(systemName: "star")
    ///     Text("Featured")
    /// }
    /// .appCard(
    ///     backgroundColor: App.Color.Brand.primary,
    ///     cornerRadius: App.Radius.xl,
    ///     shadow: .lg
    /// )
    /// ```
    public func appCard(
        backgroundColor: SwiftUI.Color = App.Color.Background.elevated,
        cornerRadius: CGFloat = App.Radius.lg,
        shadow: App.Shadow = .md
    ) -> some View {
        self.modifier(AppCardModifier(
            backgroundColor: backgroundColor,
            cornerRadius: cornerRadius,
            shadow: shadow
        ))
    }
}
