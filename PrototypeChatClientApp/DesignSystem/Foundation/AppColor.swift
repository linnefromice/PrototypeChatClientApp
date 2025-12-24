//
//  AppColor.swift
//  PrototypeChatClientApp
//
//  Design System Color Tokens
//  Provides semantic color definitions backed by Asset Catalog
//

import SwiftUI

extension App {
    /// Design System Color Tokens
    ///
    /// Temporary implementation using hardcoded colors.
    /// TODO: Migrate to Asset Catalog for proper dark mode support in Iteration 2.
    public enum Color {

        // MARK: - Brand Colors

        /// Brand color tokens for primary brand identity
        public enum Brand {
            /// Primary brand color
            /// - Light mode: Blue
            /// - Dark mode: Lighter blue for better contrast
            public static let primary = SwiftUI.Color(red: 0/255, green: 102/255, blue: 204/255) // #0066CC

            /// Secondary brand color
            /// - Light mode: Purple/Accent color
            /// - Dark mode: Adjusted for dark backgrounds
            public static let secondary = SwiftUI.Color(red: 102/255, green: 51/255, blue: 153/255) // #663399
        }

        // MARK: - Neutral Colors

        /// Neutral color scale (100 = lightest, 900 = darkest)
        ///
        /// In dark mode, these values should invert.
        /// TODO: Implement proper dark mode support with Asset Catalog
        public enum Neutral {
            public static let _100 = SwiftUI.Color(red: 245/255, green: 245/255, blue: 245/255) // #F5F5F5
            public static let _200 = SwiftUI.Color(red: 229/255, green: 229/255, blue: 229/255) // #E5E5E5
            public static let _300 = SwiftUI.Color(red: 212/255, green: 212/255, blue: 212/255) // #D4D4D4
            public static let _400 = SwiftUI.Color(red: 163/255, green: 163/255, blue: 163/255) // #A3A3A3
            public static let _500 = SwiftUI.Color(red: 115/255, green: 115/255, blue: 115/255) // #737373
            public static let _600 = SwiftUI.Color(red: 82/255, green: 82/255, blue: 82/255)   // #525252
            public static let _700 = SwiftUI.Color(red: 64/255, green: 64/255, blue: 64/255)   // #404040
            public static let _800 = SwiftUI.Color(red: 38/255, green: 38/255, blue: 38/255)   // #262626
            public static let _900 = SwiftUI.Color(red: 23/255, green: 23/255, blue: 23/255)   // #171717
        }

        // MARK: - Semantic Colors

        /// Semantic color tokens for functional purposes
        public enum Semantic {
            /// Success/positive state (green)
            public static let success = SwiftUI.Color(red: 34/255, green: 197/255, blue: 94/255) // #22C55E

            /// Error/destructive state (red)
            public static let error = SwiftUI.Color(red: 239/255, green: 68/255, blue: 68/255) // #EF4444

            /// Warning/caution state (orange/yellow)
            public static let warning = SwiftUI.Color(red: 251/255, green: 191/255, blue: 36/255) // #FBBF24

            /// Informational state (blue)
            public static let info = SwiftUI.Color(red: 59/255, green: 130/255, blue: 246/255) // #3B82F6
        }

        // MARK: - Semantic Aliases

        /// Text color tokens (semantic aliases)
        public enum Text {
            /// Primary text color (high contrast)
            public static let primary = Neutral._900

            /// Secondary text color (medium contrast)
            public static let secondary = Neutral._600

            /// Tertiary text color (low contrast)
            public static let tertiary = Neutral._400

            /// Inverse text color (for dark backgrounds)
            public static let inverse = Neutral._100
        }

        /// Background color tokens (semantic aliases)
        public enum Background {
            /// Base background color (default surface)
            public static let base = Neutral._100

            /// Elevated background color (cards, modals)
            public static let elevated = SwiftUI.Color.white

            /// Overlay background (semi-transparent)
            public static let overlay = Neutral._900.opacity(0.5)
        }
    }
}
