# Design System Plan - Trial 1: Minimal + Extensibility

**Strategy:** Start minimal, focus on extensibility and type safety

## Design Philosophy

- **Minimal initial footprint**: Only implement what's immediately needed
- **Type-safe tokens**: Use enums and structs to prevent magic values
- **Progressive enhancement**: Easy to add new tokens without breaking existing code
- **SwiftUI-first**: Leverage ViewModifier and Style protocols

## Layer Structure

### Layer 1: Primitive Tokens (Raw Values)

```swift
// Absolute, unchanging values
enum ColorPrimitive {
    static let blue500 = Color(hex: "0066CC")
    static let gray100 = Color(hex: "F5F5F5")
    static let gray900 = Color(hex: "1A1A1A")
}

enum FontSizePrimitive {
    static let xs: CGFloat = 12
    static let sm: CGFloat = 14
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}
```

### Layer 2: Semantic Tokens (Purpose-based)

```swift
// Purpose-oriented naming
extension Color {
    struct Semantic {
        static let brandPrimary = ColorPrimitive.blue500
        static let textMain = ColorPrimitive.gray900
        static let textSub = ColorPrimitive.gray600
        static let backgroundBase = ColorPrimitive.gray100
    }
}

enum Typography {
    case heading1
    case heading2
    case body
    case caption

    var font: Font {
        switch self {
        case .heading1: return .system(size: FontSizePrimitive.xxl, weight: .bold)
        case .heading2: return .system(size: FontSizePrimitive.xl, weight: .semibold)
        case .body: return .system(size: FontSizePrimitive.md, weight: .regular)
        case .caption: return .system(size: FontSizePrimitive.xs, weight: .regular)
        }
    }
}
```

### Layer 3: Components

```swift
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Typography.body.font)
            .foregroundColor(.white)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .background(Color.Semantic.brandPrimary)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
```

## File Structure

```
PrototypeChatClientApp/
├── DesignSystem/
│   ├── Foundation/
│   │   ├── ColorPrimitives.swift
│   │   ├── ColorSemantics.swift
│   │   ├── Typography.swift
│   │   ├── Spacing.swift
│   │   └── Radius.swift
│   ├── Components/
│   │   ├── Buttons/
│   │   │   ├── PrimaryButtonStyle.swift
│   │   │   └── SecondaryButtonStyle.swift
│   │   └── Cards/
│   │       └── CardModifier.swift
│   └── Modifiers/
│       └── TextStyleModifier.swift
```

## Implementation Priority

### Phase 1 (MVP)
1. Color primitives + semantics (5 colors)
2. Typography (4 styles)
3. Spacing (5 sizes)
4. Primary button style

### Phase 2
5. Radius definitions
6. Shadow styles
7. Secondary button
8. Card component

### Phase 3
9. Dark mode support
10. Animation tokens
11. Icon system integration

## Pros
- ✅ Clean separation of concerns
- ✅ Easy to understand for new developers
- ✅ Type-safe, compile-time checks
- ✅ Minimal initial complexity

## Cons
- ⚠️ Requires discipline to avoid bypassing the system
- ⚠️ Initial setup overhead before seeing benefits
- ⚠️ May need refactoring as system grows

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Developers bypass system | Medium | High | Code review enforcement, linter rules |
| Over-engineering early | Low | Medium | Start minimal, add incrementally |
| Inconsistent naming | Medium | Medium | Establish naming conventions document |

## Success Metrics

- **Adoption rate**: 80% of UI code uses design system by end of implementation
- **Consistency**: No hardcoded color/spacing values in feature code
- **Velocity**: 20% faster UI development after initial learning curve
