# Design System Specification

**Version:** 1.0.0
**Status:** Approved for Implementation
**Last Updated:** 2024-12-24

## Executive Summary

This document defines the design system for PrototypeChatClientApp. After evaluating three implementation approaches, we have selected **Trial 3: Hybrid + Gradual Migration** as the optimal strategy.

### Selected Approach: Code-Based Design System

- **Colors**: Hex-based with dynamic light/dark mode support + Gradient support
- **Typography, Spacing, Radius, Shadow**: Code-based tokens
- **Components**: SwiftUI Views + ViewModifiers
- **Migration**: Gradual, non-breaking adoption

### Key Benefits

1. ✅ **Non-breaking**: Coexists with existing code during migration
2. ✅ **Dark mode**: Automatic support via `dynamicColor(dark:light:)`
3. ✅ **Type-safe**: Compile-time checks prevent magic values
4. ✅ **Extensible**: Easy to add new tokens, gradients, and components
5. ✅ **Hex-based**: Direct color definitions without Asset Catalog dependency
6. ✅ **Gradient support**: Built-in gradient definitions with dark mode awareness
7. ✅ **Documented**: Comprehensive guides for developers

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

- Swift Code: `App.Color.Text.Default.primary`, `App.Gradient.brand`
- Color Primitives: `UIColor.gray1000`, `UIColor.systemRed100`
- Components: `AppButton`, `AppTextField`
- Modifiers: `.appText()`, `.appCard()`

## Foundation Tokens

### 1. Colors (Hex-Based Code)

#### Color System Architecture

The color system uses three layers:

1. **Color Primitives** (`AppColorPrimitives.swift`): UIColor extensions with hex definitions
2. **Semantic Colors** (`AppColor.swift`): Usage-based organization (Text, Icon, Stroke, Fill)
3. **Color Helpers**: `hex()`, `dynamicColor()`, `constantColor()` for flexible color creation

#### Color Helpers

```swift
// Create color from hex value
let brandColor = Color.hex(0x0066CC)

// Create adaptive color (light/dark mode)
let adaptiveText = Color.dynamicColor(
    dark: .white1000,
    light: .gray1000
)

// Create constant color (no adaptation)
let brandRed = Color.constantColor(.systemRed100)
```

#### Semantic Color Organization

**Text Colors** - `App.Color.Text.*`
- `Default.primary`: Highest contrast text
- `Default.secondary`: Medium contrast text
- `Default.tertiary`: Low contrast text
- `Link.primaryActive`: Active link color
- `Function.rewards`: Rewards-specific text

**Icon Colors** - `App.Color.Icon.*`
- `Default.primary`, `Default.secondary`, `Default.tertiary`
- `Function.rewards`, `Function.coin`

**Stroke/Border Colors** - `App.Color.Stroke.*`
- `Default.primary`, `Default.secondary`, `Default.border`
- `Highlight.primary`, `Highlight.button`
- `Danger.primary`, `Danger.secondary`

**Fill/Background Colors** - `App.Color.Fill.*`
- `Default.primaryStrong`, `Default.primaryLight`
- `Light.white1000`, `Light.white500`
- `Shadow.black800`, `Shadow.black500` (for shadows)
- `Function.rewardsPrimary`, `Function.coinPrimary`

**Neutral Colors** (Direct Access) - `App.Color.Neutral.*`
- `black1000`, `black700`, `black400`, `black100`
- `gray1000` through `gray100`
- `white1000` through `white100`

**Legacy Colors** (Backward Compatibility)
- `Brand.primary`, `Brand.secondary`
- `Semantic.success`, `Semantic.error`, `Semantic.warning`, `Semantic.info`

#### Swift API

```swift
// Semantic colors (recommended)
Text("Hello")
    .foregroundColor(App.Color.Text.Default.primary)

VStack {
    // ...
}
.background(App.Color.Fill.Default.primaryStrong)

// Neutral colors (direct access)
Rectangle()
    .fill(App.Color.Neutral.gray900)

// Hex colors (for custom colors)
Circle()
    .fill(Color.hex(0xFF3D00))
```

#### Color Primitives (UIColor)

All semantic colors are built on top of UIColor primitives:

```swift
// Black scale
UIColor.black1000  // hex(0x161213)
UIColor.black100   // black1000.withAlphaComponent(0.05)

// Gray scale
UIColor.gray1000   // hex(0x292929)
UIColor.gray900    // hex(0x3d3d3d)
UIColor.gray100    // hex(0xefefef)

// System colors
UIColor.systemRed100     // hex(0xff3d00)
UIColor.systemOrange100  // hex(0xffbb0c)
UIColor.systemGreen100   // hex(0x56e100)
UIColor.systemPurple100  // hex(0x8256ff)
// ... and more
```

### 2. Gradients (Code)

#### Gradient Definitions

The design system includes pre-defined gradients with automatic dark mode support:

**Brand Gradients**
```swift
// Fixed brand gradient
App.Gradient.brand
// LinearGradient: blue to purple

// Adaptive background gradient
App.Gradient.brandBackground(colorScheme: colorScheme)
```

**Functional Gradients**
```swift
App.Gradient.reward   // Magenta to purple
App.Gradient.coin     // Orange to yellow
App.Gradient.success  // Green variants
App.Gradient.error    // Red variants
```

**Utility Gradients**
```swift
// Shimmer effect (for loading states)
App.Gradient.shimmer(colorScheme: colorScheme)

// Glassmorphism overlay
App.Gradient.glass(colorScheme: colorScheme)

// Scrim overlay (fade to black/white)
App.Gradient.scrim(
    colorScheme: colorScheme,
    direction: .bottom
)
```

#### Swift API

```swift
// Using pre-defined gradients
Rectangle()
    .fill(App.Gradient.brand)

// Using adaptive gradients
@Environment(\.colorScheme) var colorScheme

VStack {
    // ...
}
.background(App.Gradient.brandBackground(colorScheme: colorScheme))

// Using gradient background modifier
VStack {
    // ...
}
.gradientBackground { colorScheme in
    App.Gradient.shimmer(colorScheme: colorScheme)
}
```

### 3. Typography (Code)

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

### 4. Spacing (Code)

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

### 5. Corner Radius (Code)

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

### 6. Shadow (Code)

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
        color: Color = App.Color.Text.Default.primary
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
            .appText(.body, color: App.Color.Text.Default.secondary)
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
│   │   ├── AppFoundation.swift       # Namespace: public enum App {}
│   │   ├── AppColorPrimitives.swift  # UIColor hex extensions
│   │   ├── AppColor.swift            # Semantic color organization
│   │   ├── AppGradient.swift         # Gradient definitions
│   │   ├── AppTypography.swift       # App.Typography enum
│   │   ├── AppSpacing.swift          # App.Spacing constants
│   │   ├── AppRadius.swift           # App.Radius constants
│   │   └── AppShadow.swift           # App.Shadow definitions
│   ├── Modifiers/
│   │   ├── AppTextStyleModifier.swift
│   │   └── AppCardModifier.swift
│   ├── Components/
│   │   ├── AppButton.swift
│   │   └── AppCard.swift
│   └── Preview/
│       └── AppPreview.swift
```

## Implementation Phases

### Phase 1: Foundation (This Prototype)

**Scope:**
1. ✅ Hex-based color system with 50+ primitive colors
2. ✅ Semantic color organization (Text, Icon, Stroke, Fill)
3. ✅ Dynamic light/dark mode support via `dynamicColor()`
4. ✅ Gradient definitions with dark mode awareness
5. ✅ Swift tokens: Typography, Spacing, Radius, Shadow
6. ✅ Modifiers: `.appText()`, `.appCard()`, `.gradientBackground()`
7. ✅ Components: `AppButton`, `AppCard`
8. ✅ Preview views for all tokens and components

**Deliverables:**
- Compilable, functional design system
- Preview app showing all components
- Basic documentation in code comments

### Phase 2: Expansion (Future)

- Additional components (TextField, Toast, Alert)
- Animation tokens
- Accessibility enhancements
- Additional gradient patterns (radial, angular)
- Color palette generator utilities

### Phase 3: Migration (Future)

- Refactor Authentication feature to use design system
- Create migration guide
- Establish code review checklist
- Linter rules for enforcement

## Usage Guidelines

### For New Code

**✅ DO:**
```swift
// Use semantic colors
Text("Welcome")
    .appText(.headline, color: App.Color.Text.Default.primary)

AppButton("Submit", style: .primary) { }

VStack(spacing: App.Spacing.md) {
    // ...
}
.padding(App.Spacing.lg)
.background(App.Color.Fill.Default.primaryStrong)

// Use gradients
Rectangle()
    .fill(App.Gradient.brand)
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

All colors use `dynamicColor(dark:light:)` for automatic dark mode adaptation:

- **Dynamic Colors**: Automatically switch based on system appearance
  ```swift
  Color.dynamicColor(dark: .white1000, light: .gray1000)
  ```
- **Constant Colors**: Stay the same regardless of appearance mode
  ```swift
  Color.constantColor(.systemRed100)
  ```
- **Gradients**: Include colorScheme parameter for dark mode variants
  ```swift
  App.Gradient.shimmer(colorScheme: colorScheme)
  ```

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
    XCTAssertNotNil(App.Color.Neutral.gray900)
    XCTAssertNotNil(App.Color.Text.Default.primary)
}

func testGradientTokens() {
    XCTAssertNotNil(App.Gradient.brand)
    XCTAssertNotNil(App.Gradient.reward)
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

### Hex-Based Colors

- ✅ Colors are resolved at compile-time
- ✅ Minimal runtime overhead
- ✅ No Asset Catalog dependency
- ✅ Direct hex values for transparency

### Component Reuse

- Prefer `ButtonStyle` over custom `View` when possible (better performance)
- Use `@ViewBuilder` for complex component layouts
- Avoid excessive view hierarchy depth

## Migration Checklist

When refactoring a screen to use the design system:

- [ ] Replace hardcoded colors with semantic colors (`App.Color.Text.*`, `App.Color.Fill.*`)
- [ ] Replace hardcoded gradients with `App.Gradient.*`
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
