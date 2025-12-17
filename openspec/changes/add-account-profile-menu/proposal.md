# Proposal: Add Account Profile Menu

**Change ID:** `add-account-profile-menu`
**Status:** Proposal
**Created:** 2025-12-17

## Overview

ナビゲーションドロワーの`NavigationMenuView`に「アカウント」メニューアイテムを追加し、ログイン中のユーザー情報を表示する専用画面を実装します。ユーザーのアバター画像を上部に配置し、その他のユーザー情報（ID、名前、作成日時など）をリスト形式で表示します。

### Current Behavior

- `NavigationMenuView`には「ログアウト」オプションのみが表示される
- ログイン中のユーザー情報を確認する手段がない
- `User`エンティティには`avatarUrl`, `id`, `idAlias`, `name`, `createdAt`が含まれているが、UIで表示されていない

### Desired Behavior

- `NavigationMenuView`に「アカウント」メニューアイテムを追加
- 「アカウント」をタップすると、ユーザー情報画面（`AccountProfileView`）に遷移
- ユーザー情報画面には以下を表示：
  - 上部：アバター画像（`avatarUrl`を使用、またはイニシャルプレースホルダー）
  - 下部：ユーザー情報をリスト形式で表示
    - ユーザーID (`id`)
    - ユーザーエイリアス (`idAlias`)
    - 名前 (`name`)
    - 作成日時 (`createdAt`)

## Why

ユーザーが現在ログインしているアカウント情報を確認できることは、アプリの基本的なUX要件です。特に複数のテストユーザーを切り替えて開発・テストする際に、現在どのユーザーでログインしているかを確認できることが重要です。

## Motivation

- ユーザー認証機能は実装済みで、`AuthSession`に`User`情報が保存されている
- `User`エンティティには表示可能な情報が十分に含まれている
- 既存の`NavigationMenuView`を拡張して、ログアウトとアカウント情報の両方にアクセス可能にする
- iOS標準の設定画面パターン（上部にプロフィール、下部にメニュー）に準拠

## Scope

### In Scope

- `NavigationMenuView`に「アカウント」メニューアイテムを追加
- `AccountProfileView`の新規作成
  - アバター画像またはイニシャルプレースホルダーの表示
  - ユーザー情報のリスト表示
  - 読み取り専用の表示
- `AuthenticationViewModel`から現在のユーザー情報を取得
- NavigationLink経由での画面遷移

### Out of Scope

- プロフィール編集機能
- アバター画像のアップロード機能
- パスワード変更機能
- アカウント削除機能
- その他の設定オプション

## Dependencies

### Existing Components

- ✅ `AuthSession` - ログイン中のユーザー情報を保持
- ✅ `User` エンティティ - 表示に必要な全ての情報を含む
- ✅ `AuthenticationViewModel` - `currentSession`経由でユーザー情報にアクセス可能
- ✅ `NavigationMenuView` - メニューアイテムを追加するベース
- ✅ `ConversationListView` - `@EnvironmentObject var authViewModel`で認証情報にアクセス可能

### No Breaking Changes

- 既存のログアウト機能は変更なし
- 既存のインターフェースは変更なし
- 新しいプロトコルやエンティティの追加なし

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|-----------|
| `avatarUrl`がnilの場合の表示 | Low | イニシャルプレースホルダー（名前の最初の文字）を表示 |
| セッション情報がnilの場合 | Low | `MainView`で既にセッションチェック済み。`AccountProfileView`には必ずユーザー情報が渡される |
| 日付フォーマットの一貫性 | Low | SwiftUIの標準DateFormatterを使用し、ローカライズ対応 |

## Success Criteria

1. `NavigationMenuView`に「アカウント」メニューアイテムが表示される
2. 「アカウント」をタップすると、ユーザー情報画面に遷移する
3. ユーザー情報画面の上部にアバター画像（またはプレースホルダー）が表示される
4. ユーザー情報画面の下部にユーザー情報がリスト形式で表示される
5. 戻るボタンで`NavigationMenuView`に戻れる
6. 既存のテストが全てpassする

## Related Changes

- Depends on: `add-logout-navigation-menu`（既存の`NavigationMenuView`を使用）
- Blocks: None

## Alternatives Considered

### Alternative 1: 会話一覧画面のヘッダーに直接ユーザー情報を表示

**Pros:**
- 常にユーザー情報が見える
- 画面遷移が不要

**Cons:**
- NavigationBarが混雑する
- 詳細情報を表示するスペースがない
- 会話一覧の表示領域が減る

**Decision:** 専用画面を作成し、詳細情報を表示

### Alternative 2: 設定タブを追加（TabView）

**Pros:**
- より多くの設定オプションを追加できる
- iOS標準のパターン

**Cons:**
- 現在のNavigationView構造を大幅に変更する必要がある
- 過剰な設計（現時点ではアカウント情報とログアウトのみが必要）

**Decision:** 既存の`NavigationMenuView`を拡張

### Alternative 3: モーダルダイアログでユーザー情報を表示

**Pros:**
- 実装がシンプル
- 画面遷移が不要

**Cons:**
- 詳細情報を表示するスペースが限られる
- モーダル表示は一時的な情報表示に適しており、プロフィール表示には不適切

**Decision:** NavigationLink経由で専用画面に遷移

## Implementation Notes

### 変更箇所

**File 1:** `PrototypeChatClientApp/Features/Authentication/Presentation/Views/NavigationMenuView.swift`

**変更内容:**
1. `@EnvironmentObject var authViewModel: AuthenticationViewModel`を追加
2. 「アカウント」メニューアイテムを追加（ログアウトの上に配置）
3. `NavigationLink`で`AccountProfileView`に遷移

**File 2:** `PrototypeChatClientApp/Features/Authentication/Presentation/Views/AccountProfileView.swift`（新規作成）

**構成:**
1. 上部セクション：
   - アバター画像（`AsyncImage`または`Image`）
   - アバターがnilの場合はイニシャルプレースホルダー
   - 中央配置、円形、適切なサイズ（80x80程度）

2. 下部セクション：
   - `List`を使用したユーザー情報の表示
   - ラベルと値のペアで表示
   - セクション分けして読みやすく

### 画面レイアウト例

```
┌─────────────────────────┐
│     AccountProfile      │
├─────────────────────────┤
│                         │
│         [Avatar]        │
│                         │
├─────────────────────────┤
│ ユーザーID               │
│   user-1                │
├─────────────────────────┤
│ ユーザーエイリアス        │
│   alice                 │
├─────────────────────────┤
│ 名前                    │
│   Alice                 │
├─────────────────────────┤
│ 作成日時                 │
│   2025/12/01 10:30      │
└─────────────────────────┘
```

### データフロー

```
ConversationListView
  ├─ @EnvironmentObject authViewModel
  └─ NavigationMenuView
      ├─ @EnvironmentObject authViewModel
      └─ NavigationLink → AccountProfileView(user: authViewModel.currentSession!.user)
```

### テスト戦略

1. **Manual Test:** シミュレータでの動作確認
   - メニューに「アカウント」が表示されることを確認
   - 「アカウント」タップで画面遷移することを確認
   - アバター画像（またはプレースホルダー）が表示されることを確認
   - ユーザー情報が正しく表示されることを確認
   - 戻るボタンでメニューに戻れることを確認

2. **Preview Test:** Xcode Previewでの表示確認
   - `avatarUrl`がnilの場合のプレースホルダー表示
   - `avatarUrl`が有効な場合の画像表示

3. **Unit Test:** 不要（表示のみのViewであり、ビジネスロジックなし）
