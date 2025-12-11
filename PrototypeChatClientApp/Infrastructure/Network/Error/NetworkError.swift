import Foundation

/// ネットワーク通信エラー
///
/// 全てのRepository実装で共通して使用されるエラー型
/// Infrastructure層の横断的なエラー定義
enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case validationError(message: String)
    case notFound
    case unauthorized
    case serverError(statusCode: Int, message: String?)
    case networkFailure(Error)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "無効なURLです"
        case .noData:
            return "データが取得できませんでした"
        case .decodingError(let error):
            return "データの解析に失敗しました: \(error.localizedDescription)"
        case .validationError(let message):
            return "入力エラー: \(message)"
        case .notFound:
            return "リソースが見つかりませんでした"
        case .unauthorized:
            return "認証が必要です"
        case .serverError(let code, let message):
            return "サーバーエラー (\(code)): \(message ?? "不明なエラー")"
        case .networkFailure(let error):
            return "通信エラー: \(error.localizedDescription)"
        case .unknown:
            return "不明なエラーが発生しました"
        }
    }

    /// HTTPステータスコードからNetworkErrorにマッピング
    static func from(statusCode: Int) -> NetworkError {
        switch statusCode {
        case 400:
            return .validationError(message: "不正なリクエストです")
        case 401:
            return .unauthorized
        case 404:
            return .notFound
        case 500...599:
            return .serverError(statusCode: statusCode, message: nil)
        default:
            return .unknown
        }
    }
}
