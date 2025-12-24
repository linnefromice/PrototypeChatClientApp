//
//  AppRadius.swift
//  PrototypeChatClientApp
//
//  Design System Corner Radius Tokens
//  Defines consistent corner rounding values
//

import CoreGraphics

extension App {
    /// Design System Corner Radius Tokens
    ///
    /// Provides consistent corner rounding values for shapes and containers.
    /// Creates visual harmony and brand identity through consistent rounding.
    ///
    /// Usage:
    /// ```swift
    /// RoundedRectangle(cornerRadius: App.Radius.lg)
    ///     .fill(App.Color.Brand.primary)
    /// ```
    public enum Radius {
        /// No rounding: 0pt
        /// - Use for: Sharp corners, material design aesthetic
        public static let none: CGFloat = 0

        /// Small rounding: 4pt
        /// - Use for: Subtle rounding, small buttons
        public static let sm: CGFloat = 4

        /// Medium rounding: 8pt (baseline)
        /// - Use for: Default rounding, buttons, inputs
        public static let md: CGFloat = 8

        /// Large rounding: 12pt
        /// - Use for: Cards, containers, prominent elements
        public static let lg: CGFloat = 12

        /// Extra large rounding: 16pt
        /// - Use for: Large cards, modals, very soft appearance
        public static let xl: CGFloat = 16

        /// Full rounding: 9999pt
        /// - Use for: Pills, circular elements, capsule shapes
        /// - Note: Actual radius is limited by element size, creating perfect circles/pills
        public static let full: CGFloat = 9999
    }
}
