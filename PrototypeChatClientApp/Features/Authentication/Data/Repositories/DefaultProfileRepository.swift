import Foundation

/// デフォルトプロフィールリポジトリ実装
///
/// `/api/protected/profile`エンドポイントと連携
class DefaultProfileRepository: ProfileRepositoryProtocol {
    private let baseURL: String
    private let session: URLSession

    init(baseURL: String = Config.apiBaseURL, session: URLSession = NetworkConfiguration.session) {
        self.baseURL = baseURL
        self.session = session
    }

    func fetchProfile() async throws -> (authUserId: String, username: String, email: String, name: String, chatUser: User?) {
        let url = URL(string: "\(baseURL)/api/protected/profile")!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ [DefaultProfileRepository] Invalid HTTP response")
            throw AuthenticationError.networkError
        }

        print("ℹ️ [DefaultProfileRepository] fetchProfile status: \(httpResponse.statusCode)")

        switch httpResponse.statusCode {
        case 200...299:
            let profileResponse = try JSONDecoder().decode(ProfileResponse.self, from: data)
            let chatUser = profileResponse.chat.map { chatResponse in
                User(
                    id: chatResponse.id,
                    idAlias: chatResponse.idAlias,
                    name: chatResponse.name,
                    avatarUrl: chatResponse.avatarUrl,
                    createdAt: Date()
                )
            }
            print("✅ [DefaultProfileRepository] Profile fetched - authUserId: \(profileResponse.auth.id), chatUser: \(chatUser?.id ?? "nil")")
            return (
                authUserId: profileResponse.auth.id,
                username: profileResponse.auth.username,
                email: profileResponse.auth.email,
                name: profileResponse.auth.name,
                chatUser: chatUser
            )
        case 401:
            print("❌ [DefaultProfileRepository] Unauthorized (401)")
            throw AuthenticationError.invalidCredentials
        case 500...599:
            if let errorString = String(data: data, encoding: .utf8) {
                print("❌ [DefaultProfileRepository] Server error (5xx): \(errorString)")
            }
            throw AuthenticationError.serverError
        default:
            if let errorString = String(data: data, encoding: .utf8) {
                print("❌ [DefaultProfileRepository] Unexpected status \(httpResponse.statusCode): \(errorString)")
            }
            throw AuthenticationError.networkError
        }
    }
}

// MARK: - Response Models

private struct ProfileResponse: Decodable {
    let auth: AuthData
    let chat: ChatData?

    struct AuthData: Decodable {
        let id: String
        let username: String
        let email: String
        let name: String
    }

    struct ChatData: Decodable {
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
    }
}

// MARK: - Config

private enum Config {
    // Always use Cloudflare Workers (change to localhost:3000 for local development)
    static let apiBaseURL = "https://prototype-hono-drizzle-backend.linnefromice.workers.dev"
}
