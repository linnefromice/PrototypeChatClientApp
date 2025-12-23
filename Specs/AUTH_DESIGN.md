# iOSチャットクライアントアプリ - 認証管理設計書

## 1. 概要

### 1.1 目的
バックエンドに認証機能がない検証実装環境において、シンプルな仮認証の仕組みを構築する。

### 1.2 設計方針
- **最小限の実装**: User IDのみで認証状態を管理
- **開発効率**: 複雑な認証フローを避け、迅速な開発を可能にする
- **拡張性**: 将来的な本格的認証（JWT等）への移行を考慮した設計

### 1.3 認証フロー

```
┌─────────────────┐
│  アプリ起動     │
└────────┬────────┘
         │
         ▼
   ┌──────────────┐
   │ローカルに     │
   │UserID保存済み?│
   └─┬──────────┬─┘
     │ YES      │ NO
     │          │
     ▼          ▼
┌─────────┐  ┌──────────────┐
│自動      │  │User ID       │
│ログイン  │  │入力画面表示  │
└────┬────┘  └──────┬───────┘
     │              │
     │              ▼
     │         ┌──────────────┐
     │         │User ID入力   │
     │         │& Submit      │
     │         └──────┬───────┘
     │                │
     ▼                ▼
   ┌────────────────────────┐
   │GET /users/{userId}呼出 │
   └──────┬─────────────────┘
          │
     ┌────┴────┐
     │         │
  成功       失敗
     │         │
     ▼         ▼
┌─────────┐ ┌──────────────┐
│User情報 │ │エラー表示    │
│を保存   │ │再入力促す    │
└────┬────┘ └──────────────┘
     │
     ▼
┌─────────────┐
│チャット     │
│画面へ遷移   │
└─────────────┘
```

---

## 2. データ構造

### 2.1 認証セッション

```swift
struct AuthSession: Codable {
    let userId: String
    let user: User
    let authenticatedAt: Date

    var isValid: Bool {
        // 将来的に有効期限チェックを追加可能
        return true
    }
}
```

### 2.2 ローカルストレージキー

```swift
enum StorageKey {
    static let authSession = "com.prototype.chat.authSession"
    static let lastUserId = "com.prototype.chat.lastUserId"
}
```

---

## 3. アーキテクチャ設計

### 3.1 レイヤー構成

```
┌─────────────────────────────────────────┐
│        Presentation Layer               │
│  - AuthenticationView                   │
│  - AuthenticationViewModel              │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│          Domain Layer                   │
│  - AuthenticationUseCase                │
│  - ValidateUserUseCase                  │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│           Data Layer                    │
│  - AuthSessionManager                   │
│  - UserRepository                       │
│  - UserDefaultsManager                  │
└─────────────────────────────────────────┘
```

---

## 4. 実装設計

### 4.1 AuthSessionManager

**責務**: 認証セッションの永続化と取得

```swift
import Foundation

protocol AuthSessionManagerProtocol {
    func saveSession(_ session: AuthSession) throws
    func loadSession() -> AuthSession?
    func clearSession()
}

class AuthSessionManager: AuthSessionManagerProtocol {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func saveSession(_ session: AuthSession) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(session)
        userDefaults.set(data, forKey: StorageKey.authSession)
        userDefaults.set(session.userId, forKey: StorageKey.lastUserId)
    }

    func loadSession() -> AuthSession? {
        guard let data = userDefaults.data(forKey: StorageKey.authSession) else {
            return nil
        }

        let decoder = JSONDecoder()
        return try? decoder.decode(AuthSession.self, from: data)
    }

    func clearSession() {
        userDefaults.removeObject(forKey: StorageKey.authSession)
        // lastUserIdは残しておく（再ログイン時の利便性向上）
    }
}
```

### 4.2 AuthenticationUseCase

**責務**: 認証ビジネスロジック

```swift
import Foundation

protocol AuthenticationUseCaseProtocol {
    func authenticate(userId: String) async throws -> AuthSession
    func loadSavedSession() -> AuthSession?
    func logout()
}

class AuthenticationUseCase: AuthenticationUseCaseProtocol {
    private let userRepository: UserRepositoryProtocol
    private let sessionManager: AuthSessionManagerProtocol

    init(
        userRepository: UserRepositoryProtocol,
        sessionManager: AuthSessionManagerProtocol
    ) {
        self.userRepository = userRepository
        self.sessionManager = sessionManager
    }

    func authenticate(userId: String) async throws -> AuthSession {
        // 1. User IDのバリデーション
        guard !userId.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw AuthenticationError.emptyUserId
        }

        // 2. GET /users/{userId} を呼び出し
        let user = try await userRepository.fetchUser(id: userId)

        // 3. セッション作成
        let session = AuthSession(
            userId: userId,
            user: user,
            authenticatedAt: Date()
        )

        // 4. ローカルに保存
        try sessionManager.saveSession(session)

        return session
    }

    func loadSavedSession() -> AuthSession? {
        guard let session = sessionManager.loadSession() else {
            return nil
        }

        // 有効性チェック
        guard session.isValid else {
            sessionManager.clearSession()
            return nil
        }

        return session
    }

    func logout() {
        sessionManager.clearSession()
    }
}
```

### 4.3 エラー定義

```swift
enum AuthenticationError: LocalizedError {
    case emptyUserId
    case userNotFound
    case invalidUserId
    case sessionExpired

    var errorDescription: String? {
        switch self {
        case .emptyUserId:
            return "User IDを入力してください"
        case .userNotFound:
            return "指定されたUser IDが見つかりません"
        case .invalidUserId:
            return "無効なUser ID形式です"
        case .sessionExpired:
            return "セッションの有効期限が切れました"
        }
    }
}
```

### 4.4 AuthenticationViewModel

**責務**: UI状態管理と認証フロー制御

```swift
import SwiftUI
import Combine

@MainActor
class AuthenticationViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var userId: String = ""
    @Published var currentSession: AuthSession?
    @Published var isAuthenticating: Bool = false
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false

    // MARK: - Dependencies
    private let authenticationUseCase: AuthenticationUseCaseProtocol

    // MARK: - Initialization
    init(authenticationUseCase: AuthenticationUseCaseProtocol) {
        self.authenticationUseCase = authenticationUseCase
    }

    // MARK: - Public Methods

    /// アプリ起動時の認証チェック
    func checkAuthentication() {
        if let session = authenticationUseCase.loadSavedSession() {
            self.currentSession = session
            self.isAuthenticated = true
            self.userId = session.userId
        }
    }

    /// ユーザーIDによる認証実行
    func authenticate() async {
        guard !userId.isEmpty else {
            errorMessage = "User IDを入力してください"
            return
        }

        isAuthenticating = true
        errorMessage = nil

        do {
            let session = try await authenticationUseCase.authenticate(userId: userId)
            self.currentSession = session
            self.isAuthenticated = true
        } catch let error as AuthenticationError {
            errorMessage = error.errorDescription
        } catch let error as NetworkError {
            // NetworkErrorからの変換
            switch error {
            case .notFound:
                errorMessage = "指定されたUser IDが見つかりません"
            default:
                errorMessage = error.errorDescription
            }
        } catch {
            errorMessage = "認証に失敗しました: \(error.localizedDescription)"
        }

        isAuthenticating = false
    }

    /// ログアウト
    func logout() {
        authenticationUseCase.logout()
        currentSession = nil
        isAuthenticated = false
        userId = ""
    }

    /// 最後に使用したUser IDを取得
    func loadLastUserId() -> String? {
        UserDefaults.standard.string(forKey: StorageKey.lastUserId)
    }
}
```

### 4.5 AuthenticationView

**責務**: 認証画面UI

```swift
import SwiftUI

struct AuthenticationView: View {
    @StateObject private var viewModel: AuthenticationViewModel

    init(viewModel: AuthenticationViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // ロゴ・タイトル
                VStack(spacing: 8) {
                    Image(systemName: "message.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)

                    Text("チャットアプリ")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("開発用認証")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 60)

                Spacer()

                // 入力フォーム
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("User ID")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        TextField("User IDを入力", text: $viewModel.userId)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .disabled(viewModel.isAuthenticating)
                            .onSubmit {
                                Task {
                                    await viewModel.authenticate()
                                }
                            }

                        // ヘルプテキスト
                        Text("バックエンドに登録済みのUser IDを入力してください")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // エラーメッセージ
                    if let errorMessage = viewModel.errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text(errorMessage)
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.red.opacity(0.1))
                        )
                    }

                    // 認証ボタン
                    Button {
                        Task {
                            await viewModel.authenticate()
                        }
                    } label: {
                        HStack {
                            if viewModel.isAuthenticating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                            Text(viewModel.isAuthenticating ? "認証中..." : "ログイン")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(viewModel.userId.isEmpty || viewModel.isAuthenticating)
                }
                .padding(.horizontal, 32)

                Spacer()

                // デバッグ情報（開発環境のみ）
                #if DEBUG
                VStack(spacing: 4) {
                    Text("開発環境")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    if let lastUserId = viewModel.loadLastUserId() {
                        Button("前回のID: \(lastUserId)") {
                            viewModel.userId = lastUserId
                        }
                        .font(.caption)
                    }
                }
                .padding(.bottom, 16)
                #endif
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Preview
#Preview {
    AuthenticationView(
        viewModel: AuthenticationViewModel(
            authenticationUseCase: MockAuthenticationUseCase()
        )
    )
}
```

---

## 5. アプリ統合

### 5.1 アプリエントリーポイント

```swift
import SwiftUI

@main
struct PrototypeChatClientAppApp: App {
    @StateObject private var authViewModel: AuthenticationViewModel

    init() {
        // 依存性注入
        let client = APIClientFactory.createClient()
        let userRepository = UserRepository(client: client)
        let sessionManager = AuthSessionManager()
        let authUseCase = AuthenticationUseCase(
            userRepository: userRepository,
            sessionManager: sessionManager
        )
        let viewModel = AuthenticationViewModel(authenticationUseCase: authUseCase)

        _authViewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
                .onAppear {
                    authViewModel.checkAuthentication()
                }
        }
    }
}
```

### 5.2 ルート画面

```swift
import SwiftUI

struct RootView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                // 認証済み: チャット画面へ
                MainTabView()
                    .environmentObject(authViewModel)
            } else {
                // 未認証: 認証画面表示
                AuthenticationView(viewModel: authViewModel)
            }
        }
    }
}
```

### 5.3 メインタブビュー

```swift
import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel

    var body: some View {
        TabView {
            // 会話一覧タブ
            ConversationListView()
                .tabItem {
                    Label("チャット", systemImage: "message.fill")
                }

            // プロフィールタブ
            ProfileView()
                .tabItem {
                    Label("プロフィール", systemImage: "person.fill")
                }
        }
    }
}
```

---

## 6. 認証情報の利用

### 6.1 ViewModelでの利用例

```swift
class ConversationListViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []

    private let fetchConversationsUseCase: FetchConversationsUseCase
    private let authViewModel: AuthenticationViewModel

    init(
        fetchConversationsUseCase: FetchConversationsUseCase,
        authViewModel: AuthenticationViewModel
    ) {
        self.fetchConversationsUseCase = fetchConversationsUseCase
        self.authViewModel = authViewModel
    }

    func loadConversations() async throws {
        // 現在のユーザーIDを使用
        guard let userId = authViewModel.currentSession?.userId else {
            throw AuthenticationError.sessionExpired
        }

        conversations = try await fetchConversationsUseCase.execute(userId: userId)
    }
}
```

### 6.2 @EnvironmentObjectでの利用

```swift
struct ConversationDetailView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject private var viewModel: ConversationDetailViewModel

    let conversationId: String

    var body: some View {
        VStack {
            // メッセージ一覧
            MessageListView(messages: viewModel.messages)

            // メッセージ入力
            MessageInputView { text in
                guard let userId = authViewModel.currentSession?.userId else {
                    return
                }

                Task {
                    try await viewModel.sendMessage(
                        text: text,
                        senderUserId: userId
                    )
                }
            }
        }
        .navigationTitle("チャット")
    }
}
```

---

## 7. セキュリティ考慮事項

### 7.1 現在の実装（開発環境）

| 項目 | 実装内容 |
|------|----------|
| **ストレージ** | UserDefaults（平文保存） |
| **通信** | HTTP/HTTPS |
| **セッション管理** | 有効期限なし |
| **認証方式** | User IDのみ |

### 7.2 将来的な改善（本番環境想定）

| 項目 | 改善案 |
|------|--------|
| **ストレージ** | Keychain（暗号化保存） |
| **通信** | HTTPS必須 + 証明書ピンニング |
| **セッション管理** | トークン有効期限 + リフレッシュ機能 |
| **認証方式** | JWT / OAuth 2.0 |

### 7.3 将来の認証実装への移行パス

```swift
// プロトコルベース設計により、実装を差し替え可能

// 現在: User ID認証
class UserIdAuthenticationUseCase: AuthenticationUseCaseProtocol {
    func authenticate(userId: String) async throws -> AuthSession { /* ... */ }
}

// 将来: JWT認証
class JWTAuthenticationUseCase: AuthenticationUseCaseProtocol {
    func authenticate(email: String, password: String) async throws -> AuthSession {
        // POST /auth/login
        // JWTトークン取得・保存
    }

    func refreshToken() async throws -> AuthSession {
        // POST /auth/refresh
        // トークン更新
    }
}
```

---

## 8. テスト設計

### 8.1 AuthSessionManager単体テスト

```swift
import XCTest
@testable import PrototypeChatClientApp

class AuthSessionManagerTests: XCTestCase {
    var sut: AuthSessionManager!
    var mockUserDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        mockUserDefaults = UserDefaults(suiteName: "test")!
        sut = AuthSessionManager(userDefaults: mockUserDefaults)
    }

    override func tearDown() {
        mockUserDefaults.removePersistentDomain(forName: "test")
        super.tearDown()
    }

    func testSaveAndLoadSession() throws {
        // Given
        let user = User(id: "user-1", name: "Test User", avatarUrl: nil, createdAt: Date())
        let session = AuthSession(userId: "user-1", user: user, authenticatedAt: Date())

        // When
        try sut.saveSession(session)
        let loadedSession = sut.loadSession()

        // Then
        XCTAssertNotNil(loadedSession)
        XCTAssertEqual(loadedSession?.userId, "user-1")
        XCTAssertEqual(loadedSession?.user.name, "Test User")
    }

    func testClearSession() throws {
        // Given
        let user = User(id: "user-1", name: "Test User", avatarUrl: nil, createdAt: Date())
        let session = AuthSession(userId: "user-1", user: user, authenticatedAt: Date())
        try sut.saveSession(session)

        // When
        sut.clearSession()
        let loadedSession = sut.loadSession()

        // Then
        XCTAssertNil(loadedSession)
    }
}
```

### 8.2 AuthenticationUseCase単体テスト

```swift
class AuthenticationUseCaseTests: XCTestCase {
    var sut: AuthenticationUseCase!
    var mockUserRepository: MockUserRepository!
    var mockSessionManager: MockAuthSessionManager!

    override func setUp() {
        super.setUp()
        mockUserRepository = MockUserRepository()
        mockSessionManager = MockAuthSessionManager()
        sut = AuthenticationUseCase(
            userRepository: mockUserRepository,
            sessionManager: mockSessionManager
        )
    }

    func testAuthenticate_Success() async throws {
        // Given
        let expectedUser = User(
            id: "user-1",
            name: "Test User",
            avatarUrl: nil,
            createdAt: Date()
        )
        mockUserRepository.mockUser = expectedUser

        // When
        let session = try await sut.authenticate(userId: "user-1")

        // Then
        XCTAssertEqual(session.userId, "user-1")
        XCTAssertEqual(session.user.name, "Test User")
        XCTAssertTrue(mockSessionManager.saveSessionCalled)
    }

    func testAuthenticate_EmptyUserId_ThrowsError() async throws {
        // When & Then
        do {
            _ = try await sut.authenticate(userId: "")
            XCTFail("Expected error to be thrown")
        } catch let error as AuthenticationError {
            XCTAssertEqual(error, .emptyUserId)
        }
    }
}
```

### 8.3 AuthenticationViewModel単体テスト

```swift
@MainActor
class AuthenticationViewModelTests: XCTestCase {
    var sut: AuthenticationViewModel!
    var mockUseCase: MockAuthenticationUseCase!

    override func setUp() async throws {
        try await super.setUp()
        mockUseCase = MockAuthenticationUseCase()
        sut = AuthenticationViewModel(authenticationUseCase: mockUseCase)
    }

    func testAuthenticate_Success() async throws {
        // Given
        let expectedUser = User(id: "user-1", name: "Test User", avatarUrl: nil, createdAt: Date())
        let expectedSession = AuthSession(userId: "user-1", user: expectedUser, authenticatedAt: Date())
        mockUseCase.mockSession = expectedSession
        sut.userId = "user-1"

        // When
        await sut.authenticate()

        // Then
        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertNotNil(sut.currentSession)
        XCTAssertNil(sut.errorMessage)
    }

    func testAuthenticate_EmptyUserId_ShowsError() async throws {
        // Given
        sut.userId = ""

        // When
        await sut.authenticate()

        // Then
        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertNotNil(sut.errorMessage)
    }
}
```

---

## 9. デバッグ支援機能

### 9.1 開発環境用クイックログイン

```swift
#if DEBUG
struct QuickLoginView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel

    let testUserIds = [
        "user-1",
        "user-2",
        "user-3"
    ]

    var body: some View {
        VStack(spacing: 12) {
            Text("クイックログイン（開発用）")
                .font(.headline)

            ForEach(testUserIds, id: \.self) { userId in
                Button(userId) {
                    authViewModel.userId = userId
                    Task {
                        await authViewModel.authenticate()
                    }
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
}
#endif
```

### 9.2 セッション情報デバッグビュー

```swift
#if DEBUG
struct SessionDebugView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel

    var body: some View {
        List {
            Section("認証状態") {
                LabeledContent("認証済み", value: authViewModel.isAuthenticated ? "YES" : "NO")
                if let session = authViewModel.currentSession {
                    LabeledContent("User ID", value: session.userId)
                    LabeledContent("User Name", value: session.user.name)
                    LabeledContent("認証日時", value: session.authenticatedAt.formatted())
                }
            }

            Section("操作") {
                Button("ログアウト", role: .destructive) {
                    authViewModel.logout()
                }
            }
        }
        .navigationTitle("セッション情報")
    }
}
#endif
```

---

## 10. FAQ

### Q1. なぜパスワードを使わないのか?
A1. バックエンドが検証実装で認証機能を持たないため、User IDのみで認証状態をシミュレートしています。本番環境では適切な認証方式（JWT、OAuth等）を実装する必要があります。

### Q2. セッションの有効期限は?
A2. 現在の実装では無期限です。アプリを再起動してもログイン状態を維持します。将来的にはトークンの有効期限管理が必要です。

### Q3. 複数デバイスでの同時ログインは?
A3. 現在の仕様では制限なく可能です。サーバー側でのセッション管理がないためです。

### Q4. User IDが見つからない場合は?
A4. `GET /users/{userId}` が404エラーを返すため、エラーメッセージを表示し再入力を促します。

### Q5. 本番環境への移行は?
A5. `AuthenticationUseCaseProtocol` の実装を差し替えることで、既存のUI層やDomain層を変更せずに移行可能です。

---

## 11. チェックリスト

### Phase 1: 基本実装
- [ ] AuthSessionManager実装
- [ ] AuthenticationUseCase実装
- [ ] AuthenticationViewModel実装
- [ ] AuthenticationView実装
- [ ] RootView統合

### Phase 2: テスト
- [ ] AuthSessionManager単体テスト
- [ ] AuthenticationUseCase単体テスト
- [ ] AuthenticationViewModel単体テスト
- [ ] UI統合テスト

### Phase 3: デバッグ機能
- [ ] クイックログイン機能
- [ ] セッション情報デバッグビュー
- [ ] エラーログ出力

### Phase 4: ドキュメント
- [ ] 使用方法ドキュメント
- [ ] トラブルシューティングガイド
- [ ] 本番移行ガイド

---

## 12. リファレンス

### 12.1 関連ドキュメント
- [アーキテクチャ概要設計書](./IOS_APP_ARCHITECTURE_20251211_JA.md)
- [API接続レイヤー設計書](./API_LAYER_DESIGN_20251211_JA.md)
- [クライアント要件書](../Design/CLIENT_REQUIREMENTS_20251211_JA.md)

### 12.2 技術リソース
- [SwiftUI Authentication Flow](https://developer.apple.com/documentation/swiftui/state-and-data-flow)
- [UserDefaults Documentation](https://developer.apple.com/documentation/foundation/userdefaults)
- [Keychain Services (将来実装用)](https://developer.apple.com/documentation/security/keychain_services)

---

**ドキュメント作成日**: 2025年12月11日
**対象環境**: 開発・検証環境
**セキュリティレベル**: 低（開発用）
**作成者**: iOS Development Team
