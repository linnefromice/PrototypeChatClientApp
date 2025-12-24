//
//  AppColor.swift
//  PrototypeChatClientApp
//
//  Design System Color Tokens
//  Provides semantic color definitions with automatic dark mode support
//

import SwiftUI

// MARK: - Color Extensions

extension Color {
    /// Create Color from hex value
    ///
    /// Example:
    /// ```swift
    /// let brandColor = Color.hex(0x0066CC)
    /// ```
    public static func hex(_ hex: UInt) -> Self {
        Self(
            red: Double((hex & 0xff0000) >> 16) / 255,
            green: Double((hex & 0x00ff00) >> 8) / 255,
            blue: Double(hex & 0x0000ff) / 255,
            opacity: 1
        )
    }

    /// Create dynamic color that adapts to light/dark mode
    ///
    /// - Parameters:
    ///   - dark: Color for dark mode
    ///   - light: Color for light mode
    /// - Returns: Adaptive Color
    ///
    /// Example:
    /// ```swift
    /// let adaptiveText = Color.dynamicColor(dark: .white1000, light: .gray1000)
    /// ```
    public static func dynamicColor(dark: UIColor, light: UIColor) -> Color {
        Color(
            UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ? dark : light
            }
        )
    }

    /// Create constant color that doesn't adapt to appearance mode
    ///
    /// - Parameter base: Base UIColor
    /// - Returns: Non-adaptive Color
    ///
    /// Example:
    /// ```swift
    /// let brandRed = Color.constantColor(.systemRed100)
    /// ```
    public static func constantColor(_ base: UIColor) -> Color {
        Color(UIColor { _ in base })
    }
}

// MARK: - App Color Theme

extension App {
    /// Design System Color Theme
    ///
    /// Organized by usage context (Text, Icon, Stroke, Fill, etc.)
    /// Supports automatic dark mode adaptation via dynamicColor and constantColor helpers.
    ///
    /// Usage:
    /// ```swift
    /// Text("Hello")
    ///     .foregroundColor(App.Color.Text.Default.primary)
    ///
    /// Rectangle()
    ///     .fill(App.Color.Fill.Default.primaryStrong)
    /// ```
    public struct Color {
        // MARK: - Text Colors

        public struct Text {
            /// Default text color tokens
            public struct Default {
                /// Primary text (highest contrast) - Body text
                /// Uses soft charcoal in light mode, off-white in dark mode
                public static let primary = SwiftUI.Color.dynamicColor(
                    dark: .textBodyDark, light: .textBodyLight)

                /// Secondary text (medium contrast)
                public static let secondary = SwiftUI.Color.dynamicColor(
                    dark: .gray300, light: .gray700)

                /// Tertiary text (low contrast)
                public static let tertiary = SwiftUI.Color.dynamicColor(
                    dark: .gray500100, light: .gray400)

                /// Tertiary strong text
                public static let tertiaryStrong = SwiftUI.Color.dynamicColor(
                    dark: .gray500100, light: .gray700)

                /// Annotation text
                public static let annotation = SwiftUI.Color.dynamicColor(
                    dark: .gray700, light: .gray400)

                /// Disabled text
                public static let disable = SwiftUI.Color.dynamicColor(
                    dark: .gray700, light: .gray300)

                /// Message text
                public static let message = SwiftUI.Color.dynamicColor(
                    dark: .gray200, light: .gray800)

                /// Inverted text (for dark backgrounds in light mode, vice versa)
                public static let inversion = SwiftUI.Color.dynamicColor(
                    dark: .black1000, light: .white1000)

                /// Danger/error text
                public static let danger = SwiftUI.Color.constantColor(.systemRed100)
            }

            /// Link text color tokens
            public struct Link {
                /// Active primary link
                public static let primaryActive = Fill.Function.linkPrimary

                /// Active secondary link
                public static let secondaryActive = SwiftUI.Color.dynamicColor(
                    dark: .gray300, light: .gray700)

                /// Error link
                public static let error = SwiftUI.Color.constantColor(.systemRed100)

                /// Disabled link
                public static let disable = SwiftUI.Color.dynamicColor(
                    dark: .gray700, light: .gray300)
            }

            /// Functional text color tokens
            public struct Function {
                /// Rewards text
                public static let rewards = SwiftUI.Color.constantColor(.systemMagenta100)

                /// Coin/currency text
                public static let coin = SwiftUI.Color.dynamicColor(
                    dark: .systemOrange100, light: .gray1000)
            }
        }

        // MARK: - Icon Colors

        public struct Icon {
            /// Default icon color tokens
            public struct Default {
                /// Primary icon
                public static let primary = SwiftUI.Color.dynamicColor(
                    dark: .white1000, light: .gray1000)

                /// Secondary icon
                public static let secondary = SwiftUI.Color.dynamicColor(
                    dark: .gray300, light: .gray700)

                /// Tertiary icon
                public static let tertiary = SwiftUI.Color.dynamicColor(
                    dark: .gray500100, light: .gray400)

                /// Tertiary strong icon
                public static let tertiaryStrong = SwiftUI.Color.dynamicColor(
                    dark: .gray500100, light: .gray700)

                /// Disabled icon
                public static let disable = SwiftUI.Color.dynamicColor(
                    dark: .gray700, light: .gray300)

                /// Inverted icon
                public static let inversion = SwiftUI.Color.dynamicColor(
                    dark: .black1000, light: .white1000)

                /// Danger/error icon
                public static let danger = SwiftUI.Color.constantColor(.systemRed100)
            }

            /// Functional icon color tokens
            public struct Function {
                /// Rewards icon
                public static let rewards = SwiftUI.Color.constantColor(.systemMagenta100)

                /// Coin/currency icon
                public static let coin = SwiftUI.Color.constantColor(.systemOrange100)
            }
        }

        // MARK: - Stroke/Border Colors

        public struct Stroke {
            /// Default stroke color tokens
            public struct Default {
                /// Primary stroke
                public static let primary = SwiftUI.Color.dynamicColor(
                    dark: .gray900, light: .gray50030)

                /// Secondary stroke
                public static let secondary = SwiftUI.Color.dynamicColor(
                    dark: .gray1000, light: .gray50010)

                /// Tertiary stroke
                public static let tertiary = SwiftUI.Color.dynamicColor(
                    dark: .black1000, light: .gray100)

                /// Border stroke
                public static let border = SwiftUI.Color.dynamicColor(
                    dark: .gray900, light: .gray200)
            }

            /// Highlight stroke color tokens
            public struct Highlight {
                /// Primary highlight
                public static let primary = SwiftUI.Color.dynamicColor(
                    dark: .white1000, light: .gray1000)

                /// Secondary highlight
                public static let secondary = SwiftUI.Color.dynamicColor(
                    dark: .white500, light: .black500)

                /// Tertiary highlight
                public static let tertiary = SwiftUI.Color.dynamicColor(
                    dark: .white300, light: .black300)

                /// Button highlight
                public static let button = SwiftUI.Color.dynamicColor(
                    dark: .white100, light: .black200)
            }

            /// Danger stroke color tokens
            public struct Danger {
                /// Primary danger
                public static let primary = SwiftUI.Color.constantColor(.systemRed100)

                /// Secondary danger
                public static let secondary = SwiftUI.Color.dynamicColor(
                    dark: .systemRed30, light: .systemRed70)
            }
        }

        // MARK: - Fill/Background Colors

        public struct Fill {
            /// Default fill color tokens
            public struct Default {
                /// Primary strong fill
                public static let primaryStrong = SwiftUI.Color.dynamicColor(
                    dark: .gray900, light: .white1000)

                /// Primary light fill
                public static let primaryLight = SwiftUI.Color.dynamicColor(
                    dark: .gray900, light: .white400)

                /// Secondary fill - Now using warm gray for chat bubbles
                /// Light: #F0F2EE (warm gray for other user bubbles)
                /// Dark: #2C2C2E (sepia dark)
                public static let secondary = SwiftUI.Color.dynamicColor(
                    dark: .otherBubbleDark, light: .otherBubbleLight)

                /// Tertiary fill
                public static let tertiary = SwiftUI.Color.dynamicColor(
                    dark: .gray200, light: .gray800)

                /// Drop shadow fill
                public static let drop = SwiftUI.Color.dynamicColor(
                    dark: .gray1000, light: .white700)

                /// Coin background fill
                public static let coin = SwiftUI.Color.dynamicColor(
                    dark: .gray1000, light: .gray50010)

                /// Tutorial overlay fill
                public static let tutorial = SwiftUI.Color.dynamicColor(
                    dark: .black500, light: .white500)

                /// Primary danger fill
                public static let dangerPrimary = SwiftUI.Color.constantColor(.systemRed100)

                /// Secondary danger fill
                public static let dangerSecondary = SwiftUI.Color.dynamicColor(
                    dark: .systemRed50, light: .systemRed80)

                /// Tertiary danger fill
                public static let dangerTertiary = SwiftUI.Color.dynamicColor(
                    dark: .systemRed30, light: .systemRed70)

                /// Light danger fill
                public static let dangerLight = SwiftUI.Color.dynamicColor(
                    dark: .systemRed10, light: .systemRed10)
            }

            /// Chat-specific fill color tokens
            public struct Chat {
                /// Chat background - Natural, paper-like ivory white
                /// Light: #F9FAF5 (ivory white, like natural paper)
                /// Dark: #1C1C1E (iOS standard dark)
                public static let background = SwiftUI.Color.dynamicColor(
                    dark: .chatBackgroundDark, light: .chatBackgroundLight)

                /// Other user's message bubble background
                /// Light: #F0F2EE (warm gray)
                /// Dark: #2C2C2E (sepia dark)
                public static let otherBubble = SwiftUI.Color.dynamicColor(
                    dark: .otherBubbleDark, light: .otherBubbleLight)
            }

            /// Light fill color tokens (adaptive)
            public struct Light {
                /// White 1000 (inverts to gray in light mode)
                public static let white1000 = SwiftUI.Color.dynamicColor(
                    dark: .white1000, light: .gray900)

                /// White 500
                public static let white500 = SwiftUI.Color.dynamicColor(
                    dark: .white500, light: .black500)

                /// White 300
                public static let white300 = SwiftUI.Color.dynamicColor(
                    dark: .white300, light: .black300)

                /// White 200
                public static let white200 = SwiftUI.Color.dynamicColor(
                    dark: .white200, light: .black200)

                /// White 100
                public static let white100 = SwiftUI.Color.dynamicColor(
                    dark: .white100, light: .black100)

                /// White 100 light variant
                public static let white100Light = SwiftUI.Color.dynamicColor(
                    dark: .white100, light: .white500)
            }

            /// Shadow fill color tokens (constant, non-adaptive)
            public struct Shadow {
                /// Black 800 shadow
                public static let black800 = SwiftUI.Color.constantColor(.black800)

                /// Black 700 shadow
                public static let black700 = SwiftUI.Color.constantColor(.black700)

                /// Black 500 shadow
                public static let black500 = SwiftUI.Color.constantColor(.black500)

                /// Black 400 shadow
                public static let black400 = SwiftUI.Color.constantColor(.black400)

                /// Black 200 shadow
                public static let black200 = SwiftUI.Color.constantColor(.black200)
            }

            /// Functional fill color tokens (feature-specific)
            public struct Function {
                // Rewards
                /// Primary rewards fill
                public static let rewardsPrimary = SwiftUI.Color.constantColor(.systemMagenta100)

                /// Secondary rewards fill
                public static let rewardsSecondary = SwiftUI.Color.constantColor(.systemMagenta50)

                /// Tertiary rewards fill
                public static let rewardsTertiary = SwiftUI.Color.constantColor(.systemMagenta10)

                // Coin/Currency
                /// Primary coin fill
                public static let coinPrimary = SwiftUI.Color.constantColor(.systemOrange100)

                /// Secondary coin fill
                public static let coinSecondary = SwiftUI.Color.constantColor(.systemOrange50)

                /// Tertiary coin fill
                public static let coinTertiary = SwiftUI.Color.constantColor(.systemOrange10)

                // Check/Verification
                /// Secondary check fill
                public static let checkSecondary = SwiftUI.Color.constantColor(.systemDarkBlue50)

                /// Tertiary check fill
                public static let checkTertiary = SwiftUI.Color.constantColor(.systemDarkBlue10)

                // Online Status
                /// Primary online fill
                public static let onlinePrimary = SwiftUI.Color.dynamicColor(
                    dark: .systemGreen100, light: .systemGreen100Light)

                /// Secondary online fill
                public static let onlineSecondary = SwiftUI.Color.dynamicColor(
                    dark: .systemGreen50, light: .systemGreen80Light)

                /// Tertiary online fill
                public static let onlineTertiary = SwiftUI.Color.dynamicColor(
                    dark: .systemGreen10, light: .systemGreen10Light)

                // Search
                /// Search fill
                public static let search = SwiftUI.Color.dynamicColor(
                    dark: .systemPink50, light: .systemGreen30Light)

                // Link
                /// Primary link fill
                public static let linkPrimary = SwiftUI.Color.constantColor(.systemPink100)

                /// Secondary link fill
                public static let linkSecondary = SwiftUI.Color.constantColor(.systemPink50)

                /// Tertiary link fill
                public static let linkTertiary = SwiftUI.Color.constantColor(.systemPink10)

                // Friends
                /// Primary friends fill
                public static let friendsPrimary = SwiftUI.Color.constantColor(.systemPurple100)

                /// Secondary friends fill
                public static let friendsSecondary = SwiftUI.Color.constantColor(.systemPurple50)

                /// Tertiary friends fill
                public static let friendsTertiary = SwiftUI.Color.constantColor(.systemPurple10)
            }
        }

        // MARK: - Neutral Colors (Direct Access)

        /// Neutral color scale (non-adaptive, direct access)
        ///
        /// Use these when you need exact color values regardless of appearance mode.
        /// For adaptive colors, use the semantic tokens above.
        public struct Neutral {
            // Black scale
            public static let black1000 = SwiftUI.Color.constantColor(.black1000)
            public static let black700 = SwiftUI.Color.constantColor(.black700)
            public static let black400 = SwiftUI.Color.constantColor(.black400)
            public static let black100 = SwiftUI.Color.constantColor(.black100)

            // Gray scale
            public static let gray1000 = SwiftUI.Color.constantColor(.gray1000)
            public static let gray900 = SwiftUI.Color.constantColor(.gray900)
            public static let gray800 = SwiftUI.Color.constantColor(.gray800)
            public static let gray700 = SwiftUI.Color.constantColor(.gray700)
            public static let gray600 = SwiftUI.Color.constantColor(.gray600)
            public static let gray500100 = SwiftUI.Color.constantColor(.gray500100)
            public static let gray50050 = SwiftUI.Color.constantColor(.gray50050)
            public static let gray50030 = SwiftUI.Color.constantColor(.gray50030)
            public static let gray50010 = SwiftUI.Color.constantColor(.gray50010)
            public static let gray400 = SwiftUI.Color.constantColor(.gray400)
            public static let gray300 = SwiftUI.Color.constantColor(.gray300)
            public static let gray200 = SwiftUI.Color.constantColor(.gray200)
            public static let gray100 = SwiftUI.Color.constantColor(.gray100)

            // White scale
            public static let white1000 = SwiftUI.Color.constantColor(.white1000)
            public static let white700 = SwiftUI.Color.constantColor(.white700)
            public static let white500 = SwiftUI.Color.constantColor(.white500)
            public static let white400 = SwiftUI.Color.constantColor(.white400)
            public static let white300 = SwiftUI.Color.constantColor(.white300)
            public static let white200 = SwiftUI.Color.constantColor(.white200)
            public static let white100 = SwiftUI.Color.constantColor(.white100)
        }

        // MARK: - Brand Colors (Sunny Sprout - Yellow-Green Theme)

        /// Brand colors based on "陽だまりの若草 (Sunny Sprout)" concept
        ///
        /// Natural, warm, organic yellow-green theme that conveys warmth and positivity
        public enum Brand {
            /// Primary brand color - Young Grass (若草色)
            /// Light: #8BC34A (vibrant young grass)
            /// Dark: #9CCC65 (slightly brighter, lower saturation)
            public static let primary = SwiftUI.Color.dynamicColor(
                dark: .brandPrimaryDark, light: .brandPrimaryLight)

            /// Secondary brand color - Pale/Deep Grass
            /// Light: #DCEDC8 (pale young grass)
            /// Dark: #33691E (deep moss)
            public static let secondary = SwiftUI.Color.dynamicColor(
                dark: .brandSecondaryDark, light: .brandSecondaryLight)
        }

        // MARK: - Legacy Semantic Colors (for backward compatibility)

        /// Semantic colors (temporary - for current implementation)
        ///
        /// TODO: Migrate to new semantic color system (Text, Icon, Stroke, Fill)
        public enum Semantic {
            public static let success = SwiftUI.Color(red: 34/255, green: 197/255, blue: 94/255) // #22C55E
            public static let error = SwiftUI.Color(red: 239/255, green: 68/255, blue: 68/255) // #EF4444
            public static let warning = SwiftUI.Color(red: 251/255, green: 191/255, blue: 36/255) // #FBBF24
            public static let info = SwiftUI.Color(red: 59/255, green: 130/255, blue: 246/255) // #3B82F6
        }

        // MARK: - Legacy Aliases (for backward compatibility)

        /// Legacy text color aliases
        ///
        /// TODO: Migrate to App.Color.Text.Default.*
        public enum LegacyText {
            public static let primary = Text.Default.primary
            public static let secondary = Text.Default.secondary
            public static let tertiary = Text.Default.tertiary
            public static let inverse = Text.Default.inversion
        }

        /// Legacy background color aliases
        ///
        /// TODO: Migrate to App.Color.Fill.Default.*
        public enum Background {
            public static let base = Fill.Default.primaryStrong
            public static let elevated = SwiftUI.Color.white
            public static let overlay = Neutral.gray900
        }
    }
}

// MARK: - Convenience Type Alias

/// Convenience type alias for App.Color
///
/// Usage:
/// ```swift
/// Text("Hello")
///     .foregroundColor(AppTheme.Text.Default.primary)
/// ```
public typealias AppTheme = App.Color
