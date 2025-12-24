# Design System Specification

**Version:** 1.0.0
**Status:** Approved for Implementation
**Last Updated:** 2024-12-24

## Executive Summary

This document defines the design system for PrototypeChatClientApp. After evaluating three implementation approaches, we have selected **Trial 3: Hybrid + Gradual Migration** as the optimal strategy.

### Selected Approach: Hybrid Model

- **Colors**: Asset Catalog (native dark mode support)
- **Typography, Spacing, Radius, Shadow**: Code-based tokens
- **Components**: SwiftUI Views + ViewModifiers
- **Migration**: Gradual, non-breaking adoption

### Key Benefits

1. ✅ **Non-breaking**: Coexists with existing code during migration
2. ✅ **Dark mode**: Automatic support via Asset Catalog
3. ✅ **Type-safe**: Compile-time checks prevent magic values
4. ✅ **Extensible**: Easy to add new tokens and components
5. ✅ **Documented**: Comprehensive guides for developers

## Architecture

### Three-Layer Model

```
┌─────────────────────────────────────┐
│   Layer 3: Components               │
│   (AppButton, AppCard, etc.)          │
├─────────────────────────────────────┤
│   Layer 2: Modifiers                │
│   (.appText(), .appCard())            │
├─────────────────────────────────────┤
│   Layer 1: Foundation Tokens        │
│   (App.Color, App.Typography, etc.)   │
└─────────────────────────────────────┘
```

### Namespace Strategy

All design system symbols are prefixed with `App` to prevent naming conflicts during migration:

- Asset Catalog: `App_Brand_Primary.colorset`
- Swift Code: `App.Color.Brand.primary`
- Components: `AppButton`, `AppTextField`
- Modifiers: `.appText()`, `.appCard()`

## Foundation Tokens

### 1. Colors (Asset Catalog)

#### Color Palette

**Brand Colors**
- `App_Brand_Primary`: Primary brand color (with light/dark variants)
- `App_Brand_Secondary`: Secondary brand color

**Neutral Scale** (100 = lightest, 900 = darkest)
- `App_Neutral_100` through `App_Neutral_900`
- Used for backgrounds, borders, disabled states

**Semantic Colors**
- `App_Semantic_Success`: Green (positive actions, success states)
- `App_Semantic_Error`: Red (errors, destructive actions)
- `App_Semantic_Warning`: Orange/Yellow (warnings, cautions)
- `App_Semantic_Info`: Blue (informational messages)

#### Swift API

```swift
// Usage
Text("Hello")
    .foregroundColor(App.Color.Brand.primary)

VStack {
    // ...
}
.background(App.Color.Background.base)
```

#### Color Token Definition

```swift
extension App {
    public enum Color {
        public enum Brand {
            public static let primary = SwiftUI.Color("App_Brand_Primary")
            public static let secondary = SwiftUI.Color("App_Brand_Secondary")
        }

        public enum Neutral {
            public static let _100 = SwiftUI.Color("App_Neutral_100")
            public static let _200 = SwiftUI.Color("App_Neutral_200")
            public static let _300 = SwiftUI.Color("App_Neutral_300")
            public static let _400 = SwiftUI.Color("App_Neutral_400")
            public static let _500 = SwiftUI.Color("App_Neutral_500")
            public static let _600 = SwiftUI.Color("App_Neutral_600")
            public static let _700 = SwiftUI.Color("App_Neutral_700")
            public static let _800 = SwiftUI.Color("App_Neutral_800")
            public static let _900 = SwiftUI.Color("App_Neutral_900")
        }

        public enum Semantic {
            public static let success = SwiftUI.Color("App_Semantic_Success")
            public static let error = SwiftUI.Color("App_Semantic_Error")
            public static let warning = SwiftUI.Color("App_Semantic_Warning")
            public static let info = SwiftUI.Color("App_Semantic_Info")
        }

        // Semantic aliases for common use cases
        public enum Text {
            public static let primary = Neutral._900
            public static let secondary = Neutral._600
            public static let tertiary = Neutral._400
            public static let inverse = Neutral._100
        }

        public enum Background {
            public static let base = Neutral._100
            public static let elevated = SwiftUI.Color.white
            public static let overlay = Neutral._900.opacity(0.5)
        }
    }
}
```

### 2. Typography (Code)

#### Type Scale

| Token | Size | Weight | Line Height | Letter Spacing | Use Case |
|-------|------|--------|-------------|----------------|----------|
| `largeTitle` | 34pt | Bold | 41pt | 0 | Hero titles |
| `title1` | 28pt | Semibold | 34pt | 0 | Page titles |
| `title2` | 22pt | Semibold | 28pt | 0 | Section headers |
| `headline` | 17pt | Semibold | 22pt | -0.24 | Emphasis text |
| `body` | 17pt | Regular | 22pt | -0.24 | Body text |
| `callout` | 16pt | Regular | 21pt | -0.24 | Secondary content |
| `subheadline` | 15pt | Regular | 20pt | -0.08 | Metadata |
| `footnote` | 13pt | Regular | 18pt | 0 | Captions |
| `caption1` | 12pt | Regular | 16pt | 0 | Small labels |
| `caption2` | 11pt | Regular | 16pt | 0 | Timestamps |

#### Swift API

```swift
// Usage with modifier
Text("Welcome")
    .appText(.headline, color: App.Color.Brand.primary)

// Direct font access
Text("Custom")
    .font(App.Typography.body.font)
```

### 3. Spacing (Code)

8-point grid system for consistent spacing:

| Token | Value | Use Case |
|-------|-------|----------|
| `xxxs` | 2pt | Minimal gaps |
| `xxs` | 4pt | Tight spacing |
| `xs` | 8pt | Compact layouts |
| `sm` | 12pt | Small padding |
| `md` | 16pt | Default spacing |
| `lg` | 24pt | Section spacing |
| `xl` | 32pt | Large gaps |
| `xxl` | 48pt | Major sections |
| `xxxl` | 64pt | Page-level spacing |

#### Swift API

```swift
// Usage
VStack(spacing: App.Spacing.md) {
    // ...
}
.padding(App.Spacing.lg)
```

### 4. Corner Radius (Code)

| Token | Value | Use Case |
|-------|-------|----------|
| `none` | 0pt | Sharp corners |
| `sm` | 4pt | Subtle rounding |
| `md` | 8pt | Default rounding |
| `lg` | 12pt | Cards, containers |
| `xl` | 16pt | Prominent rounding |
| `full` | 9999pt | Pills, circles |

#### Swift API

```swift
// Usage
RoundedRectangle(cornerRadius: App.Radius.lg)
```

### 5. Shadow (Code)

| Token | Radius | Offset | Opacity | Use Case |
|-------|--------|--------|---------|----------|
| `sm` | 2pt | (0, 1) | 10% | Subtle elevation |
| `md` | 4pt | (0, 2) | 10% | Cards |
| `lg` | 8pt | (0, 4) | 15% | Modals, popovers |

#### Swift API

```swift
// Usage
let shadow = App.Shadow.md
view.shadow(
    color: shadow.color,
    radius: shadow.radius,
    x: shadow.x,
    y: shadow.y
)
```

## Modifiers

### AppTextStyleModifier

Applies typography, line height, letter spacing, and color in one go.

```swift
Text("Hello World")
    .appText(.headline, color: App.Color.Brand.primary)
```

**Implementation:**
```swift
public struct AppTextStyleModifier: ViewModifier {
    let typography: App.Typography
    let color: Color

    public func body(content: Content) -> some View {
        content
            .font(typography.font)
            .lineSpacing(typography.lineHeight - typography.font.lineHeight)
            .tracking(typography.letterSpacing)
            .foregroundColor(color)
    }
}

extension View {
    public func appText(
        _ typography: App.Typography,
        color: Color = App.Color.Text.primary
    ) -> some View {
        modifier(AppTextStyleModifier(typography: typography, color: color))
    }
}
```

### AppCardModifier

Applies background, corner radius, and shadow for card-like containers.

```swift
VStack {
    // Content
}
.appCard()
```

**Parameters:**
- `backgroundColor`: Default = `App.Color.Background.elevated`
- `cornerRadius`: Default = `App.Radius.lg`
- `shadow`: Default = `App.Shadow.md`

## Components

### AppButton

A fully-featured button component with multiple styles and sizes.

#### Styles

- `.primary`: Filled with brand color
- `.secondary`: Neutral background
- `.tertiary`: Transparent (text-only)
- `.destructive`: Red/error color for dangerous actions

#### Sizes

- `.small`: Compact padding
- `.medium`: Default size
- `.large`: Prominent CTA

#### Usage

```swift
// Primary button
AppButton("Submit", style: .primary) {
    // Action
}

// Disabled state
AppButton("Processing", isEnabled: false) {
    // Action
}

// Custom style + size
AppButton("Delete", style: .destructive, size: .large) {
    // Action
}
```

### AppCard

A container component with consistent styling.

```swift
AppCard {
    VStack(alignment: .leading, spacing: App.Spacing.md) {
        Text("Card Title")
            .appText(.headline)
        Text("Card content goes here")
            .appText(.body, color: App.Color.Text.secondary)
    }
}
```

### Future Components (Planned)

- `AppTextField`: Styled text input
- `AppTextArea`: Multi-line text input
- `AppToast`: Temporary notifications
- `AppAlert`: Modal alerts
- `AppBadge`: Status indicators
- `AppAvatar`: User profile images

## File Structure

```
PrototypeChatClientApp/
├── DesignSystem/
│   ├── Foundation/
│   │   ├── AppFoundation.swift      # Namespace: public enum App {}
│   │   ├── AppColor.swift           # App.Color extensions
│   │   ├── AppTypography.swift      # App.Typography enum
│   │   ├── AppSpacing.swift         # App.Spacing constants
│   │   ├── AppRadius.swift          # App.Radius constants
│   │   └── AppShadow.swift          # App.Shadow definitions
│   ├── Modifiers/
│   │   ├── AppTextStyleModifier.swift
│   │   └── AppCardModifier.swift
│   ├── Components/
│   │   ├── AppButton.swift
│   │   └── AppCard.swift
│   └── Preview/
│       └── AppPreview.swift
└── Assets.xcassets/
    └── DesignSystem/
        └── Colors/
            ├── Brand/
            ├── Neutral/
            └── Semantic/
```

## Implementation Phases

### Phase 1: Foundation (This Prototype)

**Scope:**
1. ✅ Asset Catalog: 2 brand colors, 9 neutral colors, 4 semantic colors
2. ✅ Swift tokens: Color, Typography, Spacing, Radius, Shadow
3. ✅ Modifiers: `.appText()`, `.appCard()`
4. ✅ Components: `AppButton`, `AppCard`
5. ✅ Preview views for all tokens and components

**Deliverables:**
- Compilable, functional design system
- Preview app showing all components
- Basic documentation in code comments

### Phase 2: Expansion (Future)

- Additional components (TextField, Toast, Alert)
- Animation tokens
- Accessibility enhancements
- SwiftGen integration for auto-generated color wrappers

### Phase 3: Migration (Future)

- Refactor Authentication feature to use design system
- Create migration guide
- Establish code review checklist
- Linter rules for enforcement

## Usage Guidelines

### For New Code

**✅ DO:**
```swift
// Use design system tokens
Text("Welcome")
    .appText(.headline, color: App.Color.Brand.primary)

AppButton("Submit", style: .primary) { }

VStack(spacing: App.Spacing.md) {
    // ...
}
.padding(App.Spacing.lg)
```

**❌ DON'T:**
```swift
// Don't use hardcoded values
Text("Welcome")
    .font(.system(size: 17, weight: .semibold))
    .foregroundColor(Color(hex: "0066CC"))

Button("Submit") { }
    .padding(.horizontal, 24)
    .padding(.vertical, 12)
```

### For Existing Code

During the migration period, old code continues to work:

```swift
// ⚠️ Acceptable during migration
Text("Legacy")
    .font(.headline)
    .foregroundColor(.blue)
```

Migrate existing code during:
- Feature updates
- Bug fixes
- Dedicated refactoring sprints

## Dark Mode Strategy

### Automatic Support

All colors defined in Asset Catalog include light and dark variants:

- `App_Brand_Primary.colorset`: Separate colors for Light/Dark appearance
- `App_Neutral_100.colorset`: Inverts in dark mode (100 becomes 900, etc.)
- Components automatically adapt with no code changes

### Testing Dark Mode

```swift
struct MyView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MyView()
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")

            MyView()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
```

## Accessibility

All components must support:

1. **Dynamic Type**: Font sizes scale with user preferences
2. **VoiceOver**: Proper labels and hints
3. **High Contrast**: Test with Increased Contrast mode
4. **Reduced Motion**: Respect `UIAccessibility.isReduceMotionEnabled`

### Example

```swift
AppButton("Submit", style: .primary) {
    // Action
}
.accessibilityLabel("Submit form")
.accessibilityHint("Double tap to submit your information")
```

## Testing Strategy

### Unit Tests

Test token values:
```swift
func testColorTokens() {
    XCTAssertNotNil(App.Color.Brand.primary)
    XCTAssertNotNil(App.Color.Neutral._500)
}
```

### Snapshot Tests

Capture component appearances:
```swift
func testAppButtonStyles() {
    let button = AppButton("Test", style: .primary) {}
    assertSnapshot(matching: button, as: .image)
}
```

### Visual Regression

Use Xcode Previews or snapshot tests to catch unintended visual changes.

## Performance Considerations

### Asset Catalog

- ✅ Colors are resolved at compile-time
- ✅ Minimal runtime overhead
- ✅ Automatic memory management

### Component Reuse

- Prefer `ButtonStyle` over custom `View` when possible (better performance)
- Use `@ViewBuilder` for complex component layouts
- Avoid excessive view hierarchy depth

## Migration Checklist

When refactoring a screen to use the design system:

- [ ] Replace hardcoded colors with `App.Color.*`
- [ ] Replace hardcoded fonts with `.appText()`
- [ ] Replace hardcoded spacing with `App.Spacing.*`
- [ ] Replace custom buttons with `AppButton`
- [ ] Replace custom cards with `.appCard()` or `AppCard`
- [ ] Test in both light and dark mode
- [ ] Verify VoiceOver labels
- [ ] Update snapshot tests

## Rollback Plan

If the design system causes issues:

1. **Isolated code**: All DS code is in `DesignSystem/` folder
2. **Can be disabled**: Exclude from build target temporarily
3. **Non-breaking**: Old code continues to work
4. **Fast rollback**: Remove `import DesignSystem` statements

## Success Metrics

### Immediate (Phase 1)

- ✅ Design system compiles without errors
- ✅ All tokens and components have previews
- ✅ Documentation is clear and comprehensive

### Short-term (1 month)

- 🎯 50% of new UI code uses design system
- 🎯 Zero hardcoded colors in new PRs
- 🎯 At least 1 screen fully migrated

### Long-term (6 months)

- 🎯 90% of codebase uses design system
- 🎯 Linter enforces design system usage
- 🎯 Design updates can be made in hours, not days

## References

### Related Documentation

- `CLAUDE.md`: AI assistant guidelines
- `Docs/Manuals/XCODE_CONFIGURATION_GUIDE.md`: Asset Catalog setup
- `Specs/IOS_APP_ARCHITECTURE.md`: Overall app architecture

### External Resources

- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SwiftUI Button Styles](https://developer.apple.com/documentation/swiftui/buttonstyle)
- [Asset Catalog Format Reference](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_ref-Asset_Catalog_Format/)

---

**Document Status:** ✅ Approved for Implementation
**Next Step:** Begin Phase 1 prototype implementation
