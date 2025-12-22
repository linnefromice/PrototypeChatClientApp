import Foundation

/// アプリケーション実行環境
///
/// Info.plistの`BackendUrl`設定から環境を判定します。
/// Build Settingsの`BACKEND_URL`で環境ごとのURLを設定してください。
enum AppEnvironment {
    case development
    case production

    /// 環境に応じたベースURL
    var baseURL: URL {
        // Info.plistから設定されたURLを使用
        return AppConfig.backendUrl
    }

    /// 現在の環境を取得
    ///
    /// Info.plistの`BackendUrl`設定から自動判定します。
    /// - localhost → development
    /// - その他 → production
    static var current: AppEnvironment {
        // 環境変数による強制切り替え（デバッグ用）
        #if DEBUG
        if let envOverride = ProcessInfo.processInfo.environment["USE_ENVIRONMENT"] {
            switch envOverride.lowercased() {
            case "production":
                return .production
            default:
                return .development
            }
        }
        #endif

        // Info.plistの設定から自動判定
        switch AppConfig.currentEnvironmentType {
        case .development:
            return .development
        case .production:
            return .production
        }
    }
}
