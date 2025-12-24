# デザインシステム仕様書

**バージョン:** 1.0.0
**ステータス:** 実装承認済み
**最終更新日:** 2024-12-24

## エグゼクティブサマリー

本ドキュメントは PrototypeChatClientApp のデザインシステムを定義します。3つの実装アプローチを評価した結果、**試行3: ハイブリッド + 段階的移行**を最適な戦略として選択しました。

### 選択されたアプローチ: コードベースデザインシステム

- **カラー**: Hex ベース + 動的ライト/ダークモード対応 + グラデーション対応
- **タイポグラフィ、スペーシング、角丸、シャドウ**: コードベースのトークン
- **コンポーネント**: SwiftUI Views + ViewModifiers
- **移行**: 段階的、非破壊的な導入

### 主な利点

1. ✅ **非破壊的**: 移行期間中、既存コードと共存可能
2. ✅ **ダークモード**: `dynamicColor(dark:light:)` による自動対応
3. ✅ **型安全**: コンパイル時チェックによりマジックナンバーを防止
4. ✅ **拡張性**: 新しいトークン、グラデーション、コンポーネントの追加が容易
5. ✅ **Hex ベース**: Asset Catalog 依存なしの直接的なカラー定義
6. ✅ **グラデーション対応**: ダークモード対応の組み込みグラデーション定義
7. ✅ **ドキュメント化**: 開発者向けの包括的なガイド

## アーキテクチャ

### 3層モデル

```
┌─────────────────────────────────────┐
│   レイヤー3: コンポーネント          │
│   (AppButton, AppCard, など)         │
├─────────────────────────────────────┤
│   レイヤー2: モディファイア          │
│   (.appText(), .appCard())           │
├─────────────────────────────────────┤
│   レイヤー1: 基盤トークン            │
│   (App.Color, App.Typography, など)  │
└─────────────────────────────────────┘
```

### 名前空間戦略

移行期間中の命名競合を防ぐため、すべてのデザインシステムのシンボルには `App` プレフィックスを使用します：

- Swift コード: `App.Color.Text.Default.primary`, `App.Gradient.brand`
- カラープリミティブ: `UIColor.gray1000`, `UIColor.systemRed100`
- コンポーネント: `AppButton`, `AppTextField`
- モディファイア: `.appText()`, `.appCard()`

## 基盤トークン

### 1. カラー（Hex ベースコード）

#### カラーシステムアーキテクチャ

カラーシステムは3つの層で構成されています：

1. **カラープリミティブ** (`AppColorPrimitives.swift`): UIColor 拡張と hex 定義
2. **セマンティックカラー** (`AppColor.swift`): 用途ベースの組織化（Text, Icon, Stroke, Fill）
3. **カラーヘルパー**: `hex()`, `dynamicColor()`, `constantColor()` による柔軟なカラー作成

#### カラーヘルパー

```swift
// hex 値からカラーを作成
let brandColor = Color.hex(0x0066CC)

// 適応的カラーを作成（ライト/ダークモード）
let adaptiveText = Color.dynamicColor(
    dark: .white1000,
    light: .gray1000
)

// 定数カラーを作成（適応なし）
let brandRed = Color.constantColor(.systemRed100)
```

#### セマンティックカラー構成

**テキストカラー** - `App.Color.Text.*`
- `Default.primary`: 最高コントラストテキスト
- `Default.secondary`: 中コントラストテキスト
- `Default.tertiary`: 低コントラストテキスト
- `Link.primaryActive`: アクティブリンクカラー
- `Function.rewards`: リワード専用テキスト

**アイコンカラー** - `App.Color.Icon.*`
- `Default.primary`, `Default.secondary`, `Default.tertiary`
- `Function.rewards`, `Function.coin`

**ストローク/ボーダーカラー** - `App.Color.Stroke.*`
- `Default.primary`, `Default.secondary`, `Default.border`
- `Highlight.primary`, `Highlight.button`
- `Danger.primary`, `Danger.secondary`

**塗りつぶし/背景カラー** - `App.Color.Fill.*`
- `Default.primaryStrong`, `Default.primaryLight`
- `Light.white1000`, `Light.white500`
- `Shadow.black800`, `Shadow.black500`（シャドウ用）
- `Function.rewardsPrimary`, `Function.coinPrimary`

**ニュートラルカラー**（直接アクセス） - `App.Color.Neutral.*`
- `black1000`, `black700`, `black400`, `black100`
- `gray1000` ～ `gray100`
- `white1000` ～ `white100`

**レガシーカラー**（後方互換性）
- `Brand.primary`, `Brand.secondary`
- `Semantic.success`, `Semantic.error`, `Semantic.warning`, `Semantic.info`

#### Swift API

```swift
// セマンティックカラー（推奨）
Text("Hello")
    .foregroundColor(App.Color.Text.Default.primary)

VStack {
    // ...
}
.background(App.Color.Fill.Default.primaryStrong)

// ニュートラルカラー（直接アクセス）
Rectangle()
    .fill(App.Color.Neutral.gray900)

// Hex カラー（カスタムカラー用）
Circle()
    .fill(Color.hex(0xFF3D00))
```

#### カラープリミティブ（UIColor）

すべてのセマンティックカラーは UIColor プリミティブの上に構築されています：

```swift
// Black スケール
UIColor.black1000  // hex(0x161213)
UIColor.black100   // black1000.withAlphaComponent(0.05)

// Gray スケール
UIColor.gray1000   // hex(0x292929)
UIColor.gray900    // hex(0x3d3d3d)
UIColor.gray100    // hex(0xefefef)

// システムカラー
UIColor.systemRed100     // hex(0xff3d00)
UIColor.systemOrange100  // hex(0xffbb0c)
UIColor.systemGreen100   // hex(0x56e100)
UIColor.systemPurple100  // hex(0x8256ff)
// ... その他多数
```

### 2. グラデーション（コード）

#### グラデーション定義

デザインシステムには、ダークモード自動対応の事前定義されたグラデーションが含まれています：

**ブランドグラデーション**
```swift
// 固定ブランドグラデーション
App.Gradient.brand
// LinearGradient: 青から紫へ

// 適応的背景グラデーション
App.Gradient.brandBackground(colorScheme: colorScheme)
```

**機能的グラデーション**
```swift
App.Gradient.reward   // マゼンタから紫へ
App.Gradient.coin     // オレンジから黄色へ
App.Gradient.success  // 緑のバリエーション
App.Gradient.error    // 赤のバリエーション
```

**ユーティリティグラデーション**
```swift
// シマーエフェクト（ローディング状態用）
App.Gradient.shimmer(colorScheme: colorScheme)

// グラスモーフィズムオーバーレイ
App.Gradient.glass(colorScheme: colorScheme)

// スクリムオーバーレイ（黒/白へフェード）
App.Gradient.scrim(
    colorScheme: colorScheme,
    direction: .bottom
)
```

#### Swift API

```swift
// 事前定義グラデーションの使用
Rectangle()
    .fill(App.Gradient.brand)

// 適応的グラデーションの使用
@Environment(\.colorScheme) var colorScheme

VStack {
    // ...
}
.background(App.Gradient.brandBackground(colorScheme: colorScheme))

// グラデーション背景モディファイアの使用
VStack {
    // ...
}
.gradientBackground { colorScheme in
    App.Gradient.shimmer(colorScheme: colorScheme)
}
```

### 3. タイポグラフィ（コード）

#### タイプスケール

| トークン | サイズ | ウェイト | 行高 | 字間 | ユースケース |
|-------|------|--------|------|------|----------|
| `largeTitle` | 34pt | Bold | 41pt | 0 | ヒーロータイトル |
| `title1` | 28pt | Semibold | 34pt | 0 | ページタイトル |
| `title2` | 22pt | Semibold | 28pt | 0 | セクション見出し |
| `headline` | 17pt | Semibold | 22pt | -0.24 | 強調テキスト |
| `body` | 17pt | Regular | 22pt | -0.24 | 本文テキスト |
| `callout` | 16pt | Regular | 21pt | -0.24 | 補足コンテンツ |
| `subheadline` | 15pt | Regular | 20pt | -0.08 | メタデータ |
| `footnote` | 13pt | Regular | 18pt | 0 | キャプション |
| `caption1` | 12pt | Regular | 16pt | 0 | 小ラベル |
| `caption2` | 11pt | Regular | 16pt | 0 | タイムスタンプ |

#### Swift API

```swift
// モディファイアで使用
Text("Welcome")
    .appText(.headline, color: App.Color.Brand.primary)

// フォントに直接アクセス
Text("Custom")
    .font(App.Typography.body.font)
```

### 4. スペーシング（コード）

一貫したスペーシングのための8ポイントグリッドシステム：

| トークン | 値 | ユースケース |
|-------|------|----------|
| `xxxs` | 2pt | 最小間隔 |
| `xxs` | 4pt | タイトな間隔 |
| `xs` | 8pt | コンパクトレイアウト |
| `sm` | 12pt | 小パディング |
| `md` | 16pt | デフォルト間隔 |
| `lg` | 24pt | セクション間隔 |
| `xl` | 32pt | 大きな間隔 |
| `xxl` | 48pt | 主要セクション |
| `xxxl` | 64pt | ページレベル間隔 |

#### Swift API

```swift
// 使用例
VStack(spacing: App.Spacing.md) {
    // ...
}
.padding(App.Spacing.lg)
```

### 5. 角丸（コード）

| トークン | 値 | ユースケース |
|-------|------|----------|
| `none` | 0pt | 直角 |
| `sm` | 4pt | 微妙な丸み |
| `md` | 8pt | デフォルト丸み |
| `lg` | 12pt | カード、コンテナ |
| `xl` | 16pt | 目立つ丸み |
| `full` | 9999pt | ピル、円形 |

#### Swift API

```swift
// 使用例
RoundedRectangle(cornerRadius: App.Radius.lg)
```

### 6. シャドウ（コード）

| トークン | 半径 | オフセット | 不透明度 | ユースケース |
|-------|------|----------|---------|----------|
| `sm` | 2pt | (0, 1) | 10% | 微妙な立体感 |
| `md` | 4pt | (0, 2) | 10% | カード |
| `lg` | 8pt | (0, 4) | 15% | モーダル、ポップオーバー |

#### Swift API

```swift
// 使用例
let shadow = App.Shadow.md
view.shadow(
    color: shadow.color,
    radius: shadow.radius,
    x: shadow.x,
    y: shadow.y
)
```

## モディファイア

### AppTextStyleModifier

タイポグラフィ、行高、字間、カラーを一度に適用します。

```swift
Text("Hello World")
    .appText(.headline, color: App.Color.Brand.primary)
```

**実装:**
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

カード風コンテナのための背景、角丸、シャドウを適用します。

```swift
VStack {
    // コンテンツ
}
.appCard()
```

**パラメータ:**
- `backgroundColor`: デフォルト = `App.Color.Background.elevated`
- `cornerRadius`: デフォルト = `App.Radius.lg`
- `shadow`: デフォルト = `App.Shadow.md`

## コンポーネント

### AppButton

複数のスタイルとサイズを持つ多機能ボタンコンポーネント。

#### スタイル

- `.primary`: ブランドカラーで塗りつぶし
- `.secondary`: ニュートラル背景
- `.tertiary`: 透明（テキストのみ）
- `.destructive`: 危険なアクション用の赤/エラーカラー

#### サイズ

- `.small`: コンパクトパディング
- `.medium`: デフォルトサイズ
- `.large`: 目立つCTA

#### 使用例

```swift
// プライマリボタン
AppButton("Submit", style: .primary) {
    // アクション
}

// 無効状態
AppButton("Processing", isEnabled: false) {
    // アクション
}

// カスタムスタイル + サイズ
AppButton("Delete", style: .destructive, size: .large) {
    // アクション
}
```

### AppCard

一貫したスタイリングを持つコンテナコンポーネント。

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

### 今後のコンポーネント（計画）

- `AppTextField`: スタイル化されたテキスト入力
- `AppTextArea`: 複数行テキスト入力
- `AppToast`: 一時的な通知
- `AppAlert`: モーダルアラート
- `AppBadge`: ステータスインジケータ
- `AppAvatar`: ユーザープロフィール画像

## ファイル構造

```
PrototypeChatClientApp/
├── DesignSystem/
│   ├── Foundation/
│   │   ├── AppFoundation.swift       # 名前空間: public enum App {}
│   │   ├── AppColorPrimitives.swift  # UIColor hex 拡張
│   │   ├── AppColor.swift            # セマンティックカラー構成
│   │   ├── AppGradient.swift         # グラデーション定義
│   │   ├── AppTypography.swift       # App.Typography enum
│   │   ├── AppSpacing.swift          # App.Spacing 定数
│   │   ├── AppRadius.swift           # App.Radius 定数
│   │   └── AppShadow.swift           # App.Shadow 定義
│   ├── Modifiers/
│   │   ├── AppTextStyleModifier.swift
│   │   └── AppCardModifier.swift
│   ├── Components/
│   │   ├── AppButton.swift
│   │   └── AppCard.swift
│   └── Preview/
│       └── AppPreview.swift
```

## 実装フェーズ

### フェーズ1: 基盤（本プロトタイプ）

**範囲:**
1. ✅ 50種類以上のプリミティブカラーを持つ Hex ベースカラーシステム
2. ✅ セマンティックカラー構成（Text, Icon, Stroke, Fill）
3. ✅ `dynamicColor()` による動的ライト/ダークモード対応
4. ✅ ダークモード対応のグラデーション定義
5. ✅ Swift トークン: Typography, Spacing, Radius, Shadow
6. ✅ モディファイア: `.appText()`, `.appCard()`, `.gradientBackground()`
7. ✅ コンポーネント: `AppButton`, `AppCard`
8. ✅ すべてのトークンとコンポーネントのプレビュー

**成果物:**
- コンパイル可能で機能的なデザインシステム
- すべてのコンポーネントを表示するプレビューアプリ
- コードコメントによる基本ドキュメント

### フェーズ2: 拡張（将来）

- 追加コンポーネント（TextField, Toast, Alert）
- アニメーショントークン
- アクセシビリティ強化
- 追加グラデーションパターン（放射状、角度）
- カラーパレットジェネレーターユーティリティ

### フェーズ3: 移行（将来）

- 認証機能をデザインシステム使用にリファクタリング
- 移行ガイドの作成
- コードレビューチェックリストの確立
- 強制のための Linter ルール

## 使用ガイドライン

### 新規コード向け

**✅ 推奨:**
```swift
// セマンティックカラーを使用
Text("Welcome")
    .appText(.headline, color: App.Color.Text.Default.primary)

AppButton("Submit", style: .primary) { }

VStack(spacing: App.Spacing.md) {
    // ...
}
.padding(App.Spacing.lg)
.background(App.Color.Fill.Default.primaryStrong)

// グラデーションを使用
Rectangle()
    .fill(App.Gradient.brand)
```

**❌ 非推奨:**
```swift
// ハードコードされた値を使用しない
Text("Welcome")
    .font(.system(size: 17, weight: .semibold))
    .foregroundColor(Color(hex: "0066CC"))

Button("Submit") { }
    .padding(.horizontal, 24)
    .padding(.vertical, 12)
```

### 既存コード向け

移行期間中、古いコードは引き続き動作します：

```swift
// ⚠️ 移行期間中は許容される
Text("Legacy")
    .font(.headline)
    .foregroundColor(.blue)
```

既存コードは以下のタイミングで移行：
- 機能更新時
- バグ修正時
- 専用のリファクタリングスプリント

## ダークモード戦略

### 自動対応

すべてのカラーは `dynamicColor(dark:light:)` を使用して自動的にダークモード適応します：

- **動的カラー**: システムアピアランスに基づいて自動的に切り替わる
  ```swift
  Color.dynamicColor(dark: .white1000, light: .gray1000)
  ```
- **定数カラー**: アピアランスモードに関係なく同じまま
  ```swift
  Color.constantColor(.systemRed100)
  ```
- **グラデーション**: ダークモードバリアント用の colorScheme パラメータを含む
  ```swift
  App.Gradient.shimmer(colorScheme: colorScheme)
  ```

### ダークモードのテスト

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

## アクセシビリティ

すべてのコンポーネントは以下をサポートする必要があります：

1. **Dynamic Type**: ユーザー設定に応じてフォントサイズが拡大縮小
2. **VoiceOver**: 適切なラベルとヒント
3. **High Contrast**: コントラスト増加モードでテスト
4. **Reduced Motion**: `UIAccessibility.isReduceMotionEnabled` を尊重

### 例

```swift
AppButton("Submit", style: .primary) {
    // アクション
}
.accessibilityLabel("フォーム送信")
.accessibilityHint("ダブルタップで情報を送信します")
```

## テスト戦略

### ユニットテスト

トークン値をテスト：
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

### スナップショットテスト

コンポーネントの外観をキャプチャ：
```swift
func testAppButtonStyles() {
    let button = AppButton("Test", style: .primary) {}
    assertSnapshot(matching: button, as: .image)
}
```

### ビジュアルリグレッション

意図しない視覚的変更を検出するため、Xcode Previews またはスナップショットテストを使用。

## パフォーマンス考慮事項

### Hex ベースカラー

- ✅ カラーはコンパイル時に解決
- ✅ 最小限のランタイムオーバーヘッド
- ✅ Asset Catalog 依存なし
- ✅ 透明性のための直接 hex 値

### コンポーネントの再利用

- 可能な場合はカスタム `View` より `ButtonStyle` を優先（パフォーマンス向上）
- 複雑なコンポーネントレイアウトには `@ViewBuilder` を使用
- 過度なビュー階層の深さを避ける

## 移行チェックリスト

デザインシステムを使用するための画面リファクタリング時：

- [ ] ハードコードされたカラーをセマンティックカラー（`App.Color.Text.*`, `App.Color.Fill.*`）に置換
- [ ] ハードコードされたグラデーションを `App.Gradient.*` に置換
- [ ] ハードコードされたフォントを `.appText()` に置換
- [ ] ハードコードされたスペーシングを `App.Spacing.*` に置換
- [ ] カスタムボタンを `AppButton` に置換
- [ ] カスタムカードを `.appCard()` または `AppCard` に置換
- [ ] ライトとダークの両モードでテスト
- [ ] VoiceOver ラベルを確認
- [ ] スナップショットテストを更新

## ロールバック計画

デザインシステムが問題を引き起こした場合：

1. **隔離されたコード**: すべてのDSコードは `DesignSystem/` フォルダに配置
2. **無効化可能**: 一時的にビルドターゲットから除外可能
3. **非破壊的**: 古いコードは引き続き動作
4. **高速ロールバック**: `import DesignSystem` 文を削除

## 成功指標

### 即時（フェーズ1）

- ✅ デザインシステムがエラーなくコンパイル
- ✅ すべてのトークンとコンポーネントにプレビューあり
- ✅ ドキュメントが明確で包括的

### 短期（1ヶ月）

- 🎯 新規UIコードの50%がデザインシステムを使用
- 🎯 新規PRでハードコードされたカラーがゼロ
- 🎯 少なくとも1画面が完全移行

### 長期（6ヶ月）

- 🎯 コードベースの90%がデザインシステムを使用
- 🎯 Linter がデザインシステム使用を強制
- 🎯 デザイン更新が数日ではなく数時間で可能

## 参考資料

### 関連ドキュメント

- `CLAUDE.md`: AI アシスタントガイドライン
- `Docs/Manuals/XCODE_CONFIGURATION_GUIDE.md`: Asset Catalog セットアップ
- `Specs/IOS_APP_ARCHITECTURE.md`: 全体的なアプリアーキテクチャ

### 外部リソース

- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SwiftUI Button Styles](https://developer.apple.com/documentation/swiftui/buttonstyle)
- [Asset Catalog Format Reference](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_ref-Asset_Catalog_Format/)

---

**ドキュメントステータス:** ✅ 実装承認済み
**次のステップ:** フェーズ1プロトタイプ実装の開始
