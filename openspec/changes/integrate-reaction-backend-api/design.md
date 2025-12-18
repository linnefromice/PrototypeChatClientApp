# Design: Integrate Reaction Backend API

**Change ID:** `integrate-reaction-backend-api`
**Status:** Proposal
**Created:** 2025-12-17

## Architecture Overview

この変更は、リアクション機能をモック実装からバックエンドAPI接続に切り替え、「1人は1メッセージに一度だけリアクション可能」というビジネスルールをクライアント側で実装します。Clean Architectureの原則に従い、Domain層にビジネスロジックを追加し、Infrastructure層のリポジトリを実際の実装に切り替えます。

## Design Decisions

### 1. Repository Selection Strategy

**Decision:** `DependencyContainer`で条件付きでリポジトリを選択

**Current Implementation:**
```swift
// DependencyContainer.swift
self.reactionRepository = ReactionRepository(client: client)

// makePreviewContainer()では
let mockReactionRepository = MockReactionRepository()
```

**Rationale:**
- 本番環境では`ReactionRepository`（バックエンドAPI）を使用
- プレビューとテストでは`MockReactionRepository`を使用
- 環境変数や設定による切り替えは不要（シンプル）

**Alternatives Considered:**
- Feature Flag による切り替え → 過剰設計
- 環境変数による切り替え → 不要な複雑さ

### 2. "One Reaction Per Message" Business Rule Implementation

**Decision:** `ReactionUseCase`に`replaceReaction`メソッドを追加

**Implementation Strategy:**
```swift
func replaceReaction(
    messageId: String,
    userId: String,
    oldEmoji: String?,
    newEmoji: String
) async throws -> Reaction {
    // 1. 既存のリアクションがあれば削除
    if let oldEmoji = oldEmoji {
        try await removeReaction(
            messageId: messageId,
            userId: userId,
            emoji: oldEmoji
        )
    }

    // 2. 新しいリアクションを追加
    return try await addReaction(
        messageId: messageId,
        userId: userId,
        emoji: newEmoji
    )
}
```

**Rationale:**
- ビジネスロジックはDomain層（UseCase）に配置
- ViewModelは薄く保つ
- エラーハンドリングを一箇所に集約
- テストが容易

**Error Handling Strategy:**
- 削除失敗 → 例外をスロー、処理を中断
- 削除成功 + 追加失敗 → 例外をスロー（削除は復元しない）
- 理由：サーバー状態との一貫性を優先

**Alternatives Considered:**
- ViewModel内で削除→追加を実行 → ビジネスロジックがPresentation層に漏れる
- サーバー側で制御 → サーバー変更が必要、レスポンスが遅い
- トランザクション処理（ロールバック） → 複雑すぎる、必要性低い

### 3. Reaction Loading Strategy

**Decision:** メッセージ読み込み時に並列でリアクションを取得

**Implementation:**
```swift
func loadMessages() async {
    // 1. メッセージを取得
    messages = try await messageUseCase.fetchMessages(...)

    // 2. 各メッセージのリアクションを並列取得
    await withTaskGroup(of: (String, [Reaction]?).self) { group in
        for message in messages {
            group.addTask {
                do {
                    let reactions = try await self.reactionUseCase.fetchReactions(
                        messageId: message.id
                    )
                    return (message.id, reactions)
                } catch {
                    print("Failed to fetch reactions for \(message.id)")
                    return (message.id, nil)
                }
            }
        }

        for await (messageId, reactions) in group {
            if let reactions = reactions {
                self.messageReactions[messageId] = reactions
            }
        }
    }
}
```

**Rationale:**
- 並列実行でパフォーマンス向上
- 個別のリアクション取得失敗がメッセージ表示をブロックしない
- `TaskGroup`を使用して構造化された並行処理

**Alternatives Considered:**
- 順次取得 → 遅い、UXが悪い
- バックエンドで一括取得API → サーバー変更が必要
- 遅延読み込み（表示時） → 複雑、チラつきが発生

### 4. Optimistic UI Update Strategy

**Decision:** 部分的な楽観的UI（成功ケースのみ）

**Strategy:**
- リアクション追加: UIを即座に更新 → API失敗時はロールバック
- リアクション削除: UIを即座に更新 → API失敗時はロールバック
- リアクション置換: API完了後にUI更新（原子性を保証）

**Rationale:**
- シンプルなケース（追加/削除）は楽観的UI で高速なフィードバック
- 複雑なケース（置換）は慎重に処理して一貫性を保証
- エラー時のロールバックは実装が複雑なため、ユーザーに再試行を促す

**Alternatives Considered:**
- 完全な楽観的UI → エラー処理が複雑、一貫性の問題
- 楽観的UIなし → UXが悪い、ネットワーク遅延が目立つ

### 5. Error Handling and User Feedback

**Decision:** 段階的なエラーハンドリング

**Error Categories:**

1. **Network Errors** (一時的)
   - エラーメッセージ: "ネットワークエラーが発生しました。もう一度お試しください。"
   - UI: トーストまたはアラート
   - Action: ユーザーが手動で再試行

2. **Server Errors** (4xx/5xx)
   - エラーメッセージ: "リアクションの処理に失敗しました。"
   - UI: トーストまたはアラート
   - Action: ログ記録、ユーザーが手動で再試行

3. **Validation Errors** (クライアント側)
   - エラーメッセージ: なし（発生しないはず）
   - Action: 防御的プログラミング

**User Feedback:**
- `@Published var errorMessage: String?`
- `@Published var showError: Bool`
- SwiftUIの`.alert()`または`.toast()`

**Rationale:**
- ユーザーに明確なフィードバック
- 自動リトライは実装しない（ユーザーが制御）
- エラーログは開発者向け（デバッグ用）

## Component Design

### ReactionUseCase (Modified)

**New Method:**
```swift
func replaceReaction(
    messageId: String,
    userId: String,
    oldEmoji: String?,
    newEmoji: String
) async throws -> Reaction
```

**Responsibilities:**
- 既存リアクションの削除
- 新しいリアクションの追加
- エラーハンドリング
- トランザクション的な処理（ベストエフォート）

### ChatRoomViewModel (Modified)

**Updated Method:**
```swift
func toggleReaction(on messageId: String, emoji: String) async {
    // 1. ユーザーの既存リアクションを探す
    let existingReaction = messageReactions[messageId]?.first {
        $0.userId == currentUserId
    }

    // 2. 同じ絵文字 → 削除（トグル）
    if existingReaction?.emoji == emoji {
        await removeReaction(from: messageId, emoji: emoji)
        return
    }

    // 3. 異なる絵文字 or なし → 置換または追加
    do {
        let reaction = try await reactionUseCase.replaceReaction(
            messageId: messageId,
            userId: currentUserId,
            oldEmoji: existingReaction?.emoji,
            newEmoji: emoji
        )

        // Update local state
        if let oldEmoji = existingReaction?.emoji {
            messageReactions[messageId]?.removeAll {
                $0.userId == currentUserId && $0.emoji == oldEmoji
            }
        }
        messageReactions[messageId, default: []].append(reaction)
    } catch {
        errorMessage = "リアクションを変更できませんでした: \(error.localizedDescription)"
        showError = true
    }
}
```

**Updated Method:**
```swift
func loadMessages() async {
    // ... existing message loading code ...

    // Load reactions for all messages
    await loadReactionsForMessages()
}

private func loadReactionsForMessages() async {
    await withTaskGroup(of: (String, [Reaction]?).self) { group in
        for message in messages {
            group.addTask {
                do {
                    let reactions = try await self.reactionUseCase.fetchReactions(
                        messageId: message.id
                    )
                    return (message.id, reactions)
                } catch {
                    print("❌ Failed to fetch reactions for message \(message.id): \(error)")
                    return (message.id, nil)
                }
            }
        }

        for await (messageId, reactions) in group {
            if let reactions = reactions {
                self.messageReactions[messageId] = reactions
            }
        }
    }
}
```

### DependencyContainer (Modified)

**Changes:**
```swift
// Production
init(...) {
    // ...
    self.reactionRepository = ReactionRepository(client: client)
    // ...
}

// Preview/Test
static func makePreviewContainer() -> DependencyContainer {
    let mockReactionRepo = MockReactionRepository()
    return DependencyContainer(
        // ...
        reactionRepository: mockReactionRepo,
        // ...
    )
}
```

## Data Flow

### Scenario 1: メッセージ読み込み時

```
ChatRoomView.onAppear
    ↓
ChatRoomViewModel.loadMessages()
    ↓
MessageUseCase.fetchMessages() → [Message]
    ↓
ChatRoomViewModel.loadReactionsForMessages()
    ↓
TaskGroup (並列)
    ├─ ReactionUseCase.fetchReactions(msg1) → [Reaction]
    ├─ ReactionUseCase.fetchReactions(msg2) → [Reaction]
    └─ ReactionUseCase.fetchReactions(msg3) → [Reaction]
    ↓
messageReactions[msgId] = reactions
    ↓
UI更新 (@Published)
```

### Scenario 2: リアクション追加（新規）

```
User taps emoji (no existing reaction)
    ↓
ChatRoomViewModel.toggleReaction(msgId, emoji)
    ↓
Check: existingReaction? → None
    ↓
ReactionUseCase.replaceReaction(msgId, userId, nil, emoji)
    ↓
ReactionUseCase.addReaction() → Reaction
    ↓
ReactionRepository.addReaction()
    ↓
POST /messages/{id}/reactions → 201 Created
    ↓
Update messageReactions[msgId]
    ↓
UI更新 (@Published)
```

### Scenario 3: リアクション置換（別の絵文字）

```
User taps emoji (existing reaction with different emoji)
    ↓
ChatRoomViewModel.toggleReaction(msgId, newEmoji)
    ↓
Check: existingReaction? → Yes, oldEmoji ≠ newEmoji
    ↓
ReactionUseCase.replaceReaction(msgId, userId, oldEmoji, newEmoji)
    ↓
Step 1: ReactionUseCase.removeReaction(oldEmoji)
    ↓
ReactionRepository.removeReaction()
    ↓
DELETE /messages/{id}/reactions/{oldEmoji}?userId={userId} → 200 OK
    ↓
Step 2: ReactionUseCase.addReaction(newEmoji) → Reaction
    ↓
ReactionRepository.addReaction()
    ↓
POST /messages/{id}/reactions → 201 Created
    ↓
Update messageReactions[msgId] (remove old, add new)
    ↓
UI更新 (@Published)
```

### Scenario 4: リアクション削除（トグル）

```
User taps same emoji again
    ↓
ChatRoomViewModel.toggleReaction(msgId, emoji)
    ↓
Check: existingReaction? → Yes, oldEmoji == emoji
    ↓
ChatRoomViewModel.removeReaction(msgId, emoji)
    ↓
ReactionUseCase.removeReaction()
    ↓
ReactionRepository.removeReaction()
    ↓
DELETE /messages/{id}/reactions/{emoji}?userId={userId} → 200 OK
    ↓
Remove from messageReactions[msgId]
    ↓
UI更新 (@Published)
```

## Testing Strategy

### Unit Tests

**ReactionUseCaseTests:**
```swift
func testReplaceReaction_WithNoExistingReaction() async throws
func testReplaceReaction_WithExistingReaction() async throws
func testReplaceReaction_DeleteFailure() async throws
func testReplaceReaction_AddFailureAfterDelete() async throws
```

**ChatRoomViewModelTests:**
```swift
func testToggleReaction_AddNew() async throws
func testToggleReaction_Remove() async throws
func testToggleReaction_Replace() async throws
func testLoadMessages_WithReactions() async throws
```

### Integration Tests

**ReactionRepositoryTests:**
```swift
func testFetchReactions_Success() async throws
func testAddReaction_Success() async throws
func testRemoveReaction_Success() async throws
func testNetworkError_Handling() async throws
```

### Manual Tests

1. メッセージ読み込み時にリアクションが表示される
2. 新しいリアクションを追加できる
3. 既存のリアクションをタップして削除できる
4. 別の絵文字に変更できる（既存が削除され、新しいものが追加）
5. ネットワークエラー時にエラーメッセージが表示される
6. 複数ユーザーのリアクションが正しく表示される

## Performance Considerations

### Optimization Strategies

1. **並列リアクション取得**
   - `TaskGroup`を使用して複数メッセージのリアクションを同時取得
   - 個別の失敗が全体をブロックしない

2. **ローカルキャッシュ**
   - `messageReactions`辞書でリアクションをキャッシュ
   - 画面遷移時にリロードしない（既存データを保持）

3. **リクエスト最適化**
   - 不要なリクエストを避ける
   - 同じメッセージのリアクションを重複取得しない

### Performance Metrics

- メッセージ読み込み時間: +500ms以内（50メッセージの場合）
- リアクション追加レスポンス: 500ms以内
- リアクション置換レスポンス: 1000ms以内（DELETE + POST）

## Security Considerations

- **認証:** すべてのAPIリクエストで`userId`を送信
- **認可:** サーバー側で権限チェック（自分のリアクションのみ削除可能）
- **バリデーション:** クライアント側とサーバー側の両方で検証
- **データ整合性:** サーバーが信頼できる情報源（Single Source of Truth）

## Migration and Rollback

### Migration Steps

1. コード変更をデプロイ
2. バックエンドAPIが稼働していることを確認
3. シミュレータでテスト
4. 段階的にユーザーに展開

### Rollback Plan

簡単にロールバック可能:
```swift
// DependencyContainer.swiftで一行変更
self.reactionRepository = MockReactionRepository() // ← これだけ
```

### Monitoring

- API エラー率をモニタリング
- ユーザーフィードバック（エラー報告）
- パフォーマンスメトリクス

## Future Enhancements

1. **リアルタイム更新**
   - WebSocketまたはPollingで他ユーザーのリアクションを自動更新

2. **楽観的UI の改善**
   - リアクション置換時も即座にUI更新
   - エラー時の自動ロールバック

3. **リアクションアニメーション**
   - リアクション追加時のアニメーション効果

4. **カスタム絵文字**
   - ユーザー定義の絵文字サポート

5. **リアクション通知**
   - 自分のメッセージにリアクションがついた時の通知
