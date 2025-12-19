import Foundation

/// 認証UseCaseプロトコル
///
/// スコープ: Features/Authentication内でのみ使用
protocol AuthenticationUseCaseProtocol {
    // Legacy idAlias authentication (deprecated)
    func authenticate(idAlias: String) async throws -> AuthSession

    // BetterAuth methods
    func register(username: String, email: String, password: String, name: String) async throws -> AuthSession
    func login(username: String, password: String) async throws -> AuthSession
    func validateSession() async throws -> AuthSession?

    // Session management
    func loadSavedSession() -> AuthSession?
    func logout() async throws
}

/// 認証UseCase実装
///
/// 責務:
/// - BetterAuth認証（username/password）
/// - ユーザー登録
/// - セッション検証とCookie管理
/// - 入力バリデーション
class AuthenticationUseCase: AuthenticationUseCaseProtocol {
    private let authRepository: AuthenticationRepositoryProtocol
    private let userRepository: UserRepositoryProtocol  // Legacy support
    private let sessionManager: AuthSessionManagerProtocol

    init(
        authRepository: AuthenticationRepositoryProtocol,
        userRepository: UserRepositoryProtocol,
        sessionManager: AuthSessionManagerProtocol
    ) {
        self.authRepository = authRepository
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
        // Legacy endpoint doesn't provide auth_user fields, so use placeholders
        let session = AuthSession(
            authUserId: user.id,  // Use chat user id as placeholder
            username: user.idAlias,  // Use idAlias as username
            email: "\(user.idAlias)@legacy.local",  // Placeholder email
            user: user,
            chatUser: user,  // Legacy login has chat user
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

    func logout() async throws {
        // Call backend logout endpoint to invalidate session
        try await authRepository.signOut()

        // Clear local session
        sessionManager.clearSession()
    }

    // MARK: - BetterAuth Methods

    func register(username: String, email: String, password: String, name: String) async throws -> AuthSession {
        // 1. Validate inputs
        try validateUsername(username)
        try validateEmail(email)
        try validatePassword(password)
        try validateName(name)

        // 2. Call repository to register
        let session = try await authRepository.signUp(
            username: username,
            email: email,
            password: password,
            name: name
        )

        // 3. Session is managed via cookies, no need to save manually
        // sessionManager is used for migration/fallback only

        return session
    }

    func login(username: String, password: String) async throws -> AuthSession {
        // 1. Validate inputs
        guard !username.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw AuthenticationError.emptyUserId
        }
        guard !password.isEmpty else {
            throw AuthenticationError.invalidCredentials
        }

        // 2. Call repository to sign in
        let session = try await authRepository.signIn(
            username: username,
            password: password
        )

        // 3. Session is managed via cookies, no need to save manually

        return session
    }

    func validateSession() async throws -> AuthSession? {
        // Call backend to validate session via cookie
        return try await authRepository.getSession()
    }

    // MARK: - Validation Helpers

    private func validateUsername(_ username: String) throws {
        let trimmed = username.trimmingCharacters(in: .whitespaces)

        guard !trimmed.isEmpty else {
            throw AuthenticationError.emptyUserId
        }

        guard trimmed.count >= 3, trimmed.count <= 20 else {
            throw AuthenticationError.invalidUsernameFormat
        }

        // Username: alphanumeric, underscore, hyphen
        let pattern = "^[a-zA-Z0-9_-]+$"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              regex.firstMatch(in: trimmed, range: NSRange(location: 0, length: trimmed.utf16.count)) != nil else {
            throw AuthenticationError.invalidUsernameFormat
        }
    }

    private func validateEmail(_ email: String) throws {
        let trimmed = email.trimmingCharacters(in: .whitespaces)

        guard !trimmed.isEmpty else {
            throw AuthenticationError.invalidEmail
        }

        // Basic email validation
        guard trimmed.contains("@"), trimmed.contains(".") else {
            throw AuthenticationError.invalidEmail
        }
    }

    private func validatePassword(_ password: String) throws {
        guard password.count >= 8 else {
            throw AuthenticationError.passwordTooShort
        }
    }

    private func validateName(_ name: String) throws {
        let trimmed = name.trimmingCharacters(in: .whitespaces)

        guard !trimmed.isEmpty else {
            throw AuthenticationError.invalidName
        }

        guard trimmed.count <= 50 else {
            throw AuthenticationError.invalidName
        }
    }
}
