import Foundation

protocol UserRepositoryProtocol {
    func fetchUser(id: String) async throws -> User
    func fetchUsers() async throws -> [User]
    func createUser(name: String, avatarUrl: String?) async throws -> User
}
