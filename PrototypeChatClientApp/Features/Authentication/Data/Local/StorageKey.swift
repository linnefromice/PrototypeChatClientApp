import Foundation

/// 認証機能用のストレージキー定義
///
/// スコープ: Features/Authentication内でのみ使用
enum AuthenticationStorageKey {
    /// 旧セッションデータ（Cookie-based移行前）
    static let authSession = "com.prototype.chat.authSession"

    /// 最後にログインしたUser ID
    static let lastUserId = "com.prototype.chat.lastUserId"

    /// 旧セッションマイグレーション完了フラグ
    static let legacySessionMigrated = "com.prototype.chat.legacySessionMigrated"
}
