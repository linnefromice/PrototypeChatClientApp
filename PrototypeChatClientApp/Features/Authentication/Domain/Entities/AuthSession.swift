import Foundation

/// 認証セッションエンティティ（認証機能に閉じる）
///
/// スコープ: Features/Authentication内でのみ使用
/// 他機能は currentUserId のみ知れば良く、認証日時などの詳細は不要
struct AuthSession: Codable, Equatable {
    let userId: String
    let user: User  // Core/Entities/User を参照
    let authenticatedAt: Date

    var isValid: Bool {
        // 将来的に有効期限チェックを追加可能
        // 例: Date().timeIntervalSince(authenticatedAt) < tokenExpirationInterval
        return true
    }
}
