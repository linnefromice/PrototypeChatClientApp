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
        // TODO: Backend APIで全ユーザー取得エンドポイントが実装されたら置き換える
        // 現在は仮実装として空配列を返す
        // 将来的には userRepository.fetchAllUsers() のような実装が必要
        return []
    }
}
