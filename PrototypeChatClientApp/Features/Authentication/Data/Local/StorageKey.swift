import Foundation

/// 認証機能用のストレージキー定義
///
/// スコープ: Features/Authentication内でのみ使用
enum AuthenticationStorageKey {
    static let authSession = "com.prototype.chat.authSession"
    static let lastUserId = "com.prototype.chat.lastUserId"
}
