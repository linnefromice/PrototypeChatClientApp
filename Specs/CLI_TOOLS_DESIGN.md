# CLI開発ツール設計書

## 1. 概要

### 1.1 目的
ターミナルから効率的にiOSアプリの開発・ビルド・実行を行えるようにする

### 1.2 設計方針
- **Make**: シンプルで標準的なタスクランナー
- **xcodebuild**: Xcode CLIツールによる自動化
- **xcrun simctl**: シミュレータ操作
- **fastlane**: 高度な自動化（将来的なオプション）

---

## 2. ツール選定

### 2.1 推奨アプローチ: Makefile

**理由**:
- ✅ 追加インストール不要（標準搭載）
- ✅ シンプルで学習コスト低い
- ✅ 他のプロジェクトでも広く使われている
- ✅ タブ補完が効く（`make <TAB>`）

**代替案との比較**:

| ツール | メリット | デメリット | 評価 |
|--------|---------|-----------|------|
| **Makefile** | 標準搭載、シンプル | タブインデント必須 | ⭐⭐⭐⭐⭐ |
| **npm scripts** | 柔軟、JSON設定 | Node.js必要 | ⭐⭐⭐ |
| **fastlane** | 高機能、iOS特化 | 学習コスト高、オーバースペック | ⭐⭐ |
| **Tuist** | プロジェクト管理も可能 | 導入コスト高 | ⭐⭐ |

### 2.2 Xcodeコマンドラインツール

**必須ツール**:
```bash
# インストール確認
xcode-select --install

# 利用可能なツール
xcodebuild      # ビルド実行
xcrun simctl    # シミュレータ操作
xed             # Xcodeでプロジェクト開く
```

---

## 3. 推奨コマンド一覧

### 3.1 基本操作

| コマンド | 説明 | 頻度 |
|---------|------|------|
| `make help` | 利用可能なコマンド一覧表示 | 🔵 低 |
| `make open` | Xcodeでプロジェクトを開く | 🟢 中 |
| `make build` | デバッグビルド実行 | 🔴 高 |
| `make run` | シミュレータでアプリ起動 | 🔴 高 |
| `make clean` | ビルドキャッシュをクリア | 🟢 中 |

### 3.2 開発補助

| コマンド | 説明 | 頻度 |
|---------|------|------|
| `make test` | ユニットテスト実行 | 🔴 高 |
| `make format` | コードフォーマット（SwiftFormat） | 🟢 中 |
| `make lint` | 静的解析（SwiftLint） | 🟢 中 |
| `make preview` | Xcode Preview起動 | 🔵 低 |

### 3.3 シミュレータ操作

| コマンド | 説明 | 頻度 |
|---------|------|------|
| `make devices` | 利用可能なシミュレータ一覧 | 🔵 低 |
| `make boot` | シミュレータ起動 | 🟢 中 |
| `make shutdown` | シミュレータ停止 | 🔵 低 |
| `make reset` | シミュレータリセット | 🔵 低 |
| `make logs` | アプリログ表示 | 🟢 中 |

### 3.4 依存管理

| コマンド | 説明 | 頻度 |
|---------|------|------|
| `make resolve` | Swift Package依存解決 | 🟢 中 |
| `make update` | パッケージ更新 | 🔵 低 |
| `make reset-packages` | パッケージキャッシュリセット | 🔵 低 |

### 3.5 CI/リリース

| コマンド | 説明 | 頻度 |
|---------|------|------|
| `make ci` | CI環境でのビルド・テスト | 🔵 低 |
| `make archive` | Archiveビルド作成 | 🔵 低 |
| `make release` | リリースビルド | 🔵 低 |

---

## 4. Makefile設計

### 4.1 基本構造

```makefile
# プロジェクト設定
PROJECT_NAME = PrototypeChatClientApp
SCHEME = PrototypeChatClientApp
WORKSPACE = PrototypeChatClientApp.xcodeproj

# デフォルトシミュレータ
DEVICE = "iPhone 15"
OS_VERSION = "iOS 17.2"

# デフォルトターゲット
.DEFAULT_GOAL := help

# Phony targets（ファイル名と衝突しないように）
.PHONY: help build run test clean open devices

# ヘルプ表示（デフォルト）
help:
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
```

### 4.2 変数定義パターン

```makefile
# カラー出力
COLOR_RESET   = \033[0m
COLOR_INFO    = \033[36m
COLOR_SUCCESS = \033[32m
COLOR_ERROR   = \033[31m

# ビルド設定
BUILD_DIR = ./build
DERIVED_DATA = ./DerivedData
CONFIGURATION = Debug

# シミュレータID（動的取得）
SIMULATOR_ID = $(shell xcrun simctl list devices available | \
	grep "$(DEVICE)" | grep "$(OS_VERSION)" | \
	grep -E -o -i "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}" | \
	head -n 1)
```

### 4.3 主要コマンド実装例

#### ビルド

```makefile
build: ## ビルド実行
	@echo "$(COLOR_INFO)Building $(PROJECT_NAME)...$(COLOR_RESET)"
	xcodebuild build \
		-project $(WORKSPACE) \
		-scheme $(SCHEME) \
		-destination "platform=iOS Simulator,name=$(DEVICE)" \
		-configuration $(CONFIGURATION) \
		-derivedDataPath $(DERIVED_DATA) \
		| xcpretty
	@echo "$(COLOR_SUCCESS)Build completed!$(COLOR_RESET)"
```

#### シミュレータで実行

```makefile
run: boot ## シミュレータでアプリ起動
	@echo "$(COLOR_INFO)Building and running $(PROJECT_NAME)...$(COLOR_RESET)"
	xcodebuild build \
		-project $(WORKSPACE) \
		-scheme $(SCHEME) \
		-destination "platform=iOS Simulator,name=$(DEVICE)" \
		-configuration $(CONFIGURATION) \
		-derivedDataPath $(DERIVED_DATA)
	@echo "$(COLOR_INFO)Installing app to simulator...$(COLOR_RESET)"
	xcrun simctl install $(SIMULATOR_ID) $(shell find $(DERIVED_DATA) -name "$(PROJECT_NAME).app" | head -n 1)
	@echo "$(COLOR_INFO)Launching app...$(COLOR_RESET)"
	xcrun simctl launch $(SIMULATOR_ID) com.prototype.chat.PrototypeChatClientApp
	@echo "$(COLOR_SUCCESS)App launched!$(COLOR_RESET)"
```

#### テスト実行

```makefile
test: ## ユニットテスト実行
	@echo "$(COLOR_INFO)Running tests...$(COLOR_RESET)"
	xcodebuild test \
		-project $(WORKSPACE) \
		-scheme $(SCHEME) \
		-destination "platform=iOS Simulator,name=$(DEVICE)" \
		-configuration $(CONFIGURATION) \
		| xcpretty --test
	@echo "$(COLOR_SUCCESS)Tests completed!$(COLOR_RESET)"
```

#### クリーンビルド

```makefile
clean: ## ビルドキャッシュをクリア
	@echo "$(COLOR_INFO)Cleaning build artifacts...$(COLOR_RESET)"
	xcodebuild clean \
		-project $(WORKSPACE) \
		-scheme $(SCHEME)
	rm -rf $(DERIVED_DATA)
	rm -rf $(BUILD_DIR)
	@echo "$(COLOR_SUCCESS)Clean completed!$(COLOR_RESET)"
```

#### シミュレータ管理

```makefile
devices: ## 利用可能なシミュレータ一覧
	@echo "$(COLOR_INFO)Available simulators:$(COLOR_RESET)"
	xcrun simctl list devices available

boot: ## シミュレータ起動
	@echo "$(COLOR_INFO)Booting simulator: $(DEVICE)$(COLOR_RESET)"
	xcrun simctl boot $(SIMULATOR_ID) 2>/dev/null || true
	open -a Simulator
	@echo "$(COLOR_SUCCESS)Simulator booted!$(COLOR_RESET)"

shutdown: ## シミュレータ停止
	@echo "$(COLOR_INFO)Shutting down simulator...$(COLOR_RESET)"
	xcrun simctl shutdown $(SIMULATOR_ID) 2>/dev/null || true
	@echo "$(COLOR_SUCCESS)Simulator shut down!$(COLOR_RESET)"

reset: ## シミュレータリセット
	@echo "$(COLOR_ERROR)Resetting simulator...$(COLOR_RESET)"
	xcrun simctl shutdown $(SIMULATOR_ID) 2>/dev/null || true
	xcrun simctl erase $(SIMULATOR_ID)
	@echo "$(COLOR_SUCCESS)Simulator reset!$(COLOR_RESET)"
```

---

## 5. 補助ツール

### 5.1 xcpretty（出力整形）

**インストール**:
```bash
gem install xcpretty
```

**用途**:
- xcodebuildの冗長な出力を見やすく整形
- ビルドエラーの強調表示
- 進捗バーの表示

**使用例**:
```bash
xcodebuild build ... | xcpretty
```

### 5.2 SwiftFormat（コードフォーマット）

**インストール**:
```bash
brew install swiftformat
```

**Makefile統合**:
```makefile
format: ## コードフォーマット実行
	@echo "$(COLOR_INFO)Formatting Swift code...$(COLOR_RESET)"
	swiftformat . --config .swiftformat
	@echo "$(COLOR_SUCCESS)Formatting completed!$(COLOR_RESET)"
```

### 5.3 SwiftLint（静的解析）

**インストール**:
```bash
brew install swiftlint
```

**Makefile統合**:
```makefile
lint: ## SwiftLint実行
	@echo "$(COLOR_INFO)Running SwiftLint...$(COLOR_RESET)"
	swiftlint lint --config .swiftlint.yml
	@echo "$(COLOR_SUCCESS)Lint completed!$(COLOR_RESET)"
```

---

## 6. ディレクトリ構造

```
PrototypeChatClientApp/
├── Makefile                      # メインMakefile
├── .swiftformat                  # SwiftFormat設定
├── .swiftlint.yml                # SwiftLint設定
├── scripts/                      # 補助スクリプト
│   ├── setup.sh                 # 初期セットアップ
│   ├── clean-build.sh           # 完全クリーンビルド
│   └── bump-version.sh          # バージョン更新
├── PrototypeChatClientApp.xcodeproj
├── PrototypeChatClientApp/
└── DerivedData/                  # ビルド成果物（gitignore）
```

---

## 7. 使用フロー

### 7.1 初回セットアップ

```bash
# リポジトリクローン後
cd PrototypeChatClientApp

# 依存ツールインストール（オプション）
brew install xcpretty swiftformat swiftlint

# 初期セットアップスクリプト実行（オプション）
make setup

# 利用可能なコマンド確認
make help
```

### 7.2 日常的な開発フロー

```bash
# 1. ビルド確認
make build

# 2. シミュレータで実行
make run

# 3. コード変更後の再実行
make run  # ビルド→インストール→起動を一括実行

# 4. テスト実行
make test

# 5. クリーンビルド（問題発生時）
make clean
make build
```

### 7.3 トラブルシューティング

```bash
# シミュレータリセット
make reset

# パッケージキャッシュリセット
make reset-packages

# 完全クリーンビルド
make clean
rm -rf ~/Library/Developer/Xcode/DerivedData/PrototypeChatClientApp-*
make build
```

---

## 8. 環境変数による設定

### 8.1 デバイス切り替え

```bash
# iPhone 15 Proで実行
DEVICE="iPhone 15 Pro" make run

# iPadで実行
DEVICE="iPad Pro (12.9-inch)" make run
```

### 8.2 ビルド設定切り替え

```bash
# Releaseビルド
CONFIGURATION=Release make build

# 別のスキーム指定
SCHEME="PrototypeChatClientApp-Debug" make build
```

### 8.3 .env ファイル対応（オプション）

```bash
# .env.local ファイル作成
cat > .env.local <<EOF
DEVICE="iPhone 15 Pro"
CONFIGURATION=Debug
EOF

# Makefileで読み込み
-include .env.local
```

---

## 9. CI/CD統合

### 9.1 GitHub Actions連携

```yaml
# .github/workflows/ci.yml
name: iOS CI

on: [push, pull_request]

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Xcode
        run: sudo xcode-select -s /Applications/Xcode.app
      - name: Install dependencies
        run: make setup
      - name: Build
        run: make build
      - name: Test
        run: make test
```

### 9.2 CIコマンド

```makefile
ci: clean build test ## CI環境でのビルド・テスト
	@echo "$(COLOR_SUCCESS)CI pipeline completed!$(COLOR_RESET)"
```

---

## 10. 高度な機能（将来的な拡張）

### 10.1 複数シミュレータでの並列実行

```makefile
run-all: ## 複数デバイスで同時起動
	@echo "$(COLOR_INFO)Launching on multiple devices...$(COLOR_RESET)"
	$(MAKE) run DEVICE="iPhone 15" &
	$(MAKE) run DEVICE="iPhone 15 Pro Max" &
	$(MAKE) run DEVICE="iPad Pro (12.9-inch)" &
	wait
```

### 10.2 スクリーンショット自動取得

```makefile
screenshots: ## スクリーンショット取得
	@echo "$(COLOR_INFO)Taking screenshots...$(COLOR_RESET)"
	xcrun simctl io $(SIMULATOR_ID) screenshot screenshot.png
	open screenshot.png
```

### 10.3 アプリログのリアルタイム表示

```makefile
logs: ## アプリログをリアルタイム表示
	xcrun simctl spawn $(SIMULATOR_ID) log stream --predicate 'processImagePath contains "PrototypeChatClientApp"'
```

---

## 11. ベストプラクティス

### 11.1 命名規則

- **短く覚えやすい**: `run`, `test`, `clean`
- **動詞で始める**: `build`, `open`, `reset`
- **ハイフン区切り**: `clean-build`, `reset-packages`

### 11.2 エラーハンドリング

```makefile
build:
	@xcodebuild build ... || (echo "$(COLOR_ERROR)Build failed!$(COLOR_RESET)" && exit 1)
```

### 11.3 依存関係の明示

```makefile
run: build boot install launch ## ビルド→起動→インストール→実行

install: build
	# インストール処理

launch: install
	# 起動処理
```

---

## 12. チーム開発への配慮

### 12.1 READMEへの記載

```markdown
## 開発コマンド

```bash
# ビルド・実行
make run

# テスト実行
make test

# 全コマンド確認
make help
```

### 12.2 ドキュメント化

- Makefile内にコメント（`##`）でヘルプテキスト記載
- `make help`で自動的にヘルプ表示
- チームメンバーが直感的に使える

---

## 13. FAQ

### Q1. Makefileがない環境では？

A1. Makefileをプロジェクトルートに配置すれば、`make`コマンドが利用可能です。

### Q2. xcprettyがない場合は？

A2. Makefileでは以下のようにフォールバックします：

```makefile
XCPRETTY := $(shell command -v xcpretty 2> /dev/null)

build:
ifdef XCPRETTY
	xcodebuild build ... | xcpretty
else
	xcodebuild build ...
endif
```

### Q3. シミュレータが見つからない場合は？

A3. `make devices`で利用可能なデバイスを確認し、Makefile内の`DEVICE`変数を更新してください。

---

## 14. 参考リンク

### 14.1 公式ドキュメント
- [xcodebuild Man Page](https://developer.apple.com/library/archive/technotes/tn2339/_index.html)
- [xcrun simctl Documentation](https://developer.apple.com/documentation/xcode/running-your-app-in-the-simulator-or-on-a-device)

### 14.2 ツール
- [xcpretty](https://github.com/xcpretty/xcpretty)
- [SwiftFormat](https://github.com/nicklockwood/SwiftFormat)
- [SwiftLint](https://github.com/realm/SwiftLint)

---

**ドキュメント作成日**: 2025年12月11日
**対象環境**: macOS + Xcode 15+
**作成者**: iOS Development Team
