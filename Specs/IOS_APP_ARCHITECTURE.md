# iOSチャットクライアントアプリ - 概要設計書

## 1. プロジェクト概要

### 1.1 目的
Hono + Drizzle ORM ベースのチャットAPIに接続し、リアルタイムメッセージング機能を提供するネイティブiOSアプリケーションの開発

### 1.2 対象プラットフォーム
- **OS**: iOS 16.0+
- **デバイス**: iPhone (iPadは将来的に対応)
- **開発言語**: Swift 5.9+
- **開発環境**: Xcode 15.0+

### 1.3 バックエンド接続先
- **開発環境**: `http://localhost:3000`
- **本番環境**: `https://prototype-hono-drizzle-backend.linnefromice.workers.dev`

---

## 2. アーキテクチャ設計

### 2.1 全体アーキテクチャパターン
**MVVM (Model-View-ViewModel) + Clean Architecture**

```
┌─────────────────────────────────────────────────┐
│              Presentation Layer                 │
│  ┌─────────────┐         ┌──────────────┐      │
│  │   SwiftUI   │ ◄────── │  ViewModel   │      │
│  │    Views    │         │   (ObservableObject)│
│  └─────────────┘         └──────────────┘      │
└─────────────────────┬───────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────┐
│              Domain Layer                       │
│  ┌──────────────┐    ┌─────────────────┐       │
│  │   Use Cases  │    │    Entities     │       │
│  │  (Business   │    │   (Models)      │       │
│  │    Logic)    │    │                 │       │
│  └──────────────┘    └─────────────────┘       │
└─────────────────────┬───────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────┐
│               Data Layer                        │
│  ┌──────────────┐    ┌─────────────────┐       │
│  │ Repositories │    │  Data Sources   │       │
│  │              │    │  - API Service  │       │
│  │              │    │  - UserDefaults │       │
│  └──────────────┘    └─────────────────┘       │
└─────────────────────────────────────────────────┘
```

### 2.2 レイヤー構成

#### 2.2.1 Presentation Layer (UI層)
- **責務**: ユーザーインターフェース、ユーザー操作の処理
- **技術要素**:
  - SwiftUI (宣言的UI)
  - Combine (リアクティブプログラミング)
  - ObservableObject (状態管理)

#### 2.2.2 Domain Layer (ドメイン層)
- **責務**: ビジネスロジック、データモデル定義
- **技術要素**:
  - Swift Protocols (抽象化)
  - Value Types (Struct/Enum)
  - Domain Entities

#### 2.2.3 Data Layer (データ層)
- **責務**: データの永続化、API通信
- **技術要素**:
  - URLSession (HTTP通信)
  - UserDefaults (ローカルストレージ)
  - Codable (JSON変換)

---

## 3. 使用技術要素

### 3.1 コア技術スタック

| カテゴリ | 技術 | 用途 |
|---------|------|------|
| UI Framework | SwiftUI | 画面構築 |
| Reactive | Combine | 非同期処理、状態管理 |
| Networking | URLSession | REST API通信 |
| JSON Parsing | Codable | データシリアライゼーション |
| Storage | UserDefaults | ユーザー情報保存 |
| Date Handling | Foundation.Date | ISO8601日時処理 |
| Routing | NavigationStack | 画面遷移管理 |

### 3.2 外部ライブラリ (最小限)

#### 推奨ライブラリ
1. **KeychainAccess** (オプション)
   - 用途: セキュアなユーザーID保存
   - 代替: UserDefaultsで開発開始

2. **Kingfisher** (オプション)
   - 用途: アバター画像の非同期読み込み・キャッシング
   - 代替: AsyncImage (iOS 15+標準機能)

#### 依存管理
- **Swift Package Manager (SPM)** - Xcodeネイティブサポート

### 3.3 開発ツール
- **Xcode**: IDE
- **Instruments**: パフォーマンス分析
- **Charles Proxy / Proxyman**: API通信デバッグ

---

## 4. プロジェクト構造

```
PrototypeChatClientApp/
├── App/
│   ├── PrototypeChatClientAppApp.swift (エントリーポイント)
│   └── AppEnvironment.swift (環境設定)
│
├── Presentation/
│   ├── Views/
│   │   ├── Authentication/
│   │   │   └── UserRegistrationView.swift
│   │   ├── Conversations/
│   │   │   ├── ConversationListView.swift
│   │   │   ├── ConversationDetailView.swift
│   │   │   └── CreateConversationView.swift
│   │   ├── Messages/
│   │   │   ├── MessageListView.swift
│   │   │   ├── MessageInputView.swift
│   │   │   └── MessageRow.swift
│   │   └── Profile/
│   │       ├── ProfileView.swift
│   │       └── BookmarkListView.swift
│   │
│   ├── ViewModels/
│   │   ├── AuthenticationViewModel.swift
│   │   ├── ConversationListViewModel.swift
│   │   ├── ConversationDetailViewModel.swift
│   │   └── ProfileViewModel.swift
│   │
│   └── Components/
│       ├── AvatarView.swift
│       ├── MessageBubbleView.swift
│       └── ReactionPickerView.swift
│
├── Domain/
│   ├── Entities/
│   │   ├── User.swift
│   │   ├── Conversation.swift
│   │   ├── Message.swift
│   │   ├── Reaction.swift
│   │   └── Bookmark.swift
│   │
│   ├── UseCases/
│   │   ├── Authentication/
│   │   │   ├── RegisterUserUseCase.swift
│   │   │   └── GetCurrentUserUseCase.swift
│   │   ├── Conversations/
│   │   │   ├── FetchConversationsUseCase.swift
│   │   │   └── CreateConversationUseCase.swift
│   │   └── Messages/
│   │       ├── FetchMessagesUseCase.swift
│   │       ├── SendMessageUseCase.swift
│   │       └── AddReactionUseCase.swift
│   │
│   └── Repositories/ (Protocols)
│       ├── UserRepositoryProtocol.swift
│       ├── ConversationRepositoryProtocol.swift
│       └── MessageRepositoryProtocol.swift
│
├── Data/
│   ├── Generated/                 # 自動生成コード (OpenAPI Generator)
│   │   ├── Client.swift           # ※ビルド時自動生成
│   │   ├── Types.swift            # ※ビルド時自動生成
│   │   └── Operations.swift       # ※ビルド時自動生成
│   │
│   ├── Repositories/ (Implementations)
│   │   ├── UserRepository.swift
│   │   ├── ConversationRepository.swift
│   │   └── MessageRepository.swift
│   │
│   ├── Network/
│   │   ├── APIClientFactory.swift     # Client生成ファクトリ
│   │   ├── AppEnvironment.swift       # 環境設定
│   │   └── NetworkErrorMapper.swift   # エラー変換
│   │
│   ├── DTOs/
│   │   ├── UserDTO+Mapping.swift      # DTO → Entity変換
│   │   ├── ConversationDTO+Mapping.swift
│   │   └── MessageDTO+Mapping.swift
│   │
│   └── Local/
│       └── UserDefaultsManager.swift
│
├── Core/
│   ├── Extensions/
│   │   ├── Date+ISO8601.swift
│   │   └── View+Extensions.swift
│   │
│   └── Utilities/
│       ├── DateFormatter+Shared.swift
│       └── Logger.swift
│
└── Resources/
    ├── Assets.xcassets
    └── Info.plist
```

---

## 5. 主要機能モジュール設計

### 5.1 認証・ユーザー管理モジュール
**責務**: ユーザー登録、ローカルセッション管理

```swift
// ViewModel例
class AuthenticationViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false

    private let registerUserUseCase: RegisterUserUseCase
    private let userDefaultsManager: UserDefaultsManager

    func checkAuthentication() async
    func registerUser(name: String, avatarUrl: String?) async throws
    func logout()
}
```

### 5.2 会話管理モジュール
**責務**: 会話一覧表示、会話作成、未読数管理

```swift
class ConversationListViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var unreadCounts: [String: Int] = [:]

    private let fetchConversationsUseCase: FetchConversationsUseCase

    func loadConversations() async throws
    func createDirectConversation(with userId: String) async throws
    func createGroupConversation(name: String, participantIds: [String]) async throws
    func refreshUnreadCounts() async
}
```

### 5.3 メッセージングモジュール
**責務**: メッセージ送受信、ページネーション、リアクション

```swift
class ConversationDetailViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isLoadingMore: Bool = false

    private let fetchMessagesUseCase: FetchMessagesUseCase
    private let sendMessageUseCase: SendMessageUseCase

    func loadMessages(limit: Int = 50) async throws
    func loadMoreMessages(before: Date) async throws
    func sendMessage(text: String, replyTo: String?) async throws
    func addReaction(to messageId: String, emoji: String) async throws
    func startPolling(interval: TimeInterval = 5.0)
    func stopPolling()
}
```

### 5.4 ブックマークモジュール
**責務**: メッセージのブックマーク管理

```swift
class ProfileViewModel: ObservableObject {
    @Published var bookmarks: [Bookmark] = []

    func fetchBookmarks() async throws
    func addBookmark(messageId: String) async throws
    func removeBookmark(messageId: String) async throws
}
```

---

## 6. データフロー設計

### 6.1 標準的なデータフロー

```
User Action (View)
    ↓
ViewModel (State Update開始)
    ↓
Use Case (Business Logic)
    ↓
Repository (Data Access)
    ↓
API Client / Local Storage
    ↓
Repository (DTOをEntityに変換)
    ↓
Use Case (返却)
    ↓
ViewModel (@Publishedプロパティ更新)
    ↓
View (自動再描画)
```

### 6.2 メッセージ送信フローの具体例

```swift
// 1. View: ユーザーがメッセージを送信
Button("送信") {
    Task {
        await viewModel.sendMessage(text: inputText)
    }
}

// 2. ViewModel
func sendMessage(text: String) async {
    do {
        let message = try await sendMessageUseCase.execute(
            conversationId: conversationId,
            text: text,
            senderUserId: currentUserId
        )
        // 楽観的UI更新
        messages.append(message)
    } catch {
        // エラーハンドリング
    }
}

// 3. Use Case
func execute(conversationId: String, text: String, senderUserId: String) async throws -> Message {
    return try await messageRepository.sendMessage(
        conversationId: conversationId,
        text: text,
        senderUserId: senderUserId
    )
}

// 4. Repository
func sendMessage(...) async throws -> Message {
    let dto = try await apiClient.request(
        endpoint: .sendMessage(conversationId),
        method: .post,
        body: SendMessageRequest(...)
    )
    return dto.toDomain() // DTO → Entity変換
}
```

---

## 7. API通信設計

API通信レイヤーの詳細設計については、以下の専用ドキュメントを参照してください:

**→ [API接続レイヤー設計書](./API_LAYER_DESIGN_20251211_JA.md)**

### 7.1 概要

本プロジェクトでは、OpenAPI仕様書から自動的にSwiftクライアントコードを生成するアプローチを採用します。

**採用技術**:
- **Apple公式**: Swift OpenAPI Generator
- **トランスポート**: URLSession (swift-openapi-urlsession)
- **コード生成**: ビルド時自動生成（Xcode Build Plugin）

**主要な利点**:
- OpenAPI仕様との自動同期
- 型安全な通信コード
- 手動実装の最小化
- Appleによる公式サポート

### 7.2 レイヤー構成

```
Repository (手動実装) → Generated Client (自動生成) → URLSession Transport
```

- **Generated Client**: OpenAPI GeneratorがAPIエンドポイントごとのメソッドを自動生成
- **Repository**: DTOからDomain Entityへの変換を担当（手動実装）
- **Transport**: URLSessionベースのHTTP通信（swift-openapi-urlsession提供）

詳細な実装例、エラーハンドリング、テスト戦略については、専用ドキュメントを参照してください。

---

## 8. 状態管理設計

### 8.1 状態管理方針
- **グローバル状態**: `@EnvironmentObject`でアプリ全体に注入
- **ローカル状態**: `@State`, `@StateObject`で各View内管理
- **非同期処理**: Combine + async/await

### 8.2 グローバル状態の例

```swift
@main
struct PrototypeChatClientAppApp: App {
    @StateObject private var authViewModel = AuthenticationViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}

// 各Viewで使用
struct ConversationListView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel

    var body: some View {
        if let user = authViewModel.currentUser {
            // 会話一覧表示
        }
    }
}
```

---

## 9. UI/UX設計方針

### 9.1 デザインシステム
- **カラーパレット**: SwiftUIのsemantic colors活用 (`.primary`, `.secondary`, etc.)
- **タイポグラフィ**: システムフォント (San Francisco)
- **スペーシング**: 8pxグリッドシステム

### 9.2 画面遷移
- **NavigationStack**: iOS 16+ の新しいナビゲーションAPI使用
- **Sheet**: モーダル表示 (会話作成、プロフィール編集など)
- **Alert**: エラー表示

### 9.3 主要画面一覧

| 画面名 | 説明 | 主要コンポーネント |
|-------|------|------------------|
| ユーザー登録画面 | 初回起動時の登録 | TextField, Button |
| 会話一覧画面 | 全会話表示 | List, NavigationStack |
| 会話詳細画面 | メッセージ履歴 | ScrollView, MessageBubble |
| メッセージ入力欄 | テキスト送信 | TextField, Button |
| 会話作成画面 | DM/グループ作成 | Form, Picker |
| プロフィール画面 | ユーザー情報 | VStack, AsyncImage |
| ブックマーク画面 | 保存メッセージ | List |

---

## 10. パフォーマンス最適化

### 10.1 メッセージ表示最適化
- **遅延読み込み**: `LazyVStack`でリスト描画
- **ページネーション**: 50件ずつ取得
- **画像キャッシュ**: AsyncImageのキャッシング活用

### 10.2 ポーリング設計
```swift
class MessagePollingService {
    private var pollingTask: Task<Void, Never>?

    func startPolling(interval: TimeInterval, action: @escaping () async -> Void) {
        pollingTask = Task {
            while !Task.isCancelled {
                await action()
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
        }
    }

    func stopPolling() {
        pollingTask?.cancel()
    }
}
```

### 10.3 メモリ管理
- 適切な`@StateObject`/`@ObservedObject`使い分け
- 大きな画像データのキャッシュ制限
- 不要なポーリングタスクのキャンセル

---

## 11. セキュリティ考慮事項

### 11.1 App Transport Security (ATS)
**開発環境用設定** (Info.plist)
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsLocalNetworking</key>
    <true/>
</dict>
```

### 11.2 データ保護
- **UserID保存**: UserDefaults (将来的にKeychain検討)
- **通信**: 本番環境はHTTPS強制
- **入力検証**: ユーザー入力のサニタイゼーション

---

## 12. テスト戦略

### 12.1 テストレベル

| レベル | 対象 | フレームワーク |
|-------|------|--------------|
| Unit Test | Use Cases, Repositories | XCTest |
| UI Test | 画面遷移、ユーザー操作 | XCUITest |
| Integration Test | API通信 | XCTest + Mock Server |

### 12.2 テスト方針
- **依存性注入**: ProtocolベースでMock作成
- **ViewModel単体テスト**: Use Caseをモック化
- **Repository単体テスト**: APIClientをモック化

```swift
// テスト例
class ConversationListViewModelTests: XCTestCase {
    var sut: ConversationListViewModel!
    var mockUseCase: MockFetchConversationsUseCase!

    override func setUp() {
        super.setUp()
        mockUseCase = MockFetchConversationsUseCase()
        sut = ConversationListViewModel(fetchConversationsUseCase: mockUseCase)
    }

    func testLoadConversations() async throws {
        // Given
        mockUseCase.mockConversations = [/* テストデータ */]

        // When
        try await sut.loadConversations()

        // Then
        XCTAssertEqual(sut.conversations.count, 1)
    }
}
```

---

## 13. 開発フェーズ

### Phase 1: 基盤構築 (Week 1-2)
- [ ] プロジェクト構造セットアップ
- [ ] APIClient実装
- [ ] 基本的なEntity定義
- [ ] ユーザー登録機能

### Phase 2: コア機能実装 (Week 3-4)
- [ ] 会話一覧表示
- [ ] メッセージ送受信
- [ ] ポーリング実装
- [ ] 既読管理

### Phase 3: 追加機能 (Week 5-6)
- [ ] リアクション機能
- [ ] ブックマーク機能
- [ ] 返信機能
- [ ] 画像表示最適化

### Phase 4: 品質向上 (Week 7-8)
- [ ] ユニットテスト作成
- [ ] UIテスト作成
- [ ] パフォーマンス最適化
- [ ] エラーハンドリング改善

---

## 14. 将来的な拡張

### 14.1 機能拡張
- WebSocket実装 (リアルタイム更新)
- プッシュ通知 (APNs)
- オフラインモード (Core Data)
- メディア送信 (画像、動画)

### 14.2 アーキテクチャ改善
- TCA (The Composable Architecture) 導入検討
- SwiftData移行 (iOS 17+)
- Modular Architecture (マルチモジュール化)

---

## 15. リファレンス

### 15.1 関連ドキュメント
- [クライアント要件書](../Design/CLIENT_REQUIREMENTS_20251211_JA.md)
- [API接続レイヤー設計書](./API_LAYER_DESIGN_20251211_JA.md)
- OpenAPI仕様: `packages/openapi/openapi.yaml`

### 15.2 技術リソース
- [Swift Documentation](https://swift.org/documentation/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [Combine Framework](https://developer.apple.com/documentation/combine)

---

**ドキュメント作成日**: 2025年12月11日
**対象バージョン**: iOS 16.0+
**作成者**: iOS Development Team
