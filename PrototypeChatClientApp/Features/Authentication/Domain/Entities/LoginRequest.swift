import Foundation

/// ログインリクエストモデル
///
/// POST /api/auth/sign-in/username へ送信するデータ
struct LoginRequest: Codable {
    let username: String
    let password: String
}
