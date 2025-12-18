import Foundation

/// 認証セッションエンティティ（認証機能に閉じる）
///
/// スコープ: Features/Authentication内でのみ使用
/// 他機能は currentUserId のみ知れば良く、認証日時などの詳細は不要
///
/// 構造:
/// - auth_user情報（BetterAuth認証データ）: authUserId, username, email
/// - chat_user情報（チャットプロフィール）: user (User entity)
/// - セッション情報: authenticatedAt
struct AuthSession: Codable, Equatable {
    // BetterAuth auth_user fields
    let authUserId: String
    let username: String
    let email: String

    // Chat user profile (from users table)
    let user: User  // Core/Entities/User を参照

    // Session metadata
    let authenticatedAt: Date

    /// Legacy userId for backward compatibility
    /// Points to the chat user ID (user.id)
    var userId: String {
        user.id
    }

    var isValid: Bool {
        // 将来的に有効期限チェックを追加可能
        // 例: Date().timeIntervalSince(authenticatedAt) < tokenExpirationInterval
        return true
    }
}
