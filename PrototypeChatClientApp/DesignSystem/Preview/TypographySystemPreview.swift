//
//  TypographySystemPreview.swift
//  PrototypeChatClientApp
//
//  Design System Typography Preview
//  Comprehensive visualization of all typography tokens
//

import SwiftUI

/// Typography System Preview
///
/// Displays all typography tokens with:
/// - Visual samples of each style
/// - Technical specifications (size, weight, line height)
/// - Usage guidelines
/// - Code examples
struct TypographySystemPreview: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: App.Spacing.xl) {
                // Typography Scale
                TypographySection(title: "Typography Scale") {
                    TypographyToken(
                        style: .largeTitle,
                        label: "Large Title",
                        sample: "The quick brown fox",
                        usage: "Main page titles, hero sections"
                    )

                    TypographyToken(
                        style: .title1,
                        label: "Title 1",
                        sample: "The quick brown fox jumps",
                        usage: "Section headers, important headings"
                    )

                    TypographyToken(
                        style: .title2,
                        label: "Title 2",
                        sample: "The quick brown fox jumps over",
                        usage: "Subsection headers, card titles"
                    )

                    TypographyToken(
                        style: .headline,
                        label: "Headline",
                        sample: "The quick brown fox jumps over the lazy dog",
                        usage: "Emphasized text, button labels, item titles"
                    )

                    TypographyToken(
                        style: .body,
                        label: "Body",
                        sample: "The quick brown fox jumps over the lazy dog. This is the default text style for body content and general reading.",
                        usage: "Default body text, paragraphs, descriptions"
                    )

                    TypographyToken(
                        style: .callout,
                        label: "Callout",
                        sample: "The quick brown fox jumps over the lazy dog. Slightly emphasized body text.",
                        usage: "Highlighted information, important notes"
                    )

                    TypographyToken(
                        style: .subheadline,
                        label: "Subheadline",
                        sample: "The quick brown fox jumps over the lazy dog.",
                        usage: "Secondary information, subtitles"
                    )

                    TypographyToken(
                        style: .footnote,
                        label: "Footnote",
                        sample: "The quick brown fox jumps over the lazy dog.",
                        usage: "Supplementary details, helper text"
                    )

                    TypographyToken(
                        style: .caption1,
                        label: "Caption 1",
                        sample: "The quick brown fox jumps over the lazy dog.",
                        usage: "Labels, annotations, small details"
                    )

                    TypographyToken(
                        style: .caption2,
                        label: "Caption 2",
                        sample: "The quick brown fox jumps over the lazy dog.",
                        usage: "Smallest text, metadata, timestamps"
                    )
                }

                // Text Modifiers
                TypographySection(title: "Text Modifiers") {
                    VStack(alignment: .leading, spacing: App.Spacing.md) {
                        Text("Using .appText() Modifier")
                            .appText(.headline)

                        VStack(alignment: .leading, spacing: App.Spacing.sm) {
                            Text("Default usage:")
                                .appText(.caption1, color: App.Color.Text.Default.secondary)

                            CodeBlock("""
                            Text("Hello World")
                                .appText(.body)
                            """)

                            Text("With custom color:")
                                .appText(.caption1, color: App.Color.Text.Default.secondary)

                            CodeBlock("""
                            Text("Hello World")
                                .appText(
                                    .headline,
                                    color: App.Color.Text.Default.secondary
                                )
                            """)

                            Text("Examples:")
                                .appText(.caption1, color: App.Color.Text.Default.secondary)

                            Text("Primary text (default)")
                                .appText(.body)

                            Text("Secondary text")
                                .appText(.body, color: App.Color.Text.Default.secondary)

                            Text("Tertiary text")
                                .appText(.body, color: App.Color.Text.Default.tertiary)

                            Text("Danger text")
                                .appText(.body, color: App.Color.Text.Default.danger)
                        }
                        .padding(App.Spacing.md)
                        .background(App.Color.Fill.Default.secondary)
                        .cornerRadius(App.Radius.md)
                    }
                }

                // Typography Best Practices
                TypographySection(title: "Best Practices") {
                    VStack(alignment: .leading, spacing: App.Spacing.md) {
                        BestPracticeItem(
                            icon: "checkmark.circle.fill",
                            title: "Use semantic styles",
                            description: "Choose typography based on content hierarchy, not visual appearance",
                            isGood: true
                        )

                        BestPracticeItem(
                            icon: "checkmark.circle.fill",
                            title: "Maintain consistency",
                            description: "Use .appText() modifier throughout the app for consistent styling",
                            isGood: true
                        )

                        BestPracticeItem(
                            icon: "checkmark.circle.fill",
                            title: "Respect accessibility",
                            description: "Typography scales automatically with Dynamic Type settings",
                            isGood: true
                        )

                        BestPracticeItem(
                            icon: "xmark.circle.fill",
                            title: "Avoid custom font sizes",
                            description: "Don't use .font(.system(size: 16)) - use design tokens instead",
                            isGood: false
                        )

                        BestPracticeItem(
                            icon: "xmark.circle.fill",
                            title: "Don't mix systems",
                            description: "Don't combine .font() and .appText() on the same text",
                            isGood: false
                        )
                    }
                }

                // Accessibility
                TypographySection(title: "Accessibility") {
                    VStack(alignment: .leading, spacing: App.Spacing.md) {
                        Text("Dynamic Type Support")
                            .appText(.headline)

                        Text("All typography tokens automatically scale with the user's preferred text size setting. This ensures readability for users with visual impairments.")
                            .appText(.body, color: App.Color.Text.Default.secondary)

                        HStack(spacing: App.Spacing.md) {
                            VStack(alignment: .leading, spacing: App.Spacing.xs) {
                                Text("Default")
                                    .appText(.caption1, color: App.Color.Text.Default.tertiary)

                                Text("Body Text")
                                    .appText(.body)
                                    .environment(\.sizeCategory, .medium)
                            }
                            .padding(App.Spacing.sm)
                            .background(App.Color.Fill.Default.secondary)
                            .cornerRadius(App.Radius.sm)

                            VStack(alignment: .leading, spacing: App.Spacing.xs) {
                                Text("Large")
                                    .appText(.caption1, color: App.Color.Text.Default.tertiary)

                                Text("Body Text")
                                    .appText(.body)
                                    .environment(\.sizeCategory, .accessibilityLarge)
                            }
                            .padding(App.Spacing.sm)
                            .background(App.Color.Fill.Default.secondary)
                            .cornerRadius(App.Radius.sm)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Typography System")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Helper Views

/// Typography Section
///
/// Container for a group of related typography tokens
struct TypographySection<Content: View>: View {
    let title: String
    let content: () -> Content

    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: App.Spacing.md) {
            Text(title)
                .appText(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: App.Spacing.md) {
                content()
            }
        }
    }
}

/// Typography Token
///
/// Displays a single typography token with sample text and specifications
struct TypographyToken: View {
    let style: App.Typography
    let label: String
    let sample: String
    let usage: String

    var body: some View {
        VStack(alignment: .leading, spacing: App.Spacing.sm) {
            // Header
            HStack(alignment: .firstTextBaseline) {
                Text(label)
                    .appText(.subheadline, color: App.Color.Text.Default.secondary)

                Spacer()

                Text(".appText(.\(styleIdentifier))")
                    .appText(.caption2, color: App.Color.Text.Default.tertiary)
                    .font(.system(.caption2, design: .monospaced))
            }

            // Sample text
            Text(sample)
                .appText(style)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Usage description
            Text(usage)
                .appText(.caption1, color: App.Color.Text.Default.tertiary)
        }
        .padding(App.Spacing.md)
        .background(App.Color.Fill.Default.primaryStrong)
        .cornerRadius(App.Radius.md)
    }

    private var styleIdentifier: String {
        switch style {
        case .largeTitle: return "largeTitle"
        case .title1: return "title1"
        case .title2: return "title2"
        case .headline: return "headline"
        case .body: return "body"
        case .callout: return "callout"
        case .subheadline: return "subheadline"
        case .footnote: return "footnote"
        case .caption1: return "caption1"
        case .caption2: return "caption2"
        }
    }
}

/// Best Practice Item
///
/// Displays a best practice guideline with icon and description
struct BestPracticeItem: View {
    let icon: String
    let title: String
    let description: String
    let isGood: Bool

    var body: some View {
        HStack(alignment: .top, spacing: App.Spacing.sm) {
            Image(systemName: icon)
                .foregroundColor(isGood ?
                    App.Color.Semantic.success :
                    App.Color.Semantic.error
                )
                .frame(width: 24)

            VStack(alignment: .leading, spacing: App.Spacing.xxs) {
                Text(title)
                    .appText(.subheadline)

                Text(description)
                    .appText(.caption1, color: App.Color.Text.Default.secondary)
            }
        }
        .padding(App.Spacing.sm)
        .background(App.Color.Fill.Default.primaryStrong)
        .cornerRadius(App.Radius.sm)
    }
}

// MARK: - Preview

#Preview("Typography System") {
    NavigationView {
        TypographySystemPreview()
    }
}
