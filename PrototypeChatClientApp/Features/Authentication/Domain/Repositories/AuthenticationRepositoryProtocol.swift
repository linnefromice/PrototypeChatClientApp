import Foundation

/// 認証用リポジトリプロトコル（認証機能に閉じる）
///
/// 実装:
/// - MockAuthenticationRepository（開発・テスト用）
/// - AuthenticationRepository（本番用・将来実装）
///
/// 注: UserRepositoryProtocol（Core層）を利用し、認証特有の操作のみここで定義
protocol AuthenticationRepositoryProtocol {
    // 将来的に認証特有の操作を追加する場合はここに定義
    // 例: func refreshToken() async throws -> AuthToken
}
