//
//  AppTextStyleModifier.swift
//  PrototypeChatClientApp
//
//  Design System Text Style Modifier
//  Applies typography and color in a single, reusable modifier
//

import SwiftUI

/// Text style modifier for design system typography
///
/// Applies font, line spacing, letter spacing, and color in one operation.
/// This ensures consistent text rendering across the app.
///
/// Usage:
/// ```swift
/// Text("Hello World")
///     .appText(.headline, color: App.Color.Brand.primary)
/// ```
public struct AppTextStyleModifier: ViewModifier {
    let typography: App.Typography
    let color: SwiftUI.Color

    public func body(content: Content) -> some View {
        content
            .font(typography.font)
            .lineSpacing(typography.effectiveLineSpacing)
            .tracking(typography.letterSpacing)
            .foregroundColor(color)
    }
}

// MARK: - View Extension

extension View {
    /// Applies design system text styling
    ///
    /// - Parameters:
    ///   - typography: The typography style to apply
    ///   - color: Text color (defaults to primary text color)
    ///
    /// - Returns: View with text styling applied
    ///
    /// Example:
    /// ```swift
    /// Text("Welcome back!")
    ///     .appText(.title1, color: App.Color.Brand.primary)
    ///
    /// Text("Default color uses primary text")
    ///     .appText(.body)
    /// ```
    public func appText(
        _ typography: App.Typography,
        color: SwiftUI.Color = App.Color.Text.primary
    ) -> some View {
        self.modifier(AppTextStyleModifier(typography: typography, color: color))
    }
}
