//
//  ColorSystemPreview.swift
//  PrototypeChatClientApp
//
//  Design System Color Preview
//  Comprehensive visualization of all color tokens organized by semantic usage
//

import SwiftUI

/// Color System Preview
///
/// Displays all color tokens organized by:
/// - Text colors (Default, Link, Function)
/// - Icon colors (Default, Function)
/// - Stroke colors (Default, Highlight, Danger)
/// - Fill colors (Default, Light, Shadow, Function)
/// - Neutral colors (direct access)
struct ColorSystemPreview: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        List {
            // Text Colors
            Section {
                ColorTokenGroup(
                    title: "Default",
                    tokens: [
                        ("primary", App.Color.Text.Default.primary),
                        ("secondary", App.Color.Text.Default.secondary),
                        ("tertiary", App.Color.Text.Default.tertiary),
                        ("tertiaryStrong", App.Color.Text.Default.tertiaryStrong),
                        ("annotation", App.Color.Text.Default.annotation),
                        ("disable", App.Color.Text.Default.disable),
                        ("message", App.Color.Text.Default.message),
                        ("inversion", App.Color.Text.Default.inversion),
                        ("danger", App.Color.Text.Default.danger)
                    ]
                )

                ColorTokenGroup(
                    title: "Link",
                    tokens: [
                        ("primaryActive", App.Color.Text.Link.primaryActive),
                        ("secondaryActive", App.Color.Text.Link.secondaryActive),
                        ("error", App.Color.Text.Link.error),
                        ("disable", App.Color.Text.Link.disable)
                    ]
                )

                ColorTokenGroup(
                    title: "Function",
                    tokens: [
                        ("rewards", App.Color.Text.Function.rewards),
                        ("coin", App.Color.Text.Function.coin)
                    ]
                )
            } header: {
                Text("Text Colors")
                    .appText(.headline)
            }

            // Icon Colors
            Section {
                ColorTokenGroup(
                    title: "Default",
                    tokens: [
                        ("primary", App.Color.Icon.Default.primary),
                        ("secondary", App.Color.Icon.Default.secondary),
                        ("tertiary", App.Color.Icon.Default.tertiary),
                        ("tertiaryStrong", App.Color.Icon.Default.tertiaryStrong),
                        ("disable", App.Color.Icon.Default.disable),
                        ("inversion", App.Color.Icon.Default.inversion),
                        ("danger", App.Color.Icon.Default.danger)
                    ]
                )

                ColorTokenGroup(
                    title: "Function",
                    tokens: [
                        ("rewards", App.Color.Icon.Function.rewards),
                        ("coin", App.Color.Icon.Function.coin)
                    ]
                )
            } header: {
                Text("Icon Colors")
                    .appText(.headline)
            }

            // Stroke Colors
            Section {
                ColorTokenGroup(
                    title: "Default",
                    tokens: [
                        ("primary", App.Color.Stroke.Default.primary),
                        ("secondary", App.Color.Stroke.Default.secondary),
                        ("tertiary", App.Color.Stroke.Default.tertiary),
                        ("border", App.Color.Stroke.Default.border)
                    ]
                )

                ColorTokenGroup(
                    title: "Highlight",
                    tokens: [
                        ("primary", App.Color.Stroke.Highlight.primary),
                        ("secondary", App.Color.Stroke.Highlight.secondary),
                        ("tertiary", App.Color.Stroke.Highlight.tertiary),
                        ("button", App.Color.Stroke.Highlight.button)
                    ]
                )

                ColorTokenGroup(
                    title: "Danger",
                    tokens: [
                        ("primary", App.Color.Stroke.Danger.primary),
                        ("secondary", App.Color.Stroke.Danger.secondary)
                    ]
                )
            } header: {
                Text("Stroke Colors")
                    .appText(.headline)
            }

            // Fill Colors
            Section {
                ColorTokenGroup(
                    title: "Default",
                    tokens: [
                        ("primaryStrong", App.Color.Fill.Default.primaryStrong),
                        ("primaryLight", App.Color.Fill.Default.primaryLight),
                        ("secondary", App.Color.Fill.Default.secondary),
                        ("tertiary", App.Color.Fill.Default.tertiary),
                        ("drop", App.Color.Fill.Default.drop),
                        ("coin", App.Color.Fill.Default.coin),
                        ("tutorial", App.Color.Fill.Default.tutorial),
                        ("dangerPrimary", App.Color.Fill.Default.dangerPrimary),
                        ("dangerSecondary", App.Color.Fill.Default.dangerSecondary),
                        ("dangerTertiary", App.Color.Fill.Default.dangerTertiary),
                        ("dangerLight", App.Color.Fill.Default.dangerLight)
                    ]
                )

                ColorTokenGroup(
                    title: "Light",
                    tokens: [
                        ("white1000", App.Color.Fill.Light.white1000),
                        ("white500", App.Color.Fill.Light.white500),
                        ("white300", App.Color.Fill.Light.white300),
                        ("white200", App.Color.Fill.Light.white200),
                        ("white100", App.Color.Fill.Light.white100),
                        ("white100Light", App.Color.Fill.Light.white100Light)
                    ]
                )

                ColorTokenGroup(
                    title: "Shadow",
                    tokens: [
                        ("black800", App.Color.Fill.Shadow.black800),
                        ("black700", App.Color.Fill.Shadow.black700),
                        ("black500", App.Color.Fill.Shadow.black500),
                        ("black400", App.Color.Fill.Shadow.black400),
                        ("black200", App.Color.Fill.Shadow.black200)
                    ]
                )

                ColorTokenGroup(
                    title: "Function",
                    tokens: [
                        ("rewardsPrimary", App.Color.Fill.Function.rewardsPrimary),
                        ("rewardsSecondary", App.Color.Fill.Function.rewardsSecondary),
                        ("rewardsTertiary", App.Color.Fill.Function.rewardsTertiary),
                        ("coinPrimary", App.Color.Fill.Function.coinPrimary),
                        ("coinSecondary", App.Color.Fill.Function.coinSecondary),
                        ("coinTertiary", App.Color.Fill.Function.coinTertiary),
                        ("checkSecondary", App.Color.Fill.Function.checkSecondary),
                        ("checkTertiary", App.Color.Fill.Function.checkTertiary),
                        ("onlinePrimary", App.Color.Fill.Function.onlinePrimary),
                        ("onlineSecondary", App.Color.Fill.Function.onlineSecondary),
                        ("onlineTertiary", App.Color.Fill.Function.onlineTertiary),
                        ("search", App.Color.Fill.Function.search),
                        ("linkPrimary", App.Color.Fill.Function.linkPrimary),
                        ("linkSecondary", App.Color.Fill.Function.linkSecondary),
                        ("linkTertiary", App.Color.Fill.Function.linkTertiary),
                        ("friendsPrimary", App.Color.Fill.Function.friendsPrimary),
                        ("friendsSecondary", App.Color.Fill.Function.friendsSecondary),
                        ("friendsTertiary", App.Color.Fill.Function.friendsTertiary)
                    ]
                )
            } header: {
                Text("Fill Colors")
                    .appText(.headline)
            }

            // Neutral Colors
            Section {
                ColorTokenGroup(
                    title: "Black Scale",
                    tokens: [
                        ("black1000", App.Color.Neutral.black1000),
                        ("black700", App.Color.Neutral.black700),
                        ("black400", App.Color.Neutral.black400),
                        ("black100", App.Color.Neutral.black100)
                    ]
                )

                ColorTokenGroup(
                    title: "Gray Scale",
                    tokens: [
                        ("gray1000", App.Color.Neutral.gray1000),
                        ("gray900", App.Color.Neutral.gray900),
                        ("gray800", App.Color.Neutral.gray800),
                        ("gray700", App.Color.Neutral.gray700),
                        ("gray600", App.Color.Neutral.gray600),
                        ("gray500100", App.Color.Neutral.gray500100),
                        ("gray50050", App.Color.Neutral.gray50050),
                        ("gray50030", App.Color.Neutral.gray50030),
                        ("gray50010", App.Color.Neutral.gray50010),
                        ("gray400", App.Color.Neutral.gray400),
                        ("gray300", App.Color.Neutral.gray300),
                        ("gray200", App.Color.Neutral.gray200),
                        ("gray100", App.Color.Neutral.gray100)
                    ]
                )

                ColorTokenGroup(
                    title: "White Scale",
                    tokens: [
                        ("white1000", App.Color.Neutral.white1000),
                        ("white700", App.Color.Neutral.white700),
                        ("white500", App.Color.Neutral.white500),
                        ("white400", App.Color.Neutral.white400),
                        ("white300", App.Color.Neutral.white300),
                        ("white200", App.Color.Neutral.white200),
                        ("white100", App.Color.Neutral.white100)
                    ]
                )
            } header: {
                Text("Neutral Colors (Direct Access)")
                    .appText(.headline)
            }

            // Legacy Colors
            Section {
                ColorTokenGroup(
                    title: "Brand",
                    tokens: [
                        ("primary", App.Color.Brand.primary),
                        ("secondary", App.Color.Brand.secondary)
                    ]
                )

                ColorTokenGroup(
                    title: "Semantic",
                    tokens: [
                        ("success", App.Color.Semantic.success),
                        ("error", App.Color.Semantic.error),
                        ("warning", App.Color.Semantic.warning),
                        ("info", App.Color.Semantic.info)
                    ]
                )
            } header: {
                Text("Legacy Colors")
                    .appText(.headline)
            } footer: {
                Text("Current mode: \(colorScheme == .dark ? "Dark" : "Light")")
                    .appText(.caption1, color: App.Color.Text.Default.tertiary)
            }
        }
        .navigationTitle("Color System")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Helper Views

/// Color Token Group
///
/// Displays a group of related color tokens with their names
struct ColorTokenGroup: View {
    let title: String
    let tokens: [(name: String, color: Color)]

    var body: some View {
        VStack(alignment: .leading, spacing: App.Spacing.sm) {
            Text(title)
                .appText(.subheadline, color: App.Color.Text.Default.secondary)
                .padding(.top, App.Spacing.xs)

            ForEach(tokens, id: \.name) { token in
                ColorTokenRow(
                    name: token.name,
                    color: token.color,
                    path: "\(title).\(token.name)"
                )
            }
        }
    }
}

/// Color Token Row
///
/// Displays a single color token with preview swatch and code path
struct ColorTokenRow: View {
    let name: String
    let color: Color
    let path: String

    var body: some View {
        HStack(spacing: App.Spacing.md) {
            // Color swatch
            RoundedRectangle(cornerRadius: App.Radius.sm)
                .fill(color)
                .frame(width: 60, height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: App.Radius.sm)
                        .strokeBorder(App.Color.Stroke.Default.border, lineWidth: 1)
                )

            // Token information
            VStack(alignment: .leading, spacing: App.Spacing.xxxs) {
                Text(name)
                    .appText(.body)

                Text("App.Color.\(path)")
                    .appText(.caption1, color: App.Color.Text.Default.secondary)
                    .font(.system(.caption, design: .monospaced))
            }

            Spacer()
        }
        .padding(.vertical, App.Spacing.xxs)
    }
}

// MARK: - Preview

#Preview("Light Mode") {
    NavigationView {
        ColorSystemPreview()
    }
    .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    NavigationView {
        ColorSystemPreview()
    }
    .preferredColorScheme(.dark)
}
