//
//  AppShadow.swift
//  PrototypeChatClientApp
//
//  Design System Shadow Tokens
//  Defines elevation and depth through consistent shadows
//

import SwiftUI

extension App {
    /// Design System Shadow Token
    ///
    /// Represents a shadow with all necessary parameters.
    /// Provides visual elevation and depth hierarchy.
    public struct Shadow {
        /// Shadow color
        public let color: SwiftUI.Color

        /// Blur radius
        public let radius: CGFloat

        /// Horizontal offset
        public let x: CGFloat

        /// Vertical offset
        public let y: CGFloat

        /// Creates a custom shadow
        public init(color: SwiftUI.Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
            self.color = color
            self.radius = radius
            self.x = x
            self.y = y
        }

        // MARK: - Preset Shadows

        /// Small shadow: Subtle elevation
        /// - Use for: Slight lift, hovering elements
        public static let sm = Shadow(
            color: App.Color.Neutral._900.opacity(0.1),
            radius: 2,
            x: 0,
            y: 1
        )

        /// Medium shadow: Standard cards
        /// - Use for: Cards, panels, default elevation
        public static let md = Shadow(
            color: App.Color.Neutral._900.opacity(0.1),
            radius: 4,
            x: 0,
            y: 2
        )

        /// Large shadow: Prominent elevation
        /// - Use for: Modals, popovers, high importance
        public static let lg = Shadow(
            color: App.Color.Neutral._900.opacity(0.15),
            radius: 8,
            x: 0,
            y: 4
        )

        /// No shadow
        /// - Use for: Flat design, no elevation
        public static let none = Shadow(
            color: .clear,
            radius: 0,
            x: 0,
            y: 0
        )
    }
}

// MARK: - View Extension

extension View {
    /// Applies a design system shadow
    ///
    /// Usage:
    /// ```swift
    /// RoundedRectangle(cornerRadius: App.Radius.lg)
    ///     .appShadow(.md)
    /// ```
    public func appShadow(_ shadow: App.Shadow) -> some View {
        self.shadow(
            color: shadow.color,
            radius: shadow.radius,
            x: shadow.x,
            y: shadow.y
        )
    }
}
