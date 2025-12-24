//
//  ColorSchemeManager.swift
//  PrototypeChatClientApp
//
//  Color Scheme Manager
//  Manages app-wide color scheme (light/dark/system) preferences
//

import SwiftUI

/// Color scheme preference options
enum ColorSchemePreference: String, CaseIterable, Identifiable {
    case system = "システム準拠"
    case light = "ライト"
    case dark = "ダーク"

    var id: String { rawValue }

    /// Convert to SwiftUI ColorScheme (nil for system)
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    /// Display name for UI
    var displayName: String {
        rawValue
    }

    /// Icon for UI
    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}

/// Color scheme manager for app-wide theme control
@MainActor
class ColorSchemeManager: ObservableObject {
    /// Singleton instance
    static let shared = ColorSchemeManager()

    /// Current color scheme preference
    @Published var preference: ColorSchemePreference {
        didSet {
            savePreference()
        }
    }

    /// UserDefaults key for persistence
    private let preferenceKey = "colorSchemePreference"

    private init() {
        // Load saved preference or default to system
        if let saved = UserDefaults.standard.string(forKey: preferenceKey),
           let preference = ColorSchemePreference(rawValue: saved) {
            self.preference = preference
        } else {
            self.preference = .system
        }
    }

    /// Save preference to UserDefaults
    private func savePreference() {
        UserDefaults.standard.set(preference.rawValue, forKey: preferenceKey)
    }

    /// Set color scheme preference
    func setPreference(_ newPreference: ColorSchemePreference) {
        preference = newPreference
    }
}
