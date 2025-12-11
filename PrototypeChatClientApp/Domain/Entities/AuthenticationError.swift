import Foundation

enum AuthenticationError: LocalizedError, Equatable {
    case emptyUserId
    case userNotFound
    case invalidUserId
    case sessionExpired

    var errorDescription: String? {
        switch self {
        case .emptyUserId:
            return "User IDを入力してください"
        case .userNotFound:
            return "指定されたUser IDが見つかりません"
        case .invalidUserId:
            return "無効なUser ID形式です"
        case .sessionExpired:
            return "セッションの有効期限が切れました"
        }
    }
}
