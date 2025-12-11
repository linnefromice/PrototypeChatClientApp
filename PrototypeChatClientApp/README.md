# PrototypeChatClientApp - プロジェクト構造ガイド

## 📁 フォルダ構成（MultiModule化対応）

本プロジェクトは、将来的なMultiModule化を見据えた構造になっています。
現在は単一プロジェクトですが、機能ごとに明確に分離されており、将来Swift Package Managerでモジュール分割可能です。

```
PrototypeChatClientApp/
├── App/                              # 🔴 アプリケーション層
│   ├── PrototypeChatClientAppApp.swift  # アプリエントリーポイント
│   └── DependencyContainer.swift        # 依存性注入コンテナ
│
├── Core/                             # 🔵 共通基盤層（横断的）
│   ├── Entities/                     # 全機能で共有するEntity
│   │   └── User.swift               # ユーザーエンティティ
│   │
│   ├── Protocols/                    # 共通Protocol定義
│   │   ├── Repository/
│   │   │   └── UserRepositoryProtocol.swift
│   │   └── UseCase/
│   │       └── (将来追加予定)
│   │
│   ├── Extensions/                   # Foundation/SwiftUI拡張
│   │   └── (将来追加予定)
│   │
│   └── UI/                          # 共通UIコンポーネント
│       ├── Components/
│       │   └── (将来追加予定)
│       └── Styles/
│           └── (将来追加予定)
│
├── Features/                         # 🟢 機能モジュール群
│   └── Authentication/               # 認証機能
│       ├── Domain/
│       │   ├── Entities/
│       │   │   ├── AuthSession.swift          # 認証セッション
│       │   │   └── AuthenticationError.swift  # 認証エラー
│       │   ├── UseCases/
│       │   │   └── AuthenticationUseCase.swift
│       │   └── Repositories/
│       │       └── AuthenticationRepositoryProtocol.swift
│       │
│       ├── Data/
│       │   ├── Repositories/
│       │   │   └── MockUserRepository.swift
│       │   └── Local/
│       │       ├── AuthSessionManager.swift
│       │       └── StorageKey.swift
│       │
│       └── Presentation/
│           ├── ViewModels/
│           │   └── AuthenticationViewModel.swift
│           └── Views/
│               ├── AuthenticationView.swift
│               ├── RootView.swift
│               └── MainView.swift
│
├── Infrastructure/                   # 🟡 インフラ層（将来実装）
│   ├── Network/
│   │   ├── APIClient/
│   │   ├── Generated/               # OpenAPI自動生成（将来）
│   │   └── Error/
│   └── Storage/
│
└── Resources/
    ├── Assets.xcassets
    └── Info.plist
```

---

## 🎯 設計思想

### 1. レイヤー分離

| レイヤー | 責務 | 依存方向 |
|---------|------|----------|
| **App** | 全体統合、依存性注入 | → Features, Core |
| **Features** | 機能ごとの独立実装 | → Core, Infrastructure |
| **Core** | 横断的な共通機能 | なし（最下層） |
| **Infrastructure** | データアクセス基盤 | → Core |

### 2. 依存関係のルール

```
✅ 許可される依存
Features/Authentication → Core/Entities/User
Features/Authentication → Core/Protocols/Repository
Features/ConversationList → Core/Entities/User
App → Features/*
App → Core/*

❌ 禁止される依存
Features/Authentication → Features/ConversationList (Feature間の直接依存)
Core → Features (下層から上層への依存)
Infrastructure → Features (下層から上層への依存)
```

---

## 📦 エンティティの分類

### 横断的Entity（Core/Entities）

**特徴**: 複数の機能で使用される基本的なエンティティ

| Entity | 使用される機能 | 配置場所 |
|--------|--------------|----------|
| `User` | 認証、会話、メッセージ、プロフィール | `Core/Entities/User.swift` |
| `Participant`（将来） | 会話、メッセージ | `Core/Entities/Participant.swift` |

### Feature固有のEntity（Features/*/Domain/Entities）

**特徴**: 特定の機能内でのみ使用されるエンティティ

| Entity | スコープ | 配置場所 |
|--------|---------|----------|
| `AuthSession` | 認証機能のみ | `Features/Authentication/Domain/Entities/AuthSession.swift` |
| `AuthenticationError` | 認証機能のみ | `Features/Authentication/Domain/Entities/AuthenticationError.swift` |
| `Conversation`（将来） | 会話機能のみ | `Features/ConversationList/Domain/Entities/Conversation.swift` |
| `Message`（将来） | メッセージ機能のみ | `Features/ConversationDetail/Domain/Entities/Message.swift` |

---

## 🔧 依存性注入

### DependencyContainer

`App/DependencyContainer.swift`が全ての依存関係を管理します。

```swift
// 使用例
let container = DependencyContainer.shared

// Repository取得
let userRepository = container.userRepository

// UseCase取得
let authUseCase = container.authenticationUseCase

// ViewModel生成
let authViewModel = container.makeAuthenticationViewModel()
```

### 実装の差し替え

```swift
// 現在: Mock実装
lazy var userRepository: UserRepositoryProtocol = {
    MockUserRepository()
}()

// 将来: 本番API接続
lazy var userRepository: UserRepositoryProtocol = {
    UserRepository(client: apiClient)
}()
```

---

## 🚀 将来のMultiModule化

### Phase 1: Core Moduleの分離

```bash
Modules/
├── CoreEntities/
│   └── Package.swift
├── CoreProtocols/
│   └── Package.swift
└── CoreExtensions/
    └── Package.swift
```

### Phase 2: Infrastructure Moduleの分離

```bash
Modules/
├── InfrastructureNetwork/
│   └── Package.swift
└── InfrastructureStorage/
    └── Package.swift
```

### Phase 3: Feature Moduleの分離

```bash
Modules/
├── FeatureAuthentication/
│   └── Package.swift
│       dependencies: ["CoreEntities", "CoreProtocols"]
├── FeatureConversationList/
│   └── Package.swift
└── FeatureProfile/
    └── Package.swift
```

詳細は `/Specs/Plans/MULTIMODULE_STRATEGY_20251211_JA.md` を参照してください。

---

## 📝 命名規則

### ディレクトリ

| 種類 | 命名規則 | 例 |
|------|---------|-----|
| Feature | `{機能名}` | `Authentication`, `ConversationList` |
| Core | `{種類}` | `Entities`, `Protocols`, `Extensions` |

### ファイル

| 種類 | 命名規則 | 例 |
|------|---------|-----|
| Entity | `{名前}.swift` | `User.swift`, `AuthSession.swift` |
| UseCase | `{動詞}{名前}UseCase.swift` | `AuthenticationUseCase.swift` |
| Repository | `{名前}Repository.swift` | `UserRepository.swift` |
| ViewModel | `{名前}ViewModel.swift` | `AuthenticationViewModel.swift` |
| View | `{名前}View.swift` | `AuthenticationView.swift` |

---

## 🧪 テスト戦略

### 単体テスト対象

```
Core/
  └── Entities/User.swift ✅ テスト対象

Features/Authentication/
  ├── Domain/
  │   ├── UseCases/AuthenticationUseCase.swift ✅ テスト対象
  │   └── Entities/AuthSession.swift ✅ テスト対象
  ├── Data/
  │   ├── Repositories/MockUserRepository.swift ✅ テスト対象
  │   └── Local/AuthSessionManager.swift ✅ テスト対象
  └── Presentation/
      └── ViewModels/AuthenticationViewModel.swift ✅ テスト対象
```

### Mockの配置

- `Features/*/Data/Repositories/Mock*Repository.swift` - 開発・テスト用Mock実装
- テストターゲット用のMockは `*Tests/Mocks/` に配置

---

## 📚 関連ドキュメント

### 設計書

- [MultiModule化戦略](/Specs/Plans/MULTIMODULE_STRATEGY_20251211_JA.md)
- [アーキテクチャ概要設計書](/Specs/Plans/IOS_APP_ARCHITECTURE_20251211_JA.md)
- [API接続レイヤー設計書](/Specs/Plans/API_LAYER_DESIGN_20251211_JA.md)
- [認証管理設計書](/Specs/Plans/AUTH_DESIGN_20251211_JA.md)

### 実装ガイド

- [認証機能README](/Features/Authentication/Presentation/Views/Authentication/README.md)

---

## 🔍 よくある質問

### Q1. なぜ最初からMultiModuleにしないのか？

A1. 初期開発では構造が頻繁に変わるため、単一プロジェクトの方が柔軟です。ある程度構造が固まってからモジュール化することで、無駄なリファクタリングを避けられます。

### Q2. Userは本当に横断的Entityか？

A2. はい。認証、会話、メッセージ、プロフィールなど、ほぼ全ての機能で使用されるため、Core/Entitiesに配置しています。

### Q3. Feature間でデータを共有したい場合は？

A3. Core層に共通のEntityを定義するか、UseCaseを通じて間接的にアクセスします。Feature間の直接依存は避けてください。

### Q4. 新しい機能を追加する際の手順は？

A4.
1. `Features/{機能名}/` ディレクトリを作成
2. `Domain/Entities/`, `Domain/UseCases/`, `Domain/Repositories/` を実装
3. `Data/Repositories/` で実装
4. `Presentation/ViewModels/`, `Presentation/Views/` でUI実装
5. `App/DependencyContainer.swift` に依存性注入を追加

---

**最終更新**: 2025年12月11日
**対象フェーズ**: Phase 0（準備段階）
