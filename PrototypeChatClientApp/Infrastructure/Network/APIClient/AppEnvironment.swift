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
        // 環境変数 USE_PRODUCTION_API が設定されている場合は本番環境を使用
        if ProcessInfo.processInfo.environment["USE_PRODUCTION_API"] != nil {
            return .production
        }
        
        return .production

//        #if DEBUG
//        // DEBUGビルドでもlocalhostが起動していない場合は本番環境を使用
//        // TODO: より良い方法として、Settings.bundleでユーザーが切り替えられるようにする
//        return .development
//        #else
//        return .production
//        #endif
    }
}
