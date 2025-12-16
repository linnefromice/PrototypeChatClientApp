# Proposal: Integrate Create Conversation Screen

**Change ID:** `integrate-create-conversation-screen`
**Status:** Proposal
**Created:** 2025-12-15

## Overview

チャット作成画面（`CreateConversationView`）を会話一覧画面（`ConversationListView`）に統合し、ユーザーが実際にチャットを作成できるようにします。現在、`ConversationListView`の「+」ボタンは実装されていますが、プレースホルダーテキスト（"チャット作成画面（未実装）"）のみが表示されます。

### Current Behavior

- `ConversationListView`に「+」ボタンが存在
- ボタンをタップすると、"チャット作成画面（未実装）"というテキストのみ表示される（ConversationListView.swift:44-45）
- `CreateConversationView`は既に完全に実装済みだが、どこからも使用されていない
- ユーザー一覧取得とチャット作成のAPI連携は完了済み（UserRepository、ConversationRepositoryが使用中）

### Desired Behavior

- 「+」ボタンをタップすると、`CreateConversationView`がシート表示される
- ユーザーは他のユーザー一覧から選択して1:1チャットを作成できる
- チャット作成成功後、会話一覧が自動的に更新される
- 新しく作成された会話が会話一覧の最上位に表示される

## Why

`CreateConversationView`とその関連コンポーネント（ViewModel、UseCase、Repository）は既に実装済みで、APIも正常に動作しています。しかし、UIとして接続されていないため、ユーザーはこの機能を使用できません。プレースホルダーを実際の画面に置き換えるだけで、チャット作成機能が完全に動作します。

## Motivation

- チャット作成機能の完成部品が全て揃っているが、UI統合のみが欠けている
- `CreateConversationView`、`CreateConversationViewModel`、`UserListUseCase`は全て実装済み
- UserRepositoryとConversationRepositoryは既にOpenAPI経由でバックエンドAPIに接続済み
- 最小限の変更（1ファイルの数行修正）で機能を完全に有効化できる

## Scope

### In Scope

- `ConversationListView`の`.sheet`を`CreateConversationView`に接続
- `CreateConversationViewModel`の初期化とDependencyContainerからの注入
- チャット作成成功後の会話一覧リフレッシュ処理
- エラーハンドリング（既存のViewModelロジックを活用）

### Out of Scope

- `CreateConversationView`の実装（既に完了）
- APIレイヤーの実装（既に完了）
- グループチャット作成UI（将来の拡張）
- チャット詳細画面の実装（別のタスク）
- ユーザー検索・フィルタリング機能

## Dependencies

### Existing Components

- ✅ `CreateConversationView` - 実装済み
- ✅ `CreateConversationViewModel` - 実装済み
- ✅ `UserListUseCase.fetchAvailableUsers()` - 実装済み
- ✅ `ConversationUseCase.createDirectConversation()` - 実装済み
- ✅ `UserRepository.fetchUsers()` - OpenAPI経由で実装済み
- ✅ `ConversationRepository.createConversation()` - OpenAPI経由で実装済み
- ✅ `DependencyContainer` - 全てのUseCaseとRepositoryを提供済み

### No Breaking Changes

- 既存のインターフェースは変更なし
- 既存の画面レイアウトは維持
- 新しいプロトコルやエンティティの追加なし

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|-----------|
| DependencyContainerからの依存性注入エラー | Medium | `DependencyContainer.shared`が既に全ての依存性を提供済み。既存のMainViewの実装パターンを参考に実装 |
| チャット作成後の一覧更新タイミング | Low | `onConversationCreated`コールバックで`loadConversations()`を呼び出し、即座にリフレッシュ |
| 同時に複数のシートが開かれる可能性 | Low | SwiftUIの`.sheet`は同時に1つのみ表示されるため、問題なし |

## Success Criteria

1. 会話一覧画面の「+」ボタンをタップすると、`CreateConversationView`がシート表示される
2. ユーザー一覧が正しく表示され、選択できる
3. ユーザーを選択して「作成」ボタンをタップすると、チャットが作成される
4. チャット作成成功後、シートが閉じられ、会話一覧が更新される
5. 新しく作成されたチャットが一覧の最上位に表示される
6. エラー発生時は適切なエラーメッセージが表示される
7. 既存のテストが全てpassする

## Related Changes

- Depends on: `implement-chat-creation-user-list` (完了済み)
- Blocks: チャット詳細画面の実装（将来）

## Alternatives Considered

### Alternative 1: ConversationListViewModelにチャット作成ロジックを追加

**Pros:**
- ViewModelが1つだけで済む
- 依存性注入が簡素化される

**Cons:**
- Single Responsibility Principleに反する
- `ConversationListViewModel`が肥大化する
- 再利用性が低下（他の画面からチャット作成できない）
- 既に完成している`CreateConversationViewModel`が無駄になる

**Decision:** 既存の`CreateConversationView`と`CreateConversationViewModel`を活用し、責務を分離

### Alternative 2: NavigationLinkで画面遷移

**Pros:**
- 戻るボタンで一覧に戻れる

**Cons:**
- モーダルな操作（チャット作成）には適さない
- iOS標準のチャットアプリ（Messages）はシート表示を使用
- 既に`.sheet`が準備されている

**Decision:** シート表示を維持（iOS標準パターンに準拠）

## Implementation Notes

### 変更箇所

**File:** `PrototypeChatClientApp/Features/Chat/Presentation/Views/ConversationListView.swift`

**Line 43-46の変更:**

```swift
// Before:
.sheet(isPresented: $showCreateConversation) {
    // チャット作成画面は後で実装
    Text("チャット作成画面（未実装）")
}

// After:
.sheet(isPresented: $showCreateConversation) {
    CreateConversationView(
        viewModel: makeCreateConversationViewModel(),
        onConversationCreated: { _ in
            Task {
                await viewModel.loadConversations()
            }
        }
    )
}
```

**新規メソッド追加:**

```swift
private func makeCreateConversationViewModel() -> CreateConversationViewModel {
    let container = DependencyContainer.shared
    return CreateConversationViewModel(
        conversationUseCase: container.conversationUseCase,
        userListUseCase: container.userListUseCase,
        currentUserId: viewModel.currentUserId
    )
}
```

### 依存性注入パターン

- `DependencyContainer.shared`を使用（MainViewと同じパターン）
- `ConversationListViewModel`に`currentUserId`プロパティを追加（既存のプロパティを活用）
- LazyなViewModel生成で不要な初期化を回避

### テスト戦略

1. **Unit Test:** `ConversationListViewModel`のリフレッシュロジック
2. **Integration Test:** チャット作成→一覧更新のフロー
3. **Manual Test:** シミュレータでの動作確認
   - user-1でログイン
   - 「+」ボタンをタップ
   - user-2を選択
   - チャット作成
   - 一覧に表示されることを確認
