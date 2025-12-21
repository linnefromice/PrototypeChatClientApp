import Foundation

/// デフォルト認証リポジトリ実装
///
/// BetterAuth APIと連携してユーザー認証を行う
class DefaultAuthRepository: AuthenticationRepositoryProtocol {
    private let baseURL: String
    private let session: URLSession

    init(baseURL: String = Config.apiBaseURL, session: URLSession = NetworkConfiguration.session) {
        self.baseURL = baseURL
        self.session = session
    }

    func signUp(username: String, email: String, password: String, name: String) async throws -> AuthSession {
        let url = URL(string: "\(baseURL)/api/auth/sign-up/email")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "username": username,
            "email": email,
            "password": password,
            "name": name
        ]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthenticationError.networkError
        }

        switch httpResponse.statusCode {
        case 200...299:
            let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
            return try authResponse.toAuthSession()
        case 400:
            // Parse error message to determine if it's duplicate username/email
            let errorString = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ [DefaultAuthRepository] signUp failed (400): \(errorString)")

            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                if errorResponse.message.contains("username") || errorResponse.message.contains("Username") {
                    throw AuthenticationError.usernameAlreadyExists
                } else if errorResponse.message.contains("email") || errorResponse.message.contains("Email") {
                    throw AuthenticationError.emailAlreadyExists
                }
            }
            throw AuthenticationError.invalidCredentials
        case 401:
            let errorString = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ [DefaultAuthRepository] signUp failed (401): \(errorString)")
            throw AuthenticationError.invalidCredentials
        case 500...599:
            let errorString = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ [DefaultAuthRepository] signUp failed (\(httpResponse.statusCode)): \(errorString)")
            throw AuthenticationError.serverError
        default:
            let errorString = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ [DefaultAuthRepository] signUp failed (\(httpResponse.statusCode)): \(errorString)")
            throw AuthenticationError.networkError
        }
    }

    func signIn(username: String, password: String) async throws -> AuthSession {
        let url = URL(string: "\(baseURL)/api/auth/sign-in/username")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "username": username,
            "password": password
        ]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ [DefaultAuthRepository] signIn - Invalid HTTP response")
            throw AuthenticationError.networkError
        }

        switch httpResponse.statusCode {
        case 200...299:
            let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
            return try authResponse.toAuthSession()
        case 401:
            let errorString = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ [DefaultAuthRepository] signIn failed (401): \(errorString)")
            throw AuthenticationError.invalidCredentials
        case 500...599:
            let errorString = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ [DefaultAuthRepository] signIn failed (\(httpResponse.statusCode)): \(errorString)")
            throw AuthenticationError.serverError
        default:
            let errorString = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ [DefaultAuthRepository] signIn failed (\(httpResponse.statusCode)): \(errorString)")
            throw AuthenticationError.networkError
        }
    }

    func getSession() async throws -> AuthSession? {
        let url = URL(string: "\(baseURL)/api/auth/get-session")!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ [DefaultAuthRepository] getSession - Invalid HTTP response")
            throw AuthenticationError.networkError
        }

        switch httpResponse.statusCode {
        case 200...299:
            let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
            return try authResponse.toAuthSession()
        case 401:
            // Session expired or invalid
            print("ℹ️ [DefaultAuthRepository] getSession - No valid session (401)")
            return nil
        case 500...599:
            let errorString = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ [DefaultAuthRepository] getSession failed (\(httpResponse.statusCode)): \(errorString)")
            throw AuthenticationError.serverError
        default:
            let errorString = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ [DefaultAuthRepository] getSession failed (\(httpResponse.statusCode)): \(errorString)")
            throw AuthenticationError.networkError
        }
    }

    func signOut() async throws {
        let url = URL(string: "\(baseURL)/api/auth/sign-out")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(baseURL, forHTTPHeaderField: "Origin")  // Required for CSRF protection

        // Send empty JSON body as required by the API
        request.httpBody = try JSONEncoder().encode([String: String]())

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ [DefaultAuthRepository] signOut - Invalid HTTP response")
            throw AuthenticationError.networkError
        }

        print("ℹ️ [DefaultAuthRepository] signOut status: \(httpResponse.statusCode)")

        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorString = String(data: data, encoding: .utf8) {
                print("❌ [DefaultAuthRepository] signOut failed (\(httpResponse.statusCode)): \(errorString)")
            }
            throw AuthenticationError.serverError
        }

        print("✅ [DefaultAuthRepository] signOut succeeded")
        // Cookies are cleared automatically by the backend
    }
}

// MARK: - Response Models

/// BetterAuth API Response
private struct AuthResponse: Decodable {
    let user: AuthUser
    let session: Session?
    let chat: ChatUserResponse?  // NEW: Optional chat user from backend

    struct AuthUser: Decodable {
        let id: String
        let username: String
        let email: String
        let name: String
        let chatUserId: String?  // Reference to chat user (if exists)

        enum CodingKeys: String, CodingKey {
            case id
            case username
            case email
            case name
            case chatUserId = "chat_user_id"
        }
    }

    /// Chat user response from backend
    struct ChatUserResponse: Decodable {
        let id: String
        let idAlias: String
        let name: String
        let avatarUrl: String?

        enum CodingKeys: String, CodingKey {
            case id
            case idAlias = "id_alias"
            case name
            case avatarUrl = "avatar_url"
        }

        func toUser() -> User {
            User(
                id: id,
                idAlias: idAlias,
                name: name,
                avatarUrl: avatarUrl,
                createdAt: Date()
            )
        }
    }

    struct Session: Decodable {
        let token: String?
        let expiresAt: Date?

        enum CodingKeys: String, CodingKey {
            case token
            case expiresAt = "expires_at"
        }
    }

    func toAuthSession() throws -> AuthSession {
        // Parse chat user from response if available
        let chatUserEntity = chat?.toUser()

        // Create placeholder user for backward compatibility
        let placeholderUser = User(
            id: user.chatUserId ?? user.id,
            idAlias: user.username,  // Use username as idAlias for compatibility
            name: user.name,
            avatarUrl: nil,
            createdAt: Date()
        )

        return AuthSession(
            authUserId: user.id,
            username: user.username,
            email: user.email,
            user: chatUserEntity ?? placeholderUser,  // Use chat user if available, otherwise placeholder
            chatUser: chatUserEntity,  // Explicit chat user (nil if not available)
            authenticatedAt: Date()
        )
    }
}

private struct ErrorResponse: Decodable {
    let error: String?
    let message: String

    enum CodingKeys: String, CodingKey {
        case error
        case message
    }
}

// MARK: - Config

private enum Config {
    // Always use Cloudflare Workers (change to localhost:3000 for local development)
    static let apiBaseURL = "https://prototype-hono-drizzle-backend.linnefromice.workers.dev"

    // Uncomment below to use localhost for debugging
    // #if DEBUG
    // static let apiBaseURL = "http://localhost:3000"
    // #else
    // static let apiBaseURL = "https://prototype-hono-drizzle-backend.linnefromice.workers.dev"
    // #endif
}
