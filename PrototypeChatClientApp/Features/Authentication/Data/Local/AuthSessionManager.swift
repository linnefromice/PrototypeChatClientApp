import Foundation

/// 認証セッション管理プロトコル
///
/// スコープ: Features/Authentication内でのみ使用
///
/// 注意: Cookie-based認証では、セッションはHTTPCookieで管理されます。
/// このマネージャーは主に旧セッション（UserDefaults）のマイグレーション用です。
protocol AuthSessionManagerProtocol {
    /// セッション保存（Legacy - Cookie-basedでは使用しない）
    func saveSession(_ session: AuthSession) throws

    /// セッション読み込み（Legacy - マイグレーション用）
    func loadSession() -> AuthSession?

    /// セッションクリア（Cookie + UserDefaults両方をクリア）
    func clearSession()

    /// 最後に使用したUser ID取得
    func getLastUserId() -> String?

    /// 旧セッション検出（UserDefaultsにセッションが残っているか）
    func hasLegacySession() -> Bool

    /// 旧セッションマイグレーション完了をマーク
    func markLegacySessionMigrated()

    /// マイグレーション済みかチェック
    func isLegacySessionMigrated() -> Bool
}

/// 認証セッション管理実装
///
/// Cookie-based認証への移行:
/// - 新規ログイン: Cookieで管理（UserDefaultsは使用しない）
/// - 旧セッション: UserDefaultsから検出してマイグレーション
/// - ログアウト: Cookie + UserDefaults両方をクリア
class AuthSessionManager: AuthSessionManagerProtocol {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - Legacy Session Management

    /// セッション保存（Legacy - Cookie-basedでは使用しない）
    /// idAlias認証の後方互換性のためのみ残す
    func saveSession(_ session: AuthSession) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(session)
        userDefaults.set(data, forKey: AuthenticationStorageKey.authSession)
        userDefaults.set(session.userId, forKey: AuthenticationStorageKey.lastUserId)
    }

    /// セッション読み込み（Legacy - マイグレーション用）
    func loadSession() -> AuthSession? {
        guard let data = userDefaults.data(forKey: AuthenticationStorageKey.authSession) else {
            return nil
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(AuthSession.self, from: data)
    }

    /// セッションクリア（Cookie + UserDefaults両方）
    func clearSession() {
        // Clear UserDefaults session (legacy)
        userDefaults.removeObject(forKey: AuthenticationStorageKey.authSession)

        // Clear HTTP cookies for BetterAuth
        #if DEBUG
        NetworkConfiguration.clearAllCookies()
        print("🍪 [AuthSessionManager] Cleared all cookies and local session")
        #else
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
        #endif

        // lastUserIdは残しておく（再ログイン時の利便性向上）
    }

    func getLastUserId() -> String? {
        return userDefaults.string(forKey: AuthenticationStorageKey.lastUserId)
    }

    // MARK: - Migration Support

    /// 旧セッション検出（UserDefaultsにセッションが残っているか）
    func hasLegacySession() -> Bool {
        return userDefaults.data(forKey: AuthenticationStorageKey.authSession) != nil
    }

    /// 旧セッションマイグレーション完了をマーク
    func markLegacySessionMigrated() {
        userDefaults.set(true, forKey: AuthenticationStorageKey.legacySessionMigrated)
        // 旧セッションデータを削除
        userDefaults.removeObject(forKey: AuthenticationStorageKey.authSession)
        print("✅ [AuthSessionManager] Legacy session marked as migrated")
    }

    /// マイグレーション済みかチェック
    func isLegacySessionMigrated() -> Bool {
        return userDefaults.bool(forKey: AuthenticationStorageKey.legacySessionMigrated)
    }
}
