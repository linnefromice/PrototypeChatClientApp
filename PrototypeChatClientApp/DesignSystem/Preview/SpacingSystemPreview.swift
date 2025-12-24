//
//  SpacingSystemPreview.swift
//  PrototypeChatClientApp
//
//  Design System Spacing & Layout Preview
//  Comprehensive visualization of spacing, radius, and shadow tokens
//

import SwiftUI

/// Spacing System Preview
///
/// Displays all layout-related tokens:
/// - Spacing scale (xxxs to xxxl)
/// - Corner radius (none to full)
/// - Shadow styles (sm to xl)
struct SpacingSystemPreview: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: App.Spacing.xl) {
                // Spacing Scale
                SpacingScaleSection()

                Divider()

                // Corner Radius
                CornerRadiusSection()

                Divider()

                // Shadow Styles
                ShadowStylesSection()

                Divider()

                // Usage Examples
                UsageExamplesSection()
            }
            .padding()
        }
        .navigationTitle("Spacing & Layout")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Sections

/// Spacing Scale Section
///
/// Visualizes all spacing tokens from xxxs to xxxl
struct SpacingScaleSection: View {
    private let spacings: [(name: String, value: CGFloat)] = [
        ("xxxs", App.Spacing.xxxs),
        ("xxs", App.Spacing.xxs),
        ("xs", App.Spacing.xs),
        ("sm", App.Spacing.sm),
        ("md", App.Spacing.md),
        ("lg", App.Spacing.lg),
        ("xl", App.Spacing.xl),
        ("xxl", App.Spacing.xxl),
        ("xxxl", App.Spacing.xxxl)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: App.Spacing.md) {
            Text("Spacing Scale")
                .appText(.headline)

            Text("Consistent spacing creates visual rhythm and hierarchy")
                .appText(.body, color: App.Color.Text.Default.secondary)

            VStack(spacing: App.Spacing.sm) {
                ForEach(spacings, id: \.name) { spacing in
                    SpacingRow(name: spacing.name, value: spacing.value)
                }
            }
        }
    }
}

/// Spacing Row
///
/// Displays a single spacing token with visual representation
struct SpacingRow: View {
    let name: String
    let value: CGFloat

    var body: some View {
        HStack(spacing: App.Spacing.md) {
            // Token name and value
            VStack(alignment: .leading, spacing: App.Spacing.xxxs) {
                Text("App.Spacing.\(name)")
                    .appText(.body)
                    .font(.system(.body, design: .monospaced))

                Text("\(Int(value))pt")
                    .appText(.caption1, color: App.Color.Text.Default.secondary)
            }
            .frame(width: 160, alignment: .leading)

            // Visual representation
            Rectangle()
                .fill(App.Color.Brand.primary)
                .frame(width: value, height: 24)

            Spacer()
        }
        .padding(App.Spacing.sm)
        .background(App.Color.Fill.Default.primaryStrong)
        .cornerRadius(App.Radius.sm)
    }
}

/// Corner Radius Section
///
/// Visualizes all corner radius tokens
struct CornerRadiusSection: View {
    private let radii: [(name: String, value: CGFloat)] = [
        ("none", App.Radius.none),
        ("sm", App.Radius.sm),
        ("md", App.Radius.md),
        ("lg", App.Radius.lg),
        ("xl", App.Radius.xl),
        ("full", App.Radius.full)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: App.Spacing.md) {
            Text("Corner Radius")
                .appText(.headline)

            Text("Rounded corners soften the interface and define visual boundaries")
                .appText(.body, color: App.Color.Text.Default.secondary)

            VStack(spacing: App.Spacing.sm) {
                ForEach(radii, id: \.name) { radius in
                    RadiusRow(name: radius.name, value: radius.value)
                }
            }
        }
    }
}

/// Radius Row
///
/// Displays a single corner radius token with visual example
struct RadiusRow: View {
    let name: String
    let value: CGFloat

    var body: some View {
        HStack(spacing: App.Spacing.md) {
            // Token name and value
            VStack(alignment: .leading, spacing: App.Spacing.xxxs) {
                Text("App.Radius.\(name)")
                    .appText(.body)
                    .font(.system(.body, design: .monospaced))

                Text(value == App.Radius.full ? "full" : "\(Int(value))pt")
                    .appText(.caption1, color: App.Color.Text.Default.secondary)
            }
            .frame(width: 160, alignment: .leading)

            // Visual representation
            RoundedRectangle(cornerRadius: value == App.Radius.full ? 30 : value)
                .fill(App.Color.Brand.primary)
                .frame(width: 80, height: 60)

            Spacer()
        }
        .padding(App.Spacing.sm)
        .background(App.Color.Fill.Default.primaryStrong)
        .cornerRadius(App.Radius.sm)
    }
}

/// Shadow Styles Section
///
/// Visualizes all shadow style tokens
struct ShadowStylesSection: View {
    private let shadows: [(name: String, shadow: App.Shadow)] = [
        ("none", App.Shadow.none),
        ("sm", App.Shadow.sm),
        ("md", App.Shadow.md),
        ("lg", App.Shadow.lg)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: App.Spacing.md) {
            Text("Shadow Styles")
                .appText(.headline)

            Text("Shadows create depth and visual hierarchy in the interface")
                .appText(.body, color: App.Color.Text.Default.secondary)

            VStack(spacing: App.Spacing.lg) {
                ForEach(shadows, id: \.name) { shadow in
                    ShadowRow(name: shadow.name, shadow: shadow.shadow)
                }
            }
        }
    }
}

/// Shadow Row
///
/// Displays a single shadow token with visual example
struct ShadowRow: View {
    let name: String
    let shadow: App.Shadow

    var body: some View {
        VStack(alignment: .leading, spacing: App.Spacing.sm) {
            // Token name
            Text("App.Shadow.\(name)")
                .appText(.body)
                .font(.system(.body, design: .monospaced))

            // Visual representation
            RoundedRectangle(cornerRadius: App.Radius.md)
                .fill(App.Color.Fill.Default.primaryStrong)
                .frame(height: 80)
                .appShadow(shadow)
                .padding(App.Spacing.md)
                .background(App.Color.Fill.Default.secondary)
                .cornerRadius(App.Radius.md)
        }
    }
}

/// Usage Examples Section
///
/// Demonstrates practical usage of spacing, radius, and shadows
struct UsageExamplesSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: App.Spacing.md) {
            Text("Usage Examples")
                .appText(.headline)

            // Spacing example
            VStack(alignment: .leading, spacing: App.Spacing.md) {
                Text("Spacing")
                    .appText(.subheadline, color: App.Color.Text.Default.secondary)

                VStack(alignment: .leading, spacing: App.Spacing.xxxs) {
                    CodeBlock("""
                    VStack(spacing: App.Spacing.md) {
                        Text("Item 1")
                        Text("Item 2")
                    }
                    .padding(App.Spacing.lg)
                    """)
                }
                .padding(App.Spacing.md)
                .background(App.Color.Fill.Default.secondary)
                .cornerRadius(App.Radius.md)

                VStack(spacing: App.Spacing.md) {
                    Text("Item 1")
                        .appText(.body)
                    Text("Item 2")
                        .appText(.body)
                }
                .padding(App.Spacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(App.Color.Fill.Default.primaryStrong)
                .cornerRadius(App.Radius.md)
            }

            // Corner radius example
            VStack(alignment: .leading, spacing: App.Spacing.md) {
                Text("Corner Radius")
                    .appText(.subheadline, color: App.Color.Text.Default.secondary)

                VStack(alignment: .leading, spacing: App.Spacing.xxxs) {
                    CodeBlock("""
                    RoundedRectangle(
                        cornerRadius: App.Radius.lg
                    )
                    .fill(App.Color.Brand.primary)
                    """)
                }
                .padding(App.Spacing.md)
                .background(App.Color.Fill.Default.secondary)
                .cornerRadius(App.Radius.md)

                RoundedRectangle(cornerRadius: App.Radius.lg)
                    .fill(App.Color.Brand.primary)
                    .frame(height: 80)
            }

            // Shadow example
            VStack(alignment: .leading, spacing: App.Spacing.md) {
                Text("Shadow")
                    .appText(.subheadline, color: App.Color.Text.Default.secondary)

                VStack(alignment: .leading, spacing: App.Spacing.xxxs) {
                    CodeBlock("""
                    VStack {
                        Text("Elevated Card")
                    }
                    .padding(App.Spacing.md)
                    .background(
                        App.Color.Fill.Default.primaryStrong
                    )
                    .cornerRadius(App.Radius.md)
                    .appShadow(.lg)
                    """)
                }
                .padding(App.Spacing.md)
                .background(App.Color.Fill.Default.secondary)
                .cornerRadius(App.Radius.md)

                VStack {
                    Text("Elevated Card")
                        .appText(.headline)
                    Text("With large shadow")
                        .appText(.body, color: App.Color.Text.Default.secondary)
                }
                .padding(App.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(App.Color.Fill.Default.primaryStrong)
                .cornerRadius(App.Radius.md)
                .appShadow(.lg)
                .padding(App.Spacing.md)
            }

            // Combined example
            VStack(alignment: .leading, spacing: App.Spacing.md) {
                Text("Combined")
                    .appText(.subheadline, color: App.Color.Text.Default.secondary)

                Text("Using all layout tokens together creates a cohesive design:")
                    .appText(.caption1, color: App.Color.Text.Default.tertiary)

                VStack(alignment: .leading, spacing: App.Spacing.sm) {
                    Text("Profile Card")
                        .appText(.headline)

                    HStack(spacing: App.Spacing.md) {
                        Circle()
                            .fill(App.Color.Brand.primary)
                            .frame(width: 48, height: 48)

                        VStack(alignment: .leading, spacing: App.Spacing.xxs) {
                            Text("John Doe")
                                .appText(.body)
                            Text("iOS Developer")
                                .appText(.caption1, color: App.Color.Text.Default.secondary)
                        }
                    }
                }
                .padding(App.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(App.Color.Fill.Default.primaryStrong)
                .cornerRadius(App.Radius.lg)
                .appShadow(.md)
            }
        }
    }
}

// MARK: - Preview

#Preview("Spacing System") {
    NavigationView {
        SpacingSystemPreview()
    }
}
