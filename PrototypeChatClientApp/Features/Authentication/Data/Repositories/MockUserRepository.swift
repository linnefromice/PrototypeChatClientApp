import Foundation

/// モックユーザーリポジトリ（開発・テスト用）
///
/// スコープ: 開発環境での使用を想定
/// 本番環境では UserRepository（OpenAPI Generated Client使用）に差し替え
///
/// 登録済みUser ID:
/// - user-1 (alice) → Alice
/// - user-2 (bob) → Bob
/// - user-3 (charlie) → Charlie
class MockUserRepository: UserRepositoryProtocol {
    private let mockUsers: [User] = [
        User(
            id: "user-1",
            idAlias: "alice",
            name: "Alice",
            avatarUrl: nil,
            createdAt: Date()
        ),
        User(
            id: "user-2",
            idAlias: "bob",
            name: "Bob",
            avatarUrl: nil,
            createdAt: Date()
        ),
        User(
            id: "user-3",
            idAlias: "charlie",
            name: "Charlie",
            avatarUrl: nil,
            createdAt: Date()
        )
    ]

    var shouldFail: Bool = false
    var delay: TimeInterval = 0.5

    func fetchUser(id: String) async throws -> User {
        // 遅延をシミュレート
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))

        if shouldFail {
            throw NSError(domain: "MockError", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "User not found"
            ])
        }

        guard let user = mockUsers.first(where: { $0.id == id }) else {
            throw NSError(domain: "MockError", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "User not found"
            ])
        }

        return user
    }

    func fetchUsers() async throws -> [User] {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))

        if shouldFail {
            throw NSError(domain: "MockError", code: 500, userInfo: [
                NSLocalizedDescriptionKey: "Server error"
            ])
        }

        return mockUsers
    }

    func createUser(name: String, avatarUrl: String?) async throws -> User {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))

        if shouldFail {
            throw NSError(domain: "MockError", code: 400, userInfo: [
                NSLocalizedDescriptionKey: "Bad request"
            ])
        }

        let uuid = UUID().uuidString
        return User(
            id: "user-\(uuid)",
            idAlias: "user\(uuid.prefix(8))",
            name: name,
            avatarUrl: avatarUrl,
            createdAt: Date()
        )
    }

    func loginByIdAlias(_ idAlias: String) async throws -> User {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))

        if shouldFail {
            throw NSError(domain: "MockError", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "User not found"
            ])
        }

        guard let user = mockUsers.first(where: { $0.idAlias == idAlias }) else {
            throw NetworkError.notFound
        }

        return user
    }
}
