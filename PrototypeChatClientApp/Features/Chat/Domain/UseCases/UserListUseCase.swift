import Foundation

/// ユーザー一覧に関するユースケース
/// チャット作成時のユーザー選択に使用
class UserListUseCase {
    private let userRepository: UserRepositoryProtocol

    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }

    /// 全ユーザー一覧を取得（自分以外）
    /// - Parameter currentUserId: 現在のユーザーID
    /// - Returns: ユーザーリスト（自分を除く）
    func fetchAvailableUsers(excludingUserId currentUserId: String) async throws -> [User] {
        let allUsers = try await userRepository.fetchUsers()
        return allUsers.filter { $0.id != currentUserId }
    }
}
