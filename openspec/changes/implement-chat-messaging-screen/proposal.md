# Proposal: Implement Chat Messaging Screen

**Change ID:** `implement-chat-messaging-screen`
**Status:** Proposal
**Created:** 2025-12-16

## Overview

チャット一覧から会話を選択すると、メッセージの送受信が可能なチャット画面を実装します。シンプルなテキストベースのメッセージング機能により、ユーザー間のリアルタイムなコミュニケーションを実現します。

### Current Behavior

- `ConversationListView`で会話をタップすると「チャット詳細画面（未実装）」というプレースホルダーテキストが表示される
- メッセージの表示・送信機能が存在しない
- Message関連のドメインエンティティ、UseCase、Repository、ViewModelが未実装

### Desired Behavior

- 会話をタップするとメッセージ画面に遷移する
- メッセージ履歴が吹き出し形式のリストで表示される
  - 自分が送信したメッセージは右寄せ（青色の吹き出し）
  - 相手が送信したメッセージは左寄せ（グレー色の吹き出し）
  - 新しいメッセージが下に配置され、古いメッセージは上にある
  - 初期表示時は最新のメッセージが画面下部に表示されるようスクロール
- 画面下部のテキストフィールドからメッセージを入力・送信できる
- メッセージ送信後、送信したメッセージがリストの最下部に追加される

## Why

ユーザーがアプリ内でリアルタイムにコミュニケーションを取るための基本機能です。会話一覧は既に実装されており、次のステップとしてメッセージの送受信機能が必要です。

## Motivation

- バックエンドAPIのメッセージエンドポイント（`GET /conversations/{id}/messages`, `POST /conversations/{id}/messages`）は既に利用可能
- ConversationListViewのNavigationLinkはプレースホルダー実装のまま
- Message送受信の基本的なユーザー体験を早期に実現することで、フィードバックサイクルを加速
- iOS標準のメッセージアプリに似たUIパターンを使用することで、ユーザーの学習コストを低減

## Scope

### In Scope

**ドメイン層:**
- `Message`エンティティの実装（id, conversationId, senderUserId, type, text, createdAt）
- `MessageUseCase`の実装（メッセージ一覧取得、メッセージ送信）

**データ層:**
- `MessageRepository`プロトコルの定義
- `MessageRepositoryImpl`の実装（OpenAPI生成クライアント使用）
- `MockMessageRepository`の実装（テスト用）
- `MessageDTO+Mapping`の実装

**プレゼンテーション層:**
- `ChatRoomView`の実装（メッセージリスト表示）
- `ChatRoomViewModel`の実装（メッセージ状態管理、送信処理）
- `MessageBubbleView`の実装（メッセージ吹き出しUI）
- `MessageInputView`の実装（テキスト入力UI）

**ナビゲーション:**
- `ConversationListView`のNavigationLinkから`ChatRoomView`への遷移

### Out of Scope

- リアルタイム更新（WebSocket、ポーリング）- Phase 2で実装予定
- メッセージの編集・削除機能
- メッセージへの返信機能（replyToMessageId対応）
- システムメッセージの表示（type: system, systemEvent: join/leave）
- メッセージのリアクション機能
- メッセージのブックマーク機能
- 画像・ファイルの送信機能
- ページネーション（無限スクロール）- Phase 2で実装予定
- メッセージの既読管理
- プッシュ通知

## Dependencies

### Existing Components

- ✅ `ConversationDetail`エンティティ - 会話情報の取得に使用
- ✅ `User`エンティティ - メッセージ送信者情報に使用
- ✅ `ConversationListView` - チャット画面への遷移元
- ✅ `AuthenticationViewModel` - 現在ログイン中のユーザーID取得に使用
- ✅ `DependencyContainer` - 依存性注入に使用
- ✅ OpenAPI Generator - `GET /conversations/{id}/messages`, `POST /conversations/{id}/messages`のクライアント生成

### API Endpoints

- `GET /conversations/{id}/messages?userId={userId}&limit={limit}&before={before}` - メッセージ一覧取得
- `POST /conversations/{id}/messages` - メッセージ送信（body: SendMessageRequest）

### No Breaking Changes

- 既存のConversationList機能には影響なし
- 既存のAPI呼び出しには変更なし
- 新しいエンティティとUseCaseの追加のみ

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|-----------|
| メッセージ履歴が多い場合のパフォーマンス問題 | Medium | 初期実装ではAPIのlimitパラメータで50件に制限。Phase 2でページネーション実装 |
| スクロール位置の制御が複雑 | Low | SwiftUIのScrollViewReaderを使用し、メッセージ送信時に最下部へ自動スクロール |
| メッセージ送信中のエラーハンドリング | Medium | 送信失敗時にエラーアラート表示。リトライ機能はPhase 2で検討 |
| リアルタイム更新がない | Medium | Phase 1では手動更新（pull-to-refresh）で対応。Phase 2でポーリングまたはWebSocket実装 |

## Success Criteria

1. 会話一覧から会話をタップすると、メッセージ画面に遷移する
2. メッセージ画面でその会話のメッセージ履歴が表示される
3. 自分のメッセージと相手のメッセージが視覚的に区別できる
4. 最新のメッセージが画面下部に表示される
5. テキストフィールドにメッセージを入力して送信ボタンをタップすると、メッセージが送信される
6. メッセージ送信後、送信したメッセージがリストの最下部に追加される
7. 既存のテストが全てpassする
8. 新規実装した`MessageUseCase`のユニットテストがpassする

## Related Changes

- Depends on: None（既存の会話一覧機能を使用）
- Blocks: None
- Related: 将来的なリアルタイム更新機能（WebSocket実装）の基盤となる

## Alternatives Considered

### Alternative 1: リアルタイム更新を初期実装に含める

**Pros:**
- より良いユーザー体験（自動更新）
- 複数デバイスでの同期が即座に反映される

**Cons:**
- WebSocketまたはポーリング実装が必要で開発コストが高い
- バックエンドのWebSocket対応が必要（現在未実装）
- 複雑度が増し、初期リリースが遅れる

**Decision:** Phase 1ではシンプルな実装を優先。手動更新（pull-to-refresh）で対応し、リアルタイム更新はPhase 2で実装

### Alternative 2: システムメッセージ（join/leave）を初期実装に含める

**Pros:**
- 参加者の入退出を視覚的に確認できる
- APIは既にsystemEventをサポート

**Cons:**
- メッセージ表示ロジックが複雑化
- 初期リリースの優先度は低い

**Decision:** Phase 1ではtext messageのみ対応。システムメッセージはPhase 2で実装

### Alternative 3: 別画面ではなくシート表示

**Pros:**
- モーダルな体験でコンテキストが明確
- 戻るボタンが自動的に表示される

**Cons:**
- 全画面表示できず、メッセージが見づらい
- iOS標準メッセージアプリのパターンと異なる

**Decision:** NavigationLinkによる画面遷移を採用。iOS標準パターンに準拠

## Implementation Notes

### アーキテクチャ

プロジェクトの既存のMVVM + Clean Architectureパターンに従います：

```
Features/Chat/
├── Domain/
│   ├── Entities/
│   │   └── Message.swift          # 新規作成
│   ├── UseCases/
│   │   └── MessageUseCase.swift   # 新規作成
│   └── Repositories/              # プロトコルのみ（Repositoryパターン）
├── Data/
│   └── Repositories/
│       └── MockMessageRepository.swift  # 新規作成（テスト用）
├── Presentation/
│   ├── ViewModels/
│   │   └── ChatRoomViewModel.swift     # 新規作成
│   └── Views/
│       ├── ChatRoomView.swift          # 新規作成
│       ├── MessageBubbleView.swift     # 新規作成
│       └── MessageInputView.swift      # 新規作成
└── Testing/
    └── MockData.swift                  # Message用モックデータ追加
```

Infrastructure層（API通信）:
```
Infrastructure/Network/
├── Repositories/
│   └── MessageRepository.swift    # 新規作成（OpenAPIクライアント使用）
└── DTOs/
    └── MessageDTO+Mapping.swift   # 新規作成
```

### UI設計

**ChatRoomView構成:**
- NavigationBar: 会話名（ConversationDetailから取得）
- ScrollView + LazyVStack: メッセージリスト（逆順表示）
- MessageInputView: 下部固定のテキスト入力エリア

**MessageBubbleView:**
- 自分のメッセージ: HStackで右寄せ、青背景、白文字
- 相手のメッセージ: HStackで左寄せ、グレー背景、黒文字
- 送信者名（相手のメッセージのみ）、メッセージテキスト、送信時刻を表示

**MessageInputView:**
- HStack: TextField（拡張可能）+ 送信ボタン
- キーボード表示時に入力エリアがキーボード上に移動
- テキストが空の場合、送信ボタンを無効化

### データフロー

1. ChatRoomViewが表示される → `ChatRoomViewModel.loadMessages()`
2. `MessageUseCase.fetchMessages()` → `MessageRepository.fetchMessages()`
3. APIレスポンス → DTOマッピング → Messageエンティティ
4. ViewModelの`@Published var messages`が更新 → UI更新
5. ユーザーがテキスト入力 → 送信ボタンタップ
6. `ChatRoomViewModel.sendMessage()` → `MessageUseCase.sendMessage()`
7. APIレスポンス → 送信成功 → `messages`配列に追加 → UI更新

### 状態管理

ChatRoomViewModelのプロパティ:
- `@Published var messages: [Message] = []`
- `@Published var isLoading: Bool = false`
- `@Published var isSending: Bool = false`
- `@Published var errorMessage: String?`
- `@Published var showError: Bool = false`
- `@Published var messageText: String = ""`

### テスト戦略

1. **Unit Test:**
   - `MessageUseCaseTests` - メッセージ取得・送信ロジック
   - `ChatRoomViewModelTests` - ViewModel状態管理
   - `MessageTests` - Messageエンティティのcodable、equatable

2. **Manual Test:**
   - シミュレータでメッセージ送受信フロー確認
   - 複数ユーザー（user-1, user-2）でメッセージ送信確認
   - 長いテキストの表示確認
   - エラーケース（ネットワークエラー）の確認

3. **Edge Cases:**
   - メッセージが0件の場合のUI（EmptyView表示）
   - 送信中のローディング状態
   - APIエラー時のエラー表示
