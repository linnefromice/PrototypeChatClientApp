import Foundation

/// 認証エラー（認証機能に閉じる）
///
/// スコープ: Features/Authentication内でのみ使用
/// 他機能は認証エラーの詳細を知る必要なし（認証済みかどうかのみ）
enum AuthenticationError: LocalizedError, Equatable {
    case emptyUserId
    case userNotFound
    case invalidUserId
    case invalidIdAliasFormat
    case sessionExpired

    var errorDescription: String? {
        switch self {
        case .emptyUserId:
            return "ID Aliasを入力してください"
        case .userNotFound:
            return "指定されたユーザーが見つかりません"
        case .invalidUserId:
            return "無効なUser ID形式です"
        case .invalidIdAliasFormat:
            return "ID Aliasの形式が正しくありません。3-30文字の小文字英数字で始まり終わる必要があります。"
        case .sessionExpired:
            return "セッションの有効期限が切れました"
        }
    }
}
