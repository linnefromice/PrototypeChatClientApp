import Foundation

/// 認証機能用のストレージキー定義
///
/// スコープ: Features/Authentication内でのみ使用
enum AuthenticationStorageKey {
    /// 旧セッションデータ（Legacy - Cookie-basedでは使用しない）
    static let authSession = "com.prototype.chat.authSession"

    /// 最後にログインしたUser ID
    static let lastUserId = "com.prototype.chat.lastUserId"
}
