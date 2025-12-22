import Foundation

/// 認証セッションエンティティ（認証機能に閉じる）
///
/// スコープ: Features/Authentication内でのみ使用
/// 他機能は currentUserId のみ知れば良く、認証日時などの詳細は不要
///
/// 構造:
/// - auth_user情報（BetterAuth認証データ）: authUserId, username, email
/// - chat_user情報（チャットプロフィール）: user (backward compat), chatUser (explicit)
/// - セッション情報: authenticatedAt
struct AuthSession: Codable, Equatable {
    // BetterAuth auth_user fields
    let authUserId: String
    let username: String
    let email: String

    // Chat user profile (from users table)
    let user: User  // Backward compatibility - may be placeholder
    let chatUser: User?  // NEW: Explicit chat profile (nil if user has no chat profile)

    // Session metadata
    let authenticatedAt: Date

    /// Legacy userId for backward compatibility
    /// Points to the chat user ID (chatUser.id if available, otherwise user.id)
    var userId: String {
        chatUser?.id ?? user.id
    }

    var isValid: Bool {
        // 将来的に有効期限チェックを追加可能
        // 例: Date().timeIntervalSince(authenticatedAt) < tokenExpirationInterval
        return true
    }
}
