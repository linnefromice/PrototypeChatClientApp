import Foundation

/// アプリケーション実行環境
enum AppEnvironment {
    case development
    case production

    /// 環境に応じたベースURL
    var baseURL: URL {
        switch self {
        case .development:
            return URL(string: "http://localhost:3000")!
        case .production:
            return URL(string: "https://prototype-hono-drizzle-backend.linnefromice.workers.dev")!
        }
    }

    /// 現在の環境を取得
    static var current: AppEnvironment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }
}
