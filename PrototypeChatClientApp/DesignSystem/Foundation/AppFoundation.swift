//
//  AppFoundation.swift
//  PrototypeChatClientApp
//
//  Design System Foundation
//  Provides namespace for all design system tokens and utilities
//

import Foundation

/// Design System namespace
///
/// All design system tokens, components, and utilities are accessed through this namespace.
/// This prevents naming conflicts with existing code during gradual migration.
///
/// Example usage:
/// ```swift
/// Text("Hello")
///     .foregroundColor(App.Color.Brand.primary)
///     .font(App.Typography.headline.font)
/// ```
public enum App {
    // Intentionally empty - serves as namespace
    // All extensions are defined in separate files:
    // - AppColor.swift
    // - AppTypography.swift
    // - AppSpacing.swift
    // - AppRadius.swift
    // - AppShadow.swift
}
