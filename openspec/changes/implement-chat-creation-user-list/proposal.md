# Proposal: Implement Chat Creation User List

**Change ID:** `implement-chat-creation-user-list`
**Status:** Proposal
**Created:** 2025-12-15

## Overview

チャット作成機能を完成させるため、ユーザー一覧取得機能を実装します。現在、`UserListUseCase.fetchAvailableUsers()`はモック実装（空配列を返す）となっており、実際のユーザー一覧を表示できません。この変更により、ユーザーはチャット作成画面で他のユーザー一覧を表示し、1:1チャットを作成できるようになります。

### Current Behavior

- `CreateConversationView`は既に実装済みで、ユーザー一覧を表示しチャット作成するUIを提供
- `CreateConversationViewModel`は`UserListUseCase.fetchAvailableUsers()`を呼び出すが、常に空配列が返される
- バックエンドAPIは`GET /users`エンドポイントでユーザー一覧を提供済み
- `UserRepository.fetchUsers()`は既に実装済みでOpenAPI経由でユーザー取得可能

### Desired Behavior

- `UserListUseCase.fetchAvailableUsers()`が`UserRepository.fetchUsers()`を使用して実際のユーザー一覧を取得
- 現在のユーザー（自分自身）を除外したユーザー一覧を返す
- チャット作成画面で選択可能なユーザー一覧が表示される

## Why

現在の実装では、チャット作成画面が機能として動作しません（ユーザーが表示されない）。バックエンドAPI、Repository、ViewModelは全て準備済みで、UseCaseの実装のみが欠けています。最小限の変更（1ファイルの数行修正）で機能を完成でき、ユーザーは即座に1:1チャットを作成できるようになります。

## Motivation

- 現在の実装では、チャット作成画面が機能として動作しない（ユーザーが表示されない）
- バックエンドAPI、Repository、ViewModelは全て準備済みで、UseCaseの実装のみが欠けている
- 最小限の変更（1ファイルの数行修正）で機能を完成できる

## Scope

### In Scope

- `UserListUseCase.fetchAvailableUsers()`の実装
- 自分自身のユーザーIDを除外するロジック
- 既存の`UserRepositoryProtocol`を使用してユーザー取得

### Out of Scope

- グループチャット作成機能（将来の拡張）
- ユーザー検索・フィルタリング機能
- ユーザーのオンライン状態表示
- 新しいAPI実装（既存APIを使用）

## Dependencies

### Existing Components

- `UserRepositoryProtocol.fetchUsers()` - 実装済み（`UserRepository.swift`）
- `CreateConversationViewModel` - 実装済み（`UserListUseCase`を注入済み）
- `CreateConversationView` - 実装済み（ユーザー一覧表示UIあり）
- Backend API `GET /users` - 実装済み

### No Breaking Changes

- 既存のインターフェース（`UserListUseCase`）は変更なし
- 内部実装のみ変更（TODOコメントの実装）

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|-----------|
| ユーザー一覧取得失敗時のエラーハンドリング | Medium | `CreateConversationViewModel`が既にエラーハンドリング実装済み。Repositoryからthrowされた例外をキャッチして表示 |
| 大量ユーザー取得時のパフォーマンス | Low | 将来的にページネーションや検索機能で対応。現在はプロトタイプなので問題なし |
| 現在のユーザー除外ロジックの正確性 | Low | 単純なIDフィルタリングで実装。テストケースで検証 |

## Success Criteria

1. ユーザーがチャット作成画面を開くと、自分以外のユーザー一覧が表示される
2. ユーザーを選択して「作成」ボタンを押すと、1:1チャットが作成される
3. エラー時は適切なエラーメッセージが表示される
4. 既存のテストが全てpassする
5. 新しいテストケースで`UserListUseCase`の動作を検証

## Related Changes

- None（単独で完結する変更）

## Alternatives Considered

### Alternative 1: ViewModelで直接Repository呼び出し

**Pros:**
- UseCaseレイヤーをスキップして簡潔

**Cons:**
- クリーンアーキテクチャの原則に反する
- テスタビリティが低下
- 将来的にビジネスロジック追加時に変更コストが高い

**Decision:** UseCaseレイヤーを維持し、アーキテクチャ一貫性を保つ

### Alternative 2: 専用の`fetchUsers(excludingUserId:)`をRepositoryに追加

**Pros:**
- フィルタリングをRepository層で実装

**Cons:**
- Repositoryはデータアクセスのみ担当すべき
- ビジネスロジック（除外）はUseCase層で実装すべき
- 不要なRepository APIの増加

**Decision:** フィルタリングロジックはUseCase層に実装

## Implementation Notes

- `UserListUseCase.swift`の18-19行目のTODOコメントを実装
- `UserRepository.fetchUsers()`を呼び出し
- `filter { $0.id != currentUserId }`で現在のユーザーを除外
- 既存のエラーハンドリング（async throws）をそのまま活用
