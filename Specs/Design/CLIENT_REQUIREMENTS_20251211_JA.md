# iOS クライアントアプリ - 要件・設計ドキュメント

## 1. プロジェクト概要

このドキュメントは、Hono + Drizzle ORM ベースのチャットAPIに接続するiOSクライアントアプリケーションの開発要件と設計情報をまとめたものです。

### バックエンドAPI概要
- **技術スタック**: Hono (Web Framework) + Drizzle ORM + SQLite
- **APIスタイル**: RESTful API (OpenAPI 3.1.0準拠)
- **デフォルトサーバーURL**: `http://localhost:3000`
- **主要機能**: ユーザー管理、会話（チャット）管理、メッセージング、リアクション、ブックマーク

---

## 2. データモデル

### 2.1 ユーザー (User)
```json
{
  "id": "uuid",
  "name": "string",
  "avatarUrl": "string | null",
  "createdAt": "ISO8601 datetime"
}
```

**役割**: システム内でメッセージを送受信するユーザーを表現

### 2.2 会話 (Conversation)
```json
{
  "id": "uuid",
  "type": "direct | group",
  "name": "string | null",
  "createdAt": "ISO8601 datetime",
  "participants": [Participant]
}
```

**役割**:
- `direct`: 1対1のダイレクトメッセージ
- `group`: 複数人のグループチャット（名前必須）

### 2.3 参加者 (Participant)
```json
{
  "id": "uuid",
  "conversationId": "uuid",
  "userId": "uuid",
  "role": "member | admin",
  "joinedAt": "ISO8601 datetime",
  "leftAt": "ISO8601 datetime | null"
}
```

**役割**: 会話への参加情報を管理。`leftAt`が設定されている場合、退出済み。

### 2.4 メッセージ (Message)
```json
{
  "id": "uuid",
  "conversationId": "uuid",
  "senderUserId": "uuid | null",
  "type": "text | system",
  "text": "string | null",
  "replyToMessageId": "uuid | null",
  "systemEvent": "join | leave | null",
  "createdAt": "ISO8601 datetime"
}
```

**役割**:
- `text`: 通常のユーザーメッセージ
- `system`: システムメッセージ（参加/退出通知など）
- `replyToMessageId`: 返信機能（スレッド）

### 2.5 リアクション (Reaction)
```json
{
  "id": "uuid",
  "messageId": "uuid",
  "userId": "uuid",
  "emoji": "string",
  "createdAt": "ISO8601 datetime"
}
```

**役割**: メッセージへの絵文字リアクション（いいね、など）

### 2.6 会話既読管理 (ConversationRead)
```json
{
  "id": "uuid",
  "conversationId": "uuid",
  "userId": "uuid",
  "lastReadMessageId": "uuid | null",
  "updatedAt": "ISO8601 datetime"
}
```

**役割**: ユーザーごとの会話の既読位置を追跡

### 2.7 ブックマーク (Bookmark)
```json
{
  "id": "uuid",
  "messageId": "uuid",
  "userId": "uuid",
  "createdAt": "ISO8601 datetime"
}
```

**役割**: 重要なメッセージを保存する機能

---

## 3. APIエンドポイント一覧

### 3.1 ヘルスチェック
- **GET** `/health`
  - レスポンス: `{ "ok": true }`

### 3.2 ユーザー管理
- **GET** `/users` - 全ユーザー取得（開発環境のみ）
- **POST** `/users` - ユーザー作成（開発環境のみ）
  - リクエスト: `{ "name": "string", "avatarUrl": "string?" }`
- **GET** `/users/{userId}` - ユーザー詳細取得
- **GET** `/users/{userId}/bookmarks` - ユーザーのブックマーク一覧

### 3.3 会話管理
- **GET** `/conversations?userId={uuid}` - ユーザーの会話一覧
- **POST** `/conversations` - 会話作成
  - リクエスト:
    ```json
    {
      "type": "direct | group",
      "name": "string?",
      "participantIds": ["uuid"]
    }
    ```
- **GET** `/conversations/{id}` - 会話詳細取得
- **POST** `/conversations/{id}/participants` - 参加者追加
  - リクエスト: `{ "userId": "uuid", "role": "member | admin?" }`
- **DELETE** `/conversations/{id}/participants/{userId}` - 参加者退出

### 3.4 メッセージ管理
- **GET** `/conversations/{id}/messages?userId={uuid}&limit={int}&before={datetime}` - メッセージ一覧
  - ページネーション対応（limit: 1-100, before: 指定日時より前）
- **POST** `/conversations/{id}/messages` - メッセージ送信
  - リクエスト:
    ```json
    {
      "senderUserId": "uuid",
      "text": "string?",
      "replyToMessageId": "uuid?",
      "systemEvent": "join | leave?"
    }
    ```

### 3.5 リアクション
- **POST** `/messages/{id}/reactions` - リアクション追加
  - リクエスト: `{ "userId": "uuid", "emoji": "string" }`
- **DELETE** `/messages/{id}/reactions/{emoji}?userId={uuid}` - リアクション削除

### 3.6 既読管理
- **POST** `/conversations/{id}/read` - 既読位置更新
  - リクエスト: `{ "userId": "uuid", "lastReadMessageId": "uuid" }`
- **GET** `/conversations/{id}/unread-count?userId={uuid}` - 未読数取得

### 3.7 ブックマーク
- **POST** `/messages/{id}/bookmarks` - ブックマーク追加
  - リクエスト: `{ "userId": "uuid" }`
- **DELETE** `/messages/{id}/bookmarks?userId={uuid}` - ブックマーク削除

---

## 4. iOSクライアント ユースケース

### 4.1 初回起動・ユーザー登録
1. アプリ起動時にローカルストレージからuserIdを確認
2. 存在しない場合、ユーザー作成画面を表示
3. `POST /users` でユーザーを作成
4. userIdをローカルに保存

### 4.2 会話一覧表示
1. `GET /conversations?userId={currentUserId}` で会話一覧を取得
2. 各会話について`GET /conversations/{id}/unread-count`で未読数を表示
3. 会話タップで詳細画面へ遷移

### 4.3 会話作成
#### ダイレクトメッセージ
1. ユーザー選択画面で相手を選択
2. `POST /conversations` で `type: "direct"`, `participantIds: [currentUserId, targetUserId]`

#### グループチャット
1. グループ名とメンバーを選択
2. `POST /conversations` で `type: "group"`, `name: "...", participantIds: [...]`

### 4.4 メッセージ送受信
#### 表示
1. `GET /conversations/{id}/messages?userId={currentUserId}&limit=50` で最新50件取得
2. スクロール上部到達時に`before`パラメータで過去メッセージを取得（ページネーション）

#### 送信
1. テキスト入力後、`POST /conversations/{id}/messages` でメッセージ送信
2. 返信の場合は`replyToMessageId`を設定

#### リアルタイム更新
- ポーリング: 定期的に`GET /conversations/{id}/messages`を呼び出し
- **推奨**: WebSocket実装（バックエンド拡張が必要）

### 4.5 既読管理
1. メッセージ画面表示時、最新メッセージのIDを記録
2. 画面離脱時に`POST /conversations/{id}/read`で既読位置を更新
3. 会話一覧では`GET /conversations/{id}/unread-count`で未読数バッジを表示

### 4.6 リアクション
1. メッセージ長押しでリアクションピッカーを表示
2. 絵文字選択時に`POST /messages/{id}/reactions`
3. 自分のリアクションタップで`DELETE /messages/{id}/reactions/{emoji}`

### 4.7 ブックマーク
1. メッセージメニューから「ブックマーク」選択
2. `POST /messages/{id}/bookmarks` でブックマーク追加
3. プロフィール画面から`GET /users/{userId}/bookmarks`でブックマーク一覧を表示

### 4.8 参加者管理（グループのみ）
1. `POST /conversations/{id}/participants` でメンバー招待
2. `DELETE /conversations/{id}/participants/{userId}` で退出
   - 退出時にシステムメッセージが自動生成される

---

## 5. インフラストラクチャ・デプロイメント

### 5.1 本番環境（Cloudflare）

#### プラットフォーム
- **ホスティング**: Cloudflare Workers
- **データベース**: Cloudflare D1 (SQLite互換)
- **デプロイURL**: `https://prototype-hono-drizzle-backend.linnefromice.workers.dev`

#### デプロイメントフロー
1. GitHub mainブランチへのプッシュで自動デプロイ
2. GitHub Actionsが以下を実行:
   - `npm run build` でバックエンドビルド
   - `wrangler d1 migrations apply` でD1マイグレーション実行
   - シードデータ投入（ユーザーデータ）
   - `wrangler deploy` でWorkers デプロイ

#### エンドポイント
- **Health Check**: `https://prototype-hono-drizzle-backend.linnefromice.workers.dev/health`
- **API Base**: `https://prototype-hono-drizzle-backend.linnefromice.workers.dev`

### 5.2 ローカル開発環境

#### データベース
- **選択肢1 (推奨)**: Docker Compose + PostgreSQL
  - `docker-compose.yml`で定義
  - Adminerによる管理UI（`http://localhost:8080`）
  - 起動: `npm run db:up`
  - 停止: `npm run db:down`

- **選択肢2**: ローカルPostgreSQL
  - `DATABASE_URL`環境変数で接続先を指定
  - `apps/backend/.env` に設定

#### APIサーバー
- **ポート**: 3000（デフォルト）
- **起動**: `npm run dev:backend`
- **ホットリロード**: Honoのwatch機能により自動再起動

### 5.3 iOS開発者向けAPI接続設定

#### 開発時
```swift
let baseURL = "http://localhost:3000" // ローカル開発
// またはシミュレーターから
let baseURL = "http://127.0.0.1:3000"
```

#### 本番時
```swift
let baseURL = "https://prototype-hono-drizzle-backend.linnefromice.workers.dev"
```

**注意事項**:
- App Transport Security (ATS) 設定が必要（ローカル開発時）
- Info.plistで`NSAllowsArbitraryLoads`または`NSAllowsLocalNetworking`を設定
- 本番環境はHTTPSのため追加設定不要

### 5.4 CI/CD

#### GitHub Actions ワークフロー
1. **CI** (`.github/workflows/ci.yml`)
   - プルリクエスト時の自動テスト
   - ビルド検証

2. **Deploy Workers** (`.github/workflows/deploy-workers.yml`)
   - mainブランチへのマージで本番デプロイ
   - D1マイグレーション自動適用
   - 手動トリガーも可能（workflow_dispatch）

3. **Deploy Docs** (`.github/workflows/deploy-docs.yml`)
   - OpenAPI仕様書のデプロイ

#### 必要なシークレット（GitHub Secrets）
- `CLOUDFLARE_API_TOKEN`: Cloudflare APIトークン
- `CLOUDFLARE_ACCOUNT_ID`: CloudflareアカウントID

### 5.5 データベースマイグレーション

#### Drizzle ORM による管理
```bash
# スキーマ変更時
npm run db:generate    # マイグレーションファイル生成
npm run db:migrate     # マイグレーション適用
```

#### マイグレーションファイル
- 保存先: `apps/backend/drizzle/`
- SQLファイルとして生成
- バージョン管理対象

#### 本番環境での実行
- GitHub Actionsが自動実行
- 手動実行: `wrangler d1 migrations apply prototype-hono-drizzle-db --remote`

### 5.6 監視・ログ

#### Cloudflare Workers
- **ダッシュボード**: Cloudflare Workersコンソールでリアルタイム監視
- **ログ**: `wrangler tail` コマンドでログストリーミング
- **メトリクス**: リクエスト数、エラー率、レイテンシ

#### 推奨モニタリング
- Cloudflare Analytics（標準機能）
- 外形監視サービス（Pingdom、UptimeRobotなど）
- `/health` エンドポイントの定期チェック

### 5.7 スケーリング・パフォーマンス

#### Cloudflare Workers の特性
- **自動スケーリング**: トラフィック増加時に自動対応
- **グローバルエッジ**: 世界中のエッジロケーションで実行
- **コールドスタート**: ほぼゼロ（Workersの特性）
- **制限事項**:
  - CPU時間: 50ms/リクエスト（無料プラン）
  - メモリ: 128MB
  - D1クエリ数: 50,000/日（無料プラン）

#### iOS側のベストプラクティス
- リクエストのバッチ処理
- 適切なキャッシング戦略
- ページネーション活用（`limit`パラメータ）
- 不要なポーリング頻度の削減

---

## 6. API仕様補足

### 6.1 データ形式
- すべてのリクエスト/レスポンスは`application/json`
- 日時は ISO8601 形式の文字列 (例: `2025-12-11T10:30:00.000Z`)
- UUIDはハイフン付き文字列形式 (例: `550e8400-e29b-41d4-a716-446655440000`)

### 6.2 バリデーションルール
- **ユーザー名**: 1文字以上必須
- **グループ名**: グループ会話の場合必須
- **participantIds**: 最低1人必須
- **メッセージlimit**: 1-100の範囲

### 6.3 ビジネスロジック
- 会話のメッセージは参加者のみアクセス可能
- `leftAt`が設定されている参加者は操作不可
- リアクションは1ユーザー×1絵文字につき1つまで（重複不可）
- ブックマークは1ユーザー×1メッセージにつき1つ（重複不可）
- 返信先メッセージは同じ会話内である必要がある

---

## 7. 開発環境セットアップ（参考）

### バックエンドAPIのローカル起動
```bash
# リポジトリクローン後
npm install
npm run db:up              # PostgreSQL起動
npm run generate:api       # 型生成
npm run dev:backend        # APIサーバー起動 (http://localhost:3000)
```

### テストデータ作成（開発用）
```bash
# ユーザー作成例
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{"name": "Test User", "avatarUrl": null}'

# 会話作成例
curl -X POST http://localhost:3000/conversations \
  -H "Content-Type: application/json" \
  -d '{
    "type": "direct",
    "participantIds": ["user-uuid-1", "user-uuid-2"]
  }'
```

---

## 8. 参考リンク

- OpenAPI仕様: `packages/openapi/openapi.yaml`
- バックエンドリポジトリ: `apps/backend/`
- データベーススキーマ: `apps/backend/src/infrastructure/db/schema.ts`
- API実装: `apps/backend/src/routes/*.ts`

---

**ドキュメント作成日**: 2025年12月11日
**API バージョン**: 0.1.0
**対象**: iOS開発者
