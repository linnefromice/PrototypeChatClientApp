//
//  AppSpacing.swift
//  PrototypeChatClientApp
//
//  Design System Spacing Tokens
//  8-point grid system for consistent layout spacing
//

import CoreGraphics

extension App {
    /// Design System Spacing Tokens
    ///
    /// Uses an 8-point grid system for consistent spacing throughout the app.
    /// Provides a harmonious visual rhythm and simplifies layout decisions.
    ///
    /// Usage:
    /// ```swift
    /// VStack(spacing: App.Spacing.md) {
    ///     // Content
    /// }
    /// .padding(App.Spacing.lg)
    /// ```
    public enum Spacing {
        /// Extra extra extra small: 2pt
        /// - Use for: Minimal gaps, tight icon spacing
        public static let xxxs: CGFloat = 2

        /// Extra extra small: 4pt
        /// - Use for: Very tight spacing, compact layouts
        public static let xxs: CGFloat = 4

        /// Extra small: 8pt
        /// - Use for: Compact element spacing, list items
        public static let xs: CGFloat = 8

        /// Small: 12pt
        /// - Use for: Small padding, button internal spacing
        public static let sm: CGFloat = 12

        /// Medium: 16pt (baseline)
        /// - Use for: Default spacing, standard padding
        public static let md: CGFloat = 16

        /// Large: 24pt
        /// - Use for: Section spacing, card padding
        public static let lg: CGFloat = 24

        /// Extra large: 32pt
        /// - Use for: Large gaps, prominent spacing
        public static let xl: CGFloat = 32

        /// Extra extra large: 48pt
        /// - Use for: Major section dividers
        public static let xxl: CGFloat = 48

        /// Extra extra extra large: 64pt
        /// - Use for: Page-level spacing, hero sections
        public static let xxxl: CGFloat = 64
    }
}
