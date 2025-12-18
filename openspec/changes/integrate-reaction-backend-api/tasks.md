# Tasks: Integrate Reaction Backend API

**Change ID:** `integrate-reaction-backend-api`
**Status:** Proposal
**Created:** 2025-12-17

## Implementation Tasks

### Task 1: Add replaceReaction method to ReactionUseCase

**Description:**
`ReactionUseCase`に`replaceReaction`メソッドを追加し、既存リアクションの削除と新しいリアクションの追加を適切に処理する。

**Files to Modify:**
- `PrototypeChatClientApp/Features/Chat/Domain/UseCases/ReactionUseCase.swift`

**Implementation Details:**
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

**Validation:**
- メソッドがコンパイルエラーなく追加される
- 削除→追加の順序が正しい
- エラーハンドリングが適切

**Dependencies:** None

---

### Task 2: Update ChatRoomViewModel to use real repository and load reactions

**Description:**
`ChatRoomViewModel`を更新して、メッセージ読み込み時にリアクションも取得し、「1メッセージ1リアクション」ルールを実装する。

**Files to Modify:**
- `PrototypeChatClientApp/Features/Chat/Presentation/ViewModels/ChatRoomViewModel.swift`

**Implementation Details:**

1. `loadMessages`メソッドを更新:
```swift
func loadMessages() async {
    isLoading = true
    // ... existing message loading code ...

    // Load reactions for all messages
    await loadReactionsForMessages()

    isLoading = false
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

2. `toggleReaction`メソッドを更新:
```swift
func toggleReaction(on messageId: String, emoji: String) async {
    // Find user's existing reaction on this message
    let existingReaction = messageReactions[messageId]?.first {
        $0.userId == currentUserId
    }

    // Same emoji → remove (toggle off)
    if existingReaction?.emoji == emoji {
        await removeReaction(from: messageId, emoji: emoji)
        return
    }

    // Different emoji or no reaction → replace or add
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

**Validation:**
- コンパイルエラーなし
- 並列リアクション取得が正しく動作
- トグルロジックが正しく実装される
- エラーハンドリングが適切

**Dependencies:** Task 1

---

### Task 3: Update DependencyContainer to use real ReactionRepository

**Description:**
`DependencyContainer`を更新して、本番環境では`ReactionRepository`を使用し、プレビュー/テスト環境では`MockReactionRepository`を使用する。

**Files to Modify:**
- `PrototypeChatClientApp/App/DependencyContainer.swift`

**Implementation Details:**

本番環境の初期化（既存のコード確認）:
```swift
init(...) {
    // ...
    self.reactionRepository = ReactionRepository(client: client)
    // ...
}
```

プレビュー環境（既存のコード確認）:
```swift
static func makePreviewContainer(
    // ...
    reactionRepository: ReactionRepositoryProtocol? = nil,
    // ...
) -> DependencyContainer {
    let mockReactionRepo = reactionRepository ?? MockReactionRepository()

    return DependencyContainer(
        // ...
        reactionRepository: mockReactionRepo,
        // ...
    )
}
```

**Validation:**
- 本番環境で`ReactionRepository`が使用される
- プレビュー環境で`MockReactionRepository`が使用される
- ビルドエラーなし

**Dependencies:** None

---

### Task 4: Build and verify implementation

**Description:**
プロジェクトをビルドし、コンパイルエラーや警告がないことを確認する。

**Commands:**
```bash
make clean
make build
```

**Validation:**
- ビルドが成功する
- コンパイルエラーがない
- 警告が出ない

**Dependencies:** Task 1, Task 2, Task 3

---

### Task 5: Add unit tests for replaceReaction

**Description:**
`ReactionUseCase.replaceReaction`メソッドのユニットテストを追加する。

**Files to Create/Modify:**
- `PrototypeChatClientAppTests/Features/Chat/Domain/UseCases/ReactionUseCaseTests.swift`

**Test Cases:**
```swift
func testReplaceReaction_WithNoExistingReaction() async throws {
    // oldEmoji = nil の場合、addReaction のみ呼ばれる
}

func testReplaceReaction_WithExistingReaction() async throws {
    // oldEmoji がある場合、removeReaction → addReaction が順に呼ばれる
}

func testReplaceReaction_DeleteFailure() async throws {
    // removeReaction が失敗した場合、addReaction は呼ばれない
}

func testReplaceReaction_AddFailureAfterDelete() async throws {
    // removeReaction 成功後、addReaction が失敗した場合のエラー処理
}
```

**Validation:**
- 全てのテストがpassする
- エッジケースがカバーされる
- モックを使用して外部依存を排除

**Dependencies:** Task 1, Task 4

---

### Task 6: Manual testing on simulator - Basic reaction operations

**Description:**
シミュレータで基本的なリアクション操作をテストする。

**Test Steps:**
1. シミュレータを起動（`make run`）
2. テストユーザーでログイン（user-1 / Alice）
3. 既存の会話を開く
4. メッセージ読み込み時にリアクションが表示されることを確認
5. 新しいリアクションを追加
6. 同じリアクションをタップして削除（トグル）
7. 別の絵文字に変更
8. 他のユーザーのリアクションが表示されることを確認

**Test Cases:**
- **Case 1:** 新規リアクション追加
  - Expected: リアクションが即座に表示され、バックエンドに保存される
- **Case 2:** リアクション削除（トグル）
  - Expected: リアクションが消え、バックエンドから削除される
- **Case 3:** リアクション置換
  - Expected: 古いリアクションが消え、新しいリアクションが表示される

**Validation:**
- 全てのテストケースがpassする
- UIが期待通りに動作する
- ネットワークリクエストが正しく送信される（ログ確認）

**Dependencies:** Task 4

---

### Task 7: Manual testing on simulator - Error scenarios

**Description:**
シミュレータでエラーシナリオをテストする。

**Test Steps:**
1. バックエンドAPIを停止する（または無効なURLに変更）
2. リアクションを追加しようとする
3. エラーメッセージが表示されることを確認
4. バックエンドAPIを再起動
5. リアクションを追加しようとする
6. 正常に動作することを確認

**Test Cases:**
- **Case 1:** ネットワークエラー
  - Expected: エラーメッセージ表示、UI変更なし
- **Case 2:** タイムアウト
  - Expected: エラーメッセージ表示、ローディングインジケータ終了

**Validation:**
- エラーメッセージが適切に表示される
- アプリがクラッシュしない
- ユーザーが再試行できる

**Dependencies:** Task 6

---

### Task 8: Test with multiple users

**Description:**
複数のユーザーでリアクション機能をテストする。

**Test Steps:**
1. user-1 (Alice)でログインし、メッセージにリアクション
2. ログアウト
3. user-2 (Bob)でログインし、同じメッセージを開く
4. Aliceのリアクションが表示されることを確認
5. Bobも同じメッセージにリアクション
6. 両方のリアクションが表示されることを確認
7. Aliceに戻り、リアクションを変更
8. Bobに戻り、Aliceのリアクションが変更されていることを確認（リロード後）

**Validation:**
- 複数ユーザーのリアクションが正しく表示される
- リアクション置換が正しく動作する
- リアクションサマリーが正しく計算される

**Dependencies:** Task 7

---

### Task 9: Run existing tests

**Description:**
既存のテストが全てpassすることを確認する。

**Commands:**
```bash
make test
```

**Validation:**
- 全てのテストがpassする
- 既存機能が壊れていない
- リグレッションなし

**Dependencies:** Task 5

---

### Task 10: Performance testing

**Description:**
リアクション読み込みのパフォーマンスをテストする。

**Test Steps:**
1. 50件以上のメッセージがある会話を開く
2. メッセージとリアクションの読み込み時間を測定
3. 並列リアクション取得が正しく動作することを確認

**Validation:**
- メッセージ読み込み時間が許容範囲内（+500ms以内）
- 並列リクエストが正しく実行される
- UIがブロックされない

**Dependencies:** Task 8

---

## Task Summary

| Task | Type | Complexity | Dependencies |
|------|------|------------|--------------|
| 1. Add replaceReaction to UseCase | Development | Medium | None |
| 2. Update ChatRoomViewModel | Development | High | Task 1 |
| 3. Update DependencyContainer | Development | Low | None |
| 4. Build and verify | Validation | Low | Task 1, 2, 3 |
| 5. Add unit tests | Testing | Medium | Task 1, 4 |
| 6. Manual testing - Basic | Validation | Medium | Task 4 |
| 7. Manual testing - Errors | Validation | Low | Task 6 |
| 8. Test with multiple users | Validation | Low | Task 7 |
| 9. Run existing tests | Validation | Low | Task 5 |
| 10. Performance testing | Validation | Low | Task 8 |

**Total Estimated Time:** 4-6 hours

## Parallelization Opportunities

- Task 1, 3 can be done in parallel
- Task 6, 7, 8 can be done sequentially (manual testing flow)
- Task 5, 9 can be done in parallel after Task 4

## Rollback Plan

この変更は簡単にロールバック可能：

1. `DependencyContainer.swift`で`ReactionRepository`を`MockReactionRepository`に戻す
2. `ReactionUseCase.swift`の`replaceReaction`メソッドを削除（または未使用のまま残す）
3. `ChatRoomViewModel.swift`の変更を元に戻す
4. `make clean && make build`でビルドを確認

## Success Metrics

- [x] Task 1: `replaceReaction`メソッド追加
- [x] Task 2: `ChatRoomViewModel`更新
- [x] Task 3: `DependencyContainer`更新（既に正しく設定済み）
- [x] Task 4: ビルド成功
- [x] Task 5: ユニットテスト追加
- [ ] Task 6: 基本的なリアクション操作テスト
- [ ] Task 7: エラーシナリオテスト
- [ ] Task 8: 複数ユーザーテスト
- [ ] Task 9: 既存テストがpass
- [ ] Task 10: パフォーマンステスト
