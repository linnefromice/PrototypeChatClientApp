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
struct AppPreview: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Colors") {
                    AppColorPreview()
                }

                NavigationLink("Typography") {
                    AppTypographyPreview()
                }

                NavigationLink("Spacing & Layout") {
                    AppSpacingPreview()
                }

                NavigationLink("Components") {
                    AppComponentPreview()
                }
            }
            .navigationTitle("Design System")
        }
    }
}

// MARK: - Color Preview

struct AppColorPreview: View {
    var body: some View {
        List {
            Section("Brand Colors") {
                ColorRow(name: "Primary", color: App.Color.Brand.primary)
                ColorRow(name: "Secondary", color: App.Color.Brand.secondary)
            }

            Section("Neutral Scale") {
                ColorRow(name: "Gray 100", color: App.Color.Neutral.gray100)
                ColorRow(name: "Gray 200", color: App.Color.Neutral.gray200)
                ColorRow(name: "Gray 300", color: App.Color.Neutral.gray300)
                ColorRow(name: "Gray 600", color: App.Color.Neutral.gray600)
                ColorRow(name: "Gray 900", color: App.Color.Neutral.gray900)
                ColorRow(name: "Gray 1000", color: App.Color.Neutral.gray1000)
                ColorRow(name: "White 100", color: App.Color.Neutral.white100)
                ColorRow(name: "White 500", color: App.Color.Neutral.white500)
                ColorRow(name: "White 1000", color: App.Color.Neutral.white1000)
            }

            Section("Semantic Colors") {
                ColorRow(name: "Success", color: App.Color.Semantic.success)
                ColorRow(name: "Error", color: App.Color.Semantic.error)
                ColorRow(name: "Warning", color: App.Color.Semantic.warning)
                ColorRow(name: "Info", color: App.Color.Semantic.info)
            }

            Section("Text Colors") {
                ColorRow(name: "Primary", color: App.Color.Text.Default.primary)
                ColorRow(name: "Secondary", color: App.Color.Text.Default.secondary)
                ColorRow(name: "Tertiary", color: App.Color.Text.Default.tertiary)
            }

            Section("Background Colors") {
                ColorRow(name: "Base", color: App.Color.Background.base)
                ColorRow(name: "Elevated", color: App.Color.Background.elevated)
            }
        }
        .navigationTitle("Colors")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ColorRow: View {
    let name: String
    let color: Color

    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 60, height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .appText(.body)
                Text("App.Color.\(inferPath())")
                    .appText(.caption1, color: App.Color.Text.Default.secondary)
                    .font(.system(.caption, design: .monospaced))
            }
        }
        .padding(.vertical, 4)
    }

    private func inferPath() -> String {
        // Simple heuristic to show the likely path
        if name.contains("Primary") || name.contains("Secondary") {
            return "Brand.\(name.lowercased())"
        }
        return name
    }
}

// MARK: - Typography Preview

struct AppTypographyPreview: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: App.Spacing.lg) {
                TypographyRow(
                    style: .largeTitle,
                    label: "Large Title",
                    sample: "The quick brown fox"
                )

                TypographyRow(
                    style: .title1,
                    label: "Title 1",
                    sample: "The quick brown fox jumps"
                )

                TypographyRow(
                    style: .title2,
                    label: "Title 2",
                    sample: "The quick brown fox jumps over"
                )

                TypographyRow(
                    style: .headline,
                    label: "Headline",
                    sample: "The quick brown fox jumps over the lazy dog"
                )

                TypographyRow(
                    style: .body,
                    label: "Body",
                    sample: "The quick brown fox jumps over the lazy dog. This is the default text style for body content."
                )

                TypographyRow(
                    style: .callout,
                    label: "Callout",
                    sample: "The quick brown fox jumps over the lazy dog."
                )

                TypographyRow(
                    style: .subheadline,
                    label: "Subheadline",
                    sample: "The quick brown fox jumps over the lazy dog."
                )

                TypographyRow(
                    style: .footnote,
                    label: "Footnote",
                    sample: "The quick brown fox jumps over the lazy dog."
                )

                TypographyRow(
                    style: .caption1,
                    label: "Caption 1",
                    sample: "The quick brown fox jumps over the lazy dog."
                )

                TypographyRow(
                    style: .caption2,
                    label: "Caption 2",
                    sample: "The quick brown fox jumps over the lazy dog."
                )
            }
            .padding()
        }
        .navigationTitle("Typography")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TypographyRow: View {
    let style: App.Typography
    let label: String
    let sample: String

    var body: some View {
        VStack(alignment: .leading, spacing: App.Spacing.xs) {
            HStack {
                Text(label)
                    .appText(.caption1, color: App.Color.Text.Default.secondary)
                Spacer()
                Text(".appText(.\(String(describing: style)))")
                    .appText(.caption2, color: App.Color.Text.Default.tertiary)
                    .font(.system(.caption2, design: .monospaced))
            }

            Text(sample)
                .appText(style)
        }
        .padding(.vertical, App.Spacing.xs)
    }
}

// MARK: - Spacing Preview

struct AppSpacingPreview: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: App.Spacing.lg) {
                Text("Spacing Scale")
                    .appText(.headline)

                SpacingRow(name: "xxxs", value: App.Spacing.xxxs)
                SpacingRow(name: "xxs", value: App.Spacing.xxs)
                SpacingRow(name: "xs", value: App.Spacing.xs)
                SpacingRow(name: "sm", value: App.Spacing.sm)
                SpacingRow(name: "md", value: App.Spacing.md)
                SpacingRow(name: "lg", value: App.Spacing.lg)
                SpacingRow(name: "xl", value: App.Spacing.xl)
                SpacingRow(name: "xxl", value: App.Spacing.xxl)
                SpacingRow(name: "xxxl", value: App.Spacing.xxxl)

                Divider()
                    .padding(.vertical, App.Spacing.md)

                Text("Corner Radius")
                    .appText(.headline)

                RadiusRow(name: "none", value: App.Radius.none)
                RadiusRow(name: "sm", value: App.Radius.sm)
                RadiusRow(name: "md", value: App.Radius.md)
                RadiusRow(name: "lg", value: App.Radius.lg)
                RadiusRow(name: "xl", value: App.Radius.xl)
            }
            .padding()
        }
        .navigationTitle("Spacing & Layout")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SpacingRow: View {
    let name: String
    let value: CGFloat

    var body: some View {
        HStack(alignment: .center, spacing: App.Spacing.md) {
            Text("App.Spacing.\(name)")
                .appText(.caption1)
                .font(.system(.caption, design: .monospaced))
                .frame(width: 120, alignment: .leading)

            Text("\(Int(value))pt")
                .appText(.caption1, color: App.Color.Text.Default.secondary)
                .frame(width: 40, alignment: .trailing)

            Rectangle()
                .fill(App.Color.Brand.primary)
                .frame(width: value, height: 20)
        }
    }
}

struct RadiusRow: View {
    let name: String
    let value: CGFloat

    var body: some View {
        HStack(alignment: .center, spacing: App.Spacing.md) {
            Text("App.Radius.\(name)")
                .appText(.caption1)
                .font(.system(.caption, design: .monospaced))
                .frame(width: 120, alignment: .leading)

            Text("\(value == 9999 ? "full" : "\(Int(value))pt")")
                .appText(.caption1, color: App.Color.Text.Default.secondary)
                .frame(width: 40, alignment: .trailing)

            RoundedRectangle(cornerRadius: min(value, 20))
                .fill(App.Color.Brand.primary)
                .frame(width: 60, height: 40)
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
