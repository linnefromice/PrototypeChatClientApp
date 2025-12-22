# 環境設定ガイド

このドキュメントでは、開発環境・本番環境でのバックエンドURL切り替え方法を説明します。

## 概要

iOSアプリは**Info.plist + Build Settings**の組み合わせで環境別のバックエンドURLを管理します。

```
Info.plist (BackendUrl) ← Build Settings (BACKEND_URL) ← 環境別設定
```

## 環境別設定

### Development (開発環境)
- **URL**: `http://localhost:8787`
- **用途**: ローカルで`npm run wrangler:dev`を実行している場合
- **Secure Cookie**: `false` (HTTPでも動作)

### Staging (ステージング環境) - 将来用
- **URL**: `https://staging-prototype.workers.dev`
- **用途**: テスト用の本番環境
- **Secure Cookie**: `true`

### Production (本番環境)
- **URL**: `https://prototype-hono-drizzle-backend.linnefromice.workers.dev`
- **用途**: App Store配布用
- **Secure Cookie**: `true`

## セットアップ手順

### 1. Build Settingsの設定

#### Xcodeで設定する方法（推奨）

1. Xcodeでプロジェクトを開く
2. プロジェクトナビゲータで`PrototypeChatClientApp`を選択
3. `PROJECT` → `PrototypeChatClientApp` → `Info` タブを開く
4. `Configurations`セクションを確認

   **現在の構成:**
   - Debug
   - Release

5. `Build Settings`タブを開く
6. `+` → `Add User-Defined Setting`をクリック
7. 新しい設定を追加:
   - **Setting Name**: `BACKEND_URL`
   - **Debug**: `http://localhost:8787`
   - **Release**: `https://prototype-hono-drizzle-backend.linnefromice.workers.dev`

#### xcconfig ファイルで設定する方法（スケール時推奨）

将来的に環境変数が増える場合は、xconfigファイルでの管理を推奨します。

1. `Config/`ディレクトリを作成
2. 各環境用のxconfigファイルを作成:

**Config/Debug.xcconfig:**
```
// Debug環境設定
BACKEND_URL = http:/$()/localhost:8787
ENABLE_LOGGING = YES
```

**Config/Release.xcconfig:**
```
// Release環境設定
BACKEND_URL = https:/$()/prototype-hono-drizzle-backend.linnefromice.workers.dev
ENABLE_LOGGING = NO
```

3. Xcodeでxconfigファイルを適用:
   - Project → Info → Configurations
   - Debug → Based on configuration file: `Debug.xcconfig`
   - Release → Based on configuration file: `Release.xcconfig`

### 2. 動作確認

#### Info.plistの確認

`Info.plist`を開いて、以下のエントリがあることを確認:

```xml
<key>BackendUrl</key>
<string>$(BACKEND_URL)</string>
```

#### コードでの利用

```swift
import Foundation

// 新しい方法（推奨）
let backendURL = Environment.backendUrl
print("Backend URL: \(backendURL)")

// 既存コード（後方互換性）
let env = AppEnvironment.current
print("Environment: \(env)")
print("Base URL: \(env.baseURL)")
```

#### デバッグ出力

アプリ起動時に環境設定を確認:

```swift
#if DEBUG
Environment.printConfiguration()
#endif
```

出力例:
```
🔧 [Environment] Configuration:
   Backend URL: http://localhost:8787
   Environment: Development
   Secure Context: false
   API Key: (not set)
```

## 環境の切り替え

### 開発中の切り替え

#### 方法1: Xcodeスキームで切り替え

1. Xcode上部のスキーム選択 → `Edit Scheme...`
2. `Run` → `Info`タブ
3. `Build Configuration`を変更:
   - `Debug` → localhost
   - `Release` → 本番環境

#### 方法2: 環境変数で一時的に切り替え（デバッグ用）

1. Xcode → `Edit Scheme...` → `Run` → `Arguments`タブ
2. `Environment Variables`に追加:
   - **Name**: `USE_ENVIRONMENT`
   - **Value**: `production` (or `staging`, `development`)

これにより、Debug buildでも一時的に本番環境を使用できます。

### ビルド時の環境確認

```bash
# Debug build
xcodebuild -showBuildSettings -configuration Debug | grep BACKEND_URL

# Release build
xcodebuild -showBuildSettings -configuration Release | grep BACKEND_URL
```

## トラブルシューティング

### BackendUrlが`$(BACKEND_URL)`のままになる

**原因**: Build Settingsで`BACKEND_URL`が設定されていない

**解決方法**:
1. Build Settings → `+` → Add User-Defined Setting
2. `BACKEND_URL`を追加
3. Debug/Releaseそれぞれに値を設定

### localhostに接続できない

**原因**: バックエンドが起動していない、またはポートが違う

**解決方法**:
```bash
# バックエンドを起動
cd path/to/backend
npm run wrangler:dev

# ポート8787で起動していることを確認
curl http://localhost:8787/api/health
```

### 本番環境でCookieが保存されない

**原因**: HTTPSではない環境でSecure Cookieを使用している

**確認**:
- バックエンドURL が `https://` で始まっているか確認
- ローカル開発では `http://localhost:8787` を使用

## 環境変数一覧

| 変数名 | 説明 | Debug | Release |
|--------|------|-------|---------|
| `BACKEND_URL` | バックエンドAPI URL | `http://localhost:8787` | `https://prototype-hono-drizzle-backend.linnefromice.workers.dev` |
| `ENABLE_LOGGING` | ログ出力 | `YES` | `NO` |
| `API_KEY` | APIキー（将来用） | (空) | (Secrets管理) |

## 次のステップ

### Staging環境の追加

1. **Configurationsにstagingを追加**:
   - Project → Info → Configurations → `+`
   - `Duplicate "Release" Configuration`
   - 名前を`Staging`に変更

2. **Build Settingsで値を設定**:
   - `BACKEND_URL` → Staging: `https://staging-prototype.workers.dev`

3. **AppEnvironment.swiftに追加**:
   ```swift
   case staging
   ```

### CI/CD対応

GitHub Actionsなどで環境を切り替える場合:

```yaml
- name: Build for Production
  run: |
    xcodebuild -configuration Release \
      -scheme PrototypeChatClientApp \
      BACKEND_URL="https://prototype-hono-drizzle-backend.linnefromice.workers.dev" \
      build
```

## 参考

- [Apple Documentation - Build Settings Reference](https://developer.apple.com/documentation/xcode/build-settings-reference)
- [Using Configuration Settings Files](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/BuildConfigurationGuide/Introduction/Introduction.html)
