import Foundation

protocol AuthSessionManagerProtocol {
    func saveSession(_ session: AuthSession) throws
    func loadSession() -> AuthSession?
    func clearSession()
}

class AuthSessionManager: AuthSessionManagerProtocol {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func saveSession(_ session: AuthSession) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(session)
        userDefaults.set(data, forKey: StorageKey.authSession)
        userDefaults.set(session.userId, forKey: StorageKey.lastUserId)
    }

    func loadSession() -> AuthSession? {
        guard let data = userDefaults.data(forKey: StorageKey.authSession) else {
            return nil
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(AuthSession.self, from: data)
    }

    func clearSession() {
        userDefaults.removeObject(forKey: StorageKey.authSession)
        // lastUserIdは残しておく（再ログイン時の利便性向上）
    }

    func getLastUserId() -> String? {
        return userDefaults.string(forKey: StorageKey.lastUserId)
    }
}
