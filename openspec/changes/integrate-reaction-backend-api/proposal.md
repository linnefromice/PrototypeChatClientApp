# Proposal: Integrate Reaction Backend API

**Change ID:** `integrate-reaction-backend-api`
**Status:** Proposal
**Created:** 2025-12-17

## Overview

リアクション機能のバックエンドAPIが実装されたため、クライアント側をモックからバックエンドAPI接続に切り替えます。同時に、「1人は1メッセージに一度だけリアクション可能」というビジネスルールをクライアント側で適切に処理します。

### Current Behavior

- `ReactionRepository`はバックエンドAPI呼び出しを実装済み（GET, POST, DELETE）
- `DependencyContainer`では`MockReactionRepository`を使用
- `ChatRoomViewModel.toggleReaction`は単純なトグルロジック
- リアクションデータは`messageReactions`に保存されるが、メッセージ読み込み時にリアクションを取得していない

### Desired Behavior

- `DependencyContainer`で実際の`ReactionRepository`を使用
- メッセージ読み込み時に各メッセージのリアクションを取得
- ユーザーが既に同じメッセージに別の絵文字でリアクションしている場合、既存のリアクションを削除してから新しいリアクションを追加
- `toggleReaction`メソッドを拡張して「1メッセージ1リアクション」ルールを実装

## Why

バックエンドAPIが実装され、実際のデータ永続化が可能になったため、モックから本番実装に移行する必要があります。また、ビジネスルールに基づいて、1人のユーザーが同じメッセージに複数の異なる絵文字でリアクションできないように制御する必要があります。

## Motivation

- バックエンドAPIとの統合により、複数デバイス間でのリアクション同期が可能に
- 「1メッセージ1リアクション」ルールにより、UI/UX がシンプルで直感的に
- サーバー側でデータが永続化され、アプリ再起動後もリアクションが保持される

## Scope

### In Scope

- `DependencyContainer`で`ReactionRepository`（実装）を使用するように切り替え
- `ChatRoomViewModel.loadMessages`でメッセージ読み込み時にリアクションも取得
- `ReactionUseCase`に「既存リアクション置換」ロジックを追加
- `ChatRoomViewModel`の`toggleReaction`を更新して新しいロジックを使用
- エラーハンドリングとユーザーフィードバック

### Out of Scope

- リアクションのリアルタイム更新（WebSocket/Polling）
- リアクションアニメーション
- カスタム絵文字
- リアクション通知機能

## Dependencies

### Existing Components

- ✅ `ReactionRepository` - バックエンドAPI実装済み
- ✅ OpenAPI仕様 - GET/POST/DELETEエンドポイント定義済み
- ✅ `ReactionUseCase` - 基本的なCRUD操作実装済み
- ✅ `ChatRoomViewModel` - リアクション管理機能実装済み
- ✅ `ReactionSummaryView` - リアクション表示UI実装済み

### Breaking Changes

なし（内部実装の変更のみ）

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|-----------|
| ネットワークエラーによるリアクション失敗 | Medium | エラーメッセージ表示、楽観的UI更新の実装 |
| 複数リクエストの競合 | Low | 順次処理、適切なエラーハンドリング |
| リアクション削除→追加の原子性 | Medium | エラー時のロールバック処理 |
| APIレスポンスの遅延 | Low | ローディングインジケータ、楽観的UI |

## Success Criteria

1. `DependencyContainer`で実際の`ReactionRepository`が使用される
2. メッセージ読み込み時にリアクションも一緒に取得される
3. ユーザーが既にリアクションしている場合、新しい絵文字を選択すると既存が削除され新しいものが追加される
4. 同じ絵文字を再度タップすると、リアクションが削除される（トグル動作）
5. ネットワークエラーが適切に処理され、ユーザーにフィードバックされる
6. 既存のリアクションUIが正常に動作する

## Related Changes

- Depends on: OpenAPI仕様の更新（完了済み）
- Relates to: `implement-message-reactions`, `implement-minimal-reaction-ui`
- Blocks: None

## Alternatives Considered

### Alternative 1: サーバー側で「1メッセージ1リアクション」を強制

**Pros:**
- クライアント側のロジックがシンプル
- すべてのクライアントで一貫した動作

**Cons:**
- サーバー側の変更が必要
- レスポンスタイムが長くなる可能性

**Decision:** クライアント側で処理（サーバー変更不要、即座にUI反映）

### Alternative 2: ユーザーが複数の絵文字でリアクション可能

**Pros:**
- より柔軟なリアクション
- Slack/Discordと同様の動作

**Cons:**
- UIが複雑になる
- ビジネス要件と異なる

**Decision:** 「1メッセージ1リアクション」ルールを遵守

### Alternative 3: 楽観的UI更新なし

**Pros:**
- 実装がシンプル
- サーバーの状態と完全に同期

**Cons:**
- UXが悪い（レスポンスが遅い）
- ネットワーク遅延が目立つ

**Decision:** 楽観的UI更新を部分的に実装（成功ケースのみ）

## Implementation Notes

### 変更箇所

**File 1:** `App/DependencyContainer.swift`

**変更内容:**
- `reactionRepository`の初期化を`MockReactionRepository`から`ReactionRepository`に変更
- プレビュー用コンテナのみ`MockReactionRepository`を使用

**File 2:** `Features/Chat/Domain/UseCases/ReactionUseCase.swift`

**新規メソッド:**
```swift
func replaceReaction(
    messageId: String,
    userId: String,
    oldEmoji: String?,
    newEmoji: String
) async throws -> Reaction
```

このメソッドは：
1. `oldEmoji`が存在する場合、既存のリアクションを削除
2. 新しいリアクションを追加
3. エラー時は適切に処理

**File 3:** `Features/Chat/Presentation/ViewModels/ChatRoomViewModel.swift`

**変更内容:**
1. `loadMessages`メソッドを更新してリアクションも取得
2. `toggleReaction`メソッドを更新して「1メッセージ1リアクション」ルールを実装
3. エラーハンドリングの改善

### データフロー

```
User taps emoji
    ↓
ChatRoomViewModel.toggleReaction()
    ↓
Check: ユーザーの既存リアクション?
    ├─ Yes, same emoji → removeReaction()
    ├─ Yes, different emoji → replaceReaction(old, new)
    └─ No → addReaction()
    ↓
ReactionUseCase
    ↓
ReactionRepository (Backend API)
    ↓
Update local state (messageReactions)
    ↓
UI updates via @Published
```

### テスト戦略

1. **Unit Test:**
   - `ReactionUseCase.replaceReaction`のロジックテスト
   - 削除失敗時のエラーハンドリング
   - 追加失敗時のエラーハンドリング

2. **Integration Test:**
   - バックエンドAPIとの接続テスト
   - ネットワークエラーハンドリング

3. **Manual Test:**
   - メッセージ読み込み時のリアクション表示
   - リアクション追加/削除/置換の動作
   - 複数ユーザーのリアクション表示
   - ネットワークエラー時の動作

### エラーハンドリング

**シナリオ1: リアクション削除失敗**
- エラーメッセージ表示
- 既存のリアクションを保持（UIは変更しない）

**シナリオ2: リアクション追加失敗（削除成功後）**
- エラーメッセージ表示
- 削除されたリアクションは復元しない（サーバー状態と同期）
- ユーザーに再試行を促す

**シナリオ3: ネットワーク接続なし**
- エラーメッセージ表示
- ローカル状態は変更しない

### パフォーマンス考慮事項

- リアクション取得は並列実行（複数メッセージ）
- 失敗したリクエストはリトライしない（ユーザーが手動で再試行）
- ローカルキャッシュ（`messageReactions`）を活用

## Migration Plan

段階的な移行は不要（内部実装の変更のみ）:

1. コード変更を適用
2. ビルド・テスト
3. バックエンドAPIが稼働していることを確認
4. シミュレータでテスト
5. 問題なければリリース

ロールバックも容易：
- `DependencyContainer`の設定を`MockReactionRepository`に戻すのみ
