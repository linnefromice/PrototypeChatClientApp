# チャット機能実装計画

**作成日**: 2025年12月12日
**対象フェーズ**: Phase 1 - 基本的なチャット導線
**アーキテクチャ**: Clean Architecture + Protocol-based DI

---

## 📋 概要

ログイン後にチャット一覧画面を表示し、1:1チャット作成機能を実装します。最小限のUI（ネイティブコンポーネント）で実装し、既存の認証機能アーキテクチャを踏襲します。

---

## 🎯 実装スコープ

### Phase 1: 基本的なチャット導線（今回実装）

#### 実装する機能
1. **チャット一覧画面** (ConversationListView)
   - ログイン後のメイン画面として表示
   - 現在ログインしているユーザーの会話一覧を表示
   - 各会話で相手ユーザーの名前を表示
   - 右上に「チャット作成」ボタン（`+` アイコン）

2. **チャット作成画面** (CreateChatView)
   - Sheet形式で表示
   - ユーザー一覧を表示（GET /users使用）
   - ユーザーを選択
   - 「作成」ボタンで1:1チャット作成（POST /conversations）
   - 作成後に一覧画面に戻る

3. **基本的なナビゲーション**
   - 一覧画面 ↔ 作成画面（Sheet）
   - TabView統合（チャット・設定）

### 後回しにする項目（Phase 2以降）
- ✗ チャット詳細画面（メッセージ送受信）
- ✗ グループチャット作成
- ✗ デザインのブラッシュアップ
- ✗ リアルタイム更新（WebSocket/SSE）
- ✗ メッセージ検索・通知

---

## 🏗️ アーキテクチャ設計

### ディレクトリ構成

```
PrototypeChatClientApp/
├── Core/
│   ├── Entities/
│   │   └── User.swift                        # 既存（再利用）
│   └── Protocols/
│       └── Repository/
│           ├── UserRepositoryProtocol.swift  # 既存（再利用）
│           └── ConversationRepositoryProtocol.swift  # 新規
│
├── Features/
│   ├── Authentication/                       # 既存
│   └── Chat/                                 # 新規
│       ├── Domain/
│       │   ├── Entities/
│       │   │   ├── Conversation.swift        # 会話エンティティ
│       │   │   ├── Participant.swift         # 参加者エンティティ
│       │   │   ├── ConversationType.swift    # direct/group enum
│       │   │   └── ConversationDetail.swift  # Conversation + Participants
│       │   └── UseCases/
│       │       ├── ConversationUseCase.swift # 会話一覧取得・作成
│       │       └── UserListUseCase.swift     # ユーザー一覧取得
│       ├── Data/
│       │   └── Repositories/
│       │       └── MockConversationRepository.swift  # テスト用モック
│       └── Presentation/
│           ├── ViewModels/
│           │   ├── ConversationListViewModel.swift  # 一覧画面VM
│           │   └── CreateChatViewModel.swift        # 作成画面VM
│           └── Views/
│               ├── ConversationListView.swift       # 一覧画面
│               ├── CreateChatView.swift             # 作成画面
│               └── ConversationRow.swift            # 一覧の行コンポーネント
│
├── Infrastructure/
│   └── Network/
│       ├── Repositories/
│       │   ├── UserRepository.swift          # 既存（再利用）
│       │   └── ConversationRepository.swift  # 新規
│       └── DTOs/
│           ├── UserDTO+Mapping.swift         # 既存（再利用）
│           ├── ConversationDTO+Mapping.swift # 新規
│           └── ParticipantDTO+Mapping.swift  # 新規
│
└── App/
    ├── DependencyContainer.swift             # 更新
    └── PrototypeChatClientAppApp.swift       # 既存

PrototypeChatClientAppTests/
└── Features/
    └── Chat/
        ├── ConversationUseCaseTests.swift
        ├── UserListUseCaseTests.swift
        ├── ConversationListViewModelTests.swift
        └── CreateChatViewModelTests.swift
```

---

## 📦 詳細設計

### 1. Domain Layer

#### **Entities**

##### Conversation.swift
```swift
import Foundation

/// 会話エンティティ
///
/// スコープ: Features/Chat内で使用
struct Conversation: Identifiable, Codable, Equatable {
    let id: String
    let type: ConversationType
    let name: String?
    let createdAt: Date
}
```

##### ConversationType.swift
```swift
/// 会話タイプ
enum ConversationType: String, Codable {
    case direct  // 1:1チャット
    case group   // グループチャット
}
```

##### Participant.swift
```swift
import Foundation

/// 会話参加者エンティティ
struct Participant: Identifiable, Codable, Equatable {
    let id: String
    let conversationId: String
    let userId: String
    let user: User  // Core層のUserを再利用
    let joinedAt: Date
    let leftAt: Date?

    var isActive: Bool {
        leftAt == nil
    }
}
```

##### ConversationDetail.swift
```swift
/// 会話詳細（会話 + 参加者リスト）
struct ConversationDetail: Identifiable, Equatable {
    let conversation: Conversation
    let participants: [Participant]

    var id: String { conversation.id }
    var type: ConversationType { conversation.type }
    var createdAt: Date { conversation.createdAt }

    /// アクティブな参加者のみ取得
    var activeParticipants: [Participant] {
        participants.filter { $0.isActive }
    }
}
```

#### **Repository Protocol (Core層)**

##### ConversationRepositoryProtocol.swift
```swift
import Foundation

/// 会話リポジトリプロトコル
///
/// スコープ: Core層で定義、Features/Chat内で使用
protocol ConversationRepositoryProtocol {
    /// ユーザーの会話一覧を取得
    /// - Parameter userId: ユーザーID
    /// - Returns: 会話詳細リスト
    func fetchConversations(userId: String) async throws -> [ConversationDetail]

    /// 会話を作成
    /// - Parameters:
    ///   - type: 会話タイプ (direct/group)
    ///   - participantIds: 参加者のユーザーIDリスト
    ///   - name: 会話名（グループチャットの場合のみ）
    /// - Returns: 作成された会話詳細
    func createConversation(
        type: ConversationType,
        participantIds: [String],
        name: String?
    ) async throws -> ConversationDetail
}
```

#### **UseCases**

##### ConversationUseCase.swift
```swift
/// 会話UseCase
///
/// 責務:
/// - 会話一覧の取得
/// - 1:1チャット作成
/// - ビジネスロジック（表示名の生成など）
class ConversationUseCase {
    private let conversationRepository: ConversationRepositoryProtocol
    private let currentUserId: String

    init(
        conversationRepository: ConversationRepositoryProtocol,
        currentUserId: String
    ) {
        self.conversationRepository = conversationRepository
        self.currentUserId = currentUserId
    }

    /// 会話一覧を取得
    func loadConversations() async throws -> [ConversationDetail] {
        return try await conversationRepository.fetchConversations(userId: currentUserId)
    }

    /// 1:1チャットを作成
    /// - Parameter otherUserId: 相手ユーザーのID
    /// - Returns: 作成された会話詳細
    func createDirectChat(withUserId otherUserId: String) async throws -> ConversationDetail {
        let participantIds = [currentUserId, otherUserId]
        return try await conversationRepository.createConversation(
            type: .direct,
            participantIds: participantIds,
            name: nil
        )
    }

    /// 会話の表示名を取得
    /// - Direct: 相手ユーザーの名前
    /// - Group: 会話名 or "グループチャット"
    func getDisplayName(for detail: ConversationDetail) -> String {
        switch detail.type {
        case .direct:
            // 自分以外のユーザーを取得
            if let otherUser = detail.activeParticipants.first(where: { $0.userId != currentUserId })?.user {
                return otherUser.name
            }
            return "不明なユーザー"
        case .group:
            return detail.conversation.name ?? "グループチャット"
        }
    }

    /// 1:1チャットの相手ユーザーを取得
    func getOtherUser(in detail: ConversationDetail) -> User? {
        guard detail.type == .direct else { return nil }
        return detail.activeParticipants.first(where: { $0.userId != currentUserId })?.user
    }
}
```

##### UserListUseCase.swift
```swift
/// ユーザー一覧UseCase
///
/// 責務:
/// - チャット作成時のユーザー一覧取得
class UserListUseCase {
    private let userRepository: UserRepositoryProtocol
    private let currentUserId: String

    init(
        userRepository: UserRepositoryProtocol,
        currentUserId: String
    ) {
        self.userRepository = userRepository
        self.currentUserId = currentUserId
    }

    /// ユーザー一覧を取得（自分以外）
    func loadUsers() async throws -> [User] {
        let allUsers = try await userRepository.fetchUsers()
        // 自分自身を除外
        return allUsers.filter { $0.id != currentUserId }
    }
}
```

---

### 2. Presentation Layer

#### **ViewModels**

##### ConversationListViewModel.swift
```swift
import SwiftUI

@MainActor
class ConversationListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var conversations: [ConversationDetail] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showCreateChat = false

    // MARK: - Dependencies
    private let conversationUseCase: ConversationUseCase

    // MARK: - Initialization
    init(conversationUseCase: ConversationUseCase) {
        self.conversationUseCase = conversationUseCase
    }

    // MARK: - Public Methods

    /// 会話一覧を読み込み
    func loadConversations() async {
        isLoading = true
        errorMessage = nil

        do {
            conversations = try await conversationUseCase.loadConversations()
        } catch {
            errorMessage = "会話の読み込みに失敗しました"
        }

        isLoading = false
    }

    /// 会話の表示名を取得
    func getDisplayName(for conversation: ConversationDetail) -> String {
        conversationUseCase.getDisplayName(for: conversation)
    }

    /// 1:1チャットの相手ユーザーを取得
    func getOtherUser(in conversation: ConversationDetail) -> User? {
        conversationUseCase.getOtherUser(in: conversation)
    }

    /// チャット作成成功時のコールバック
    func onChatCreated(_ conversation: ConversationDetail) {
        conversations.insert(conversation, at: 0)
        showCreateChat = false
    }
}
```

##### CreateChatViewModel.swift
```swift
import SwiftUI

@MainActor
class CreateChatViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var users: [User] = []
    @Published var selectedUserId: String?
    @Published var isLoading = false
    @Published var isCreating = false
    @Published var errorMessage: String?

    // MARK: - Dependencies
    private let userListUseCase: UserListUseCase
    private let conversationUseCase: ConversationUseCase

    // MARK: - Callbacks
    var onChatCreated: ((ConversationDetail) -> Void)?
    var onDismiss: (() -> Void)?

    // MARK: - Initialization
    init(
        userListUseCase: UserListUseCase,
        conversationUseCase: ConversationUseCase
    ) {
        self.userListUseCase = userListUseCase
        self.conversationUseCase = conversationUseCase
    }

    // MARK: - Public Methods

    /// ユーザー一覧を読み込み
    func loadUsers() async {
        isLoading = true
        errorMessage = nil

        do {
            users = try await userListUseCase.loadUsers()
        } catch {
            errorMessage = "ユーザーの読み込みに失敗しました"
        }

        isLoading = false
    }

    /// チャットを作成
    func createChat() async {
        guard let selectedUserId = selectedUserId else { return }

        isCreating = true
        errorMessage = nil

        do {
            let conversation = try await conversationUseCase.createDirectChat(withUserId: selectedUserId)
            onChatCreated?(conversation)
            onDismiss?()
        } catch {
            errorMessage = "チャットの作成に失敗しました"
        }

        isCreating = false
    }
}
```

#### **Views**

##### ConversationListView.swift
```swift
import SwiftUI

struct ConversationListView: View {
    @StateObject var viewModel: ConversationListViewModel
    @StateObject var createChatViewModel: CreateChatViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("読み込み中...")
                } else if viewModel.conversations.isEmpty {
                    emptyStateView
                } else {
                    conversationList
                }
            }
            .navigationTitle("チャット")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showCreateChat = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showCreateChat) {
                CreateChatView(viewModel: createChatViewModel)
            }
            .task {
                await viewModel.loadConversations()
            }
            .alert("エラー", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    private var conversationList: some View {
        List(viewModel.conversations) { detail in
            ConversationRow(
                displayName: viewModel.getDisplayName(for: detail),
                otherUser: viewModel.getOtherUser(in: detail)
            )
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "message")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("チャットがありません")
                .font(.headline)
            Text("右上の + ボタンから新しいチャットを作成できます")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
```

##### CreateChatView.swift
```swift
import SwiftUI

struct CreateChatView: View {
    @StateObject var viewModel: CreateChatViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("読み込み中...")
                } else if viewModel.users.isEmpty {
                    emptyStateView
                } else {
                    userList
                }
            }
            .navigationTitle("新しいチャット")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("作成") {
                        Task {
                            await viewModel.createChat()
                        }
                    }
                    .disabled(viewModel.selectedUserId == nil || viewModel.isCreating)
                }
            }
            .task {
                await viewModel.loadUsers()
            }
            .alert("エラー", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .onAppear {
                viewModel.onDismiss = {
                    dismiss()
                }
            }
        }
    }

    private var userList: some View {
        List(viewModel.users) { user in
            Button {
                viewModel.selectedUserId = user.id
            } label: {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)

                    Text(user.name)
                        .foregroundColor(.primary)

                    Spacer()

                    if viewModel.selectedUserId == user.id {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("ユーザーが見つかりません")
                .font(.headline)
        }
        .padding()
    }
}
```

##### ConversationRow.swift
```swift
import SwiftUI

struct ConversationRow: View {
    let displayName: String
    let otherUser: User?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 44))
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 4) {
                Text(displayName)
                    .font(.headline)

                Text("最近のメッセージなし")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}
```

---

### 3. Infrastructure Layer

#### **Repository Implementation**

##### ConversationRepository.swift
```swift
import Foundation
import OpenAPIRuntime

/// 会話リポジトリの実装（OpenAPI使用）
class ConversationRepository: ConversationRepositoryProtocol {
    private let client: Client

    init(client: Client) {
        self.client = client
    }

    func fetchConversations(userId: String) async throws -> [ConversationDetail] {
        let input = Operations.get_sol_conversations.Input(
            query: .init(userId: userId)
        )

        let response = try await client.get_sol_conversations(input)

        switch response {
        case .ok(let okResponse):
            let conversationDTOs = try okResponse.body.json
            return conversationDTOs.map { $0.toDomain() }
        case .undocumented(statusCode: let code, _):
            throw NetworkError.from(statusCode: code)
        }
    }

    func createConversation(
        type: ConversationType,
        participantIds: [String],
        name: String?
    ) async throws -> ConversationDetail {
        let input = Operations.post_sol_conversations.Input(
            body: .json(
                Components.Schemas.CreateConversationRequest(
                    _type: type.rawValue,
                    name: name,
                    participantIds: participantIds
                )
            )
        )

        let response = try await client.post_sol_conversations(input)

        switch response {
        case .created(let createdResponse):
            let conversationDTO = try createdResponse.body.json
            return conversationDTO.toDomain()
        case .undocumented(statusCode: let code, _):
            throw NetworkError.from(statusCode: code)
        }
    }
}
```

#### **DTO Mapping**

##### ConversationDTO+Mapping.swift
```swift
import Foundation
import OpenAPIRuntime

/// OpenAPI DTO → Domain Entity マッピング
extension Components.Schemas.ConversationDetail {
    func toDomain() -> ConversationDetail {
        ConversationDetail(
            conversation: Conversation(
                id: id,
                type: ConversationType(rawValue: _type) ?? .direct,
                name: name,
                createdAt: createdAt
            ),
            participants: participants.map { $0.toDomain() }
        )
    }
}

extension Components.Schemas.Conversation {
    func toDomain() -> Conversation {
        Conversation(
            id: id,
            type: ConversationType(rawValue: _type) ?? .direct,
            name: name,
            createdAt: createdAt
        )
    }
}
```

##### ParticipantDTO+Mapping.swift
```swift
import Foundation
import OpenAPIRuntime

extension Components.Schemas.Participant {
    func toDomain() -> Participant {
        Participant(
            id: id,
            conversationId: conversationId,
            userId: userId,
            user: user.toDomain(),
            joinedAt: joinedAt,
            leftAt: leftAt
        )
    }
}
```

#### **Mock Repository**

##### MockConversationRepository.swift
```swift
/// テスト用のモック会話リポジトリ
class MockConversationRepository: ConversationRepositoryProtocol {
    var conversations: [ConversationDetail] = []
    var shouldThrowError: Error?

    func fetchConversations(userId: String) async throws -> [ConversationDetail] {
        if let error = shouldThrowError {
            throw error
        }
        return conversations
    }

    func createConversation(
        type: ConversationType,
        participantIds: [String],
        name: String?
    ) async throws -> ConversationDetail {
        if let error = shouldThrowError {
            throw error
        }

        // モックデータ生成
        let newConversation = ConversationDetail(
            conversation: Conversation(
                id: UUID().uuidString,
                type: type,
                name: name,
                createdAt: Date()
            ),
            participants: [] // 簡略化
        )
        conversations.insert(newConversation, at: 0)
        return newConversation
    }
}
```

---

### 4. Dependency Injection

#### **DependencyContainer.swift 更新**

現在の構造を維持しつつ、会話機能用の依存性を追加します。

```swift
@MainActor
final class DependencyContainer: ObservableObject {
    // MARK: - Environment
    let environment: AppEnvironment

    // MARK: - Infrastructure Layer
    private lazy var apiClient: Client = {
        APIClientFactory.createClient(environment: environment)
    }()

    // MARK: - Repository Layer
    var userRepository: UserRepositoryProtocol
    var authSessionManager: AuthSessionManagerProtocol

    // 新規追加: 会話リポジトリ
    var conversationRepository: ConversationRepositoryProtocol

    // MARK: - Use Cases
    lazy var authenticationUseCase: AuthenticationUseCaseProtocol = {
        AuthenticationUseCase(
            userRepository: userRepository,
            sessionManager: authSessionManager
        )
    }()

    // 新規追加: 会話UseCase
    lazy var conversationUseCase: ConversationUseCase = {
        guard let session = authSessionManager.loadSession() else {
            fatalError("No authenticated session for ConversationUseCase")
        }
        return ConversationUseCase(
            conversationRepository: conversationRepository,
            currentUserId: session.userId
        )
    }()

    // 新規追加: ユーザー一覧UseCase
    lazy var userListUseCase: UserListUseCase = {
        guard let session = authSessionManager.loadSession() else {
            fatalError("No authenticated session for UserListUseCase")
        }
        return UserListUseCase(
            userRepository: userRepository,
            currentUserId: session.userId
        )
    }()

    // MARK: - View Models
    lazy var authenticationViewModel: AuthenticationViewModel = {
        AuthenticationViewModel(
            authenticationUseCase: authenticationUseCase,
            sessionManager: authSessionManager
        )
    }()

    // 新規追加: 会話一覧ViewModel
    lazy var conversationListViewModel: ConversationListViewModel = {
        ConversationListViewModel(conversationUseCase: conversationUseCase)
    }()

    // 新規追加: チャット作成ViewModel
    lazy var createChatViewModel: CreateChatViewModel = {
        CreateChatViewModel(
            userListUseCase: userListUseCase,
            conversationUseCase: conversationUseCase
        )
    }()

    // MARK: - Singleton
    static let shared = DependencyContainer()

    // MARK: - Initialization
    private init(
        environment: AppEnvironment = .current,
        userRepository: UserRepositoryProtocol? = nil,
        authSessionManager: AuthSessionManagerProtocol? = nil,
        conversationRepository: ConversationRepositoryProtocol? = nil
    ) {
        self.environment = environment

        // UserRepository
        if let mockUserRepository = userRepository {
            self.userRepository = mockUserRepository
        } else {
            let client = APIClientFactory.createClient(environment: environment)
            self.userRepository = UserRepository(client: client)
        }

        // AuthSessionManager
        self.authSessionManager = authSessionManager ?? AuthSessionManager()

        // ConversationRepository (新規)
        if let mockConversationRepository = conversationRepository {
            self.conversationRepository = mockConversationRepository
        } else {
            let client = APIClientFactory.createClient(environment: environment)
            self.conversationRepository = ConversationRepository(client: client)
        }
    }

    // MARK: - Factory Methods for Testing & Preview
    static func makeTestContainer(
        userRepository: UserRepositoryProtocol? = nil,
        authSessionManager: AuthSessionManagerProtocol? = nil,
        conversationRepository: ConversationRepositoryProtocol? = nil
    ) -> DependencyContainer {
        DependencyContainer(
            environment: .development,
            userRepository: userRepository ?? MockUserRepository(),
            authSessionManager: authSessionManager ?? MockAuthSessionManager(),
            conversationRepository: conversationRepository ?? MockConversationRepository()
        )
    }

    static func makePreviewContainer() -> DependencyContainer {
        let mockUserRepository = MockUserRepository()
        let mockSessionManager = MockAuthSessionManager()
        let mockConversationRepository = MockConversationRepository()

        return makeTestContainer(
            userRepository: mockUserRepository,
            authSessionManager: mockSessionManager,
            conversationRepository: mockConversationRepository
        )
    }
}
```

**変更点の説明**:
- `conversationRepository`プロパティ追加
- `conversationUseCase`, `userListUseCase`をlazy varとして追加
- `conversationListViewModel`, `createChatViewModel`をlazy varとして追加
- 各UseCaseとViewModelは`authSessionManager.loadSession()`から`currentUserId`を取得
- 既存の`apiClient`プロパティは保持（必要に応じて活用）

---

### 5. MainView の更新

#### **既存MainViewをTabViewに変更**

現在の`MainView.swift`を以下のように置き換えます：

```swift
import SwiftUI

struct MainView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel

    // DependencyContainerから会話関連のViewModelを取得
    @StateObject private var conversationListViewModel: ConversationListViewModel
    @StateObject private var createChatViewModel: CreateChatViewModel

    init(
        conversationListViewModel: ConversationListViewModel,
        createChatViewModel: CreateChatViewModel
    ) {
        _conversationListViewModel = StateObject(wrappedValue: conversationListViewModel)
        _createChatViewModel = StateObject(wrappedValue: createChatViewModel)
    }

    var body: some View {
        TabView {
            ConversationListView(
                viewModel: conversationListViewModel,
                createChatViewModel: createChatViewModel
            )
            .tabItem {
                Label("チャット", systemImage: "message")
            }

            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gearshape")
                }
        }
    }
}

// MARK: - Settings View (新規作成)
struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel

    var body: some View {
        NavigationStack {
            List {
                if let session = authViewModel.currentSession {
                    Section("ユーザー情報") {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.blue)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(session.user.name)
                                    .font(.headline)
                                Text(session.userId)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section {
                    Button(role: .destructive) {
                        authViewModel.logout()
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("ログアウト")
                        }
                    }
                }
            }
            .navigationTitle("設定")
        }
    }
}

// MARK: - Preview
#Preview {
    MainViewPreview()
}

private struct MainViewPreview: View {
    @StateObject private var container = DependencyContainer.makePreviewContainer()

    var body: some View {
        let authViewModel = container.authenticationViewModel
        authViewModel.isAuthenticated = true
        authViewModel.currentSession = AuthSession(
            userId: "user-1",
            user: User(id: "user-1", name: "Alice", avatarUrl: nil, createdAt: Date()),
            authenticatedAt: Date()
        )

        return MainView(
            conversationListViewModel: container.conversationListViewModel,
            createChatViewModel: container.createChatViewModel
        )
        .environmentObject(authViewModel)
    }
}
```

**重要な変更点**:
1. `MainView`はTabViewでチャット一覧と設定画面を切り替え
2. ViewModelは`@StateObject`で初期化時に受け取る
3. `SettingsView`は別ファイル`Features/Authentication/Presentation/Views/SettingsView.swift`として作成
4. Preview用の構造も追加

#### **RootView.swift の更新**

`MainView`の初期化を変更します：

```swift
import SwiftUI

struct RootView: View {
    @EnvironmentObject var container: DependencyContainer

    var body: some View {
        let authViewModel = container.authenticationViewModel

        Group {
            if authViewModel.isAuthenticated {
                MainView(
                    conversationListViewModel: container.conversationListViewModel,
                    createChatViewModel: container.createChatViewModel
                )
                .environmentObject(authViewModel)
            } else {
                AuthenticationView(viewModel: authViewModel)
            }
        }
        .onAppear {
            authViewModel.checkAuthentication()
        }
    }
}
```

**変更点**:
- `MainView`の初期化時に`conversationListViewModel`と`createChatViewModel`を渡す
- `authViewModel`は引き続き`environmentObject`で渡す

---

## 🧪 テスト戦略

### Unit Tests

#### ConversationUseCaseTests.swift
```swift
import XCTest
@testable import PrototypeChatClientApp

@MainActor
final class ConversationUseCaseTests: XCTestCase {
    var sut: ConversationUseCase!
    var mockRepository: MockConversationRepository!
    let currentUserId = "user-1"

    override func setUp() {
        super.setUp()
        mockRepository = MockConversationRepository()
        sut = ConversationUseCase(
            conversationRepository: mockRepository,
            currentUserId: currentUserId
        )
    }

    func testLoadConversations_Success() async throws {
        // Given
        let mockConversation = createMockConversation()
        mockRepository.conversations = [mockConversation]

        // When
        let result = try await sut.loadConversations()

        // Then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, mockConversation.id)
    }

    func testCreateDirectChat_Success() async throws {
        // Given
        let otherUserId = "user-2"

        // When
        let result = try await sut.createDirectChat(withUserId: otherUserId)

        // Then
        XCTAssertEqual(result.type, .direct)
        XCTAssertEqual(mockRepository.conversations.count, 1)
    }

    func testGetDisplayName_DirectChat() {
        // Given
        let otherUser = User(id: "user-2", name: "Bob", avatarUrl: nil, createdAt: Date())
        let conversation = createMockDirectConversation(otherUser: otherUser)

        // When
        let displayName = sut.getDisplayName(for: conversation)

        // Then
        XCTAssertEqual(displayName, "Bob")
    }

    // Helper methods
    private func createMockConversation() -> ConversationDetail {
        // Implementation
    }
}
```

#### CreateChatViewModelTests.swift
```swift
import XCTest
@testable import PrototypeChatClientApp

@MainActor
final class CreateChatViewModelTests: XCTestCase {
    var sut: CreateChatViewModel!
    var mockUserRepository: MockUserRepository!
    var mockConversationRepository: MockConversationRepository!

    override func setUp() {
        super.setUp()
        mockUserRepository = MockUserRepository()
        mockConversationRepository = MockConversationRepository()

        let userListUseCase = UserListUseCase(
            userRepository: mockUserRepository,
            currentUserId: "user-1"
        )
        let conversationUseCase = ConversationUseCase(
            conversationRepository: mockConversationRepository,
            currentUserId: "user-1"
        )

        sut = CreateChatViewModel(
            userListUseCase: userListUseCase,
            conversationUseCase: conversationUseCase
        )
    }

    func testLoadUsers_Success() async {
        // Given
        let mockUsers = [
            User(id: "user-2", name: "Bob", avatarUrl: nil, createdAt: Date()),
            User(id: "user-3", name: "Charlie", avatarUrl: nil, createdAt: Date())
        ]
        mockUserRepository.users = mockUsers

        // When
        await sut.loadUsers()

        // Then
        XCTAssertEqual(sut.users.count, 2)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    func testCreateChat_Success() async {
        // Given
        sut.selectedUserId = "user-2"
        var createdConversation: ConversationDetail?
        sut.onChatCreated = { conversation in
            createdConversation = conversation
        }

        // When
        await sut.createChat()

        // Then
        XCTAssertNotNil(createdConversation)
        XCTAssertEqual(createdConversation?.type, .direct)
    }
}
```

---

## 📝 実装順序

### Step 0: 事前準備（日付パース修正） ⚠️
**所要時間**: 5分

0. `Infrastructure/Network/APIClient/APIClientFactory.swift` - CustomDateTranscoderの再追加
   - バックエンドが返す`"2025-12-10T11:03:08"`（タイムゾーンなし）に対応
   - ISO8601（タイムゾーン付き）へのフォールバック

### Step 1: Domain層の基礎 ✅
**所要時間**: 15分

1. `Core/Protocols/Repository/ConversationRepositoryProtocol.swift`
2. `Features/Chat/Domain/Entities/ConversationType.swift`
3. `Features/Chat/Domain/Entities/Conversation.swift`
4. `Features/Chat/Domain/Entities/Participant.swift`
5. `Features/Chat/Domain/Entities/ConversationDetail.swift`

### Step 2: Infrastructure層 ✅
**所要時間**: 20分

6. `Infrastructure/Network/DTOs/ConversationDTO+Mapping.swift`
7. `Infrastructure/Network/DTOs/ParticipantDTO+Mapping.swift`
8. `Infrastructure/Network/Repositories/ConversationRepository.swift`
9. `Features/Chat/Data/Repositories/MockConversationRepository.swift`

### Step 3: UseCase層 ✅
**所要時間**: 15分

10. `Features/Chat/Domain/UseCases/ConversationUseCase.swift`
11. `Features/Chat/Domain/UseCases/UserListUseCase.swift`

### Step 4: Presentation層 ✅
**所要時間**: 30分

12. `Features/Chat/Presentation/ViewModels/ConversationListViewModel.swift`
13. `Features/Chat/Presentation/ViewModels/CreateChatViewModel.swift`
14. `Features/Chat/Presentation/Views/ConversationRow.swift`
15. `Features/Chat/Presentation/Views/ConversationListView.swift`
16. `Features/Chat/Presentation/Views/CreateChatView.swift`

### Step 5: 統合 ✅
**所要時間**: 20分

17. `App/DependencyContainer.swift` - 更新
18. `Features/Authentication/Presentation/Views/MainView.swift` - TabView化
19. `Features/Authentication/Presentation/Views/SettingsView.swift` - 新規作成
20. `Features/Authentication/Presentation/Views/RootView.swift` - MainViewへの引数追加
21. 動作確認・デバッグ

**合計所要時間**: 約105分（1時間45分）

### ⚠️ 重要な前提条件

**Step 0を必ず最初に実行すること！**

現在`APIClientFactory.swift`から`CustomDateTranscoder`が削除されているため、会話一覧取得時に日付パースエラーが発生します。バックエンドは`"2025-12-10T11:03:08"`形式（タイムゾーン情報なし）を返すため、カスタムデコーダーが必須です。

```swift
// 再追加が必要なコード
struct CustomDateTranscoder: DateTranscoder {
    func decode(_ dateString: String) throws -> Date {
        // 1. ISO8601 with timezone (e.g., "2025-12-10T11:03:08Z")
        if let date = ISO8601DateFormatter().date(from: dateString) {
            return date
        }

        // 2. ISO8601 without timezone (e.g., "2025-12-10T11:03:08")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        if let date = formatter.date(from: dateString) {
            return date
        }

        throw DecodingError.dataCorrupted(...)
    }
}
```

---

## 🎨 UI設計（最小限）

### チャット一覧画面
```
┌─────────────────────────────────┐
│ チャット                    [+] │ ← NavigationBar
├─────────────────────────────────┤
│ 👤  Alice                      │
│     最近のメッセージなし          │
├─────────────────────────────────┤
│ 👤  Bob                        │
│     最近のメッセージなし          │
├─────────────────────────────────┤
│ 👤  Charlie                    │
│     最近のメッセージなし          │
└─────────────────────────────────┘
│ 💬    ⚙️  │ ← TabBar
└───────────┘
```

### チャット作成画面（Sheet）
```
┌─────────────────────────────────┐
│ キャンセル  新しいチャット  作成  │ ← NavigationBar
├─────────────────────────────────┤
│ 👤  Alice                    ✓ │ ← 選択中
├─────────────────────────────────┤
│ 👤  Bob                        │
├─────────────────────────────────┤
│ 👤  Charlie                    │
└─────────────────────────────────┘
```

### 空の状態
```
┌─────────────────────────────────┐
│ チャット                    [+] │
├─────────────────────────────────┤
│                                 │
│          💬                     │
│                                 │
│     チャットがありません          │
│                                 │
│  右上の + ボタンから新しい       │
│  チャットを作成できます          │
│                                 │
└─────────────────────────────────┘
```

---

## ⚠️ 注意点・制約

### 技術的制約
1. **日付フォーマット**:
   - **重要**: `APIClientFactory`に`CustomDateTranscoder`の再追加が必要
   - バックエンドは`"2025-12-10T11:03:08"`形式（タイムゾーンなし）を返す
   - デフォルトのISO8601DateFormatterはタイムゾーン必須のため、カスタムトランスコーダー必須
2. **認証情報**: `AuthSession`から`currentUserId`を取得
3. **エラーハンドリング**: 既存の`NetworkError`を再利用
4. **テスタビリティ**: Protocol-based DI維持（Mock実装を用意）

### ビジネスロジック
5. **1:1チャット**:
   - 参加者は必ず2名（自分 + 相手）
   - 会話名は不要（相手の名前を表示）
6. **ユーザー一覧**: 自分自身は除外して表示
7. **会話表示名**:
   - Direct: 相手ユーザーの名前
   - Group: 会話名 or "グループチャット"

### OpenAPI対応
8. **生成コードの依存**: 以下のDTOマッピングが必要
   - `Components.Schemas.ConversationDetail`
   - `Components.Schemas.Conversation`
   - `Components.Schemas.Participant`
   - `Components.Schemas.CreateConversationRequest`

### UI/UX
9. **ネイティブコンポーネント**: SwiftUI標準コンポーネントのみ使用
10. **デザイン**: 最小限のスタイリング（後回し）
11. **リアルタイム更新**: なし（手動リフレッシュのみ）

---

## 🚀 次フェーズ（Phase 2以降）

### Phase 2: チャット詳細画面
- メッセージ一覧表示
- メッセージ送信
- メッセージページング

### Phase 3: リアルタイム機能
- WebSocket/SSE統合
- 新着メッセージの自動受信
- オンラインステータス表示

### Phase 4: 高度な機能
- グループチャット作成
- メッセージ検索
- 画像・ファイル送信
- リアクション機能
- プッシュ通知

### Phase 5: UI/UXブラッシュアップ
- カスタムデザインシステム
- アニメーション
- 既読・未読管理
- タイピングインジケーター

---

## 📚 参考資料

- [既存の認証機能アーキテクチャ](./API_LAYER_DESIGN_20251211_JA.md)
- [OpenAPI仕様書](../PrototypeChatClientApp/openapi.yaml)
- [OpenAPIセットアップガイド](../OPENAPI_SETUP.md)

---

**最終更新**: 2025年12月12日
