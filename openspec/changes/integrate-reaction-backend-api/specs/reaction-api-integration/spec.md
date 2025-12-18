# Spec: Reaction API Integration

**Capability:** `reaction-api-integration`
**Status:** Proposed
**Created:** 2025-12-17

## Overview

リアクション機能をモック実装からバックエンドAPI接続に切り替え、「1人は1メッセージに一度だけリアクション可能」というビジネスルールをクライアント側で実装します。

## MODIFIED Requirements

### Requirement: REQ-REACT-001 - Backend API Integration

リアクション機能はバックエンドAPIに接続し、実際のデータ永続化を行わなければならない(MUST)。システムは、モック実装ではなく実際の`ReactionRepository`を使用してバックエンドAPIを呼び出さなければならない(MUST)。

#### Scenario: Application uses real ReactionRepository

**Given:**
- アプリケーションが起動する
- `DependencyContainer`が初期化される

**When:**
- 本番環境でアプリケーションを実行

**Then:**
- `DependencyContainer.reactionRepository`は`ReactionRepository`インスタンスである
- `MockReactionRepository`は使用されない
- すべてのリアクション操作はバックエンドAPIを呼び出す

#### Scenario: Preview mode uses MockReactionRepository

**Given:**
- Xcodeプレビューまたはテスト環境

**When:**
- `DependencyContainer.makePreviewContainer()`が呼び出される

**Then:**
- `reactionRepository`は`MockReactionRepository`インスタンスである
- バックエンドAPIは呼び出されない

### Requirement: REQ-REACT-002 - Load Reactions with Messages

メッセージ読み込み時に、各メッセージに関連するリアクションも取得しなければならない(MUST)。システムは、リアクションの取得失敗がメッセージ表示をブロックしないようにしなければならない(MUST)。

#### Scenario: Load messages with reactions successfully

**Given:**
- ユーザーがチャットルーム画面を開く
- メッセージが存在する
- 一部のメッセージにリアクションが付いている

**When:**
- `ChatRoomViewModel.loadMessages()`が呼び出される

**Then:**
- メッセージが取得される
- 各メッセージのリアクションが並列で取得される
- `messageReactions`辞書にリアクションが格納される
- リアクションが UI に表示される

#### Scenario: Load messages when reaction fetch fails

**Given:**
- ユーザーがチャットルーム画面を開く
- メッセージが存在する
- 一部のメッセージのリアクション取得が失敗する（ネットワークエラー）

**When:**
- `ChatRoomViewModel.loadMessages()`が呼び出される

**Then:**
- メッセージは正常に表示される
- 成功したメッセージのリアクションは表示される
- 失敗したメッセージのリアクションは表示されない
- エラーログが記録される
- ユーザーにエラーメッセージは表示されない（非クリティカルエラー）

## ADDED Requirements

### Requirement: REQ-REACT-003 - One Reaction Per User Per Message

1人のユーザーは1つのメッセージに対して1つのリアクションのみ可能でなければならない(MUST)。ユーザーが既にリアクションしている場合、新しい絵文字を選択すると既存のリアクションが削除され、新しいリアクションが追加されなければならない(MUST)。

#### Scenario: User adds first reaction to message

**Given:**
- ユーザーがメッセージを表示している
- ユーザーはまだそのメッセージにリアクションしていない

**When:**
- ユーザーが絵文字を選択してリアクションを追加

**Then:**
- 新しいリアクションがバックエンドAPIに送信される（POST）
- リアクションがローカル状態（`messageReactions`）に追加される
- UI にリアクションが表示される
- リアクション数が1増加する

#### Scenario: User toggles existing reaction off

**Given:**
- ユーザーがメッセージにリアクションしている（例: 👍）
- そのリアクションが UI に表示されている

**When:**
- ユーザーが同じ絵文字（👍）を再度タップ

**Then:**
- 既存のリアクションがバックエンドAPIから削除される（DELETE）
- リアクションがローカル状態から削除される
- UI からリアクションが消える
- リアクション数が1減少する

#### Scenario: User replaces existing reaction with different emoji

**Given:**
- ユーザーがメッセージにリアクションしている（例: 👍）
- そのリアクションが UI に表示されている

**When:**
- ユーザーが別の絵文字（例: ❤️）を選択

**Then:**
- 既存のリアクション（👍）がバックエンドAPIから削除される（DELETE）
- 削除が成功した後、新しいリアクション（❤️）がバックエンドAPIに追加される（POST）
- ローカル状態が更新される（古いリアクションを削除、新しいリアクションを追加）
- UI が更新される（👍が消えて❤️が表示される）
- リアクション総数は変わらない（1つ削除、1つ追加）

#### Scenario: User replaces reaction but deletion fails

**Given:**
- ユーザーがメッセージにリアクションしている（例: 👍）
- バックエンドAPIが一時的に利用不可

**When:**
- ユーザーが別の絵文字（例: ❤️）を選択
- 既存リアクションの削除APIが失敗する

**Then:**
- エラーメッセージが表示される: "リアクションを変更できませんでした"
- ローカル状態は変更されない
- UI は変更されない（👍が表示されたまま）
- 新しいリアクション（❤️）は追加されない

#### Scenario: User replaces reaction but addition fails after successful deletion

**Given:**
- ユーザーがメッセージにリアクションしている（例: 👍）

**When:**
- ユーザーが別の絵文字（例: ❤️）を選択
- 既存リアクションの削除（DELETE）が成功
- 新しいリアクションの追加（POST）が失敗

**Then:**
- エラーメッセージが表示される: "リアクションを変更できませんでした"
- 既存リアクション（👍）はサーバーから削除されたまま
- 新しいリアクション（❤️）は追加されない
- ローカル状態は削除のみ反映される（追加は反映されない）
- UI から👍が消える（サーバー状態と一致）
- ユーザーは手動で再試行できる

### Requirement: REQ-REACT-004 - Replace Reaction Use Case

`ReactionUseCase`は、既存のリアクションを新しいリアクションに置き換える機能を提供しなければならない(MUST)。システムは、削除と追加を適切な順序で実行し、エラーを適切に処理しなければならない(MUST)。

#### Scenario: Replace reaction successfully

**Given:**
- ユーザーが`messageId`に対して`oldEmoji`でリアクションしている

**When:**
- `ReactionUseCase.replaceReaction(messageId, userId, oldEmoji, newEmoji)`が呼び出される

**Then:**
- 既存のリアクション（`oldEmoji`）が削除される
- 新しいリアクション（`newEmoji`）が追加される
- 新しい`Reaction`オブジェクトが返される
- 両方の操作がログに記録される

#### Scenario: Replace reaction with no existing reaction

**Given:**
- ユーザーが`messageId`に対してリアクションしていない

**When:**
- `ReactionUseCase.replaceReaction(messageId, userId, nil, newEmoji)`が呼び出される

**Then:**
- 削除処理はスキップされる
- 新しいリアクション（`newEmoji`）が追加される
- 新しい`Reaction`オブジェクトが返される

#### Scenario: Replace reaction with deletion failure

**Given:**
- ユーザーが`messageId`に対して`oldEmoji`でリアクションしている
- バックエンドAPIが利用不可

**When:**
- `ReactionUseCase.replaceReaction(messageId, userId, oldEmoji, newEmoji)`が呼び出される
- 削除APIが失敗する

**Then:**
- 例外がスローされる
- 新しいリアクションは追加されない
- 既存のリアクションは保持される
- エラーが呼び出し元に伝播される

### Requirement: REQ-REACT-005 - Error Handling and User Feedback

システムは、リアクション操作のエラーを適切に処理し、ユーザーに明確なフィードバックを提供しなければならない(MUST)。

#### Scenario: Network error during reaction addition

**Given:**
- ユーザーがリアクションを追加しようとする
- ネットワーク接続がない

**When:**
- リアクション追加APIが失敗する

**Then:**
- エラーメッセージが表示される: "ネットワークエラーが発生しました。もう一度お試しください。"
- ローカル状態は変更されない
- UI は変更されない
- ユーザーは再試行できる

#### Scenario: Server error during reaction operation

**Given:**
- バックエンドサーバーがエラーを返す（5xx）

**When:**
- リアクション操作APIが失敗する

**Then:**
- エラーメッセージが表示される: "リアクションの処理に失敗しました。"
- エラーがログに記録される
- ローカル状態は変更されない
- ユーザーは再試行できる

#### Scenario: Successful reaction operation

**Given:**
- リアクション操作が成功する

**When:**
- APIレスポンスが正常に返される

**Then:**
- エラーメッセージは表示されない
- ローカル状態が更新される
- UI が即座に更新される
- ユーザーに成功フィードバック（視覚的変化）

## REMOVED Requirements

なし（既存の要件は削除されない）

## Cross-References

### Related Requirements

- **Message Loading:** メッセージ読み込み機能に依存
- **Authentication:** ユーザー認証に依存（`currentUserId`）
- **Network Layer:** バックエンドAPI接続に依存

### Future Enhancements

以下の機能は今回のスコープ外ですが、将来的に追加可能：
- リアルタイムリアクション更新（REQ-REACT-REALTIME）
- リアクションアニメーション（REQ-REACT-ANIMATION）
- カスタム絵文字サポート（REQ-REACT-CUSTOM-EMOJI）
- リアクション通知（REQ-REACT-NOTIFICATION）

## Validation Criteria

- [ ] `DependencyContainer`で`ReactionRepository`が使用される
- [ ] メッセージ読み込み時にリアクションも取得される
- [ ] 並列リアクション取得が正常に動作する
- [ ] リアクション取得失敗がメッセージ表示をブロックしない
- [ ] ユーザーは1メッセージに1リアクションのみ追加できる
- [ ] 既存のリアクションを別の絵文字に置き換えられる
- [ ] 同じ絵文字をタップしてリアクションを削除できる
- [ ] リアクション置換時に適切なエラーハンドリングが行われる
- [ ] ネットワークエラーが適切にユーザーに伝えられる
- [ ] 既存のリアクションUIが正常に動作する
