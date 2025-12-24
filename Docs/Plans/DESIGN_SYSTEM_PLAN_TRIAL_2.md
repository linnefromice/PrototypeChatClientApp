# Design System Plan - Trial 2: Asset Catalog Driven

**Strategy:** Leverage Xcode's Asset Catalog for maximum OS integration and automatic dark mode support

## Design Philosophy

- **OS-native first**: Use Asset Catalog for colors, reducing code complexity
- **Visual editing**: Designers can edit colors directly in Xcode
- **Automatic dark mode**: Built-in light/dark mode support via Asset Catalog
- **Instant preview**: See color changes without recompiling

## Layer Structure

### Layer 1: Asset Catalog (Visual)

```
Assets.xcassets/
├── Colors/
│   ├── Brand/
│   │   ├── Primary.colorset (with Any/Dark variants)
│   │   └── Secondary.colorset
│   ├── Background/
│   │   ├── Base.colorset
│   │   └── Layer1.colorset
│   ├── Text/
│   │   ├── Primary.colorset
│   │   ├── Secondary.colorset
│   │   └── Tertiary.colorset
│   └── Semantic/
│       ├── Success.colorset
│       ├── Error.colorset
│       └── Warning.colorset
```

### Layer 2: Swift Wrappers (Type-safe access)

```swift
// Auto-generated or manually maintained
extension Color {
    enum Brand {
        static let primary = Color("Brand/Primary")
        static let secondary = Color("Brand/Secondary")
    }

    enum Background {
        static let base = Color("Background/Base")
        static let layer1 = Color("Background/Layer1")
    }

    enum Text {
        static let primary = Color("Text/Primary")
        static let secondary = Color("Text/Secondary")
        static let tertiary = Color("Text/Tertiary")
    }

    enum Semantic {
        static let success = Color("Semantic/Success")
        static let error = Color("Semantic/Error")
        static let warning = Color("Semantic/Warning")
    }
}
```

### Layer 3: Typography & Spacing (Code-based)

```swift
// These remain in code as they're more flexible
enum DSTypography {
    case largeTitle
    case title1
    case title2
    case headline
    case body
    case callout
    case subheadline
    case footnote
    case caption1
    case caption2

    var font: Font {
        switch self {
        case .largeTitle: return .largeTitle
        case .title1: return .title
        case .title2: return .title2
        case .headline: return .headline
        case .body: return .body
        case .callout: return .callout
        case .subheadline: return .subheadline
        case .footnote: return .footnote
        case .caption1: return .caption
        case .caption2: return .caption2
        }
    }

    var lineHeight: CGFloat {
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
}

struct DSTextStyle: ViewModifier {
    let typography: DSTypography
    let color: Color

    func body(content: Content) -> some View {
        content
            .font(typography.font)
            .lineSpacing(typography.lineHeight - typography.font.lineHeight)
            .foregroundColor(color)
    }
}

extension View {
    func dsTextStyle(_ typography: DSTypography, color: Color = Color.Text.primary) -> some View {
        modifier(DSTextStyle(typography: typography, color: color))
    }
}
```

### Layer 4: Components

```swift
struct DSButton {
    enum Style {
        case primary
        case secondary
        case tertiary
    }

    let title: String
    let style: Style
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .dsTextStyle(.headline, color: foregroundColor)
                .padding(.horizontal, DSSpacing.lg)
                .padding(.vertical, DSSpacing.md)
        }
        .background(backgroundColor)
        .cornerRadius(DSRadius.medium)
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: return Color.Brand.primary
        case .secondary: return Color.Background.layer1
        case .tertiary: return .clear
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: return .white
        case .secondary: return Color.Brand.primary
        case .tertiary: return Color.Brand.primary
        }
    }
}
```

## File Structure

```
PrototypeChatClientApp/
├── DesignSystem/
│   ├── Tokens/
│   │   ├── DSColor.swift          // Color extension wrappers
│   │   ├── DSTypography.swift     // Typography definitions
│   │   ├── DSSpacing.swift        // Spacing constants
│   │   ├── DSRadius.swift         // Corner radius values
│   │   └── DSShadow.swift         // Shadow styles
│   ├── Modifiers/
│   │   ├── DSTextStyle.swift      // Text style modifier
│   │   └── DSCardStyle.swift      // Card modifier
│   ├── Components/
│   │   ├── DSButton.swift
│   │   ├── DSCard.swift
│   │   └── DSTextField.swift
│   └── Preview/
│       └── DesignSystemPreview.swift  // Preview all tokens/components
└── Assets.xcassets/
    └── Colors/                    // All color definitions
```

## Implementation Priority

### Phase 1 (MVP)
1. **Asset Catalog setup**
   - Create color sets with light/dark variants
   - Brand colors (2)
   - Background colors (2)
   - Text colors (3)

2. **Swift wrappers**
   - Color extension with namespaces

3. **Basic typography**
   - 5 essential text styles
   - TextStyle modifier

4. **Spacing system**
   - 5 spacing values

### Phase 2
5. **Component library**
   - Primary button
   - Secondary button
   - Text field

6. **Semantic colors**
   - Success/Error/Warning

7. **Card component**

### Phase 3
8. **Advanced typography**
   - Custom font support
   - Dynamic type support

9. **Animation tokens**
10. **Design system preview app**

## Pros
- ✅ Native dark mode support (automatic)
- ✅ Visual color editing in Xcode
- ✅ No runtime color calculations
- ✅ Designers can work directly in Xcode
- ✅ Asset Catalog optimizes color storage

## Cons
- ⚠️ Color changes require rebuilding app
- ⚠️ Asset Catalog can become cluttered
- ⚠️ Harder to version control color changes (binary format)
- ⚠️ Need to manually maintain Swift wrappers

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Asset Catalog merge conflicts | Medium | Medium | Use xcassets diff tool, enforce single person editing |
| Missing dark mode variants | High | High | Checklist in PR template, automated tests |
| Wrapper code out of sync | Low | High | Code generation script or SwiftGen integration |
| Designer workflow friction | Medium | Low | Provide clear documentation and training |

## Success Metrics

- **Dark mode compliance**: 100% of colors support dark mode from day 1
- **Color consistency**: Zero hardcoded hex values in feature code
- **Designer engagement**: Designers can update colors without developer help
- **Performance**: No measurable performance impact from design system

## Special Considerations

### SwiftGen Integration (Optional Phase 4)

Auto-generate color wrappers from Asset Catalog:

```swift
// Auto-generated by SwiftGen
extension Color {
    enum Brand {
        static let primary = ColorAsset(name: "Brand/Primary").swiftUIColor
    }
}
```

### Design Tokens Export

Asset Catalog can be exported to JSON for design tools:
- Figma plugin integration
- Sketch integration
- Web/Android sharing
