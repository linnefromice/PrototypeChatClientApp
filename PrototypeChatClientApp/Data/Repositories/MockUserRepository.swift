import Foundation

class MockUserRepository: UserRepositoryProtocol {
    private let mockUsers: [User] = [
        User(
            id: "user-1",
            name: "Alice",
            avatarUrl: nil,
            createdAt: Date()
        ),
        User(
            id: "user-2",
            name: "Bob",
            avatarUrl: nil,
            createdAt: Date()
        ),
        User(
            id: "user-3",
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

        return User(
            id: "user-\(UUID().uuidString)",
            name: name,
            avatarUrl: avatarUrl,
            createdAt: Date()
        )
    }
}
