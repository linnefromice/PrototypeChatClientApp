import Foundation

/// 認証セッション管理プロトコル
///
/// スコープ: Features/Authentication内でのみ使用
protocol AuthSessionManagerProtocol {
    func saveSession(_ session: AuthSession) throws
    func loadSession() -> AuthSession?
    func clearSession()
    func getLastUserId() -> String?
}

/// 認証セッション管理実装
///
/// 責務:
/// - UserDefaultsへのAuthSession永続化
/// - セッションの読み込み
/// - セッションのクリア
/// - 最後に使用したUser IDの管理
class AuthSessionManager: AuthSessionManagerProtocol {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func saveSession(_ session: AuthSession) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(session)
        userDefaults.set(data, forKey: AuthenticationStorageKey.authSession)
        userDefaults.set(session.userId, forKey: AuthenticationStorageKey.lastUserId)
    }

    func loadSession() -> AuthSession? {
        guard let data = userDefaults.data(forKey: AuthenticationStorageKey.authSession) else {
            return nil
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(AuthSession.self, from: data)
    }

    func clearSession() {
        userDefaults.removeObject(forKey: AuthenticationStorageKey.authSession)
        // lastUserIdは残しておく（再ログイン時の利便性向上）
    }

    func getLastUserId() -> String? {
        return userDefaults.string(forKey: AuthenticationStorageKey.lastUserId)
    }
}
