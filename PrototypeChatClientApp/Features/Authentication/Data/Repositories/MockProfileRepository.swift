import Foundation

/// Mock implementation of ProfileRepository for testing and preview
class MockProfileRepository: ProfileRepositoryProtocol {
    var shouldThrowError: Error?
    var mockProfile: (authUserId: String, username: String, email: String, name: String, chatUser: User?)?

    func fetchProfile() async throws -> (authUserId: String, username: String, email: String, name: String, chatUser: User?) {
        if let error = shouldThrowError {
            throw error
        }

        // Return mock profile if set, otherwise return default Alice profile
        if let profile = mockProfile {
            return profile
        }

        // Default mock profile with Alice
        let aliceUser = User(
            id: "user-1",
            idAlias: "alice",
            name: "Alice",
            avatarUrl: nil,
            createdAt: Date()
        )

        return (
            authUserId: "auth-1",
            username: "alice",
            email: "alice@example.com",
            name: "Alice",
            chatUser: aliceUser
        )
    }
}
