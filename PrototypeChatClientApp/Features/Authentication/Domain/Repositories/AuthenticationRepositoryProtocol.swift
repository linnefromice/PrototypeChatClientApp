import Foundation

/// 認証用リポジトリプロトコル（認証機能に閉じる）
///
/// 実装:
/// - MockAuthenticationRepository（開発・テスト用）
/// - DefaultAuthenticationRepository（本番用・BetterAuth連携）
///
/// BetterAuth API endpoints:
/// - POST /api/auth/sign-up/email - ユーザー登録
/// - POST /api/auth/sign-in/username - ユーザーログイン
/// - GET /api/auth/get-session - セッション検証
/// - POST /api/auth/sign-out - ログアウト（将来実装）
protocol AuthenticationRepositoryProtocol {
    /// ユーザー登録
    /// - Parameters:
    ///   - username: ユーザー名 (3-20文字、英数字+_-)
    ///   - email: メールアドレス
    ///   - password: パスワード (8文字以上)
    ///   - name: 表示名 (1-50文字)
    /// - Returns: 作成されたAuthSession
    /// - Throws: AuthenticationError
    func signUp(username: String, email: String, password: String, name: String) async throws -> AuthSession

    /// ユーザーログイン
    /// - Parameters:
    ///   - username: ユーザー名
    ///   - password: パスワード
    /// - Returns: 認証済みAuthSession
    /// - Throws: AuthenticationError
    func signIn(username: String, password: String) async throws -> AuthSession

    /// セッション検証
    /// - Returns: 有効なセッション、または nil（セッション無効時）
    /// - Throws: AuthenticationError（ネットワークエラー等）
    func getSession() async throws -> AuthSession?

    /// ログアウト
    /// - Throws: AuthenticationError
    func signOut() async throws
}
