import Foundation

/// 認証UseCaseプロトコル
///
/// スコープ: Features/Authentication内でのみ使用
protocol AuthenticationUseCaseProtocol {
    func authenticate(userId: String) async throws -> AuthSession
    func loadSavedSession() -> AuthSession?
    func logout()
}

/// 認証UseCase実装
///
/// 責務:
/// - User IDのバリデーション
/// - UserRepositoryを使用してユーザー取得
/// - AuthSessionの作成と永続化
/// - セッションの有効性チェック
class AuthenticationUseCase: AuthenticationUseCaseProtocol {
    private let userRepository: UserRepositoryProtocol  // Core層のProtocolに依存
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

        // 2. GET /users/{userId} を呼び出し（Core層のUserRepositoryProtocolを使用）
        let user: User
        do {
            user = try await userRepository.fetchUser(id: userId)
        } catch {
            // NetworkErrorをAuthenticationErrorに変換
            throw AuthenticationError.userNotFound
        }

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
