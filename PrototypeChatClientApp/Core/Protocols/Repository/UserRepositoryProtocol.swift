import Foundation

/// ユーザーリポジトリの共通プロトコル
///
/// 実装:
/// - MockUserRepository（開発・テスト用）
/// - UserRepository（本番API接続用・将来実装）
protocol UserRepositoryProtocol {
    func fetchUser(id: String) async throws -> User
    func fetchUsers() async throws -> [User]
    func createUser(name: String, avatarUrl: String?) async throws -> User
    func loginByIdAlias(_ idAlias: String) async throws -> User
}
