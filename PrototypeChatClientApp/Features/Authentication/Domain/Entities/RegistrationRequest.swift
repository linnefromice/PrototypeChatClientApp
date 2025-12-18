import Foundation

/// ユーザー登録リクエストモデル
///
/// POST /api/auth/sign-up/email へ送信するデータ
struct RegistrationRequest: Codable {
    let username: String
    let email: String
    let password: String
    let name: String
}
