# CI/CD・環境整備 詳細提案書
## PrototypeChatClientApp - Phase-based Implementation Plan

**提案日**: 2025年12月23日
**対象**: iOSアプリケーション (MVVM + Clean Architecture)
**現状**: Makefile充実、テスト実装済み、3つのBuild Configuration運用中
**目標**: CI/CD自動化、環境管理最適化、コード品質自動チェック

---

## エグゼクティブサマリー

### 現状分析
- ✅ **強み**: 充実したMakefile、テストコード実装済み、3環境運用 (Debug/Development/Release)
- ⚠️ **課題**: GitHub Actions未導入、xcconfig未使用、SwiftLint/SwiftFormat未設定、Secrets管理未整備
- 📊 **テストカバレッジ**: 約40% (Domain/UseCaseレイヤーのみ)

### 期待効果
| 項目 | 改善前 | Phase 1完了後 | Phase 3完了後 |
|------|--------|---------------|---------------|
| ビルド検証 | 手動 | PR毎に自動 | 自動+品質ゲート |
| テスト実行 | 手動 | PR毎に自動 | カバレッジ70%達成 |
| コード品質 | レビュー依存 | SwiftLint自動 | 自動+解析レポート |
| 環境切替 | Makefile変数 | xcconfig化 | Secrets自動注入 |
| デプロイ | 手動のみ | - | TestFlight自動配布 |

### 総工数・コスト
- **Phase 1** (必須): 8-12時間 (1.5-2日)
- **Phase 2** (推奨): 10-15時間 (2-3日)
- **Phase 3** (高度): 15-20時間 (3-4日)
- **合計**: 33-47時間 (約1週間)

---

# Phase 1: 基盤構築 (必須・最優先)
**期間**: 1.5-2日 | **工数**: 8-12時間 | **難易度**: 中

## 1.1 GitHub Actions - 基本CI構築

### 目的
- プルリクエスト毎のビルド・テスト自動化
- main/developブランチの品質保証
- 早期バグ検出

### 実装: `.github/workflows/ci.yml`

```yaml
name: CI

on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main, develop]

env:
  XCODE_VERSION: '15.2'
  IOS_SIMULATOR: 'iPhone 16'
  IOS_VERSION: '17.2'

jobs:
  build-and-test:
    name: Build & Test
    runs-on: macos-14
    timeout-minutes: 30

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Select Xcode version
        run: sudo xcode-select -s /Applications/Xcode_${{ env.XCODE_VERSION }}.app

      - name: Show Xcode version
        run: xcodebuild -version

      - name: Cache SPM dependencies
        uses: actions/cache@v4
        with:
          path: |
            .build
            ~/Library/Caches/org.swift.swiftpm
          key: ${{ runner.os }}-spm-${{ hashFiles('**/Package.resolved') }}
          restore-keys: |
            ${{ runner.os }}-spm-

      - name: Resolve Swift Package dependencies
        run: make resolve

      - name: Build (Debug configuration)
        run: |
          xcodebuild build \
            -project PrototypeChatClientApp.xcodeproj \
            -scheme PrototypeChatClientApp \
            -destination "platform=iOS Simulator,name=${{ env.IOS_SIMULATOR }},OS=${{ env.IOS_VERSION }}" \
            -configuration Debug \
            -derivedDataPath ./DerivedData \
            | xcpretty && exit ${PIPESTATUS[0]}

      - name: Run Unit Tests
        run: |
          xcodebuild test \
            -project PrototypeChatClientApp.xcodeproj \
            -scheme PrototypeChatClientApp \
            -destination "platform=iOS Simulator,name=${{ env.IOS_SIMULATOR }},OS=${{ env.IOS_VERSION }}" \
            -configuration Debug \
            -derivedDataPath ./DerivedData \
            -enableCodeCoverage YES \
            | xcpretty && exit ${PIPESTATUS[0]}

      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: test-results
          path: |
            DerivedData/Logs/Test/*.xcresult
          retention-days: 7

  # 複数環境ビルド検証 (main/developブランチのみ)
  build-matrix:
    name: Build - ${{ matrix.configuration }}
    runs-on: macos-14
    if: github.ref == 'refs/heads/main' || github.ref == 'refs/heads/develop'
    timeout-minutes: 20
    strategy:
      fail-fast: false
      matrix:
        configuration: [Debug, Development, Release]

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Select Xcode version
        run: sudo xcode-select -s /Applications/Xcode_${{ env.XCODE_VERSION }}.app

      - name: Cache SPM dependencies
        uses: actions/cache@v4
        with:
          path: |
            .build
            ~/Library/Caches/org.swift.swiftpm
          key: ${{ runner.os }}-spm-${{ hashFiles('**/Package.resolved') }}

      - name: Resolve dependencies
        run: make resolve

      - name: Build - ${{ matrix.configuration }}
        run: make build CONFIGURATION=${{ matrix.configuration }}
```

### セキュリティ考慮事項

1. **Permissions設定** (推奨)
```yaml
permissions:
  contents: read
  pull-requests: write  # PR コメント投稿用
  checks: write  # ステータスチェック更新用
```

2. **タイムアウト設定**
```yaml
timeout-minutes: 30  # 無限実行防止
```

3. **Secrets管理** (Phase 2で詳述)
- `BACKEND_URL` はまだハードコード可 (localhost/production URLのみ)
- API キー等が必要になる場合は GitHub Secrets 使用

### 期待効果
- ✅ PR毎に自動ビルド・テスト実行 (約15-20分/回)
- ✅ ビルド失敗の早期検出 (コミット後5分以内)
- ✅ 3環境全てのビルド検証 (main/developブランチ)

### 工数: 3-4時間
- ワークフロー作成: 1時間
- テスト・調整: 2-3時間

---

## 1.2 xconfigファイル導入

### 目的
- Build Settings のバージョン管理
- 環境依存設定の一元管理
- チーム開発での設定統一

### ファイル構成

```
Config/
├── Shared.xcconfig              # 全環境共通設定
├── Debug.xcconfig               # localhost backend
├── Development.xcconfig         # production backend (開発用)
└── Release.xcconfig             # production backend (本番用)
```

### 実装例

#### `Config/Shared.xcconfig`
```xcconfig
// ===================================================
// Shared Configuration - All Environments
// ===================================================

// App Information
APP_DISPLAY_NAME = PrototypeChat
PRODUCT_BUNDLE_IDENTIFIER = com.linnefromice.PrototypeChatClientApp

// Deployment
IPHONEOS_DEPLOYMENT_TARGET = 16.0
TARGETED_DEVICE_FAMILY = 1  // iPhone only

// Swift Compiler
SWIFT_VERSION = 5.9
ENABLE_BITCODE = NO
SWIFT_OPTIMIZATION_LEVEL = -Onone  // Override in Release

// Code Signing
CODE_SIGN_STYLE = Automatic
DEVELOPMENT_TEAM = YOUR_TEAM_ID  // TODO: Replace with actual team ID

// Build Options
SKIP_INSTALL = NO
ENABLE_TESTABILITY = YES

// Asset Catalog
ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon
ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor
```

#### `Config/Debug.xcconfig`
```xcconfig
// ===================================================
// Debug Configuration - Localhost Backend
// ===================================================

#include "Shared.xcconfig"

// Backend Configuration
BACKEND_URL = http:/$()/localhost:8787
ENVIRONMENT_NAME = Debug
API_TIMEOUT = 30.0

// Compiler Optimization
SWIFT_OPTIMIZATION_LEVEL = -Onone
GCC_OPTIMIZATION_LEVEL = 0

// Debug Flags
SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG
GCC_PREPROCESSOR_DEFINITIONS = DEBUG=1

// Code Signing
CODE_SIGN_IDENTITY = iPhone Developer

// Other
VALIDATE_PRODUCT = NO
ENABLE_TESTABILITY = YES

// Logging
LOG_LEVEL = verbose
```

#### `Config/Development.xcconfig`
```xcconfig
// ===================================================
// Development Configuration - Production Backend
// ===================================================

#include "Shared.xcconfig"

// Backend Configuration
BACKEND_URL = https:/$()/prototype-hono-drizzle-backend.linnefromice.workers.dev
ENVIRONMENT_NAME = Development
API_TIMEOUT = 20.0

// Compiler Optimization
SWIFT_OPTIMIZATION_LEVEL = -O
GCC_OPTIMIZATION_LEVEL = s

// Debug Flags
SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEVELOPMENT
GCC_PREPROCESSOR_DEFINITIONS = DEVELOPMENT=1

// Code Signing
CODE_SIGN_IDENTITY = iPhone Developer

// Other
VALIDATE_PRODUCT = YES
ENABLE_TESTABILITY = YES

// Logging
LOG_LEVEL = info
```

#### `Config/Release.xcconfig`
```xcconfig
// ===================================================
// Release Configuration - Production Backend
// ===================================================

#include "Shared.xcconfig"

// Backend Configuration
BACKEND_URL = https:/$()/prototype-hono-drizzle-backend.linnefromice.workers.dev
ENVIRONMENT_NAME = Release
API_TIMEOUT = 15.0

// Compiler Optimization
SWIFT_OPTIMIZATION_LEVEL = -O
GCC_OPTIMIZATION_LEVEL = s
SWIFT_COMPILATION_MODE = wholemodule

// Debug Flags (None)
SWIFT_ACTIVE_COMPILATION_CONDITIONS = RELEASE
GCC_PREPROCESSOR_DEFINITIONS = RELEASE=1

// Code Signing
CODE_SIGN_IDENTITY = iPhone Distribution

// Other
VALIDATE_PRODUCT = YES
ENABLE_TESTABILITY = NO
COPY_PHASE_STRIP = YES
STRIP_INSTALLED_PRODUCT = YES

// Security
ENABLE_NS_ASSERTIONS = NO

// Logging
LOG_LEVEL = error
```

### Xcodeプロジェクト設定手順

1. **xcconfig ファイル作成**
```bash
mkdir -p Config
# 上記4ファイルを Config/ に配置
```

2. **Xcodeプロジェクトに追加**
- Xcodeで Config フォルダをプロジェクトにドラッグ
- "Create groups" を選択
- Target には追加しない (チェックを外す)

3. **Build Configuration にxcconfig を関連付け**
- Project → Info → Configurations
- Debug → PrototypeChatClientApp → `Config/Debug.xcconfig`
- Development → PrototypeChatClientApp → `Config/Development.xcconfig`
- Release → PrototypeChatClientApp → `Config/Release.xcconfig`

4. **Build Settings で User-Defined Settings 削除**
- Project → Build Settings → User-Defined
- `BACKEND_URL` 等の設定を削除 (xcconfigに移行したため)

5. **Info.plist は既存のまま**
```xml
<key>BackendUrl</key>
<string>$(BACKEND_URL)</string>
<key>Configuration</key>
<string>$(CONFIGURATION)</string>
```

### 期待効果
- ✅ 設定ファイルのバージョン管理
- ✅ 環境設定の可視化・レビュー可能化
- ✅ チーム開発での設定衝突回避

### 工数: 2-3時間
- xcconfig ファイル作成: 1時間
- Xcode設定・テスト: 1-2時間

---

## 1.3 SwiftLint 基本設定

### 目的
- コードスタイル統一
- 潜在的バグの早期発見
- コードレビュー負担軽減

### インストール
```bash
brew install swiftlint
```

### 実装: `.swiftlint.yml`

```yaml
# ===================================================
# SwiftLint Configuration
# PrototypeChatClientApp - Phase 1 (基本ルール)
# ===================================================

# 対象ディレクトリ
included:
  - PrototypeChatClientApp
  - PrototypeChatClientAppTests

# 除外ディレクトリ
excluded:
  - Pods
  - DerivedData
  - .build
  - PrototypeChatClientApp/Infrastructure/Network/Generated  # OpenAPI自動生成コード

# 基本ルールの有効化
opt_in_rules:
  - empty_count
  - empty_string
  - explicit_init
  - first_where
  - sorted_imports
  - vertical_whitespace_closing_braces
  - vertical_whitespace_opening_braces

# 無効化するルール (プロジェクト特性に応じて)
disabled_rules:
  - trailing_whitespace  # 一時的に無効化、Phase 2で有効化
  - line_length  # 一時的に緩和

# ルールのカスタマイズ
line_length:
  warning: 120
  error: 200
  ignores_function_declarations: true
  ignores_comments: true

file_length:
  warning: 500
  error: 1000

function_body_length:
  warning: 60
  error: 100

type_body_length:
  warning: 300
  error: 500

cyclomatic_complexity:
  warning: 15
  error: 25

nesting:
  type_level: 2

identifier_name:
  min_length:
    warning: 2
    error: 1
  max_length:
    warning: 50
    error: 60
  excluded:
    - id
    - db
    - i
    - j
    - k
    - x
    - y
    - z

type_name:
  min_length: 3
  max_length:
    warning: 50
    error: 60

# カスタムルール (Phase 2で追加検討)
# custom_rules:

# レポーター設定
reporter: "xcode"  # Xcodeでの表示に最適化
```

### Makefile 統合

既存のMakefileに以下を追加 (すでに `lint` ターゲットは存在):

```makefile
lint: ## Run SwiftLint
	@if command -v swiftlint > /dev/null; then \
		echo "$(COLOR_INFO)Running SwiftLint...$(COLOR_RESET)"; \
		swiftlint lint --strict; \
		echo "$(COLOR_SUCCESS)✓ Lint completed!$(COLOR_RESET)"; \
	else \
		echo "$(COLOR_WARNING)⚠ SwiftLint not installed$(COLOR_RESET)"; \
		echo "$(COLOR_INFO)Install: brew install swiftlint$(COLOR_RESET)"; \
	fi

lint-autocorrect: ## Auto-correct SwiftLint violations
	@if command -v swiftlint > /dev/null; then \
		echo "$(COLOR_INFO)Auto-correcting SwiftLint violations...$(COLOR_RESET)"; \
		swiftlint --fix; \
		echo "$(COLOR_SUCCESS)✓ Auto-correction completed!$(COLOR_RESET)"; \
	else \
		echo "$(COLOR_ERROR)✗ SwiftLint not installed$(COLOR_RESET)"; \
	fi
```

### GitHub Actions 統合

`.github/workflows/ci.yml` に追加:

```yaml
  swiftlint:
    name: SwiftLint
    runs-on: macos-14
    timeout-minutes: 10

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Install SwiftLint
        run: brew install swiftlint

      - name: Run SwiftLint
        run: |
          swiftlint lint --strict --reporter github-actions-logging

      - name: Upload SwiftLint results
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: swiftlint-results
          path: swiftlint.log
```

### 期待効果
- ✅ コードスタイルの自動チェック
- ✅ PR時の品質ゲート (CI失敗でマージ不可)
- ✅ レビュー時の指摘削減 (スタイル面)

### 工数: 2-3時間
- `.swiftlint.yml` 作成: 1時間
- 既存コードの警告修正: 1-2時間

---

## 1.4 Makefile の拡張

### 追加コマンド案

```makefile
# ===================================================
# CI/CD Commands
# ===================================================

ci-check: clean lint build test ## Run full CI check locally
	@echo "$(COLOR_SUCCESS)✓ All CI checks passed!$(COLOR_RESET)"

pre-commit: lint ## Run pre-commit checks
	@echo "$(COLOR_INFO)Running pre-commit checks...$(COLOR_RESET)"
	@git diff --cached --name-only | grep "\.swift$$" | xargs swiftlint lint --strict --quiet
	@echo "$(COLOR_SUCCESS)✓ Pre-commit checks passed!$(COLOR_RESET)"

# ===================================================
# Code Coverage
# ===================================================

coverage: ## Generate test coverage report
	@echo "$(COLOR_INFO)Generating coverage report...$(COLOR_RESET)"
	@xcodebuild test \
		-project $(WORKSPACE) \
		-scheme $(SCHEME) \
		-destination "platform=iOS Simulator,name=$(DEVICE)" \
		-configuration Debug \
		-enableCodeCoverage YES \
		-derivedDataPath $(DERIVED_DATA) \
		| xcpretty
	@echo "$(COLOR_SUCCESS)✓ Coverage report generated!$(COLOR_RESET)"
	@echo "$(COLOR_INFO)View in Xcode: $(DERIVED_DATA)/Logs/Test/*.xcresult$(COLOR_RESET)"

coverage-html: coverage ## Generate HTML coverage report (requires xcov)
	@if command -v xcov > /dev/null; then \
		xcov --scheme $(SCHEME) --derived_data_path $(DERIVED_DATA); \
		open xcov_report/index.html; \
	else \
		echo "$(COLOR_WARNING)⚠ xcov not installed$(COLOR_RESET)"; \
		echo "$(COLOR_INFO)Install: gem install xcov$(COLOR_RESET)"; \
	fi

# ===================================================
# Environment Info
# ===================================================

env-debug: ## Show Debug environment configuration
	@echo "$(COLOR_INFO)Debug Environment$(COLOR_RESET)"
	@make info CONFIGURATION=Debug

env-dev: ## Show Development environment configuration
	@echo "$(COLOR_INFO)Development Environment$(COLOR_RESET)"
	@make info CONFIGURATION=Development

env-release: ## Show Release environment configuration
	@echo "$(COLOR_INFO)Release Environment$(COLOR_RESET)"
	@make info CONFIGURATION=Release
```

### Git Hooks 設定 (Optional)

```bash
# .git/hooks/pre-commit に追加
#!/bin/sh
make pre-commit
```

### 期待効果
- ✅ ローカルでCI環境を再現可能
- ✅ コミット前の品質チェック自動化
- ✅ カバレッジレポート生成の簡略化

### 工数: 1-2時間

---

## Phase 1 完了基準

- [ ] GitHub Actions ワークフロー作成 (`.github/workflows/ci.yml`)
- [ ] xcconfig ファイル4種類作成・適用
- [ ] `.swiftlint.yml` 作成・ルール適用
- [ ] Makefile拡張 (`ci-check`, `coverage`, 等)
- [ ] PR作成時にCIが自動実行されることを確認
- [ ] 全3環境でビルド成功を確認
- [ ] SwiftLint警告件数 0件達成 (または許容範囲内)

**成果物チェックリスト**:
```bash
make ci-check          # ローカルで全チェック実行
make env-debug         # Debug環境確認
make env-dev           # Development環境確認
make env-release       # Release環境確認
```

---

# Phase 2: 品質強化 (推奨)
**期間**: 2-3日 | **工数**: 10-15時間 | **難易度**: 中〜高

## 2.1 テストカバレッジ向上

### 現状分析
- **現在**: 約40% (Domain/UseCaseレイヤーのみ)
- **目標**: 70% (Presentationレイヤー追加)

### 実装計画

#### 2.1.1 ViewModel テストの追加

**対象**: `Presentation/ViewModels/`

**テンプレート例** (`ConversationListViewModelTests.swift`):

```swift
import XCTest
@testable import PrototypeChatClientApp

@MainActor
final class ConversationListViewModelTests: XCTestCase {

    var sut: ConversationListViewModel!
    var mockUseCase: MockConversationUseCase!

    override func setUp() async throws {
        try await super.setUp()
        mockUseCase = MockConversationUseCase()
        sut = ConversationListViewModel(conversationUseCase: mockUseCase)
    }

    override func tearDown() async throws {
        sut = nil
        mockUseCase = nil
        try await super.tearDown()
    }

    func testInitialState() {
        // Given: ViewModelが初期化された

        // Then: 初期状態が正しい
        XCTAssertTrue(sut.conversations.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    func testLoadConversations_Success() async {
        // Given: モックが会話リストを返す
        let mockConversations = [
            ConversationDetail.mock(id: "1", title: "Test 1"),
            ConversationDetail.mock(id: "2", title: "Test 2")
        ]
        mockUseCase.conversationsToReturn = mockConversations

        // When: 会話リスト読み込み
        await sut.loadConversations()

        // Then: 会話リストが更新される
        XCTAssertEqual(sut.conversations.count, 2)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    func testLoadConversations_Failure() async {
        // Given: モックがエラーを返す
        mockUseCase.shouldThrowError = true

        // When: 会話リスト読み込み
        await sut.loadConversations()

        // Then: エラーメッセージが表示される
        XCTAssertTrue(sut.conversations.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNotNil(sut.errorMessage)
    }
}

// Mock UseCase
class MockConversationUseCase: ConversationUseCaseProtocol {
    var conversationsToReturn: [ConversationDetail] = []
    var shouldThrowError = false

    func getConversations() async throws -> [ConversationDetail] {
        if shouldThrowError {
            throw NSError(domain: "Test", code: 1)
        }
        return conversationsToReturn
    }
}
```

**対象ViewModels**:
1. ✅ `AuthenticationViewModel` (既存テストあり)
2. ❌ `ConversationListViewModel` (新規作成)
3. ❌ `ChatRoomViewModel` (新規作成)
4. ❌ `CreateConversationViewModel` (新規作成)

**工数**: 6-8時間 (ViewModel 3つ × 2-3時間)

---

#### 2.1.2 Repository テストの追加

**対象**: `Data/Repositories/Default*Repository.swift`

**テンプレート例** (`DefaultConversationRepositoryTests.swift`):

```swift
import XCTest
@testable import PrototypeChatClientApp

final class DefaultConversationRepositoryTests: XCTestCase {

    var sut: DefaultConversationRepository!
    var mockNetworkService: MockNetworkService!

    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        sut = DefaultConversationRepository(networkService: mockNetworkService)
    }

    override func tearDown() {
        sut = nil
        mockNetworkService = nil
        super.tearDown()
    }

    func testGetConversations_Success() async throws {
        // Given: ネットワークサービスが成功レスポンスを返す
        let mockResponse = ConversationsResponse.mock()
        mockNetworkService.responseToReturn = mockResponse

        // When: 会話リスト取得
        let conversations = try await sut.getConversations()

        // Then: 正しいデータが返される
        XCTAssertEqual(conversations.count, mockResponse.conversations.count)
        XCTAssertEqual(mockNetworkService.requestCallCount, 1)
    }

    func testGetConversations_NetworkError() async {
        // Given: ネットワークエラー
        mockNetworkService.shouldThrowError = true

        // When/Then: エラーがthrowされる
        do {
            _ = try await sut.getConversations()
            XCTFail("Should throw error")
        } catch {
            XCTAssertNotNil(error)
        }
    }
}
```

**工数**: 2-3時間

---

#### 2.1.3 カバレッジ計測の自動化

`.github/workflows/ci.yml` に追加:

```yaml
  test-coverage:
    name: Test Coverage
    runs-on: macos-14
    timeout-minutes: 30

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_15.2.app

      - name: Run tests with coverage
        run: |
          xcodebuild test \
            -project PrototypeChatClientApp.xcodeproj \
            -scheme PrototypeChatClientApp \
            -destination "platform=iOS Simulator,name=iPhone 16" \
            -enableCodeCoverage YES \
            -derivedDataPath ./DerivedData \
            | xcpretty

      - name: Generate coverage report
        run: |
          xcrun xccov view --report --only-targets \
            DerivedData/Logs/Test/*.xcresult > coverage.txt
          cat coverage.txt

      - name: Check coverage threshold
        run: |
          COVERAGE=$(xcrun xccov view --report --only-targets DerivedData/Logs/Test/*.xcresult | grep "PrototypeChatClientApp.app" | awk '{print $4}' | sed 's/%//')
          echo "Coverage: ${COVERAGE}%"
          if (( $(echo "$COVERAGE < 70.0" | bc -l) )); then
            echo "❌ Coverage ${COVERAGE}% is below 70% threshold"
            exit 1
          fi
          echo "✅ Coverage ${COVERAGE}% meets 70% threshold"

      - name: Upload coverage report
        uses: actions/upload-artifact@v4
        with:
          name: coverage-report
          path: coverage.txt
```

**期待効果**:
- ✅ PR毎にカバレッジ計測
- ✅ カバレッジ70%未満でCI失敗
- ✅ カバレッジレポート自動生成

**工数**: 2-3時間

---

## 2.2 SwiftFormat 導入

### 目的
- コードフォーマット自動化
- チーム開発でのスタイル統一
- レビューでのノイズ削減

### インストール
```bash
brew install swiftformat
```

### 実装: `.swiftformat`

```swift
# ===================================================
# SwiftFormat Configuration
# PrototypeChatClientApp
# ===================================================

# Swift version
--swiftversion 5.9

# Indentation
--indent 4
--tabwidth 4
--indentcase false
--ifdef no-indent

# Spacing
--trimwhitespace always
--nospaceoperators ..<, ..., >>, <<
--ranges spaced

# Wrapping
--maxwidth 120
--wraparguments before-first
--wrapparameters before-first
--wrapcollections before-first
--closingparen balanced

# Braces
--allman false  # K&R style (開き波括弧を同じ行に)

# Semicolons
--semicolons never

# Commas
--commas always

# Blank Lines
--emptybraces no-space
--linebreaks lf

# Imports
--importgrouping testable-bottom

# Headers
--header strip

# File options
--exclude Pods,DerivedData,.build,PrototypeChatClientApp/Infrastructure/Network/Generated

# Rules (disabled)
--disable redundantSelf  # self の明示的使用を許可
--disable unusedArguments  # 未使用引数の警告を無効化 (Protocol実装時)

# Rules (enabled)
--enable isEmpty
--enable sortedImports
```

### Makefile統合

```makefile
format: ## Format Swift code with SwiftFormat
	@if command -v swiftformat > /dev/null; then \
		echo "$(COLOR_INFO)Formatting Swift code...$(COLOR_RESET)"; \
		swiftformat . --config .swiftformat; \
		echo "$(COLOR_SUCCESS)✓ Formatting completed!$(COLOR_RESET)"; \
	else \
		echo "$(COLOR_WARNING)⚠ SwiftFormat not installed$(COLOR_RESET)"; \
		echo "$(COLOR_INFO)Install: brew install swiftformat$(COLOR_RESET)"; \
	fi

format-check: ## Check code formatting without applying changes
	@if command -v swiftformat > /dev/null; then \
		echo "$(COLOR_INFO)Checking code format...$(COLOR_RESET)"; \
		swiftformat . --config .swiftformat --lint; \
		echo "$(COLOR_SUCCESS)✓ Format check completed!$(COLOR_RESET)"; \
	else \
		echo "$(COLOR_ERROR)✗ SwiftFormat not installed$(COLOR_RESET)"; \
	fi
```

### GitHub Actions統合

`.github/workflows/ci.yml` に追加:

```yaml
  swiftformat:
    name: SwiftFormat Check
    runs-on: macos-14
    timeout-minutes: 10

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Install SwiftFormat
        run: brew install swiftformat

      - name: Run SwiftFormat (lint mode)
        run: |
          swiftformat . --config .swiftformat --lint
```

**期待効果**:
- ✅ コード整形自動化
- ✅ PR時にフォーマット違反を検出
- ✅ チーム全体でのコードスタイル統一

**工数**: 2-3時間
- `.swiftformat` 作成: 1時間
- 既存コード整形: 1-2時間

---

## 2.3 Secrets管理の導入

### 目的
- APIキー等の機密情報をコードから分離
- GitHub Actionsでの安全なビルド
- チーム開発での情報共有最小化

### 実装方針

#### 2.3.1 GitHub Secrets設定

```bash
# Repository Settings → Secrets → Actions で設定

# 必須Secrets
BACKEND_URL_PRODUCTION=https://prototype-hono-drizzle-backend.linnefromice.workers.dev
BACKEND_URL_LOCALHOST=http://localhost:8787

# 将来的に必要になるSecrets (Phase 3)
APP_STORE_CONNECT_API_KEY=<base64 encoded p8>
MATCH_PASSWORD=<fastlane match password>
APPLE_TEAM_ID=<10文字のチームID>
```

#### 2.3.2 GitHub Actions でのSecrets利用

`.github/workflows/ci.yml` 修正:

```yaml
env:
  BACKEND_URL: ${{ secrets.BACKEND_URL_PRODUCTION }}  # Development/Release用
  BACKEND_URL_DEBUG: ${{ secrets.BACKEND_URL_LOCALHOST }}  # Debug用
```

#### 2.3.3 ローカル開発での Secrets管理

**方法1: xcconfig の Git管理対象外化** (推奨)

```bash
# .gitignore に追加
Config/Secrets.xcconfig
```

```xcconfig
// Config/Secrets.xcconfig (Git管理対象外)
BACKEND_URL = http://localhost:8787
APPLE_TEAM_ID = YOUR_TEAM_ID
```

```xcconfig
// Config/Debug.xcconfig
#include "Secrets.xcconfig"  // Secretsを読み込み
#include "Shared.xcconfig"

// その他の設定...
```

**方法2: .env ファイル + Xconfigスクリプト** (高度)

```bash
# .env (Git管理対象外)
BACKEND_URL_DEBUG=http://localhost:8787
BACKEND_URL_PRODUCTION=https://...
```

Build Phase で `.env` → xcconfig 変換スクリプト実行

**工数**: 3-4時間

---

## 2.4 Danger の導入 (Optional)

### 目的
- PR自動レビュー
- チェックリスト強制
- レビュー観点の標準化

### 実装: `Dangerfile`

```ruby
# ===================================================
# Danger Configuration
# PrototypeChatClientApp
# ===================================================

# PR情報
pr_title = github.pr_title
pr_body = github.pr_body || ""
changed_files = git.added_files + git.modified_files

# ===================================================
# ファイル変更チェック
# ===================================================

# Info.plist や xcconfig 変更時の警告
if changed_files.include?("PrototypeChatClientApp/Info.plist")
  warn("⚠️ Info.plist が変更されています。設定変更が意図的か確認してください。")
end

if changed_files.any? { |file| file.include?(".xcconfig") }
  warn("⚠️ xcconfig が変更されています。全環境でビルド確認してください。")
end

# ===================================================
# PRサイズチェック
# ===================================================

# 変更行数が多い場合の警告
if git.lines_of_code > 500
  warn("⚠️ PR が大きすぎます (#{git.lines_of_code}行)。分割を検討してください。")
end

# ===================================================
# テストファイルチェック
# ===================================================

# 実装ファイルが追加された場合、テストファイルも追加されているか確認
added_swift_files = git.added_files.select { |file| file.end_with?(".swift") && !file.include?("Tests") }
added_test_files = git.added_files.select { |file| file.include?("Tests") && file.end_with?(".swift") }

if added_swift_files.any? && added_test_files.empty?
  warn("⚠️ 新規実装ファイルが追加されましたが、テストファイルがありません。")
end

# ===================================================
# PR説明チェック
# ===================================================

# PR本文が空の場合
if pr_body.length < 10
  fail("❌ PR説明を記載してください。")
end

# チェックリストの確認
unless pr_body.include?("- [x]") || pr_body.include?("- [X]")
  warn("⚠️ PR テンプレートのチェックリストを完了してください。")
end

# ===================================================
# SwiftLint 統合
# ===================================================

swiftlint.config_file = '.swiftlint.yml'
swiftlint.lint_files inline_mode: true

# ===================================================
# カバレッジチェック (Phase 2後半)
# ===================================================

# カバレッジが下がっている場合の警告
# (xcov gem が必要)
# xcov.report(
#   scheme: 'PrototypeChatClientApp',
#   minimum_coverage_percentage: 70.0
# )

# ===================================================
# 成功メッセージ
# ===================================================

message("✅ 自動チェック完了！レビューをお待ちください。")
```

### GitHub Actions統合

`.github/workflows/ci.yml` に追加:

```yaml
  danger:
    name: Danger
    runs-on: macos-14
    timeout-minutes: 10
    if: github.event_name == 'pull_request'

    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Danger が diff を取得するために必要

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
          bundler-cache: true

      - name: Install Danger
        run: |
          gem install danger
          gem install danger-swiftlint

      - name: Run Danger
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: danger
```

**期待効果**:
- ✅ PR自動レビュー
- ✅ レビュー観点の標準化
- ✅ レビュアー負担軽減

**工数**: 2-3時間

---

## Phase 2 完了基準

- [ ] ViewModelテスト3つ追加 (ConversationList, ChatRoom, CreateConversation)
- [ ] カバレッジ70%達成
- [ ] SwiftFormat導入・既存コード整形完了
- [ ] GitHub Secrets設定完了
- [ ] Danger導入 (Optional)
- [ ] CI でカバレッジチェック・フォーマットチェック実行確認

**成果物チェックリスト**:
```bash
make test                   # カバレッジ70%以上
make format-check           # フォーマット違反なし
make lint                   # SwiftLint警告なし
```

---

# Phase 3: デプロイメント自動化 (高度)
**期間**: 3-4日 | **工数**: 15-20時間 | **難易度**: 高

## 3.1 Fastlane 導入

### 目的
- TestFlight配布自動化
- ビルド番号管理自動化
- スクリーンショット生成自動化

### インストール

```bash
# Fastlane インストール
sudo gem install fastlane

# 初期化
cd /path/to/PrototypeChatClientApp
fastlane init
```

### 実装: `fastlane/Fastfile`

```ruby
# ===================================================
# Fastlane Configuration
# PrototypeChatClientApp
# ===================================================

default_platform(:ios)

platform :ios do

  # ===================================================
  # Variables
  # ===================================================

  SCHEME = "PrototypeChatClientApp"
  PROJECT = "PrototypeChatClientApp.xcodeproj"
  BUNDLE_ID = "com.linnefromice.PrototypeChatClientApp"

  # ===================================================
  # Before All
  # ===================================================

  before_all do
    ensure_git_status_clean unless ENV['FASTLANE_SKIP_GIT_CHECK']
  end

  # ===================================================
  # Lanes - Testing
  # ===================================================

  desc "Run all tests"
  lane :test do
    run_tests(
      scheme: SCHEME,
      devices: ["iPhone 16"],
      code_coverage: true,
      output_directory: "./fastlane/test_output",
      result_bundle: true
    )
  end

  desc "Run tests and generate coverage report"
  lane :coverage do
    test
    xcov(
      scheme: SCHEME,
      minimum_coverage_percentage: 70.0,
      output_directory: "./fastlane/coverage_report"
    )
  end

  # ===================================================
  # Lanes - Build
  # ===================================================

  desc "Build Debug (localhost backend)"
  lane :build_debug do
    build_app(
      scheme: SCHEME,
      configuration: "Debug",
      export_method: "development",
      output_directory: "./build",
      output_name: "#{SCHEME}-Debug.ipa",
      clean: true
    )
  end

  desc "Build Development (production backend for testing)"
  lane :build_development do
    build_app(
      scheme: SCHEME,
      configuration: "Development",
      export_method: "development",
      output_directory: "./build",
      output_name: "#{SCHEME}-Development.ipa",
      clean: true
    )
  end

  desc "Build Release (App Store)"
  lane :build_release do
    build_app(
      scheme: SCHEME,
      configuration: "Release",
      export_method: "app-store",
      output_directory: "./build",
      output_name: "#{SCHEME}-Release.ipa",
      clean: true
    )
  end

  # ===================================================
  # Lanes - TestFlight
  # ===================================================

  desc "Deploy to TestFlight (Development build)"
  lane :beta do
    # バージョン番号の取得・インクリメント
    increment_build_number(xcodeproj: PROJECT)

    # ビルド
    build_development

    # TestFlight アップロード
    upload_to_testflight(
      skip_waiting_for_build_processing: true,
      changelog: generate_changelog,
      distribute_external: false  # 内部テスターのみ
    )

    # Slack 通知 (Optional)
    # slack(
    #   message: "🚀 TestFlight へのアップロードが完了しました",
    #   channel: "#ios-builds"
    # )

    # Git タグ作成
    add_git_tag(
      tag: "testflight/#{get_version_number}-#{get_build_number}"
    )
  end

  desc "Deploy to TestFlight (External testers)"
  lane :beta_external do
    beta

    # 外部テスターへの配布
    upload_to_testflight(
      distribute_external: true,
      groups: ["External Testers"],
      changelog: generate_changelog
    )
  end

  # ===================================================
  # Lanes - App Store
  # ===================================================

  desc "Deploy to App Store"
  lane :release do
    # バージョン確認
    ensure_git_branch(branch: "main")

    # ビルド
    build_release

    # App Store アップロード
    upload_to_app_store(
      force: true,
      skip_metadata: true,
      skip_screenshots: true,
      submit_for_review: false,  # 手動レビュー申請
      precheck_include_in_app_purchases: false
    )

    # Git タグ作成
    add_git_tag(
      tag: "release/#{get_version_number}"
    )

    # GitHub Release 作成
    github_release = set_github_release(
      repository_name: "linnefromice/PrototypeChatClientApp",
      api_token: ENV["GITHUB_TOKEN"],
      name: "v#{get_version_number}",
      tag_name: "release/#{get_version_number}",
      description: generate_changelog,
      is_draft: false
    )
  end

  # ===================================================
  # Lanes - Code Signing
  # ===================================================

  desc "Setup code signing (using match)"
  lane :setup_signing do
    match(
      type: "development",
      app_identifier: BUNDLE_ID,
      readonly: true
    )

    match(
      type: "appstore",
      app_identifier: BUNDLE_ID,
      readonly: true
    )
  end

  # ===================================================
  # Lanes - Screenshots
  # ===================================================

  desc "Generate screenshots for App Store"
  lane :screenshots do
    capture_screenshots(
      scheme: SCHEME,
      devices: [
        "iPhone 15 Pro Max",
        "iPhone 15 Pro",
        "iPhone 15",
        "iPhone SE (3rd generation)",
        "iPad Pro (12.9-inch) (6th generation)"
      ],
      languages: ["ja-JP", "en-US"],
      output_directory: "./fastlane/screenshots",
      clear_previous_screenshots: true
    )

    # スクリーンショットのフレーム追加 (Optional)
    # frame_screenshots(white: false)
  end

  # ===================================================
  # Lanes - Utility
  # ===================================================

  desc "Increment build number"
  lane :bump_build do
    increment_build_number(xcodeproj: PROJECT)
    commit_version_bump(
      message: "Bump build number to #{get_build_number}",
      xcodeproj: PROJECT
    )
  end

  desc "Increment version number (patch)"
  lane :bump_version do |options|
    bump_type = options[:type] || "patch"  # major, minor, patch
    increment_version_number(
      bump_type: bump_type,
      xcodeproj: PROJECT
    )
    commit_version_bump(
      message: "Bump version to #{get_version_number}",
      xcodeproj: PROJECT
    )
  end

  # ===================================================
  # Private Lanes
  # ===================================================

  private_lane :generate_changelog do
    # Git履歴からChangelogを生成
    changelog = changelog_from_git_commits(
      between: [last_git_tag, "HEAD"],
      pretty: "- %s",
      merge_commit_filtering: "exclude_merges"
    )
    changelog
  end

  # ===================================================
  # Error Handling
  # ===================================================

  error do |lane, exception|
    # Slack通知 (Optional)
    # slack(
    #   message: "❌ Fastlane エラー: #{exception}",
    #   success: false
    # )
  end
end
```

### 実装: `fastlane/Appfile`

```ruby
app_identifier("com.linnefromice.PrototypeChatClientApp")
apple_id("your-apple-id@example.com")  # TODO: 実際のApple IDに置き換え
team_id("YOUR_TEAM_ID")  # TODO: 実際のTeam IDに置き換え

# iTunes Connect Team ID (必要に応じて)
# itc_team_id("123456789")
```

### 実装: `fastlane/.env.default`

```bash
# ===================================================
# Fastlane Environment Variables (Default)
# ===================================================

# App Store Connect API Key (推奨)
# APP_STORE_CONNECT_API_KEY_PATH=./AuthKey_XXXXXXXXXX.p8
# APP_STORE_CONNECT_API_KEY_ID=XXXXXXXXXX
# APP_STORE_CONNECT_API_ISSUER_ID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX

# Fastlane Match (Code Signing)
# MATCH_GIT_URL=git@github.com:yourorg/certificates.git
# MATCH_PASSWORD=your-strong-password

# Slack (Optional)
# SLACK_WEBHOOK_URL=https://hooks.slack.com/services/XXX/YYY/ZZZ

# GitHub
# GITHUB_TOKEN=ghp_XXXXXXXXXXXXXXXXXXXX
```

### Makefile統合

```makefile
# ===================================================
# Fastlane Commands
# ===================================================

fastlane-test: ## Run tests via Fastlane
	@bundle exec fastlane test

fastlane-beta: ## Deploy to TestFlight
	@bundle exec fastlane beta

fastlane-release: ## Deploy to App Store
	@bundle exec fastlane release

fastlane-screenshots: ## Generate App Store screenshots
	@bundle exec fastlane screenshots
```

### 期待効果
- ✅ TestFlight配布自動化
- ✅ ビルド番号自動インクリメント
- ✅ リリースノート自動生成

### 工数: 8-10時間
- Fastlane設定: 4-5時間
- Code Signing設定: 2-3時間
- テスト・調整: 2-3時間

---

## 3.2 GitHub Actions - デプロイメント自動化

### 実装: `.github/workflows/deploy-testflight.yml`

```yaml
name: Deploy to TestFlight

on:
  push:
    branches:
      - develop
      - release/*
  workflow_dispatch:  # 手動トリガー

env:
  XCODE_VERSION: '15.2'

jobs:
  deploy:
    name: Deploy to TestFlight
    runs-on: macos-14
    timeout-minutes: 60

    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0  # 全履歴取得 (Changelog生成用)

      - name: Select Xcode version
        run: sudo xcode-select -s /Applications/Xcode_${{ env.XCODE_VERSION }}.app

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
          bundler-cache: true

      - name: Install Fastlane
        run: |
          bundle install
          bundle exec fastlane --version

      - name: Setup App Store Connect API Key
        env:
          APP_STORE_CONNECT_API_KEY_CONTENT: ${{ secrets.APP_STORE_CONNECT_API_KEY }}
        run: |
          mkdir -p ~/.appstoreconnect/private_keys
          echo -n "$APP_STORE_CONNECT_API_KEY_CONTENT" | base64 --decode > ~/.appstoreconnect/private_keys/AuthKey_${{ secrets.APP_STORE_CONNECT_API_KEY_ID }}.p8

      - name: Setup Code Signing (Match)
        env:
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
          MATCH_GIT_URL: ${{ secrets.MATCH_GIT_URL }}
        run: bundle exec fastlane setup_signing

      - name: Deploy to TestFlight
        env:
          APP_STORE_CONNECT_API_KEY_ID: ${{ secrets.APP_STORE_CONNECT_API_KEY_ID }}
          APP_STORE_CONNECT_API_ISSUER_ID: ${{ secrets.APP_STORE_CONNECT_API_ISSUER_ID }}
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
        run: bundle exec fastlane beta

      - name: Upload build artifacts
        if: success()
        uses: actions/upload-artifact@v4
        with:
          name: ipa-file
          path: build/*.ipa
          retention-days: 30

      - name: Notify Slack (Optional)
        if: success()
        run: |
          # Slack Webhook で通知 (SLACK_WEBHOOK_URL secret必要)
          echo "TestFlight deployment successful"
```

### 実装: `.github/workflows/release.yml`

```yaml
name: Release to App Store

on:
  push:
    tags:
      - 'v*.*.*'  # v1.0.0 形式のタグでトリガー

env:
  XCODE_VERSION: '15.2'

jobs:
  release:
    name: Release to App Store
    runs-on: macos-14
    timeout-minutes: 60

    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Select Xcode version
        run: sudo xcode-select -s /Applications/Xcode_${{ env.XCODE_VERSION }}.app

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
          bundler-cache: true

      - name: Install Fastlane
        run: bundle install

      - name: Setup App Store Connect API Key
        env:
          APP_STORE_CONNECT_API_KEY_CONTENT: ${{ secrets.APP_STORE_CONNECT_API_KEY }}
        run: |
          mkdir -p ~/.appstoreconnect/private_keys
          echo -n "$APP_STORE_CONNECT_API_KEY_CONTENT" | base64 --decode > ~/.appstoreconnect/private_keys/AuthKey_${{ secrets.APP_STORE_CONNECT_API_KEY_ID }}.p8

      - name: Setup Code Signing
        env:
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
          MATCH_GIT_URL: ${{ secrets.MATCH_GIT_URL }}
        run: bundle exec fastlane setup_signing

      - name: Deploy to App Store
        env:
          APP_STORE_CONNECT_API_KEY_ID: ${{ secrets.APP_STORE_CONNECT_API_KEY_ID }}
          APP_STORE_CONNECT_API_ISSUER_ID: ${{ secrets.APP_STORE_CONNECT_API_ISSUER_ID }}
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
        run: bundle exec fastlane release

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v1
        with:
          files: build/*.ipa
          generate_release_notes: true
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### 期待効果
- ✅ developブランチプッシュで自動TestFlight配布
- ✅ タグ作成で自動App Store提出
- ✅ リリースノート自動生成

### 工数: 4-6時間

---

## 3.3 バージョン管理戦略

### セマンティックバージョニング採用

```
MAJOR.MINOR.PATCH (例: 1.2.3)

MAJOR: 破壊的変更 (API変更、大規模リファクタリング)
MINOR: 新機能追加 (後方互換性あり)
PATCH: バグ修正のみ
```

### ブランチ戦略

```
main           - 本番リリース用 (App Store)
  └─ develop   - 開発ブランチ (TestFlight)
      └─ feature/xxx   - 機能開発
      └─ bugfix/xxx    - バグ修正
```

### リリースフロー

#### TestFlight配布 (開発版)
```bash
# 1. 機能開発完了
git checkout develop
git pull origin develop

# 2. ビルド番号自動インクリメント (Fastlane)
bundle exec fastlane bump_build

# 3. developにプッシュ → 自動でTestFlight配布
git push origin develop
```

#### App Storeリリース (本番)
```bash
# 1. developからmainへマージ
git checkout main
git merge --no-ff develop
git push origin main

# 2. バージョンアップ
bundle exec fastlane bump_version type:minor  # or major, patch

# 3. タグ作成 → 自動でApp Store提出
git tag v1.2.0
git push origin v1.2.0
```

### Xcodeプロジェクト設定

**Info.plist** (既存のまま):
```xml
<key>CFBundleShortVersionString</key>
<string>$(MARKETING_VERSION)</string>
<key>CFBundleVersion</key>
<string>$(CURRENT_PROJECT_VERSION)</string>
```

**Build Settings**:
- `MARKETING_VERSION` = 1.0.0 (手動/Fastlaneで更新)
- `CURRENT_PROJECT_VERSION` = 1 (自動インクリメント)

### 期待効果
- ✅ バージョン管理の自動化
- ✅ リリース履歴の明確化
- ✅ ロールバック容易性

### 工数: 2-3時間

---

## 3.4 リリースノート自動生成

### 実装方針

#### 1. コミットメッセージ規約 (Conventional Commits)

```bash
# 形式
<type>(<scope>): <subject>

# 例
feat(auth): Add biometric authentication
fix(chat): Fix message sending error
docs(readme): Update installation guide
chore(deps): Bump SwiftLint to 0.50.0
```

**Type一覧**:
- `feat`: 新機能
- `fix`: バグ修正
- `docs`: ドキュメント
- `refactor`: リファクタリング
- `test`: テスト追加
- `chore`: ビルド・ツール変更

#### 2. Changelog生成スクリプト

**`scripts/generate_changelog.sh`**:

```bash
#!/bin/bash

# ===================================================
# Changelog Generator
# ===================================================

LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
CURRENT_VERSION=${1:-"Unreleased"}

if [ -z "$LAST_TAG" ]; then
  echo "# Changelog - $CURRENT_VERSION"
  echo ""
  echo "初回リリース"
  exit 0
fi

echo "# Changelog - $CURRENT_VERSION"
echo ""
echo "## What's Changed"
echo ""

# Features
echo "### ✨ New Features"
git log ${LAST_TAG}..HEAD --pretty=format:"- %s (%h)" --grep="^feat" | sed 's/^feat[(:]//g' | sed 's/):/)/g'
echo ""

# Fixes
echo "### 🐛 Bug Fixes"
git log ${LAST_TAG}..HEAD --pretty=format:"- %s (%h)" --grep="^fix" | sed 's/^fix[(:]//g' | sed 's/):/)/g'
echo ""

# Improvements
echo "### 🔧 Improvements"
git log ${LAST_TAG}..HEAD --pretty=format:"- %s (%h)" --grep="^refactor\|^perf" | sed 's/^refactor[(:]//g' | sed 's/^perf[(:]//g' | sed 's/):/)/g'
echo ""

# Other
echo "### 📝 Other Changes"
git log ${LAST_TAG}..HEAD --pretty=format:"- %s (%h)" --grep="^docs\|^chore\|^test" | sed 's/^docs[(:]//g' | sed 's/^chore[(:]//g' | sed 's/^test[(:]//g' | sed 's/):/)/g'
echo ""

echo "**Full Changelog**: https://github.com/linnefromice/PrototypeChatClientApp/compare/${LAST_TAG}...${CURRENT_VERSION}"
```

#### 3. Fastlane統合

```ruby
# Fastfile に追加
private_lane :generate_changelog do
  sh("../scripts/generate_changelog.sh #{get_version_number}")
end
```

#### 4. GitHub Actions統合

`.github/workflows/release.yml` に追加:

```yaml
- name: Generate Changelog
  run: |
    chmod +x scripts/generate_changelog.sh
    ./scripts/generate_changelog.sh ${{ github.ref_name }} > CHANGELOG.md

- name: Create GitHub Release
  uses: softprops/action-gh-release@v1
  with:
    body_path: CHANGELOG.md
    files: build/*.ipa
```

### 期待効果
- ✅ リリースノート自動生成
- ✅ コミット履歴の可視化
- ✅ ユーザー向け変更内容の伝達

### 工数: 2-3時間

---

## Phase 3 完了基準

- [ ] Fastlane設定完了 (`Fastfile`, `Appfile`)
- [ ] GitHub Actions デプロイメントワークフロー作成
- [ ] App Store Connect API Key設定
- [ ] Fastlane Match でCode Signing設定
- [ ] developブランチプッシュでTestFlight自動配布確認
- [ ] タグ作成でApp Store自動提出確認 (テスト環境)
- [ ] Changelog自動生成確認

**成果物チェックリスト**:
```bash
bundle exec fastlane test           # テスト実行
bundle exec fastlane beta           # TestFlight配布 (ローカル)
bundle exec fastlane screenshots    # スクリーンショット生成
scripts/generate_changelog.sh      # Changelog生成
```

---

# 総合運用ガイド

## 日常開発フロー

### 1. 機能開発開始
```bash
git checkout develop
git pull origin develop
git checkout -b feature/new-feature

# 開発...
make build
make test
make lint
```

### 2. コミット
```bash
# Conventional Commits形式
git commit -m "feat(chat): Add message reactions"
```

### 3. PR作成
```bash
git push origin feature/new-feature
# GitHub UI でPR作成
# → GitHub Actions が自動で CI 実行
# → Danger が自動レビュー
# → SwiftLint/SwiftFormat/Tests 全て通過で Merge可能
```

### 4. TestFlight配布
```bash
git checkout develop
git merge --no-ff feature/new-feature
git push origin develop
# → GitHub Actions が自動でTestFlight配布
```

### 5. App Storeリリース
```bash
git checkout main
git merge --no-ff develop
bundle exec fastlane bump_version type:minor
git tag v1.2.0
git push origin main --tags
# → GitHub Actions が自動でApp Store提出
```

---

## トラブルシューティング

### CI失敗時

#### ビルドエラー
```bash
# ローカルで再現
make clean
make build

# キャッシュクリア
make reset-packages
```

#### テスト失敗
```bash
# ローカルで再現
make test

# カバレッジ確認
make coverage
```

#### SwiftLint警告
```bash
# 警告確認
make lint

# 自動修正
make lint-autocorrect
```

#### SwiftFormat違反
```bash
# 違反確認
make format-check

# 自動修正
make format
```

### Fastlane エラー

#### Code Signing エラー
```bash
# 証明書再取得
bundle exec fastlane match development --force
bundle exec fastlane match appstore --force
```

#### TestFlight アップロードエラー
```bash
# ビルド番号重複確認
bundle exec fastlane bump_build

# 手動アップロード
open build/PrototypeChatClientApp-Development.ipa
```

---

## セキュリティチェックリスト

### GitHub Secrets (必須)
- [ ] `BACKEND_URL_PRODUCTION`
- [ ] `BACKEND_URL_LOCALHOST`
- [ ] `APP_STORE_CONNECT_API_KEY` (Phase 3)
- [ ] `APP_STORE_CONNECT_API_KEY_ID` (Phase 3)
- [ ] `APP_STORE_CONNECT_API_ISSUER_ID` (Phase 3)
- [ ] `MATCH_PASSWORD` (Phase 3)
- [ ] `MATCH_GIT_URL` (Phase 3)

### Git管理対象外ファイル
- [ ] `Config/Secrets.xcconfig` (ローカル環境設定)
- [ ] `fastlane/.env.default` (環境変数テンプレート)
- [ ] `AuthKey_*.p8` (App Store Connect API Key)
- [ ] `*.mobileprovision` (プロビジョニングプロファイル)

### コードレビュー観点
- [ ] `.env` ファイルに機密情報がないか
- [ ] ハードコードされたAPIキーがないか
- [ ] `.gitignore` が適切か

---

## コスト・工数サマリー

| フェーズ | 期間 | 工数 | 優先度 | ROI |
|---------|------|------|--------|-----|
| Phase 1: 基盤構築 | 1.5-2日 | 8-12h | 必須 | 高 |
| Phase 2: 品質強化 | 2-3日 | 10-15h | 推奨 | 中〜高 |
| Phase 3: デプロイ自動化 | 3-4日 | 15-20h | 高度 | 中 |
| **合計** | **1週間** | **33-47h** | - | - |

### 投資対効果 (ROI) 分析

#### Phase 1 (基盤構築)
**投資**: 8-12時間
**効果**:
- PR毎の自動テスト実行 (週5回 × 15分節約 = 75分/週)
- ビルド失敗の早期発見 (平均2時間/週節約)
- コードレビュー時間短縮 (SwiftLint導入で30分/週節約)

**年間節約時間**: 約160時間 (= 20営業日相当)
**ROI**: 初月から13倍のリターン

#### Phase 2 (品質強化)
**投資**: 10-15時間
**効果**:
- バグ検出率向上 (カバレッジ70%達成で品質向上)
- リファクタリング時の安全性向上 (テストによる保護)
- 本番バグ削減 (平均4時間/月節約)

**年間節約時間**: 約50時間
**ROI**: 3-5ヶ月でペイ

#### Phase 3 (デプロイ自動化)
**投資**: 15-20時間
**効果**:
- TestFlight配布自動化 (30分/回 × 月4回 = 2時間/月)
- App Storeリリース自動化 (2時間/回 × 年4回 = 8時間/年)
- リリースノート自動生成 (1時間/回 × 年4回 = 4時間/年)

**年間節約時間**: 約36時間
**ROI**: 6-8ヶ月でペイ

---

## 推奨実装順序

### 最小構成 (1週間以内に導入すべき)
1. **Phase 1.1**: GitHub Actions CI (3-4h)
2. **Phase 1.3**: SwiftLint (2-3h)
3. **Phase 1.2**: xcconfig (2-3h)

**合計**: 7-10時間
**効果**: PR毎の自動チェック、コード品質向上

### 標準構成 (1ヶ月以内に導入すべき)
1. 最小構成 (7-10h)
2. **Phase 2.1**: テストカバレッジ向上 (6-8h)
3. **Phase 2.2**: SwiftFormat (2-3h)
4. **Phase 2.3**: Secrets管理 (3-4h)

**合計**: 18-25時間
**効果**: カバレッジ70%達成、品質ゲート確立

### 完全構成 (3ヶ月以内に導入すべき)
1. 標準構成 (18-25h)
2. **Phase 3.1**: Fastlane (8-10h)
3. **Phase 3.2**: デプロイ自動化 (4-6h)
4. **Phase 3.3**: バージョン管理戦略 (2-3h)

**合計**: 32-44時間
**効果**: 完全自動化、手作業ゼロ

---

## 参考資料

### GitHub Actions
- [公式ドキュメント](https://docs.github.com/ja/actions)
- [iOS CI/CD ベストプラクティス](https://docs.github.com/ja/actions/deployment/deploying-xcode-applications)

### SwiftLint
- [公式リポジトリ](https://github.com/realm/SwiftLint)
- [ルール一覧](https://realm.github.io/SwiftLint/rule-directory.html)

### SwiftFormat
- [公式リポジトリ](https://github.com/nicklockwood/SwiftFormat)
- [設定オプション](https://github.com/nicklockwood/SwiftFormat#options)

### Fastlane
- [公式ドキュメント](https://docs.fastlane.tools/)
- [iOS アプリのCI/CD](https://docs.fastlane.tools/getting-started/ios/beta-deployment/)
- [Match (Code Signing)](https://docs.fastlane.tools/actions/match/)

### xcconfig
- [Xcode Build Configuration Files](https://nshipster.com/xcconfig/)
- [xcconfig Best Practices](https://pewpewthespells.com/blog/xcconfig_guide.html)

---

## 付録: 設定ファイル一覧

### Phase 1
- `.github/workflows/ci.yml` - CI/CDワークフロー
- `Config/Shared.xcconfig` - 共通設定
- `Config/Debug.xcconfig` - Debug環境設定
- `Config/Development.xcconfig` - Development環境設定
- `Config/Release.xcconfig` - Release環境設定
- `.swiftlint.yml` - SwiftLint設定
- `Makefile` (拡張) - 開発コマンド

### Phase 2
- `.swiftformat` - SwiftFormat設定
- `Dangerfile` (Optional) - 自動PR レビュー
- `Gemfile` - Ruby依存関係 (Danger用)

### Phase 3
- `fastlane/Fastfile` - Fastlane設定
- `fastlane/Appfile` - App Store Connect設定
- `fastlane/.env.default` - 環境変数テンプレート
- `.github/workflows/deploy-testflight.yml` - TestFlight配布
- `.github/workflows/release.yml` - App Storeリリース
- `scripts/generate_changelog.sh` - Changelog生成
- `Gemfile` (拡張) - Fastlane依存関係

---

## 改訂履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 1.0 | 2025-12-23 | 初版作成 |

---

**作成者**: AI Assistant
**対象プロジェクト**: PrototypeChatClientApp
**ドキュメントパス**: `/Specs/CI_CD_ENVIRONMENT_PROPOSAL_20251223.md`
