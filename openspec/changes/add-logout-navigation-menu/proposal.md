# Proposal: Add Logout Navigation Menu

**Change ID:** `add-logout-navigation-menu`
**Status:** Proposal
**Created:** 2025-12-16

## Overview

会話一覧画面の左上にナビゲーションメニューボタンを追加し、ログアウト機能を提供します。現在、`AuthenticationViewModel`にはログアウトメソッドが実装されていますが、UIからアクセスする手段がありません。

### Current Behavior

- `ConversationListView`の右上に「+」ボタンがあり、チャット作成画面を開く
- ログアウト機能は`AuthenticationViewModel.logout()`として実装済みだが、UIから呼び出せない
- ユーザーはアプリを終了する以外にログアウトする方法がない

### Desired Behavior

- 会話一覧画面の左上（`navigationBarItems(leading:)`）にメニューボタンを追加
- メニューボタンをタップすると、ナビゲーションメニューが表示される
- メニューには「ログアウト」オプションが含まれる
- ログアウトをタップすると、確認ダイアログが表示される
- 確認後、ログアウト処理が実行され、ログイン画面に戻る

## Why

ユーザーがアカウントを切り替えたり、セキュリティのためにログアウトしたりする機能が必要です。現在の実装では、ユーザーがログアウトする手段がなく、複数のテストユーザー（user-1, user-2, user-3）を切り替えて動作確認することができません。

## Motivation

- ログアウト機能のバックエンド実装（`AuthenticationViewModel.logout()`）は完了済み
- UIから呼び出す手段のみが欠けている
- iOS標準の設定画面パターンに準拠した実装
- 最小限の変更で機能を有効化できる

## Scope

### In Scope

- `ConversationListView`に左上のメニューボタンを追加
- メニューシート（`.sheet`または`.actionSheet`）の実装
- ログアウト確認ダイアログの実装
- `AuthenticationViewModel.logout()`の呼び出し
- ログアウト後のログイン画面への遷移

### Out of Scope

- プロフィール編集機能
- アカウント設定画面
- その他のメニューオプション（通知設定、プライバシー設定など）
- アカウント削除機能

## Dependencies

### Existing Components

- ✅ `AuthenticationViewModel.logout()` - 実装済み
- ✅ `AuthenticationUseCase.logout()` - 実装済み
- ✅ `AuthSessionManager.clearSession()` - 実装済み
- ✅ `RootView` - 認証状態に応じた画面切り替えロジック
- ✅ `ConversationListView` - NavigationView構造

### No Breaking Changes

- 既存のインターフェースは変更なし
- 既存の画面レイアウトは維持（右上の「+」ボタンはそのまま）
- 新しいプロトコルやエンティティの追加なし

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|-----------|
| ログアウト時のデータ消失 | Low | SessionManagerがUserDefaultsのみクリア。会話データはサーバー側に保存されているため問題なし |
| 意図しないログアウト | Medium | 確認ダイアログを表示し、ユーザーの意図を確認 |
| NavigationBarの混雑 | Low | 左上にメニューボタン、右上に「+」ボタンで、標準的なレイアウト |

## Success Criteria

1. 会話一覧画面の左上にメニューボタンが表示される
2. メニューボタンをタップすると、メニューオプションが表示される
3. 「ログアウト」オプションをタップすると、確認ダイアログが表示される
4. 「ログアウト」を確認すると、セッションがクリアされる
5. ログアウト後、ログイン画面に自動的に遷移する
6. 既存のテストが全てpassする

## Related Changes

- Depends on: None（既存の認証システムを使用）
- Blocks: None

## Alternatives Considered

### Alternative 1: 右上の「+」ボタンの隣にログアウトボタンを追加

**Pros:**
- メニュー画面が不要
- 実装がシンプル

**Cons:**
- NavigationBarが混雑する
- 将来的に他の設定オプションを追加する余地がない
- iOS標準のパターンではない

**Decision:** 左上にメニューボタンを追加し、拡張性を確保

### Alternative 2: 設定タブを追加（TabView）

**Pros:**
- より多くの設定オプションを追加できる
- iOS標準のパターン

**Cons:**
- 現在のNavigationView構造を大幅に変更する必要がある
- 過剰な設計（現時点ではログアウトのみが必要）

**Decision:** 最小限の変更でログアウト機能を提供

### Alternative 3: Long Press on NavigationTitle

**Pros:**
- UIが追加されない
- クリーンな見た目

**Cons:**
- ディスカバラビリティが低い（ユーザーが見つけにくい）
- iOS標準のパターンではない

**Decision:** 明示的なメニューボタンを使用

## Implementation Notes

### 変更箇所

**File:** `PrototypeChatClientApp/Features/Chat/Presentation/Views/ConversationListView.swift`

**追加要素:**

1. メニュー表示状態の管理
```swift
@State private var showMenu = false
@State private var showLogoutConfirmation = false
```

2. 左上のメニューボタン
```swift
.navigationBarItems(
    leading: Button(action: {
        showMenu = true
    }) {
        Image(systemName: "line.3.horizontal")
    },
    trailing: // 既存の「+」ボタン
)
```

3. メニューシート
```swift
.sheet(isPresented: $showMenu) {
    NavigationMenuView(
        onLogout: {
            showLogoutConfirmation = true
        }
    )
}
```

4. ログアウト確認ダイアログ
```swift
.alert("ログアウト", isPresented: $showLogoutConfirmation) {
    Button("キャンセル", role: .cancel) { }
    Button("ログアウト", role: .destructive) {
        authViewModel.logout()
    }
} message: {
    Text("ログアウトしますか？")
}
```

### 新規ファイル

**File:** `PrototypeChatClientApp/Features/Authentication/Presentation/Views/NavigationMenuView.swift`

簡易的なメニュー画面：
```swift
struct NavigationMenuView: View {
    @Environment(\.dismiss) var dismiss
    let onLogout: () -> Void

    var body: some View {
        NavigationView {
            List {
                Button(role: .destructive, action: {
                    dismiss()
                    onLogout()
                }) {
                    Label("ログアウト", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
            .navigationTitle("メニュー")
            .navigationBarItems(trailing: Button("閉じる") {
                dismiss()
            })
        }
    }
}
```

### 依存性の受け渡し

`ConversationListView`は現在`@EnvironmentObject`を使用していないため、以下の2つのアプローチがあります：

1. `@EnvironmentObject var authViewModel: AuthenticationViewModel`を追加
2. `MainView`から`authViewModel`を渡す

推奨: アプローチ1（`@EnvironmentObject`を使用）

### テスト戦略

1. **Unit Test:** `AuthenticationViewModel.logout()`の動作確認（既存テストで対応済み）
2. **Manual Test:** シミュレータでの動作確認
   - メニューボタンの表示確認
   - メニューシートの表示確認
   - ログアウト確認ダイアログの表示確認
   - ログアウト後のログイン画面遷移確認
