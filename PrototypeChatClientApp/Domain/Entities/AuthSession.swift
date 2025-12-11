import Foundation

struct AuthSession: Codable, Equatable {
    let userId: String
    let user: User
    let authenticatedAt: Date

    var isValid: Bool {
        // 将来的に有効期限チェックを追加可能
        return true
    }
}
