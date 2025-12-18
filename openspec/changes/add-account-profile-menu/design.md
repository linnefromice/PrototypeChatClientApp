# Design: Add Account Profile Menu

**Change ID:** `add-account-profile-menu`
**Status:** Proposal
**Created:** 2025-12-17

## Architecture Overview

この変更は、既存の`NavigationMenuView`を拡張し、新しい`AccountProfileView`を追加することで、ログイン中のユーザー情報を表示する機能を追加します。MVVM + Clean Architectureの原則に従い、Presentation層のみの変更で実装可能です。

## Design Decisions

### 1. Feature Placement

**Decision:** `Features/Authentication/Presentation/Views/`に配置

**Rationale:**
- アカウント情報の表示は認証機能に密接に関連
- `AuthSession`と`User`エンティティを使用
- 既存の`NavigationMenuView`が`Features/Authentication/`に配置されている
- 将来的にプロフィール編集機能を追加する場合も同じディレクトリに配置可能

**Alternatives Considered:**
- `Features/Profile/`に配置 → 現時点ではProfileという独立した機能領域が存在しないため見送り
- `Features/Settings/`に配置 → 設定機能はまだ存在せず、アカウント情報は設定ではなく認証に関連するため不適切

### 2. Data Flow Pattern

**Decision:** `@EnvironmentObject`を使用した認証情報の伝播

```
RootView
  └─ MainView (@EnvironmentObject authViewModel)
      └─ ConversationListView (@EnvironmentObject authViewModel)
          └─ NavigationMenuView (@EnvironmentObject authViewModel)
              └─ AccountProfileView(user: User)
```

**Rationale:**
- `AuthenticationViewModel`は既に`@EnvironmentObject`として注入されている
- 認証情報はアプリ全体で必要な横断的関心事
- `AccountProfileView`には`User`オブジェクトを直接渡すことで、ViewModelへの依存を排除
- 読み取り専用の表示のため、ViewModelは不要

**Alternatives Considered:**
- `AccountProfileViewModel`を作成 → 表示のみでビジネスロジックがないため過剰設計
- 引数経由で`User`を渡す → 画面遷移のチェーンが長くなるため不適切
- Dependency Injection経由 → 単純な表示画面には過剰

### 3. Avatar Display Strategy

**Decision:** `AsyncImage`とイニシャルプレースホルダーのフォールバック

**Implementation:**
```swift
if let avatarUrl = user.avatarUrl, let url = URL(string: avatarUrl) {
    AsyncImage(url: url) { phase in
        switch phase {
        case .success(let image):
            image.resizable().scaledToFill()
        case .failure, .empty:
            initialsPlaceholder
        @unknown default:
            initialsPlaceholder
        }
    }
} else {
    initialsPlaceholder
}
```

**Rationale:**
- `User.avatarUrl`はオプショナル（nilの可能性がある）
- ネットワークエラーや無効なURLの場合にも対応
- イニシャルプレースホルダーは標準的なUXパターン
- SwiftUIの`AsyncImage`は画像読み込みとキャッシングを自動処理

**Alternatives Considered:**
- システムアイコン（`person.circle`）を使用 → 個人を識別できないため不適切
- 空白を表示 → UXが悪い
- Kingfisher等のサードパーティライブラリ → 標準機能で十分

### 4. User Information Display Format

**Decision:** `List`を使用したラベル-値ペアの表示

**Structure:**
```swift
List {
    Section {
        LabeledContent("ユーザーID", value: user.id)
        LabeledContent("ユーザーエイリアス", value: user.idAlias)
        LabeledContent("名前", value: user.name)
        LabeledContent("作成日時", value: formattedDate)
    }
}
```

**Rationale:**
- iOS標準の設定画面パターン
- 読みやすく、拡張しやすい
- `LabeledContent`はiOS 16+で利用可能（デプロイメントターゲットがiOS 16.0+）
- セクション分けにより将来の拡張が容易

**Alternatives Considered:**
- カスタムレイアウト（VStack + HStack） → 標準パターンを使用する方が一貫性がある
- Form → Listの方がシンプルで適切
- Grid → 情報量が少ないため過剰

### 5. Date Formatting Strategy

**Decision:** `Date.FormatStyle`を使用したローカライズ対応

```swift
private var formattedDate: String {
    user.createdAt.formatted(date: .abbreviated, time: .shortened)
}
```

**Rationale:**
- iOS 15+の新しいDate Formatting API
- 自動的にローカライズされる
- 読みやすく、メンテナンスしやすい
- タイムゾーンを自動処理

**Alternatives Considered:**
- `DateFormatter` → 古いAPI、より冗長
- ISO8601文字列をそのまま表示 → ユーザーフレンドリーでない
- 相対日時（"2 days ago"） → 作成日時には不適切

## Component Design

### NavigationMenuView (Modified)

**Changes:**
1. `@EnvironmentObject var authViewModel: AuthenticationViewModel`を追加
2. 「アカウント」メニューアイテムを追加（ログアウトの上に配置）
3. `NavigationLink`で`AccountProfileView`に遷移

**Code Structure:**
```swift
struct NavigationMenuView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    let onLogout: () -> Void

    var body: some View {
        NavigationView {
            List {
                // Account menu item
                if let user = authViewModel.currentSession?.user {
                    NavigationLink {
                        AccountProfileView(user: user)
                    } label: {
                        Label("アカウント", systemImage: "person.circle")
                    }
                }

                // Logout button (existing)
                Button(role: .destructive, action: { /* ... */ }) {
                    Label("ログアウト", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
            .navigationTitle("メニュー")
        }
    }
}
```

### AccountProfileView (New)

**Responsibility:**
- ログイン中のユーザー情報を表示
- 読み取り専用
- 状態管理なし

**Structure:**
```swift
struct AccountProfileView: View {
    let user: User

    var body: some View {
        List {
            Section {
                avatarSection
            }

            Section {
                LabeledContent("ユーザーID", value: user.id)
                LabeledContent("ユーザーエイリアス", value: user.idAlias)
                LabeledContent("名前", value: user.name)
                LabeledContent("作成日時", value: formattedDate)
            }
        }
        .navigationTitle("アカウント")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var avatarSection: some View { /* ... */ }
    private var initialsPlaceholder: some View { /* ... */ }
    private var formattedDate: String { /* ... */ }
}
```

## UI/UX Considerations

### 1. Avatar Size and Style

- Size: 80x80 points
- Style: Circle with border
- Positioning: Center-aligned
- Background: Secondary background color

### 2. Information Hierarchy

1. **Primary:** アバター（視覚的識別）
2. **Secondary:** ユーザーエイリアス（日常的な識別子）
3. **Tertiary:** 名前、ID、作成日時（詳細情報）

### 3. Accessibility

- アバター画像に適切な`accessibilityLabel`を設定
- `LabeledContent`は自動的にアクセシビリティに対応
- VoiceOver対応

### 4. Empty States

- `avatarUrl`がnil → イニシャルプレースホルダー
- 名前が空 → "N/A"または"未設定"（現在の`User`では必須のため発生しない）

## Testing Strategy

### 1. Preview Testing

**Test Cases:**
- アバターURLがnilの場合
- アバターURLが有効な場合
- 長い名前・IDの場合

**Implementation:**
```swift
#Preview("Avatar Nil") {
    NavigationStack {
        AccountProfileView(user: User(
            id: "user-1",
            idAlias: "alice",
            name: "Alice",
            avatarUrl: nil,
            createdAt: Date()
        ))
    }
}

#Preview("With Avatar") {
    NavigationStack {
        AccountProfileView(user: User(
            id: "user-1",
            idAlias: "alice",
            name: "Alice",
            avatarUrl: "https://example.com/avatar.jpg",
            createdAt: Date()
        ))
    }
}
```

### 2. Manual Testing

1. メニューから「アカウント」をタップ
2. アバター表示を確認（nil/有効なURL）
3. ユーザー情報が正しく表示されることを確認
4. 日付フォーマットが正しいことを確認
5. 戻るボタンでメニューに戻れることを確認

### 3. Unit Testing

不要（表示のみのViewであり、ビジネスロジックなし）

## Performance Considerations

- `AsyncImage`は自動的に画像をキャッシュ
- 小さい画像サイズ（80x80）のため、メモリ使用量は最小限
- ネットワークリクエストは非同期で実行
- 画面遷移はNavigationStackで管理され、パフォーマンスへの影響は最小限

## Future Extensions

### Potential Enhancements

1. **プロフィール編集機能:**
   - 名前の編集
   - アバター画像のアップロード
   - `AccountProfileViewModel`の導入

2. **アカウント設定:**
   - 通知設定
   - プライバシー設定
   - `SettingsView`の追加

3. **ステータスメッセージ:**
   - ユーザーのステータスメッセージ表示・編集
   - `User`エンティティへの`statusMessage`フィールド追加

4. **アカウント統計:**
   - 作成した会話数
   - 送信したメッセージ数
   - バックエンドAPIの追加が必要

### Migration Path

現在の設計は将来の拡張を妨げない：
- `AccountProfileView`は独立したコンポーネント
- 編集機能を追加する際は`AccountProfileViewModel`を導入
- ナビゲーション構造は変更不要
