import Foundation

/// プロフィールリポジトリプロトコル
///
/// ユーザープロフィール情報の取得を担当
protocol ProfileRepositoryProtocol {
    /// 認証済みユーザーの完全なプロフィールを取得
    /// - Returns: 認証ユーザーデータとオプショナルのチャットユーザーデータ
    func fetchProfile() async throws -> (authUserId: String, username: String, email: String, name: String, chatUser: User?)
}
