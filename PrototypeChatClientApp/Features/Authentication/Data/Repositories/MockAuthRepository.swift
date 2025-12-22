import Foundation

/// モック認証リポジトリ（開発・テスト用）
///
/// BetterAuth APIの振る舞いをシミュレートする
///
/// テストユーザー:
/// - alice / password123 → Alice
/// - bob / password123 → Bob
/// - charlie / password123 → Charlie
class MockAuthRepository: AuthenticationRepositoryProtocol {
    private var mockUsers: [MockUser] = [
        MockUser(
            authUserId: "auth-1",
            username: "alice",
            email: "alice@example.com",
            password: "password123",
            name: "Alice",
            chatUserId: "user-1"
        ),
        MockUser(
            authUserId: "auth-2",
            username: "bob",
            email: "bob@example.com",
            password: "password123",
            name: "Bob",
            chatUserId: "user-2"
        ),
        MockUser(
            authUserId: "auth-3",
            username: "charlie",
            email: "charlie@example.com",
            password: "password123",
            name: "Charlie",
            chatUserId: "user-3"
        )
    ]

    var shouldFail: Bool = false
    var delay: TimeInterval = 0.5
    private var currentSession: AuthSession?

    func signUp(username: String, email: String, password: String, name: String) async throws -> AuthSession {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))

        if shouldFail {
            throw AuthenticationError.serverError
        }

        // Check if username already exists
        if mockUsers.contains(where: { $0.username == username }) {
            throw AuthenticationError.usernameAlreadyExists
        }

        // Check if email already exists
        if mockUsers.contains(where: { $0.email == email }) {
            throw AuthenticationError.emailAlreadyExists
        }

        // Create new user
        let authUserId = "auth-\(UUID().uuidString.prefix(8))"
        let chatUserId = "user-\(UUID().uuidString.prefix(8))"

        let newUser = MockUser(
            authUserId: authUserId,
            username: username,
            email: email,
            password: password,
            name: name,
            chatUserId: chatUserId
        )

        mockUsers.append(newUser)

        // Create session
        let session = newUser.toAuthSession()
        currentSession = session

        return session
    }

    func signIn(username: String, password: String) async throws -> AuthSession {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))

        if shouldFail {
            throw AuthenticationError.serverError
        }

        guard let mockUser = mockUsers.first(where: { $0.username == username && $0.password == password }) else {
            throw AuthenticationError.invalidCredentials
        }

        let session = mockUser.toAuthSession()
        currentSession = session

        return session
    }

    func getSession() async throws -> AuthSession? {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))

        if shouldFail {
            throw AuthenticationError.serverError
        }

        return currentSession
    }

    func signOut() async throws {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))

        if shouldFail {
            throw AuthenticationError.serverError
        }

        currentSession = nil
    }

    // MARK: - Test Helpers

    func reset() {
        currentSession = nil
        shouldFail = false
    }

    func setSession(_ session: AuthSession?) {
        currentSession = session
    }
}

// MARK: - Mock User Model

private struct MockUser {
    let authUserId: String
    let username: String
    let email: String
    let password: String
    let name: String
    let chatUserId: String

    func toAuthSession() -> AuthSession {
        let chatUser = User(
            id: chatUserId,
            idAlias: username,
            name: name,
            avatarUrl: nil,
            createdAt: Date()
        )

        return AuthSession(
            authUserId: authUserId,
            username: username,
            email: email,
            user: chatUser,
            chatUser: chatUser,  // Mock always has chat user
            authenticatedAt: Date()
        )
    }
}
