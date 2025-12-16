import Foundation

/// 認証UseCaseプロトコル
///
/// スコープ: Features/Authentication内でのみ使用
protocol AuthenticationUseCaseProtocol {
    func authenticate(idAlias: String) async throws -> AuthSession
    func loadSavedSession() -> AuthSession?
    func logout()
}

/// 認証UseCase実装
///
/// 責務:
/// - ID Aliasのバリデーション
/// - UserRepositoryを使用してユーザーログイン
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

    func authenticate(idAlias: String) async throws -> AuthSession {
        // 1. ID Aliasのバリデーション
        guard !idAlias.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw AuthenticationError.emptyUserId
        }

        // 2. ID Aliasのフォーマットバリデーション
        try validateIdAliasFormat(idAlias)

        // 3. POST /users/login を呼び出し（Core層のUserRepositoryProtocolを使用）
        let user: User
        do {
            user = try await userRepository.loginByIdAlias(idAlias)
        } catch {
            // NetworkErrorをAuthenticationErrorに変換
            throw AuthenticationError.userNotFound
        }

        // 4. セッション作成（user.idを使用）
        let session = AuthSession(
            userId: user.id,
            user: user,
            authenticatedAt: Date()
        )

        // 5. ローカルに保存
        try sessionManager.saveSession(session)

        return session
    }

    private func validateIdAliasFormat(_ idAlias: String) throws {
        // 長さチェック
        guard idAlias.count >= 3, idAlias.count <= 30 else {
            throw AuthenticationError.invalidIdAliasFormat
        }

        // パターンマッチング: 小文字英数字で始まり終わる、途中に . _ - を含んでもよい
        let pattern = "^[a-z0-9][a-z0-9._-]*[a-z0-9]$"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              regex.firstMatch(in: idAlias, range: NSRange(location: 0, length: idAlias.utf16.count)) != nil else {
            throw AuthenticationError.invalidIdAliasFormat
        }
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
