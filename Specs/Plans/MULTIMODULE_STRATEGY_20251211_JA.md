# MultiModule化戦略 - フォルダ構成設計書

## 1. 概要

### 1.1 目的
- 初期は単一プロジェクトで開発効率を重視
- 将来的なMultiModule化を容易にする構造
- 機能ごとの独立性を高め、ビルド時間短縮とチーム開発を促進

### 1.2 基本方針
- **Feature単位でのモジュール分割**を想定
- **共通レイヤー（Core/Shared）を明確に定義**
- **依存関係を一方向に保つ**（循環参照の防止）

---

## 2. モジュール分割戦略

### 2.1 最終的なモジュール構成（目標）

```
App (実行可能モジュール)
  ↓ 依存
┌─────────────────────────────────────────┐
│         Feature Modules                 │
│  - FeatureAuthentication                │
│  - FeatureConversationList              │
│  - FeatureConversationDetail            │
│  - FeatureProfile                       │
└─────────────────┬───────────────────────┘
                  ↓ 依存
┌─────────────────────────────────────────┐
│         Domain Modules                  │
│  - DomainUser                           │
│  - DomainConversation                   │
│  - DomainMessage                        │
└─────────────────┬───────────────────────┘
                  ↓ 依存
┌─────────────────────────────────────────┐
│         Infrastructure Modules          │
│  - InfrastructureNetwork                │
│  - InfrastructureStorage                │
└─────────────────┬───────────────────────┘
                  ↓ 依存
┌─────────────────────────────────────────┐
│         Core/Shared Modules             │
│  - CoreEntities                         │
│  - CoreProtocols                        │
│  - CoreExtensions                       │
│  - CoreUI (共通UIコンポーネント)         │
└─────────────────────────────────────────┘
```

### 2.2 モジュール依存関係ルール

```
App
 ├─ Feature* (複数可)
 │   └─ Domain*
 │       └─ Infrastructure*
 │           └─ Core*
 └─ Core* (直接参照も可)

禁止事項:
❌ Feature → Feature（機能間の直接依存）
❌ Domain → Feature（下層から上層への依存）
❌ Infrastructure → Feature（下層から上層への依存）
✅ Feature → Core（共通機能の利用）
✅ Domain → Core（共通機能の利用）
```

---

## 3. 現在のフォルダ構成（単一プロジェクト）

### 3.1 提案する構造

```
PrototypeChatClientApp/
├── App/
│   ├── PrototypeChatClientAppApp.swift
│   ├── AppEnvironment.swift
│   └── DependencyContainer.swift
│
├── Core/                          # 🔵 横断的な共通機能
│   ├── Entities/                  # 全ドメインで共有されるEntity
│   │   ├── User.swift
│   │   └── Identifiable+Extensions.swift
│   │
│   ├── Protocols/                 # 共通Protocol定義
│   │   ├── Repository/
│   │   │   └── RepositoryProtocol.swift
│   │   └── UseCase/
│   │       └── UseCaseProtocol.swift
│   │
│   ├── Extensions/                # Foundation/SwiftUI拡張
│   │   ├── Date+ISO8601.swift
│   │   ├── String+Validation.swift
│   │   └── View+Extensions.swift
│   │
│   └── UI/                        # 共通UIコンポーネント
│       ├── Components/
│       │   ├── LoadingView.swift
│       │   └── ErrorView.swift
│       └── Styles/
│           └── ButtonStyles.swift
│
├── Features/                      # 🟢 機能単位のモジュール（将来分割対象）
│   ├── Authentication/
│   │   ├── Domain/
│   │   │   ├── Entities/
│   │   │   │   ├── AuthSession.swift
│   │   │   │   └── AuthenticationError.swift
│   │   │   ├── UseCases/
│   │   │   │   └── AuthenticationUseCase.swift
│   │   │   └── Repositories/
│   │   │       └── AuthenticationRepositoryProtocol.swift
│   │   │
│   │   ├── Data/
│   │   │   ├── Repositories/
│   │   │   │   └── MockAuthenticationRepository.swift
│   │   │   └── Local/
│   │   │       ├── AuthSessionManager.swift
│   │   │       └── StorageKey.swift
│   │   │
│   │   └── Presentation/
│   │       ├── ViewModels/
│   │       │   └── AuthenticationViewModel.swift
│   │       └── Views/
│   │           ├── AuthenticationView.swift
│   │           ├── RootView.swift
│   │           └── MainView.swift
│   │
│   ├── ConversationList/          # 将来実装
│   │   ├── Domain/
│   │   ├── Data/
│   │   └── Presentation/
│   │
│   ├── ConversationDetail/        # 将来実装
│   │   ├── Domain/
│   │   ├── Data/
│   │   └── Presentation/
│   │
│   └── Profile/                   # 将来実装
│       ├── Domain/
│       ├── Data/
│       └── Presentation/
│
├── Infrastructure/                # 🟡 データアクセス基盤（将来分割対象）
│   ├── Network/
│   │   ├── APIClient/
│   │   │   ├── APIClientFactory.swift
│   │   │   ├── APIEndpoint.swift
│   │   │   └── HTTPMethod.swift
│   │   ├── Generated/            # OpenAPI自動生成
│   │   │   ├── Client.swift
│   │   │   ├── Types.swift
│   │   │   └── Operations.swift
│   │   └── Error/
│   │       └── NetworkError.swift
│   │
│   └── Storage/
│       └── UserDefaultsManager.swift
│
└── Resources/
    ├── Assets.xcassets
    └── Info.plist
```

---

## 4. データモデルの分類

### 4.1 横断的Entity（Core/Entities）

**特徴**: 複数の機能で使用される基本的なエンティティ

```swift
// Core/Entities/User.swift
// ✅ 横断的に利用される
// - 認証機能で使用
// - 会話機能で使用（参加者として）
// - プロフィール機能で使用
// - メッセージ機能で使用（送信者として）

struct User: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let avatarUrl: String?
    let createdAt: Date
}
```

**該当するEntity**:
- `User` - 全機能で利用
- `Participant`（将来） - 会話・メッセージで利用
- 将来的に追加される共通型

### 4.2 Feature固有のEntity（Features/*/Domain/Entities）

**特徴**: 特定の機能内でのみ使用されるエンティティ

```swift
// Features/Authentication/Domain/Entities/AuthSession.swift
// ✅ 認証機能に閉じる
// - 他の機能は「現在のユーザーID」だけ知れば良い
// - 認証日時などは認証機能の内部情報

struct AuthSession: Codable, Equatable {
    let userId: String
    let user: User  // ← Core/Entities/User を参照
    let authenticatedAt: Date
}
```

```swift
// Features/Authentication/Domain/Entities/AuthenticationError.swift
// ✅ 認証機能に閉じる
// - 他の機能は認証エラーの詳細を知る必要なし

enum AuthenticationError: LocalizedError {
    case emptyUserId
    case userNotFound
    case invalidUserId
    case sessionExpired
}
```

**該当するEntity**:
- `AuthSession` - 認証機能専用
- `AuthenticationError` - 認証機能専用
- `Conversation`（将来） - 会話機能専用
- `Message`（将来） - メッセージ機能専用

### 4.3 Infrastructure層の型（Infrastructure/Network/Error）

**特徴**: データアクセス層の横断的なエラー定義

```swift
// Infrastructure/Network/Error/NetworkError.swift
// ✅ 横断的に利用される
// - 全てのRepository実装で使用
// - Feature層でハンドリング

enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(statusCode: Int, message: String?)
    case networkFailure(Error)
}
```

---

## 5. 依存関係の実例

### 5.1 認証機能の依存関係

```
Features/Authentication/
  Presentation/AuthenticationViewModel
    ↓ 依存
  Domain/UseCases/AuthenticationUseCase
    ↓ 依存
  Domain/Repositories/AuthenticationRepositoryProtocol
    ↑ 実装
  Data/Repositories/MockAuthenticationRepository
    ↓ 依存
Core/Entities/User (横断的Entity)
```

### 5.2 将来の会話機能の依存関係（例）

```
Features/ConversationList/
  Presentation/ConversationListViewModel
    ↓ 依存
  Domain/UseCases/FetchConversationsUseCase
    ↓ 依存
  Domain/Repositories/ConversationRepositoryProtocol
    ↑ 実装
  Data/Repositories/ConversationRepository
    ↓ 依存
Infrastructure/Network/APIClient (共通インフラ)
    ↓ 依存
Core/Entities/User (横断的Entity)
Core/Entities/Participant (横断的Entity)
```

---

## 6. モジュール分割の実施手順（将来）

### Phase 1: Core Moduleの分離

```bash
# Swift Package Managerでローカルパッケージ作成
Modules/
├── CoreEntities/
│   └── Package.swift
├── CoreProtocols/
│   └── Package.swift
└── CoreExtensions/
    └── Package.swift
```

**Package.swift例**:
```swift
// Modules/CoreEntities/Package.swift
let package = Package(
    name: "CoreEntities",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "CoreEntities", targets: ["CoreEntities"]),
    ],
    targets: [
        .target(name: "CoreEntities"),
        .testTarget(name: "CoreEntitiesTests", dependencies: ["CoreEntities"]),
    ]
)
```

### Phase 2: Infrastructure Moduleの分離

```bash
Modules/
├── InfrastructureNetwork/
│   └── Package.swift (swift-openapi-generator依存)
└── InfrastructureStorage/
    └── Package.swift
```

### Phase 3: Feature Moduleの分離

```bash
Modules/
├── FeatureAuthentication/
│   └── Package.swift
│       dependencies: [
│           "CoreEntities",
│           "CoreProtocols",
│           "InfrastructureNetwork",
│           "InfrastructureStorage"
│       ]
└── FeatureConversationList/
    └── Package.swift
```

### Phase 4: Appモジュールの整理

```swift
// App/PrototypeChatClientAppApp.swift
import FeatureAuthentication
import FeatureConversationList
import FeatureProfile

@main
struct PrototypeChatClientAppApp: App {
    // Feature Moduleを組み合わせて使用
}
```

---

## 7. ビルド時間への影響

### 7.1 単一プロジェクト（現在）

```
全体ビルド時間: T秒
変更時: 全体を再ビルド
```

### 7.2 MultiModule化後

```
初回ビルド時間: T秒（変わらず）
変更時:
  - CoreEntitiesのみ変更 → 全モジュール再ビルド（影響大）
  - FeatureAuthenticationのみ変更 → そのモジュールのみ再ビルド（影響小）
  - Appのみ変更 → Appのみ再ビルド（影響最小）

期待効果: 部分的な変更での開発サイクル高速化
```

---

## 8. 命名規則

### 8.1 フォルダ命名

| 種類 | 命名規則 | 例 |
|------|---------|-----|
| Feature | `Feature{機能名}` | `FeatureAuthentication` |
| Domain | `Domain{ドメイン名}` | `DomainUser` |
| Infrastructure | `Infrastructure{種類}` | `InfrastructureNetwork` |
| Core | `Core{種類}` | `CoreEntities` |

### 8.2 ファイル命名

| 種類 | 命名規則 | 例 |
|------|---------|-----|
| Entity | `{名前}.swift` | `User.swift` |
| UseCase | `{動詞}{名前}UseCase.swift` | `AuthenticationUseCase.swift` |
| Repository | `{名前}Repository.swift` | `UserRepository.swift` |
| ViewModel | `{名前}ViewModel.swift` | `AuthenticationViewModel.swift` |
| View | `{名前}View.swift` | `AuthenticationView.swift` |

---

## 9. アクセス修飾子の使い分け

### 9.1 単一プロジェクト（現在）

```swift
// 全て internal でOK
struct User { }
class AuthenticationUseCase { }
```

### 9.2 MultiModule化後

```swift
// Core/Entities/User.swift
public struct User { } // 他モジュールから参照

// Features/Authentication/Domain/Entities/AuthSession.swift
public struct AuthSession { } // Appから参照可能

// Features/Authentication/Data/Repositories/AuthenticationRepository.swift
internal class AuthenticationRepository { } // Feature内部のみ

// Features/Authentication/Presentation/ViewModels/AuthenticationViewModel.swift
public class AuthenticationViewModel { } // Appから参照
```

---

## 10. 移行チェックリスト

### Phase 0: 準備（現在）
- [x] MultiModule化を見据えたフォルダ構成
- [x] 横断的Entityと機能固有Entityの分離
- [ ] 依存関係の可視化ツール導入（optional）

### Phase 1: Core Module分離
- [ ] CoreEntities パッケージ作成
- [ ] CoreProtocols パッケージ作成
- [ ] CoreExtensions パッケージ作成
- [ ] アクセス修飾子を`public`に変更
- [ ] ビルド確認

### Phase 2: Infrastructure Module分離
- [ ] InfrastructureNetwork パッケージ作成
- [ ] InfrastructureStorage パッケージ作成
- [ ] 依存関係設定
- [ ] ビルド確認

### Phase 3: Feature Module分離
- [ ] FeatureAuthentication パッケージ作成
- [ ] 他のFeatureパッケージ作成
- [ ] App層での統合
- [ ] ビルド確認

---

## 11. FAQ

### Q1. なぜ最初からMultiModuleにしないのか？
A1. 初期開発では構造が頻繁に変わるため、単一プロジェクトの方が柔軟です。ある程度構造が固まってからモジュール化することで、無駄なリファクタリングを避けられます。

### Q2. Userは本当に横断的Entityか？
A2. はい。認証、会話、メッセージ、プロフィールなど、ほぼ全ての機能で使用されるため、Core/Entitiesに配置します。

### Q3. Feature間で共通のUIコンポーネントは？
A3. `Core/UI/Components/`に配置します。例: LoadingView, ErrorView, CustomButton等。

### Q4. OpenAPI自動生成コードの配置は？
A4. `Infrastructure/Network/Generated/`に配置し、将来は`InfrastructureNetwork`モジュールに含めます。

---

## 12. 参考リンク

### 12.1 関連ドキュメント
- [アーキテクチャ概要設計書](./IOS_APP_ARCHITECTURE_20251211_JA.md)
- [API接続レイヤー設計書](./API_LAYER_DESIGN_20251211_JA.md)
- [認証管理設計書](./AUTH_DESIGN_20251211_JA.md)

### 12.2 技術リソース
- [Swift Package Manager - Apple](https://swift.org/package-manager/)
- [Modular Architecture - Point-Free](https://www.pointfree.co/collections/tours/modular-dependency-management)

---

**ドキュメント作成日**: 2025年12月11日
**対象フェーズ**: Phase 0（準備段階）
**作成者**: iOS Development Team
