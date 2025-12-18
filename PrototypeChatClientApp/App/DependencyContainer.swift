import Foundation
import SwiftUI
import OpenAPIRuntime
import OpenAPIURLSession

/// 依存性注入コンテナ
///
/// 責務:
/// - アプリ全体で使用するインスタンスの生成と管理
/// - 依存関係の解決
/// - テスト・Preview用のMock依存性提供
///
/// 将来的なMultiModule化時:
/// - 各Feature Moduleが独自のDependencyContainerを持つ可能性
/// - このコンテナはApp層での統合時に使用
@MainActor
final class DependencyContainer: ObservableObject {

    // MARK: - Environment

    let environment: AppEnvironment

    // MARK: - Infrastructure Layer

    private lazy var apiClient: Client = {
        APIClientFactory.createClient(environment: environment)
    }()

    // MARK: - Repository Layer

    /// ユーザーリポジトリ（実装版・Mock版を切り替え可能）
    var userRepository: UserRepositoryProtocol

    /// 会話リポジトリ（実装版・Mock版を切り替え可能）
    var conversationRepository: ConversationRepositoryProtocol

    /// メッセージリポジトリ（実装版・Mock版を切り替え可能）
    var messageRepository: MessageRepositoryProtocol

    /// リアクションリポジトリ（実装版・Mock版を切り替え可能）
    var reactionRepository: ReactionRepositoryProtocol

    /// 認証リポジトリ（実装版・Mock版を切り替え可能）
    var authRepository: AuthenticationRepositoryProtocol

    /// 認証セッションマネージャー
    var authSessionManager: AuthSessionManagerProtocol

    // MARK: - Use Cases

    /// 認証UseCase
    lazy var authenticationUseCase: AuthenticationUseCaseProtocol = {
        AuthenticationUseCase(
            authRepository: authRepository,
            userRepository: userRepository,
            sessionManager: authSessionManager
        )
    }()

    /// 会話UseCase
    lazy var conversationUseCase: ConversationUseCase = {
        ConversationUseCase(conversationRepository: conversationRepository)
    }()

    /// ユーザー一覧UseCase
    lazy var userListUseCase: UserListUseCase = {
        UserListUseCase(userRepository: userRepository)
    }()

    /// メッセージUseCase
    lazy var messageUseCase: MessageUseCase = {
        MessageUseCase(messageRepository: messageRepository)
    }()

    /// リアクションUseCase
    lazy var reactionUseCase: ReactionUseCase = {
        ReactionUseCase(reactionRepository: reactionRepository)
    }()

    // MARK: - View Models

    /// 認証ViewModel（lazy初期化）
    lazy var authenticationViewModel: AuthenticationViewModel = {
        AuthenticationViewModel(
            authenticationUseCase: authenticationUseCase,
            sessionManager: authSessionManager
        )
    }()

    // MARK: - Singleton

    static let shared = DependencyContainer()

    // MARK: - Initialization

    private init(
        environment: AppEnvironment = .current,
        userRepository: UserRepositoryProtocol? = nil,
        conversationRepository: ConversationRepositoryProtocol? = nil,
        messageRepository: MessageRepositoryProtocol? = nil,
        reactionRepository: ReactionRepositoryProtocol? = nil,
        authRepository: AuthenticationRepositoryProtocol? = nil,
        authSessionManager: AuthSessionManagerProtocol? = nil
    ) {
        self.environment = environment

        // Use provided dependencies or create real implementations
        let client = APIClientFactory.createClient(environment: environment)

        if let mockUserRepository = userRepository {
            self.userRepository = mockUserRepository
        } else {
            self.userRepository = UserRepository(client: client)
        }

        if let mockConversationRepository = conversationRepository {
            self.conversationRepository = mockConversationRepository
        } else {
            self.conversationRepository = ConversationRepository(client: client)
        }

        if let mockMessageRepository = messageRepository {
            self.messageRepository = mockMessageRepository
        } else {
            self.messageRepository = MessageRepository(client: client)
        }

        if let mockReactionRepository = reactionRepository {
            self.reactionRepository = mockReactionRepository
        } else {
            self.reactionRepository = ReactionRepository(client: client)
        }

        if let mockAuthRepository = authRepository {
            self.authRepository = mockAuthRepository
        } else {
            self.authRepository = DefaultAuthRepository()
        }

        self.authSessionManager = authSessionManager ?? AuthSessionManager()
    }

    // MARK: - Factory Methods for Testing & Preview

    /// Create a container with mock dependencies for testing
    static func makeTestContainer(
        userRepository: UserRepositoryProtocol? = nil,
        conversationRepository: ConversationRepositoryProtocol? = nil,
        messageRepository: MessageRepositoryProtocol? = nil,
        reactionRepository: ReactionRepositoryProtocol? = nil,
        authRepository: AuthenticationRepositoryProtocol? = nil,
        authSessionManager: AuthSessionManagerProtocol? = nil
    ) -> DependencyContainer {
        let mockUserRepo = userRepository ?? MockUserRepository()
        let mockConversationRepo = conversationRepository ?? MockConversationRepository()
        let mockMessageRepo = messageRepository ?? MockMessageRepository()
        let mockReactionRepo = reactionRepository ?? MockReactionRepository()
        let mockAuthRepo = authRepository ?? MockAuthRepository()
        let mockSessionManager = authSessionManager ?? MockAuthSessionManager()

        return DependencyContainer(
            environment: .development,
            userRepository: mockUserRepo,
            conversationRepository: mockConversationRepo,
            messageRepository: mockMessageRepo,
            reactionRepository: mockReactionRepo,
            authRepository: mockAuthRepo,
            authSessionManager: mockSessionManager
        )
    }

    /// Create a container with mock dependencies for preview
    static func makePreviewContainer() -> DependencyContainer {
        let mockUserRepository = MockUserRepository()
        // MockUserRepository has predefined users (user-1, user-2, user-3)

        let mockConversationRepository = MockConversationRepository()
        let mockMessageRepository = MockMessageRepository()
        let mockReactionRepository = MockReactionRepository()
        let mockAuthRepository = MockAuthRepository()
        let mockSessionManager = MockAuthSessionManager()

        return makeTestContainer(
            userRepository: mockUserRepository,
            conversationRepository: mockConversationRepository,
            messageRepository: mockMessageRepository,
            reactionRepository: mockReactionRepository,
            authRepository: mockAuthRepository,
            authSessionManager: mockSessionManager
        )
    }
}

// MARK: - Mock AuthSessionManager

/// Mock implementation for testing and preview
class MockAuthSessionManager: AuthSessionManagerProtocol {
    var savedSession: AuthSession?
    var shouldThrowError: Error?
    var lastUserId: String?
    var hasLegacy: Bool = false
    var isMigrated: Bool = false

    func saveSession(_ session: AuthSession) throws {
        if let error = shouldThrowError {
            throw error
        }
        savedSession = session
        lastUserId = session.userId
    }

    func loadSession() -> AuthSession? {
        return savedSession
    }

    func clearSession() {
        savedSession = nil
    }

    func getLastUserId() -> String? {
        return lastUserId
    }

    func hasLegacySession() -> Bool {
        return hasLegacy
    }

    func markLegacySessionMigrated() {
        isMigrated = true
        hasLegacy = false
    }

    func isLegacySessionMigrated() -> Bool {
        return isMigrated
    }
}

// MARK: - 将来的な拡張例（コメントアウト）

/*
extension DependencyContainer {
    // 本番API接続時の実装例
    lazy var apiClient: APIClient = {
        APIClientFactory.createClient(environment: .current)
    }()

    lazy var userRepository: UserRepositoryProtocol = {
        UserRepository(client: apiClient)
    }()

    // 会話機能追加時の例
    lazy var conversationRepository: ConversationRepositoryProtocol = {
        ConversationRepository(client: apiClient)
    }()

    lazy var fetchConversationsUseCase: FetchConversationsUseCaseProtocol = {
        FetchConversationsUseCase(repository: conversationRepository)
    }()
}
*/
