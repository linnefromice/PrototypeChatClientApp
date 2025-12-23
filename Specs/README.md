# Specs - 設計ドキュメント

このディレクトリには、PrototypeChatClientAppの**最新の設計情報（マスタ）**が含まれています。

## 📋 設計ドキュメント一覧

### アーキテクチャ設計

- **[IOS_APP_ARCHITECTURE.md](IOS_APP_ARCHITECTURE.md)** - iOSアプリ全体のアーキテクチャ設計
  - MVVM + Clean Architecture
  - レイヤー構造とその役割
  - 技術スタック

- **[MULTIMODULE_STRATEGY.md](MULTIMODULE_STRATEGY.md)** - マルチモジュール化戦略
  - フォルダ構造とモジュール分割方針
  - 段階的な移行計画
  - 依存関係ルール

### 機能設計

- **[AUTH_DESIGN.md](AUTH_DESIGN.md)** - 認証機能の設計
  - BetterAuth統合
  - セッション管理（Cookie + UserDefaults）
  - ユーザー登録・ログインフロー

- **[CHAT_FEATURE_PLAN.md](CHAT_FEATURE_PLAN.md)** - チャット機能の計画
  - メッセージング機能
  - リアルタイム通信
  - UI/UX設計

- **[CLIENT_REQUIREMENTS.md](CLIENT_REQUIREMENTS.md)** - クライアント要件
  - 機能要件
  - 非機能要件
  - ユーザーストーリー

### インフラストラクチャ設計

- **[API_LAYER_DESIGN.md](API_LAYER_DESIGN.md)** - API層の設計
  - OpenAPI Generator統合
  - ネットワーククライアント実装
  - エラーハンドリング

- **[CLI_TOOLS_DESIGN.md](CLI_TOOLS_DESIGN.md)** - CLIツール・ビルドシステム
  - Makefile設計
  - 開発コマンド
  - ビルド設定管理

## 📁 関連ドキュメント

### Docs/ ディレクトリ

設計の補足情報、計画、履歴は `Docs/` ディレクトリに配置されています。

- **[Docs/Plans/](../Docs/Plans/)** - 将来の計画・提案
  - 改善ロードマップ
  - CI/CD提案
  - その他の提案文書

- **[Docs/History/](../Docs/History/)** - 分析・調査レポート（日付付き）
  - アーキテクチャ分析
  - リファクタリング分析
  - 過去の検討内容

- **[Docs/Manuals/](../Docs/Manuals/)** - 手順書・ガイド
  - ビルド設定手順
  - 環境セットアップ
  - Xcode設定ガイド

## 🔄 更新ルール

### Specs/ (このディレクトリ)
- **常に最新の設計を反映**
- 日付情報は含めない
- 実装の真実の情報源（Single Source of Truth）

### Docs/History/
- 分析・調査レポートは日付付きで保存
- 過去の検討経過を履歴として保持
- ファイル名フォーマット: `[FILENAME]_YYYYMMDD.md`

### Docs/Plans/
- 将来の計画・提案を配置
- 実装前の検討内容

## 🛠️ 開発の始め方

1. まず [CLAUDE.md](../CLAUDE.md) を読んで、開発環境とコマンドを理解する
2. [IOS_APP_ARCHITECTURE.md](IOS_APP_ARCHITECTURE.md) でアーキテクチャ全体像を把握する
3. 実装する機能の設計ドキュメント（AUTH_DESIGN.md など）を確認する
4. 必要に応じて [Docs/Manuals/](../Docs/Manuals/) の手順書を参照する

## 📝 ドキュメント作成ガイド

新しい設計ドキュメントを作成する場合:

1. **Specs/** に配置するもの
   - 機能設計（Features）
   - アーキテクチャ設計
   - インフラ設計
   - ファイル名: 日付なし、SNAKE_CASE

2. **Docs/Plans/** に配置するもの
   - 将来の改善計画
   - 提案文書
   - ロードマップ

3. **Docs/History/** に配置するもの
   - 分析レポート
   - 調査結果
   - ファイル名: `[NAME]_YYYYMMDD.md`

---

**最終更新:** 2025-12-24
