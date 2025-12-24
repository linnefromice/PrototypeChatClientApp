# Design System Plan - Trial 3: Hybrid + Gradual Migration

**Strategy:** Combine best of both worlds (Asset Catalog + Code) with gradual migration path for existing codebase

## Design Philosophy

- **Pragmatic hybrid**: Use Asset Catalog for colors, code for typography/spacing
- **Non-breaking migration**: Introduce system without breaking existing features
- **Coexistence period**: Old and new systems work side-by-side
- **Feature-by-feature adoption**: Teams adopt at their own pace
- **Documentation-first**: Comprehensive examples and migration guides

## Layer Structure

### Layer 1: Foundation Tokens

#### Colors (Asset Catalog)
```
Assets.xcassets/
└── DesignSystem/
    └── Colors/
        ├── Brand/
        │   ├── DS_Brand_Primary.colorset
        │   └── DS_Brand_Secondary.colorset
        ├── Neutral/
        │   ├── DS_Neutral_100.colorset  # Lightest
        │   ├── DS_Neutral_200.colorset
        │   ├── DS_Neutral_300.colorset
        │   ├── DS_Neutral_400.colorset
        │   ├── DS_Neutral_500.colorset
        │   ├── DS_Neutral_600.colorset
        │   ├── DS_Neutral_700.colorset
        │   ├── DS_Neutral_800.colorset
        │   └── DS_Neutral_900.colorset  # Darkest
        └── Semantic/
            ├── DS_Semantic_Success.colorset
            ├── DS_Semantic_Error.colorset
            ├── DS_Semantic_Warning.colorset
            └── DS_Semantic_Info.colorset
```

Note: `DS_` prefix prevents naming conflicts during migration

#### Typography, Spacing, etc. (Code)
```swift
// Foundation/DSFoundation.swift
public enum DS {
    // Namespace for entire design system
}

// Foundation/DSColor.swift
extension DS {
    public enum Color {
        public enum Brand {
            public static let primary = SwiftUI.Color("DS_Brand_Primary")
            public static let secondary = SwiftUI.Color("DS_Brand_Secondary")
        }

        public enum Neutral {
            public static let _100 = SwiftUI.Color("DS_Neutral_100")
            public static let _200 = SwiftUI.Color("DS_Neutral_200")
            // ... up to 900
        }

        public enum Semantic {
            public static let success = SwiftUI.Color("DS_Semantic_Success")
            public static let error = SwiftUI.Color("DS_Semantic_Error")
            public static let warning = SwiftUI.Color("DS_Semantic_Warning")
            public static let info = SwiftUI.Color("DS_Semantic_Info")
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

```swift
// Foundation/DSTypography.swift
extension DS {
    public enum Typography {
        case largeTitle     // 34pt, bold
        case title1         // 28pt, semibold
        case title2         // 22pt, semibold
        case headline       // 17pt, semibold
        case body           // 17pt, regular
        case callout        // 16pt, regular
        case subheadline    // 15pt, regular
        case footnote       // 13pt, regular
        case caption1       // 12pt, regular
        case caption2       // 11pt, regular

        public var font: Font {
            switch self {
            case .largeTitle: return .system(size: 34, weight: .bold)
            case .title1: return .system(size: 28, weight: .semibold)
            case .title2: return .system(size: 22, weight: .semibold)
            case .headline: return .system(size: 17, weight: .semibold)
            case .body: return .system(size: 17, weight: .regular)
            case .callout: return .system(size: 16, weight: .regular)
            case .subheadline: return .system(size: 15, weight: .regular)
            case .footnote: return .system(size: 13, weight: .regular)
            case .caption1: return .system(size: 12, weight: .regular)
            case .caption2: return .system(size: 11, weight: .regular)
            }
        }

        public var lineHeight: CGFloat {
            switch self {
            case .largeTitle: return 41
            case .title1: return 34
            case .title2: return 28
            case .headline: return 22
            case .body: return 22
            case .callout: return 21
            case .subheadline: return 20
            case .footnote: return 18
            case .caption1, .caption2: return 16
            }
        }

        public var letterSpacing: CGFloat {
            switch self {
            case .largeTitle, .title1, .title2: return 0
            case .headline, .body, .callout: return -0.24
            case .subheadline: return -0.08
            case .footnote: return 0
            case .caption1, .caption2: return 0
            }
        }
    }
}
```

```swift
// Foundation/DSSpacing.swift
extension DS {
    public enum Spacing {
        public static let xxxs: CGFloat = 2
        public static let xxs: CGFloat = 4
        public static let xs: CGFloat = 8
        public static let sm: CGFloat = 12
        public static let md: CGFloat = 16
        public static let lg: CGFloat = 24
        public static let xl: CGFloat = 32
        public static let xxl: CGFloat = 48
        public static let xxxl: CGFloat = 64
    }
}
```

```swift
// Foundation/DSRadius.swift
extension DS {
    public enum Radius {
        public static let none: CGFloat = 0
        public static let sm: CGFloat = 4
        public static let md: CGFloat = 8
        public static let lg: CGFloat = 12
        public static let xl: CGFloat = 16
        public static let full: CGFloat = 9999  // Capsule effect
    }
}
```

```swift
// Foundation/DSShadow.swift
extension DS {
    public struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat

        public static let sm = Shadow(
            color: DS.Color.Neutral._900.opacity(0.1),
            radius: 2,
            x: 0,
            y: 1
        )

        public static let md = Shadow(
            color: DS.Color.Neutral._900.opacity(0.1),
            radius: 4,
            x: 0,
            y: 2
        )

        public static let lg = Shadow(
            color: DS.Color.Neutral._900.opacity(0.15),
            radius: 8,
            x: 0,
            y: 4
        )
    }
}
```

### Layer 2: Modifiers (Reusable Styling)

```swift
// Modifiers/DSTextStyleModifier.swift
public struct DSTextStyleModifier: ViewModifier {
    let typography: DS.Typography
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
    public func dsText(
        _ typography: DS.Typography,
        color: Color = DS.Color.Text.primary
    ) -> some View {
        modifier(DSTextStyleModifier(typography: typography, color: color))
    }
}
```

```swift
// Modifiers/DSCardModifier.swift
public struct DSCardModifier: ViewModifier {
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let shadow: DS.Shadow

    public func body(content: Content) -> some View {
        content
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(
                color: shadow.color,
                radius: shadow.radius,
                x: shadow.x,
                y: shadow.y
            )
    }
}

extension View {
    public func dsCard(
        backgroundColor: Color = DS.Color.Background.elevated,
        cornerRadius: CGFloat = DS.Radius.lg,
        shadow: DS.Shadow = .md
    ) -> some View {
        modifier(DSCardModifier(
            backgroundColor: backgroundColor,
            cornerRadius: cornerRadius,
            shadow: shadow
        ))
    }
}
```

### Layer 3: Components

```swift
// Components/DSButton.swift
public struct DSButton: View {
    public enum Style {
        case primary
        case secondary
        case tertiary
        case destructive
    }

    public enum Size {
        case small
        case medium
        case large
    }

    let title: String
    let style: Style
    let size: Size
    let isEnabled: Bool
    let action: () -> Void

    public init(
        _ title: String,
        style: Style = .primary,
        size: Size = .medium,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.size = size
        self.isEnabled = isEnabled
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .dsText(.headline, color: foregroundColor)
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
                .frame(maxWidth: .infinity)
        }
        .background(backgroundColor)
        .cornerRadius(DS.Radius.md)
        .opacity(isEnabled ? 1.0 : 0.5)
        .disabled(!isEnabled)
    }

    private var backgroundColor: Color {
        guard isEnabled else { return DS.Color.Neutral._300 }
        switch style {
        case .primary: return DS.Color.Brand.primary
        case .secondary: return DS.Color.Neutral._200
        case .tertiary: return .clear
        case .destructive: return DS.Color.Semantic.error
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary, .destructive: return .white
        case .secondary, .tertiary: return DS.Color.Brand.primary
        }
    }

    private var horizontalPadding: CGFloat {
        switch size {
        case .small: return DS.Spacing.md
        case .medium: return DS.Spacing.lg
        case .large: return DS.Spacing.xl
        }
    }

    private var verticalPadding: CGFloat {
        switch size {
        case .small: return DS.Spacing.xs
        case .medium: return DS.Spacing.sm
        case .large: return DS.Spacing.md
        }
    }
}

// Alternative: ButtonStyle approach
public struct DSPrimaryButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .dsText(.headline, color: .white)
            .padding(.horizontal, DS.Spacing.lg)
            .padding(.vertical, DS.Spacing.sm)
            .background(DS.Color.Brand.primary)
            .cornerRadius(DS.Radius.md)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == DSPrimaryButtonStyle {
    public static var dsPrimary: DSPrimaryButtonStyle { DSPrimaryButtonStyle() }
}
```

## File Structure

```
PrototypeChatClientApp/
├── DesignSystem/
│   ├── Foundation/
│   │   ├── DSFoundation.swift      # Namespace definition
│   │   ├── DSColor.swift           # Color tokens
│   │   ├── DSTypography.swift      # Typography tokens
│   │   ├── DSSpacing.swift         # Spacing tokens
│   │   ├── DSRadius.swift          # Radius tokens
│   │   └── DSShadow.swift          # Shadow tokens
│   ├── Modifiers/
│   │   ├── DSTextStyleModifier.swift
│   │   ├── DSCardModifier.swift
│   │   └── DSLoadingModifier.swift
│   ├── Components/
│   │   ├── Buttons/
│   │   │   ├── DSButton.swift
│   │   │   └── DSButtonStyles.swift
│   │   ├── Cards/
│   │   │   └── DSCard.swift
│   │   ├── Inputs/
│   │   │   ├── DSTextField.swift
│   │   │   └── DSTextArea.swift
│   │   └── Feedback/
│   │       ├── DSToast.swift
│   │       └── DSAlert.swift
│   ├── Preview/
│   │   ├── DSColorPreview.swift
│   │   ├── DSTypographyPreview.swift
│   │   └── DSComponentPreview.swift
│   └── Documentation/
│       ├── DSGettingStarted.md
│       ├── DSMigrationGuide.md
│       └── DSComponentGuidelines.md
└── Assets.xcassets/
    └── DesignSystem/
        └── Colors/                 # Color definitions
```

## Implementation Strategy

### Phase 1: Foundation Setup (Week 1)
1. ✅ Create Asset Catalog structure with `DS_` prefix
2. ✅ Define 9 neutral colors (100-900) with light/dark variants
3. ✅ Define 2 brand colors
4. ✅ Define 4 semantic colors (Success/Error/Warning/Info)
5. ✅ Create `DSFoundation.swift` namespace
6. ✅ Implement `DSColor` extension
7. ✅ Implement `DSTypography` enum
8. ✅ Implement `DSSpacing` enum
9. ✅ Implement `DSRadius` enum
10. ✅ Create preview playground

### Phase 2: Core Modifiers (Week 2)
11. ✅ `DSTextStyleModifier` + `.dsText()` extension
12. ✅ `DSCardModifier` + `.dsCard()` extension
13. ✅ Create component preview views

### Phase 3: Component Library (Week 3-4)
14. ✅ `DSButton` component (4 styles, 3 sizes)
15. ✅ `DSTextField` component
16. ✅ `DSCard` component
17. ✅ `DSToast` component
18. ✅ Documentation markdown files

### Phase 4: Migration & Adoption (Week 5-8)
19. 🔄 Migrate Authentication feature to design system
20. 🔄 Migrate existing components one-by-one
21. 🔄 Remove old hardcoded values
22. 🔄 Update CLAUDE.md with design system usage guidelines

## Migration Strategy

### Coexistence Rules

```swift
// ✅ GOOD: New code uses design system
Text("Welcome")
    .dsText(.headline, color: DS.Color.Brand.primary)

// ⚠️ ACCEPTABLE during migration: Old code still works
Text("Legacy")
    .font(.headline)
    .foregroundColor(.blue)

// ❌ BAD: New code with hardcoded values
Text("Don't do this")
    .font(.system(size: 17, weight: .semibold))
    .foregroundColor(Color(hex: "0066CC"))
```

### Feature-by-Feature Adoption

1. **New features**: Must use design system from day 1
2. **Existing features**: Migrate during bug fixes or feature updates
3. **Critical paths**: Migrate last to minimize risk

### Rollback Plan

If design system causes issues:
1. Design system code is isolated in `DesignSystem/` folder
2. Can be excluded from build without breaking existing features
3. Asset Catalog colors are additive (won't break old `Color.blue` usage)

## Pros
- ✅ Non-breaking: Can adopt gradually without breaking existing code
- ✅ Best of both: Asset Catalog colors + code-based tokens
- ✅ Clear migration path with rollback option
- ✅ `DS` namespace prevents naming conflicts
- ✅ Comprehensive documentation from start

## Cons
- ⚠️ Longer implementation timeline (8 weeks vs 2-3 weeks)
- ⚠️ Coexistence period may confuse developers
- ⚠️ Requires discipline to use new system in new code

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Slow adoption rate | High | Medium | Provide excellent docs, make migration easy |
| Confusion during coexistence | Medium | Medium | Clear naming (`DS_` prefix), good documentation |
| Inconsistent usage | Medium | High | Code review checklist, linter rules |
| Performance regression | Low | High | Profile before/after, use lazy loading |
| Breaking existing UI | Low | Critical | Isolated namespace, extensive testing |

## Success Metrics

### Week 4 (Foundation Complete)
- ✅ All tokens defined and documented
- ✅ Preview app shows all colors/typography
- ✅ Zero build errors

### Week 8 (Components Complete)
- ✅ 5+ reusable components built
- ✅ Component documentation complete
- ✅ At least 1 feature migrated successfully

### Week 12 (Adoption Phase)
- 🎯 50% of new code uses design system
- 🎯 20% of existing screens migrated
- 🎯 Zero hardcoded colors in new PRs

### Week 24 (Full Adoption)
- 🎯 90% of codebase uses design system
- 🎯 All new code enforced via linter
- 🎯 Legacy code refactored

## Special Considerations

### SwiftUI Previews

Every component must have rich previews:

```swift
struct DSButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: DS.Spacing.md) {
            DSButton("Primary", style: .primary) {}
            DSButton("Secondary", style: .secondary) {}
            DSButton("Tertiary", style: .tertiary) {}
            DSButton("Destructive", style: .destructive) {}
        }
        .padding()
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Button Styles")

        VStack(spacing: DS.Spacing.md) {
            DSButton("Small", size: .small) {}
            DSButton("Medium", size: .medium) {}
            DSButton("Large", size: .large) {}
        }
        .padding()
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Button Sizes")

        VStack(spacing: DS.Spacing.md) {
            DSButton("Enabled") {}
            DSButton("Disabled", isEnabled: false) {}
        }
        .padding()
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Button States")
    }
}
```

### Accessibility

All components must support:
- Dynamic Type (font scaling)
- VoiceOver labels
- High contrast mode
- Reduced motion preferences

### Documentation

Create comprehensive Markdown docs:
- Getting Started guide
- Migration guide (with before/after code examples)
- Component usage guidelines
- Contribution guidelines

## Recommendation

**This hybrid approach (Trial 3) is recommended** because:

1. ✅ Non-breaking migration reduces risk
2. ✅ Combines best practices from Trial 1 and Trial 2
3. ✅ Scalable for long-term maintenance
4. ✅ Provides clear rollback path
5. ✅ Includes comprehensive documentation

The 8-week timeline allows for quality implementation and thorough testing before broad adoption.
