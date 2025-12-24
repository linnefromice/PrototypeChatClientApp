//
//  AppPreview.swift
//  PrototypeChatClientApp
//
//  Design System Preview
//  Comprehensive preview of all design system tokens and components
//

import SwiftUI

/// Design System Showcase
///
/// Displays all design system tokens (colors, typography, spacing, etc.)
/// and components for visual verification and testing.
///
/// Use this view during development to:
/// - Verify design system implementation
/// - Test light/dark mode
/// - Review component variations
/// - Demonstrate the design system to stakeholders
///
/// **Phase 1 Implementation:**
/// - Enhanced #Preview with comprehensive token visualization
/// - TabView navigation for quick access to all design system elements
/// - Real-time dark mode switching for testing
struct AppPreview: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        TabView {
            // Foundation Tokens
            NavigationView {
                ColorSystemPreview()
            }
            .tabItem {
                Label("Colors", systemImage: "paintpalette.fill")
            }

            NavigationView {
                GradientSystemPreview()
            }
            .tabItem {
                Label("Gradients", systemImage: "circle.lefthalf.filled")
            }

            NavigationView {
                TypographySystemPreview()
            }
            .tabItem {
                Label("Typography", systemImage: "textformat")
            }

            NavigationView {
                SpacingSystemPreview()
            }
            .tabItem {
                Label("Layout", systemImage: "ruler")
            }

            // Components
            NavigationView {
                AppComponentPreview()
            }
            .tabItem {
                Label("Components", systemImage: "square.stack.3d.up.fill")
            }
        }
    }
}

// MARK: - Component Preview

struct AppComponentPreview: View {
    @State private var showToast = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: App.Spacing.xl) {
                // Buttons
                VStack(alignment: .leading, spacing: App.Spacing.md) {
                    Text("Buttons")
                        .appText(.headline)

                    AppButton("Primary Button", style: .primary) {}
                    AppButton("Secondary Button", style: .secondary) {}
                    AppButton("Tertiary Button", style: .tertiary) {}
                    AppButton("Destructive Button", style: .destructive) {}
                    AppButton("Disabled Button", isEnabled: false) {}

                    Text("Button Sizes")
                        .appText(.subheadline, color: App.Color.Text.Default.secondary)
                        .padding(.top, App.Spacing.sm)

                    AppButton("Small", size: .small) {}
                    AppButton("Medium (default)", size: .medium) {}
                    AppButton("Large", size: .large) {}
                }

                Divider()

                // Cards
                VStack(alignment: .leading, spacing: App.Spacing.md) {
                    Text("Cards")
                        .appText(.headline)

                    AppCard {
                        VStack(alignment: .leading, spacing: App.Spacing.sm) {
                            Text("Default Card")
                                .appText(.headline)
                            Text("This is a card component with default styling.")
                                .appText(.body, color: App.Color.Text.Default.secondary)
                        }
                    }

                    AppCard(
                        backgroundColor: App.Color.Brand.primary.opacity(0.1),
                        cornerRadius: App.Radius.xl,
                        shadow: .lg
                    ) {
                        HStack(spacing: App.Spacing.md) {
                            Image(systemName: "star.fill")
                                .foregroundColor(App.Color.Brand.primary)
                            VStack(alignment: .leading, spacing: App.Spacing.xxs) {
                                Text("Featured Card")
                                    .appText(.headline, color: App.Color.Brand.primary)
                                Text("Custom styled with large radius and shadow")
                                    .appText(.callout, color: App.Color.Text.Default.secondary)
                            }
                        }
                    }
                }

                Divider()

                // Modifiers
                VStack(alignment: .leading, spacing: App.Spacing.md) {
                    Text("Modifiers")
                        .appText(.headline)

                    VStack(alignment: .leading, spacing: App.Spacing.sm) {
                        Text("Using .appCard() Modifier")
                            .appText(.subheadline, color: App.Color.Text.Default.secondary)

                        VStack(alignment: .leading) {
                            Text("Card via Modifier")
                                .appText(.headline)
                            Text("Applied using .appCard() modifier")
                                .appText(.body, color: App.Color.Text.Default.secondary)
                        }
                        .padding(App.Spacing.md)
                        .appCard()
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Components")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

struct AppPreview_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AppPreview()
                .previewDisplayName("Light Mode")

            AppPreview()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
