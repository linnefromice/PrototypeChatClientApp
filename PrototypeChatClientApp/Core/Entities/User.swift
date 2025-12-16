import Foundation

/// 横断的に利用されるユーザーエンティティ
///
/// 使用される機能:
/// - 認証機能（AuthSession内で使用）
/// - 会話機能（参加者として使用）
/// - プロフィール機能（ユーザー情報表示）
/// - メッセージ機能（送信者として使用）
struct User: Codable, Identifiable, Equatable {
    let id: String
    let idAlias: String
    let name: String
    let avatarUrl: String?
    let createdAt: Date
}
