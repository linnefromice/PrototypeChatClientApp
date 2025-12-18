import Foundation

/// 認証エラー（認証機能に閉じる）
///
/// スコープ: Features/Authentication内でのみ使用
/// 他機能は認証エラーの詳細を知る必要なし（認証済みかどうかのみ）
enum AuthenticationError: LocalizedError, Equatable {
    // Legacy errors
    case emptyUserId
    case userNotFound
    case invalidUserId
    case invalidIdAliasFormat
    case sessionExpired

    // BetterAuth errors
    case invalidCredentials
    case invalidUsernameFormat
    case invalidEmail
    case passwordTooShort
    case invalidName
    case usernameAlreadyExists
    case emailAlreadyExists
    case networkError
    case serverError

    var errorDescription: String? {
        switch self {
        // Legacy errors
        case .emptyUserId:
            return "ユーザー名を入力してください"
        case .userNotFound:
            return "指定されたユーザーが見つかりません"
        case .invalidUserId:
            return "無効なUser ID形式です"
        case .invalidIdAliasFormat:
            return "ID Aliasの形式が正しくありません。3-30文字の小文字英数字で始まり終わる必要があります。"
        case .sessionExpired:
            return "セッションの有効期限が切れました"

        // BetterAuth errors
        case .invalidCredentials:
            return "ユーザー名またはパスワードが正しくありません"
        case .invalidUsernameFormat:
            return "ユーザー名は3-20文字の英数字、_、-のみ使用できます"
        case .invalidEmail:
            return "有効なメールアドレスを入力してください"
        case .passwordTooShort:
            return "パスワードは8文字以上で入力してください"
        case .invalidName:
            return "名前は1-50文字で入力してください"
        case .usernameAlreadyExists:
            return "このユーザー名は既に使用されています"
        case .emailAlreadyExists:
            return "このメールアドレスは既に使用されています"
        case .networkError:
            return "ネットワークエラーが発生しました。もう一度お試しください。"
        case .serverError:
            return "サーバーエラーが発生しました。しばらくしてからお試しください。"
        }
    }
}
