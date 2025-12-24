# Design Catalog Preview Roadmap

**Version:** 1.0.0
**Status:** Planning
**Last Updated:** 2024-12-24

## Executive Summary

This roadmap outlines the strategy for creating a visual catalog of the Design System, starting with Xcode Previews (#Preview) and progressing toward automated snapshot testing and HTML catalog generation (Storybook-like approach).

### Vision

Create a comprehensive, maintainable design system catalog that serves:
- **Engineers**: Quick visual reference during development
- **Designers**: Visual verification of implementation
- **PMs**: Understanding of available UI components
- **Stakeholders**: Documentation via static HTML/PNG exports

### Approach

**Hybrid Strategy**: Integrate catalog views into the main app's debug build + Automated snapshot testing

```
┌─────────────────────────────────────────────────────┐
│  Phase 1: Enhanced #Preview                         │
│  → Immediate developer productivity                 │
├─────────────────────────────────────────────────────┤
│  Phase 2: Integrated Catalog View                   │
│  → Debug menu integration                           │
├─────────────────────────────────────────────────────┤
│  Phase 3: Snapshot Testing                          │
│  → Automated visual regression + PNG generation     │
├─────────────────────────────────────────────────────┤
│  Phase 4: HTML Catalog Generation                   │
│  → Storybook-like static site                       │
└─────────────────────────────────────────────────────┘
```

---

## Phase 1: Enhanced #Preview (Week 1-2)

**Status**: 🎯 Next Up
**Goal**: Expand existing `AppPreview.swift` to comprehensively showcase all design tokens

### 1.1 File Structure

```
DesignSystem/
└── Preview/
    ├── AppPreview.swift                    # Main entry point (TabView)
    ├── Foundation/
    │   ├── ColorSystemPreview.swift        # All semantic colors
    │   ├── GradientSystemPreview.swift     # All gradients
    │   ├── TypographySystemPreview.swift   # Typography scale
    │   ├── SpacingSystemPreview.swift      # Spacing tokens
    │   ├── RadiusSystemPreview.swift       # Corner radius
    │   └── ShadowSystemPreview.swift       # Shadow tokens
    ├── Components/
    │   ├── ButtonComponentPreview.swift    # AppButton variations
    │   └── CardComponentPreview.swift      # AppCard variations
    └── Helpers/
        ├── ColorRow.swift                  # Reusable color display
        ├── GradientRow.swift               # Reusable gradient display
        └── TokenSection.swift              # Section wrapper
```

### 1.2 Implementation Details

#### Main Entry Point

```swift
// AppPreview.swift
struct AppPreview: View {
    var body: some View {
        TabView {
            ColorSystemPreview()
                .tabItem { Label("Colors", systemImage: "paintpalette") }

            GradientSystemPreview()
                .tabItem { Label("Gradients", systemImage: "wand.and.rays") }

            TypographySystemPreview()
                .tabItem { Label("Typography", systemImage: "textformat") }

            SpacingSystemPreview()
                .tabItem { Label("Spacing", systemImage: "ruler") }

            ComponentShowcase()
                .tabItem { Label("Components", systemImage: "square.stack.3d.up") }
        }
    }
}

#Preview("Design System") {
    AppPreview()
}

#Preview("Design System - Dark") {
    AppPreview()
        .preferredColorScheme(.dark)
}
```

#### Color System Preview

```swift
// ColorSystemPreview.swift
struct ColorSystemPreview: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationView {
            List {
                Section("Text Colors") {
                    ColorRow(
                        name: "Text.Default.primary",
                        color: App.Color.Text.Default.primary,
                        description: "Highest contrast text"
                    )
                    ColorRow(
                        name: "Text.Default.secondary",
                        color: App.Color.Text.Default.secondary,
                        description: "Medium contrast text"
                    )
                    // ... more text colors
                }

                Section("Icon Colors") {
                    // ... icon colors
                }

                Section("Fill Colors") {
                    // ... fill colors
                }

                Section("Neutral Colors") {
                    // ... neutral colors
                }
            }
            .navigationTitle("Colors")
        }
    }
}
```

#### Gradient System Preview

```swift
// GradientSystemPreview.swift
struct GradientSystemPreview: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationView {
            List {
                Section("Brand Gradients") {
                    GradientRow(
                        name: "brand",
                        gradient: AnyShapeStyle(App.Gradient.brand),
                        description: "Primary brand gradient"
                    )
                    GradientRow(
                        name: "brandBackground",
                        gradient: AnyShapeStyle(
                            App.Gradient.brandBackground(colorScheme: colorScheme)
                        ),
                        description: "Adaptive background gradient"
                    )
                }

                Section("Functional Gradients") {
                    GradientRow(
                        name: "reward",
                        gradient: AnyShapeStyle(App.Gradient.reward),
                        description: "Magenta to purple"
                    )
                    // ... more functional gradients
                }

                Section("Utility Gradients") {
                    // ... utility gradients
                }
            }
            .navigationTitle("Gradients")
        }
    }
}
```

### 1.3 Deliverables

- ✅ Comprehensive preview for all Layer 1 tokens (Colors, Gradients, Typography, Spacing, Radius, Shadow)
- ✅ Light/Dark mode toggle in previews
- ✅ Reusable preview components (ColorRow, GradientRow, etc.)
- ✅ Documentation comments in code

### 1.4 Success Metrics

- All 50+ color primitives displayed
- All semantic color categories (Text, Icon, Stroke, Fill) documented
- All 10+ gradients showcased
- Typography scale (10 styles) fully visible
- Light/Dark mode comparison available

---

## Phase 2: Integrated Catalog View (Week 3-4)

**Status**: 🔜 Upcoming
**Goal**: Make design catalog accessible from the main app's debug build

### 2.1 Architecture

```swift
// DesignSystem/Catalog/DesignSystemCatalog.swift
public struct DesignSystemCatalog: View {
    public init() {}

    public var body: some View {
        NavigationView {
            List {
                Section(header: Text("Layer 1: Foundation Tokens")) {
                    NavigationLink("Colors", destination: ColorSystemPreview())
                    NavigationLink("Gradients", destination: GradientSystemPreview())
                    NavigationLink("Typography", destination: TypographySystemPreview())
                    NavigationLink("Spacing", destination: SpacingSystemPreview())
                    NavigationLink("Radius & Shadow", destination: RadiusShadowPreview())
                }

                Section(header: Text("Layer 2: Modifiers & Components")) {
                    NavigationLink("Components", destination: ComponentShowcase())
                    NavigationLink("Modifiers", destination: ModifierShowcase())
                }

                Section(header: Text("Utilities")) {
                    NavigationLink("Dark Mode Comparison", destination: DarkModeComparison())
                }
            }
            .navigationTitle("Design System v1.0.0")
        }
    }
}
```

### 2.2 Integration Point

```swift
// App/PrototypeChatClientAppApp.swift
@main
struct PrototypeChatClientAppApp: App {
    #if DEBUG
    @State private var showDesignCatalog = false
    #endif

    var body: some Scene {
        WindowGroup {
            RootView()
                #if DEBUG
                .onShake { showDesignCatalog = true }
                .sheet(isPresented: $showDesignCatalog) {
                    DesignSystemCatalog()
                }
                #endif
        }
    }
}

// Core/Extensions/UIDevice+Shake.swift (if needed)
extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name("deviceDidShakeNotification")
}

extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        self.modifier(ShakeGestureModifier(action: action))
    }
}
```

### 2.3 Alternative Access Methods

**Option A: Debug Menu Button**
```swift
// Add floating debug button in debug builds
#if DEBUG
.overlay(alignment: .bottomTrailing) {
    Button {
        showDesignCatalog = true
    } label: {
        Image(systemName: "paintpalette.fill")
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(Circle())
    }
    .padding()
}
#endif
```

**Option B: Triple Tap Gesture**
```swift
.onTapGesture(count: 3) {
    #if DEBUG
    showDesignCatalog = true
    #endif
}
```

### 2.4 Deliverables

- ✅ `DesignSystemCatalog` entry point
- ✅ Debug-only access method (shake, button, or gesture)
- ✅ Navigation structure for all tokens and components
- ✅ Real device testing capability

### 2.5 Success Metrics

- Catalog accessible on real devices and simulators
- No impact on Release builds (debug-only)
- Navigation works smoothly
- All previews from Phase 1 integrated

---

## Phase 3: Snapshot Testing (Week 5-6)

**Status**: 📋 Planned
**Goal**: Automate visual documentation and enable visual regression testing

### 3.1 Setup

**Dependencies:**
```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.15.0")
]
```

**Test Target Structure:**
```
PrototypeChatClientAppTests/
└── DesignSystem/
    ├── ColorSystemSnapshotTests.swift
    ├── GradientSystemSnapshotTests.swift
    ├── TypographySystemSnapshotTests.swift
    ├── ComponentSnapshotTests.swift
    └── __Snapshots__/                  # Auto-generated
        ├── ColorSystemPreview/
        │   ├── light.png
        │   └── dark.png
        └── GradientSystemPreview/
            ├── light.png
            └── dark.png
```

### 3.2 Implementation Example

```swift
// DesignSystemTests/ColorSystemSnapshotTests.swift
import XCTest
import SnapshotTesting
import SwiftUI
@testable import PrototypeChatClientApp

class ColorSystemSnapshotTests: XCTestCase {

    func testColorSystemLight() {
        let view = ColorSystemPreview()
            .frame(width: 375, height: 2000) // Ensure all content visible

        assertSnapshot(
            matching: view,
            as: .image(
                precision: 0.99,
                traits: .init(userInterfaceStyle: .light)
            ),
            record: false // Set to true to record new snapshots
        )
    }

    func testColorSystemDark() {
        let view = ColorSystemPreview()
            .frame(width: 375, height: 2000)

        assertSnapshot(
            matching: view,
            as: .image(
                precision: 0.99,
                traits: .init(userInterfaceStyle: .dark)
            )
        )
    }

    func testSemanticColors() {
        let view = VStack(spacing: 20) {
            ColorRow(name: "Text.Default.primary",
                    color: App.Color.Text.Default.primary)
            ColorRow(name: "Fill.Default.primaryStrong",
                    color: App.Color.Fill.Default.primaryStrong)
            // ... more colors
        }
        .frame(width: 375)
        .padding()

        assertSnapshot(matching: view, as: .image)
    }
}
```

### 3.3 CI/CD Integration

```yaml
# .github/workflows/design-system-snapshots.yml
name: Design System Snapshots

on:
  pull_request:
    paths:
      - 'PrototypeChatClientApp/DesignSystem/**'
  push:
    branches:
      - main

jobs:
  snapshot-tests:
    runs-on: macos-latest

    steps:
      - uses: actions/checkout@v3

      - name: Run Snapshot Tests
        run: |
          xcodebuild test \
            -project PrototypeChatClientApp.xcodeproj \
            -scheme PrototypeChatClientApp \
            -destination 'platform=iOS Simulator,name=iPhone 15' \
            -only-testing:PrototypeChatClientAppTests/DesignSystemSnapshotTests

      - name: Upload Snapshots
        uses: actions/upload-artifact@v3
        with:
          name: design-system-snapshots
          path: |
            **/__Snapshots__/**/*.png
```

### 3.4 Deliverables

- ✅ Snapshot tests for all design system views
- ✅ Light/Dark mode snapshots
- ✅ CI/CD integration for automated testing
- ✅ Snapshot artifacts uploaded to CI
- ✅ Visual regression detection

### 3.5 Success Metrics

- 100% coverage of design system tokens
- Snapshots generated for both light and dark modes
- CI runs snapshot tests on every PR
- Regression detected before merge

---

## Phase 4: HTML Catalog Generation (Week 7-8)

**Status**: 📋 Planned
**Goal**: Create a static HTML site (Storybook-like) for non-technical stakeholders

### 4.1 Architecture

```
scripts/
├── generate-catalog.sh           # Main generation script
├── catalog-template/
│   ├── index.html               # Main page template
│   ├── styles.css               # Catalog styles
│   └── assets/
│       └── logo.png
└── catalog-output/               # Generated site
    ├── index.html
    ├── colors.html
    ├── gradients.html
    ├── typography.html
    ├── components.html
    ├── assets/
    │   └── snapshots/
    │       ├── colors-light.png
    │       ├── colors-dark.png
    │       └── ...
    └── styles.css
```

### 4.2 Generation Script

```bash
#!/bin/bash
# scripts/generate-catalog.sh

# 1. Run snapshot tests to generate latest images
echo "📸 Generating snapshots..."
xcodebuild test \
  -project PrototypeChatClientApp.xcodeproj \
  -scheme PrototypeChatClientApp \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:PrototypeChatClientAppTests/DesignSystemSnapshotTests

# 2. Copy snapshots to output directory
echo "📁 Copying snapshots..."
mkdir -p scripts/catalog-output/assets/snapshots
cp -R **/__Snapshots__/**/*.png scripts/catalog-output/assets/snapshots/

# 3. Generate HTML pages
echo "🌐 Generating HTML..."
python3 scripts/generate-html.py

echo "✅ Catalog generated at scripts/catalog-output/index.html"
```

### 4.3 HTML Template Structure

```html
<!-- scripts/catalog-template/index.html -->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Design System Catalog v1.0.0</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <nav class="sidebar">
        <h1>Design System</h1>
        <ul>
            <li><a href="#colors">Colors</a></li>
            <li><a href="#gradients">Gradients</a></li>
            <li><a href="#typography">Typography</a></li>
            <li><a href="#components">Components</a></li>
        </ul>
    </nav>

    <main class="content">
        <section id="colors">
            <h2>Colors</h2>
            <div class="theme-toggle">
                <button onclick="showLight()">Light</button>
                <button onclick="showDark()">Dark</button>
            </div>
            <img class="snapshot light" src="assets/snapshots/colors-light.png" alt="Colors Light">
            <img class="snapshot dark" src="assets/snapshots/colors-dark.png" alt="Colors Dark" style="display:none">
        </section>

        <!-- More sections... -->
    </main>

    <script src="scripts.js"></script>
</body>
</html>
```

### 4.4 Python Generation Script

```python
# scripts/generate-html.py
import os
from pathlib import Path

TEMPLATE_DIR = Path("scripts/catalog-template")
OUTPUT_DIR = Path("scripts/catalog-output")
SNAPSHOTS_DIR = Path("**/__Snapshots__")

def generate_section(name, light_img, dark_img):
    return f"""
    <section id="{name.lower()}">
        <h2>{name}</h2>
        <div class="theme-toggle">
            <button onclick="showTheme('{name.lower()}', 'light')">Light</button>
            <button onclick="showTheme('{name.lower()}', 'dark')">Dark</button>
        </div>
        <img class="{name.lower()}-light snapshot"
             src="{light_img}"
             alt="{name} Light Mode">
        <img class="{name.lower()}-dark snapshot"
             src="{dark_img}"
             alt="{name} Dark Mode"
             style="display:none">
    </section>
    """

def main():
    # Read template
    template = (TEMPLATE_DIR / "index.html").read_text()

    # Find all snapshot images
    snapshots = list(Path(".").glob("**/__Snapshots__/**/*.png"))

    # Group by category
    sections = {}
    for snapshot in snapshots:
        # Parse filename to extract category and theme
        # e.g., ColorSystemPreview-light.png -> ("Colors", "light")
        # Implementation details...
        pass

    # Generate HTML sections
    html_sections = []
    for category, images in sections.items():
        html_sections.append(
            generate_section(
                category,
                images.get("light"),
                images.get("dark")
            )
        )

    # Replace template placeholders
    output_html = template.replace("{{SECTIONS}}", "\n".join(html_sections))

    # Write output
    (OUTPUT_DIR / "index.html").write_text(output_html)

if __name__ == "__main__":
    main()
```

### 4.5 Hosting Options

**Option A: GitHub Pages**
```yaml
# .github/workflows/deploy-catalog.yml
name: Deploy Design Catalog

on:
  push:
    branches: [main]
    paths:
      - 'PrototypeChatClientApp/DesignSystem/**'

jobs:
  deploy:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Generate Catalog
        run: ./scripts/generate-catalog.sh
      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./scripts/catalog-output
```

**Option B: Netlify/Vercel**
- Drag & drop `catalog-output/` folder
- Auto-deploy on git push

### 4.6 Deliverables

- ✅ HTML catalog generation script
- ✅ Responsive catalog template
- ✅ Light/Dark mode toggle in HTML
- ✅ CI/CD deployment to GitHub Pages (or similar)
- ✅ Shareable URL for stakeholders

### 4.7 Success Metrics

- Static site accessible via URL
- All design tokens visually documented
- Non-technical team members can view without Xcode
- Updates automatically on design system changes

---

## Implementation Timeline

```
Week 1-2:  Phase 1 - Enhanced #Preview ✅ (Highest Priority)
Week 3-4:  Phase 2 - Integrated Catalog View
Week 5-6:  Phase 3 - Snapshot Testing
Week 7-8:  Phase 4 - HTML Catalog Generation
```

### Parallel Tracks

- **Track 1 (Engineering)**: Phases 1-3 (Previews → Catalog → Snapshots)
- **Track 2 (DevOps)**: Phase 4 setup (CI/CD, hosting)
- **Track 3 (Documentation)**: Keep design specs in sync with implementation

---

## Maintenance Strategy

### Continuous Updates

1. **New Token Added**: Update corresponding preview file + snapshot test
2. **Component Updated**: Re-record snapshots, verify HTML regenerates
3. **Breaking Changes**: Update catalog version number, document migration

### Review Process

- **Weekly**: Review snapshot diffs in PRs
- **Monthly**: Review HTML catalog with design team
- **Quarterly**: Audit coverage (ensure all tokens documented)

---

## Alternative Considerations

### Why Not Mini App?

**Rejected**: Separate Mini App approach

**Reasons:**
- ❌ Higher maintenance cost (separate target, provisioning)
- ❌ Duplicate code between main app and mini app
- ❌ TestFlight distribution overhead
- ✅ Integrated catalog provides same functionality with less overhead

### Why Not Third-Party Tools?

**Considered**: Storybook, Zeplin, Figma Plugins

**Decision:**
- Storybook is web-focused, requires React/Vue components
- Zeplin/Figma are design tools, not developer references
- SwiftUI native approach keeps single source of truth in code

---

## Success Criteria

### Phase 1 Complete When:
- [x] All design tokens have dedicated preview views
- [x] Light/Dark mode toggle works in all previews
- [x] Code is well-documented with usage examples

### Phase 2 Complete When:
- [ ] Catalog accessible from debug builds
- [ ] Navigation structure is intuitive
- [ ] No performance impact on release builds

### Phase 3 Complete When:
- [ ] All views have snapshot tests
- [ ] CI/CD runs tests automatically
- [ ] Visual regressions are caught before merge

### Phase 4 Complete When:
- [ ] HTML catalog publicly accessible
- [ ] Design team can share link with stakeholders
- [ ] Catalog auto-updates on design system changes

---

## Next Steps

### Immediate Action Items

1. **Week 1**: Implement `ColorSystemPreview.swift`
2. **Week 1**: Implement `GradientSystemPreview.swift`
3. **Week 2**: Implement remaining token previews
4. **Week 2**: Create reusable helper components

### Decision Points

- [ ] Confirm debug access method (shake, button, or gesture)
- [ ] Select hosting platform for HTML catalog (GitHub Pages, Netlify, etc.)
- [ ] Define snapshot test coverage requirements

---

**Document Owner**: Development Team
**Reviewers**: Design Team, Engineering Manager
**Next Review**: After Phase 1 completion
