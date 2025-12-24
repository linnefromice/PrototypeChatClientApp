//
//  AppTypography.swift
//  PrototypeChatClientApp
//
//  Design System Typography Tokens
//  Defines font sizes, weights, line heights, and letter spacing
//

import SwiftUI

extension App {
    /// Design System Typography Tokens
    ///
    /// Provides consistent text styling across the app.
    /// Each style includes font, line height, and letter spacing.
    ///
    /// Usage:
    /// ```swift
    /// Text("Hello")
    ///     .appText(.headline, color: App.Color.Brand.primary)
    /// ```
    public enum Typography {
        case largeTitle     // 34pt, bold - Hero titles
        case title1         // 28pt, semibold - Page titles
        case title2         // 22pt, semibold - Section headers
        case headline       // 17pt, semibold - Emphasis text
        case body           // 17pt, regular - Body text
        case callout        // 16pt, regular - Secondary content
        case subheadline    // 15pt, regular - Metadata
        case footnote       // 13pt, regular - Captions
        case caption1       // 12pt, regular - Small labels
        case caption2       // 11pt, regular - Timestamps

        /// SwiftUI Font for this typography style
        public var font: Font {
            switch self {
            case .largeTitle:
                return .system(size: 34, weight: .bold)
            case .title1:
                return .system(size: 28, weight: .semibold)
            case .title2:
                return .system(size: 22, weight: .semibold)
            case .headline:
                return .system(size: 17, weight: .semibold)
            case .body:
                return .system(size: 17, weight: .regular)
            case .callout:
                return .system(size: 16, weight: .regular)
            case .subheadline:
                return .system(size: 15, weight: .regular)
            case .footnote:
                return .system(size: 13, weight: .regular)
            case .caption1:
                return .system(size: 12, weight: .regular)
            case .caption2:
                return .system(size: 11, weight: .regular)
            }
        }

        /// Line height for proper vertical rhythm
        public var lineHeight: CGFloat {
            switch self {
            case .largeTitle:
                return 41
            case .title1:
                return 34
            case .title2:
                return 28
            case .headline:
                return 22
            case .body:
                return 22
            case .callout:
                return 21
            case .subheadline:
                return 20
            case .footnote:
                return 18
            case .caption1, .caption2:
                return 16
            }
        }

        /// Letter spacing (tracking) for optical balance
        public var letterSpacing: CGFloat {
            switch self {
            case .largeTitle, .title1, .title2:
                return 0
            case .headline, .body, .callout:
                return -0.24
            case .subheadline:
                return -0.08
            case .footnote:
                return 0
            case .caption1, .caption2:
                return 0
            }
        }

        /// Effective line spacing to add to SwiftUI (lineHeight - intrinsic height)
        ///
        /// SwiftUI's `.lineSpacing()` adds extra space, so we calculate the difference
        /// between desired line height and the font's intrinsic line height.
        internal var effectiveLineSpacing: CGFloat {
            // Approximation: font size * 1.2 is typical intrinsic line height
            let intrinsicLineHeight: CGFloat
            switch self {
            case .largeTitle: intrinsicLineHeight = 34 * 1.2
            case .title1: intrinsicLineHeight = 28 * 1.2
            case .title2: intrinsicLineHeight = 22 * 1.2
            case .headline: intrinsicLineHeight = 17 * 1.2
            case .body: intrinsicLineHeight = 17 * 1.2
            case .callout: intrinsicLineHeight = 16 * 1.2
            case .subheadline: intrinsicLineHeight = 15 * 1.2
            case .footnote: intrinsicLineHeight = 13 * 1.2
            case .caption1: intrinsicLineHeight = 12 * 1.2
            case .caption2: intrinsicLineHeight = 11 * 1.2
            }
            return max(0, lineHeight - intrinsicLineHeight)
        }
    }
}
