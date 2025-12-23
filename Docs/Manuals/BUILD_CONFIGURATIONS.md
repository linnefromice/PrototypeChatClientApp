# Build Configurations ガイド

このドキュメントでは、異なるバックエンド環境でアプリをビルド・実行する方法を説明します。

## Build Configurations 一覧

プロジェクトには3つのBuild Configurationsが定義されています：

| Configuration | BACKEND_URL | 用途 |
|---------------|-------------|------|
| **Debug** | `http://localhost:8787` | ローカル開発（バックエンドをlocalhostで起動） |
| **Development** | `https://prototype-hono-drizzle-backend.linnefromice.workers.dev` | 本番環境での開発・テスト |
| **Release** | `https://prototype-hono-drizzle-backend.linnefromice.workers.dev` | App Store配布用 |

## Makefileコマンド

### 1. ビルドのみ

```bash
# Debug configuration (localhost backend)
make build-debug

# Development configuration (production backend)
make build-dev

# Release configuration (production backend)
make build-release

# デフォルト (Debug)
make build
```

### 2. ビルド + 実行

```bash
# Debug configuration (localhost backend)
make run-debug

# Development configuration (production backend)
make run-dev

# Release configuration (production backend)
make run-release

# デフォルト (Debug)
make run
```

### 3. 環境変数で指定

```bash
# 任意のconfigurationを指定
make run CONFIGURATION=Development

# 任意のデバイスとconfiguration
make run DEVICE="iPhone 15 Pro" CONFIGURATION=Release
```

## xcodebuildコマンド直接実行

Makefileを使わず、xcodebuildコマンドを直接実行する場合：

### ビルドのみ

```bash
# Debug configuration
xcodebuild build \
  -project PrototypeChatClientApp.xcodeproj \
  -scheme PrototypeChatClientApp \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  -configuration Debug

# Development configuration
xcodebuild build \
  -project PrototypeChatClientApp.xcodeproj \
  -scheme PrototypeChatClientApp \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  -configuration Development

# Release configuration
xcodebuild build \
  -project PrototypeChatClientApp.xcodeproj \
  -scheme PrototypeChatClientApp \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  -configuration Release
```

### ビルド + インストール + 起動

```bash
# 1. ビルド (例: Development)
xcodebuild build \
  -project PrototypeChatClientApp.xcodeproj \
  -scheme PrototypeChatClientApp \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  -configuration Development \
  -derivedDataPath ./DerivedData

# 2. シミュレータ起動
xcrun simctl boot "iPhone 16"
open -a Simulator

# 3. アプリをインストール
APP_PATH=$(find ./DerivedData -name "PrototypeChatClientApp.app" | head -n 1)
xcrun simctl install "iPhone 16" "$APP_PATH"

# 4. アプリを起動
xcrun simctl launch "iPhone 16" com.linnefromice.PrototypeChatClientApp
```

## プロジェクト情報の確認

現在の設定を確認：

```bash
make info
```

出力例：
```
Project Information:
  Project: PrototypeChatClientApp
  Scheme: PrototypeChatClientApp
  Device: iPhone 16
  Configuration: Debug
  Bundle ID: com.linnefromice.PrototypeChatClientApp

Backend Configuration:
  Backend URL: http://localhost:8787

Simulator:
  ID: 33AD998C-ECEC-4E64-83DD-F3F57512AFFC
  Status: Booted
```

特定のconfigurationの設定を確認：

```bash
# Debug
xcodebuild -project PrototypeChatClientApp.xcodeproj \
  -showBuildSettings -configuration Debug | grep BACKEND_URL

# Development
xcodebuild -project PrototypeChatClientApp.xcodeproj \
  -showBuildSettings -configuration Development | grep BACKEND_URL

# Release
xcodebuild -project PrototypeChatClientApp.xcodeproj \
  -showBuildSettings -configuration Release | grep BACKEND_URL
```

## 利用シーン別の推奨Configuration

### ローカル開発（バックエンドもローカル）

```bash
# バックエンドを起動
cd path/to/backend
npm run wrangler:dev  # http://localhost:8787

# アプリをDebug configurationで実行
make run-debug
```

### 本番環境でのテスト

```bash
# バックエンドは起動不要（Cloudflare Workersを使用）
make run-dev
```

### App Store配布用ビルド

```bash
make build-release
```

## トラブルシューティング

### 接続エラー (localhost)

```bash
# 原因: バックエンドが起動していない
# 解決方法:
cd path/to/backend
npm run wrangler:dev

# または本番環境を使用:
make run-dev
```

### 環境設定の確認

```bash
# 利用可能なconfiguration一覧
xcodebuild -project PrototypeChatClientApp.xcodeproj -list

# 現在の設定確認
make info

# 特定configurationのbackend URL確認
xcodebuild -project PrototypeChatClientApp.xcodeproj \
  -showBuildSettings -configuration Debug \
  | grep BACKEND_URL
```

### Configuration切り替え後もURLが変わらない

```bash
# DerivedDataをクリーン
make clean

# 再ビルド
make build-dev
```

## CI/CD での利用

GitHub Actionsなどで使用する場合：

```yaml
- name: Build for Development
  run: make build-dev

- name: Build for Release
  run: make build-release

# または
- name: Build with specific configuration
  run: |
    xcodebuild build \
      -project PrototypeChatClientApp.xcodeproj \
      -scheme PrototypeChatClientApp \
      -destination "platform=iOS Simulator,name=iPhone 16" \
      -configuration Development
```

## 参考

- Makefileの全コマンド: `make help`
- 環境設定詳細: `Docs/ENVIRONMENT_SETUP.md`
- AppConfig実装: `Infrastructure/Environment/AppConfig.swift`
