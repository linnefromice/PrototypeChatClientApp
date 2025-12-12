# PrototypeChatClientApp

iOSチャットクライアントアプリケーション（プロトタイプ）

## 📋 概要

Hono + Drizzle ORM ベースのチャットAPIに接続するiOSクライアントアプリケーション。
MultiModule化を見据えた構造で、認証機能を実装済み。

## 🚀 クイックスタート

### 前提条件

- macOS 13.0+
- Xcode 15.0+
- iOS 16.0+ (実行環境)

### ビルド・実行

```bash
# プロジェクトをクローン
git clone https://github.com/linnefromice/PrototypeChatClientApp.git
cd PrototypeChatClientApp

# シミュレータでアプリを起動
make run

# または、Xcodeで開く
make open
```

## 🛠️ 開発コマンド

全てのコマンドは `make` を使用して実行できます。

### 基本コマンド

```bash
make help           # 利用可能なコマンド一覧を表示
make build          # アプリをビルド
make run            # シミュレータでアプリを起動
make test           # ユニットテストを実行
make clean          # ビルドキャッシュをクリア
make open           # Xcodeでプロジェクトを開く
```

### シミュレータ操作

```bash
make devices        # 利用可能なシミュレータ一覧
make boot           # シミュレータを起動
make shutdown       # シミュレータを停止
make reset          # シミュレータをリセット
make logs           # アプリログをリアルタイム表示
make screenshot     # スクリーンショットを取得
```

### デバイス指定

```bash
# iPhone 15 Proで実行
DEVICE="iPhone 15 Pro" make run

# iPadで実行
DEVICE="iPad Pro (12.9-inch) (6th generation)" make run
```

### コード品質

```bash
make format         # SwiftFormatでコード整形
make lint           # SwiftLintで静的解析
```

### パッケージ管理

```bash
make resolve        # Swift Package依存関係を解決
make update         # パッケージを更新
make reset-packages # パッケージキャッシュをリセット
```

### CI/CD

```bash
make ci             # CI環境でのビルド・テスト実行
```

## 📁 プロジェクト構造

```
PrototypeChatClientApp/
├── App/                              # アプリケーション層
│   ├── PrototypeChatClientAppApp.swift
│   └── DependencyContainer.swift
│
├── Core/                             # 共通基盤層
│   ├── Entities/                     # 横断的Entity
│   └── Protocols/                    # 共通Protocol
│
├── Features/                         # 機能モジュール
│   └── Authentication/               # 認証機能
│       ├── Domain/                   # ビジネスロジック
│       ├── Data/                     # データ管理
│       └── Presentation/             # UI
│
├── Infrastructure/                   # インフラ層（準備中）
│   ├── Network/
│   └── Storage/
│
├── Specs/                            # 設計ドキュメント
│   ├── Design/
│   └── Plans/
│
└── Makefile                          # 開発コマンド
```

詳細は `PrototypeChatClientApp/README.md` を参照。

## 🔑 認証機能

### テスト用User ID

開発環境では以下のUser IDが使用可能です：

- `user-1` → Alice
- `user-2` → Bob
- `user-3` → Charlie

### 認証フロー

1. アプリ起動時にローカルセッションをチェック
2. セッションがない場合、User ID入力画面を表示
3. User IDを入力してログイン
4. `GET /users/{userId}` APIを呼び出し
5. 成功したらセッションを保存

## 🏗️ アーキテクチャ

### 設計方針

- **Clean Architecture**: Domain/Data/Presentationの3層分離
- **MVVM**: ViewModelによる状態管理
- **Protocol指向**: テスタブルな設計
- **MultiModule対応**: 将来のモジュール分割を見据えた構造

### 依存関係

```
App → Features → Core
    → Infrastructure → Core
```

詳細は `Specs/Plans/MULTIMODULE_STRATEGY_20251211_JA.md` を参照。

## 🔌 API接続

### 現在の状態

- ✅ Mock実装（開発・テスト用）
- ✅ OpenAPI Generator環境構築済み
- ⏳ 本番API接続（未実装）

### 接続先

- **開発環境**: `http://localhost:3000` (予定)
- **本番環境**: `https://prototype-hono-drizzle-backend.linnefromice.workers.dev`

### OpenAPI Generator セットアップ

Swift OpenAPI Generatorを使用してAPIクライアントを自動生成します。

**Apple Best Practice採用:**
- 生成コードは `DerivedData/` に配置（ビルド成果物として扱う）
- ビルド時に自動的にコード生成
- gitには生成コードを含めない

**初回セットアップ:**
1. OpenAPI仕様書を取得: `make fetch-openapi`
2. Xcodeでプロジェクトを開く: `make open`
3. Swift Package依存を追加（詳細は [OPENAPI_SETUP.md](OPENAPI_SETUP.md) を参照）
4. Build Pluginを設定（OPENAPI_SETUP.mdの手順に従う）
5. ビルド: `make build`

**OpenAPI仕様書の更新:**
```bash
make fetch-openapi  # 最新の仕様書を取得
make build          # コード再生成（自動）
```

**生成コードの確認:**
```bash
# 生成されたファイルを確認
find DerivedData/Build/Intermediates.noindex/ \
  -name "*.swift" \
  -path "*/OpenAPIGenerator/GeneratedSources/*"
```

詳細な手順は [OPENAPI_SETUP.md](OPENAPI_SETUP.md) を参照してください。

## 📚 ドキュメント

### 設計書

- [MultiModule化戦略](Specs/Plans/MULTIMODULE_STRATEGY_20251211_JA.md)
- [アーキテクチャ概要](Specs/Plans/IOS_APP_ARCHITECTURE_20251211_JA.md)
- [API接続レイヤー設計](Specs/Plans/API_LAYER_DESIGN_20251211_JA.md)
- [認証管理設計](Specs/Plans/AUTH_DESIGN_20251211_JA.md)
- [CLI開発ツール設計](Specs/Plans/CLI_TOOLS_DESIGN_20251211_JA.md)

### 実装ガイド

- [プロジェクト構造ガイド](PrototypeChatClientApp/README.md)

## 🧪 テスト

```bash
# ユニットテストを実行
make test

# 特定のテストを実行
xcodebuild test \
  -project PrototypeChatClientApp.xcodeproj \
  -scheme PrototypeChatClientApp \
  -destination "platform=iOS Simulator,name=iPhone 15" \
  -only-testing:PrototypeChatClientAppTests/AuthenticationUseCaseTests
```

## 🔧 トラブルシューティング

### ビルドエラーが発生する

```bash
# クリーンビルド
make clean
make build
```

### シミュレータが起動しない

```bash
# シミュレータをリセット
make reset

# 別のデバイスで試す
make devices
DEVICE="iPhone 15 Pro" make run
```

### パッケージの問題

```bash
# パッケージキャッシュをリセット
make reset-packages
make resolve
```

### DerivedDataの問題

```bash
# DerivedDataを完全削除
rm -rf ~/Library/Developer/Xcode/DerivedData/PrototypeChatClientApp-*
make clean
make build
```

## 🤝 コントリビューション

1. このリポジトリをフォーク
2. フィーチャーブランチを作成 (`git checkout -b feat/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add amazing feature'`)
4. ブランチにプッシュ (`git push origin feat/amazing-feature`)
5. プルリクエストを作成

### コーディング規約

```bash
# コードフォーマット
make format

# 静的解析
make lint
```

## 📄 ライセンス

このプロジェクトはプロトタイプであり、現時点ではライセンスは未定です。

## 📧 コンタクト

プロジェクトに関する質問や提案は、GitHubのIssuesでお願いします。

---

**最終更新**: 2025年12月11日
