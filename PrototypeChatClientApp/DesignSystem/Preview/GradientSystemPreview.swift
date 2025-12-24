//
//  GradientSystemPreview.swift
//  PrototypeChatClientApp
//
//  Design System Gradient Preview
//  Comprehensive visualization of all gradient definitions
//

import SwiftUI

/// Gradient System Preview
///
/// Displays all available gradients organized by:
/// - Brand gradients (static)
/// - Functional gradients (dynamic)
/// - Utility gradients (shimmer, overlay, etc.)
struct GradientSystemPreview: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: App.Spacing.xl) {
                // Brand Gradients
                GradientSection(title: "Brand Gradients") {
                    GradientRow(
                        name: "brand",
                        gradient: AnyShapeStyle(App.Gradient.brand),
                        path: "App.Gradient.brand"
                    )
                }

                // Functional Gradients (Static)
                GradientSection(title: "Functional Gradients") {
                    GradientRow(
                        name: "reward",
                        gradient: AnyShapeStyle(App.Gradient.reward),
                        path: "App.Gradient.reward"
                    )

                    GradientRow(
                        name: "coin",
                        gradient: AnyShapeStyle(App.Gradient.coin),
                        path: "App.Gradient.coin"
                    )

                    GradientRow(
                        name: "success",
                        gradient: AnyShapeStyle(App.Gradient.success),
                        path: "App.Gradient.success"
                    )

                    GradientRow(
                        name: "error",
                        gradient: AnyShapeStyle(App.Gradient.error),
                        path: "App.Gradient.error"
                    )
                }

                // Utility Gradients (Dynamic)
                GradientSection(title: "Utility Gradients") {
                    GradientRow(
                        name: "shimmer",
                        gradient: AnyShapeStyle(App.Gradient.shimmer(colorScheme: colorScheme)),
                        path: "App.Gradient.shimmer(colorScheme:)"
                    )

                    GradientRow(
                        name: "glass",
                        gradient: AnyShapeStyle(App.Gradient.glass(colorScheme: colorScheme)),
                        path: "App.Gradient.glass(colorScheme:)"
                    )

                    GradientRow(
                        name: "scrim",
                        gradient: AnyShapeStyle(App.Gradient.scrim(colorScheme: colorScheme)),
                        path: "App.Gradient.scrim(colorScheme:)"
                    )

                    GradientRow(
                        name: "brandBackground",
                        gradient: AnyShapeStyle(App.Gradient.brandBackground(colorScheme: colorScheme)),
                        path: "App.Gradient.brandBackground(colorScheme:)"
                    )
                }

                // Usage Examples
                GradientSection(title: "Usage Examples") {
                    VStack(alignment: .leading, spacing: App.Spacing.md) {
                        Text("Static Gradient")
                            .appText(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        RoundedRectangle(cornerRadius: App.Radius.lg)
                            .fill(App.Gradient.brand)
                            .frame(height: 120)
                            .overlay(
                                VStack {
                                    Text("Brand Gradient")
                                        .appText(.headline, color: .white)
                                    Text("App.Gradient.brand")
                                        .appText(.caption1, color: .white.opacity(0.8))
                                        .font(.system(.caption, design: .monospaced))
                                }
                            )
                    }

                    VStack(alignment: .leading, spacing: App.Spacing.md) {
                        Text("Dynamic Gradient (Dark Mode Aware)")
                            .appText(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        RoundedRectangle(cornerRadius: App.Radius.lg)
                            .fill(App.Gradient.shimmer(colorScheme: colorScheme))
                            .frame(height: 120)
                            .overlay(
                                VStack {
                                    Text("Shimmer Effect")
                                        .appText(.headline, color: App.Color.Text.Default.primary)
                                    Text(".shimmer(colorScheme:)")
                                        .appText(.caption1, color: App.Color.Text.Default.secondary)
                                        .font(.system(.caption, design: .monospaced))
                                }
                            )
                    }

                    VStack(alignment: .leading, spacing: App.Spacing.md) {
                        Text("Using Gradient Modifier")
                            .appText(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        VStack {
                            Image(systemName: "star.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.white)
                            Text("gradientBackground Modifier")
                                .appText(.headline, color: .white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 120)
                        .gradientBackground { colorScheme in
                            App.Gradient.glass(colorScheme: colorScheme)
                        }
                        .cornerRadius(App.Radius.lg)
                    }

                    VStack(alignment: .leading, spacing: App.Spacing.md) {
                        Text("Code Example")
                            .appText(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(alignment: .leading, spacing: App.Spacing.xs) {
                            CodeBlock("""
                            // Static gradient
                            Rectangle()
                                .fill(App.Gradient.brand)

                            // Dynamic gradient
                            @Environment(\\.colorScheme) var colorScheme
                            Rectangle()
                                .fill(App.Gradient.shimmer(
                                    colorScheme: colorScheme
                                ))

                            // Using modifier
                            VStack { ... }
                                .gradientBackground { colorScheme in
                                    App.Gradient.glass(
                                        colorScheme: colorScheme
                                    )
                                }
                            """)
                        }
                        .padding(App.Spacing.md)
                        .background(App.Color.Fill.Default.secondary)
                        .cornerRadius(App.Radius.md)
                    }
                }

                // Mode indicator
                HStack {
                    Spacer()
                    Text("Current mode: \(colorScheme == .dark ? "Dark" : "Light")")
                        .appText(.caption1, color: App.Color.Text.Default.tertiary)
                    Spacer()
                }
                .padding(.vertical, App.Spacing.md)
            }
            .padding()
        }
        .navigationTitle("Gradient System")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Helper Views

/// Gradient Section
///
/// Container for a group of related gradients
struct GradientSection<Content: View>: View {
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

/// Gradient Row
///
/// Displays a single gradient with preview and code path
struct GradientRow: View {
    let name: String
    let gradient: AnyShapeStyle
    let path: String

    var body: some View {
        VStack(alignment: .leading, spacing: App.Spacing.sm) {
            // Gradient name
            Text(name)
                .appText(.subheadline)

            // Gradient preview
            RoundedRectangle(cornerRadius: App.Radius.md)
                .fill(gradient)
                .frame(height: 80)
                .overlay(
                    RoundedRectangle(cornerRadius: App.Radius.md)
                        .strokeBorder(App.Color.Stroke.Default.border, lineWidth: 1)
                )

            // Code path
            Text(path)
                .appText(.caption1, color: App.Color.Text.Default.secondary)
                .font(.system(.caption, design: .monospaced))
        }
        .padding(App.Spacing.sm)
        .background(App.Color.Fill.Default.primaryStrong)
        .cornerRadius(App.Radius.md)
    }
}

/// Code Block
///
/// Displays formatted code with monospaced font
struct CodeBlock: View {
    let code: String

    init(_ code: String) {
        self.code = code
    }

    var body: some View {
        Text(code)
            .appText(.caption1, color: App.Color.Text.Default.secondary)
            .font(.system(.caption, design: .monospaced))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview

#Preview("Light Mode") {
    NavigationView {
        GradientSystemPreview()
    }
    .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    NavigationView {
        GradientSystemPreview()
    }
    .preferredColorScheme(.dark)
}
