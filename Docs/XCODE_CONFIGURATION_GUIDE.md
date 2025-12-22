# Xcode Build Configuration 切り替えガイド

このドキュメントでは、Xcodeから実行する際にBuild Configurationを切り替える方法を説明します。

## 前提知識

プロジェクトには3つのBuild Configurationsがあります：

| Configuration | Backend URL | 用途 |
|---------------|-------------|------|
| Debug | `http://localhost:8787` | ローカル開発 |
| Development | `https://prototype-hono-drizzle-backend.linnefromice.workers.dev` | 本番環境テスト |
| Release | `https://prototype-hono-drizzle-backend.linnefromice.workers.dev` | App Store配布 |

---

## 方法1: Schemeの編集（推奨）

実行時のConfigurationを変更する最も一般的な方法です。

### 手順

#### 1. Scheme編集画面を開く

**方法A: ツールバーから**
```
Xcode上部ツールバー
┌─────────────────────────────────────────┐
│ PrototypeChatClientApp > iPhone 16  ▼  │ ← クリック
└─────────────────────────────────────────┘
         ↓
「Edit Scheme...」を選択
```

**方法B: キーボードショートカット**
```
⌘ + < (Command + Shift + ,)
```

**方法C: メニューバーから**
```
Product → Scheme → Edit Scheme...
```

#### 2. Build Configurationを変更

```
┌──────────────────────────────────────────────────┐
│ PrototypeChatClientApp                           │
│ ┌────────────┬─────────────────────────────┐    │
│ │ Run        │ ┌───────────────────────┐   │    │
│ │ Test       │ │ Info                  │   │    │
│ │ Profile    │ └───────────────────────┘   │    │
│ │ Analyze    │                              │    │
│ │ Archive    │ Build Configuration:         │    │
│ │            │ ┌─────────────────────┐      │    │
│ └────────────│ │ Debug            ▼  │ ← ここ  │
│              │ └─────────────────────┘      │    │
│              │   - Debug (localhost)        │    │
│              │   - Development (production) │    │
│              │   - Release (production)     │    │
│              └──────────────────────────────┘    │
│                                     [Close]      │
└──────────────────────────────────────────────────┘
```

#### 3. 変更を確認して実行

- 「Close」ボタンをクリック
- `⌘ + R`でアプリを実行
- Xcodeコンソールで以下のログを確認：

```
🔧 [Environment] Configuration:
   Backend URL: http://localhost:8787
   Environment: Development
   Secure Context: false
```

### Configuration別の設定例

**ローカル開発（バックエンドをlocalhostで起動）:**
- Build Configuration: `Debug`
- Backend URL: `http://localhost:8787`

**本番環境でテスト:**
- Build Configuration: `Development`
- Backend URL: `https://prototype-hono-drizzle-backend.linnefromice.workers.dev`

**リリースビルド:**
- Build Configuration: `Release`
- Backend URL: `https://prototype-hono-drizzle-backend.linnefromice.workers.dev`

---

## 方法2: 複数のSchemeを作成（推奨・上級者向け）

環境ごとに専用のSchemeを作成すると、ツールバーからワンクリックで切り替えられます。

### 手順

#### 1. Scheme管理画面を開く

```
Xcodeツールバー
┌─────────────────────────────────────────┐
│ PrototypeChatClientApp > iPhone 16  ▼  │ ← クリック
└─────────────────────────────────────────┘
         ↓
「Manage Schemes...」を選択
```

#### 2. 新しいSchemeを複製

```
┌────────────────────────────────────────────┐
│ Manage Schemes                             │
│ ┌────────────────────────────────────────┐ │
│ │ ✓ PrototypeChatClientApp               │ │ ← 選択
│ └────────────────────────────────────────┘ │
│                                [+ - ⚙️]    │ ← 「+」をクリック
└────────────────────────────────────────────┘
         ↓
「Duplicate」を選択
```

#### 3. Schemeに名前をつける

```
┌────────────────────────────────────────────┐
│ Name: PrototypeChatClientApp (Development) │
│ ☑ Shared                                   │
└────────────────────────────────────────────┘
```

**推奨名:**
- `PrototypeChatClientApp (Debug)`
- `PrototypeChatClientApp (Development)`
- `PrototypeChatClientApp (Release)`

#### 4. Build Configurationを設定

各Schemeを選択して「Edit...」をクリック：

**Debug Scheme:**
- Run → Info → Build Configuration: `Debug`
- Test → Info → Build Configuration: `Debug`
- Profile → Info → Build Configuration: `Debug`
- Analyze → Info → Build Configuration: `Debug`
- Archive → Info → Build Configuration: `Release`

**Development Scheme:**
- Run → Info → Build Configuration: `Development`
- Test → Info → Build Configuration: `Development`
- Profile → Info → Build Configuration: `Development`
- Analyze → Info → Build Configuration: `Development`
- Archive → Info → Build Configuration: `Release`

**Release Scheme:**
- Run → Info → Build Configuration: `Release`
- Test → Info → Build Configuration: `Release`
- Profile → Info → Build Configuration: `Release`
- Analyze → Info → Build Configuration: `Release`
- Archive → Info → Build Configuration: `Release`

#### 5. Schemeを選択して実行

```
Xcodeツールバー
┌──────────────────────────────────────────────┐
│ PrototypeChatClientApp (Development) ▼      │ ← クリックして選択
└──────────────────────────────────────────────┘
  - PrototypeChatClientApp (Debug)       ← localhost
  - PrototypeChatClientApp (Development) ← production
  - PrototypeChatClientApp (Release)     ← production (optimized)
```

`⌘ + R`で選択したSchemeで実行

---

## 確認方法

### 1. アプリ起動時のログ確認

アプリ実行後、Xcodeのコンソール（⌘ + Shift + Y）で確認：

```
🔧 [Environment] Configuration:
   Backend URL: http://localhost:8787
   Environment: Development
   Secure Context: false
   API Key: (not set)
```

### 2. Build Settingsの確認

**Xcodeで確認:**
1. プロジェクトナビゲータでプロジェクトを選択
2. 「Build Settings」タブを選択
3. 検索バーに「BACKEND_URL」と入力
4. 各Configurationの値を確認

```
BACKEND_URL
  Debug        http://localhost:8787
  Development  https://prototype-hono-drizzle-backend.linnefromice.workers.dev
  Release      https://prototype-hono-drizzle-backend.linnefromice.workers.dev
```

### 3. Report Navigatorで確認

1. Xcode → View → Navigators → Report Navigator (`⌘ + 9`)
2. 最新のビルドを選択
3. Build Logで「BACKEND_URL」を検索

---

## トラブルシューティング

### Configuration変更が反映されない

#### 解決方法1: クリーンビルド

```
Product → Clean Build Folder (⌘ + Shift + K)
```

またはコマンドラインから：
```bash
make clean
```

#### 解決方法2: DerivedDataを削除

```
Xcode → Preferences → Locations → DerivedData → 矢印アイコンをクリック
→ DerivedDataフォルダを削除
```

またはコマンドラインから：
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/PrototypeChatClientApp-*
make clean
```

#### 解決方法3: Xcodeを再起動

完全にXcodeを終了して再起動

### localhostに接続できない

#### 原因: バックエンドが起動していない

**確認:**
```bash
curl http://localhost:8787/api/health
```

**解決方法:**
```bash
cd path/to/backend
npm run wrangler:dev
```

または本番環境を使用：
- Scheme → Edit Scheme → Build Configuration: `Development`

### Build Configurationの選択肢が表示されない

#### 原因: Configurationsが正しく設定されていない

**確認:**
1. プロジェクトナビゲータでプロジェクトを選択
2. PROJECT (not TARGET) → Info タブ
3. Configurationsセクションを確認

**期待される設定:**
```
Configurations
  Debug
  Development
  Release
```

---

## ベストプラクティス

### 開発フロー別の推奨Configuration

**日常的なローカル開発:**
```
Scheme: PrototypeChatClientApp (Debug)
Backend: localhost:8787 (ローカルで起動)
```

**本番環境でのテスト:**
```
Scheme: PrototypeChatClientApp (Development)
Backend: Cloudflare Workers (本番)
```

**パフォーマンステスト:**
```
Scheme: PrototypeChatClientApp (Release)
Backend: Cloudflare Workers (本番)
Note: Release buildは最適化されるため、実際のパフォーマンスを測定できます
```

### チーム開発での推奨設定

**Schemeを共有する:**
1. Manage Schemes で各Schemeの「Shared」にチェック
2. `.xcodeproj/xcshareddata/xcschemes/` にSchemeファイルが作成される
3. これをGitにコミット
4. チームメンバー全員が同じSchemeを使用できる

**gitignore設定:**
```gitignore
# User-specific schemes
*.xcodeproj/xcuserdata/

# Shared schemes (コミットする)
!*.xcodeproj/xcshareddata/
!*.xcodeproj/xcshareddata/xcschemes/
```

---

## 参考

- Build Configurationの詳細: `Docs/BUILD_CONFIGURATIONS.md`
- コマンドラインでの実行: `Docs/BUILD_CONFIGURATIONS.md`
- 環境設定: `Docs/ENVIRONMENT_SETUP.md`
- Makefileコマンド一覧: `make help`
