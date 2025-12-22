import Foundation

/// アプリケーション環境設定
///
/// Info.plistから環境変数を読み込み、型安全にアクセスできるようにします。
/// Build Configurationsごとに異なる値を設定することで、環境を切り替えられます。
struct AppConfig {
    // MARK: - Info.plist読み込み

    /// Info.plistの辞書データ
    private static var infoDict: [String: Any] {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Info.plistが見つかりません")
        }
        return dict
    }

    // MARK: - Backend Configuration

    /// バックエンドAPIのベースURL
    ///
    /// Build Settingsの`BACKEND_URL`から設定されます:
    /// - Debug: `http://localhost:8787`
    /// - Development: `https://prototype-hono-drizzle-backend.linnefromice.workers.dev`
    /// - Release: `https://prototype-hono-drizzle-backend.linnefromice.workers.dev`
    static var backendUrl: URL {
        // 1. Info.plistから読み取り（ビルド時に変数置換されている場合）
        if let urlString = infoDict["BackendUrl"] as? String,
           !urlString.isEmpty,
           !urlString.contains("$("),  // 未設定の場合は$(BACKEND_URL)のまま
           let url = URL(string: urlString) {
            return url
        }

        // 2. Configurationに基づいてハードコードされた値を返す
        // Info.plistの変数置換が機能しない場合のフォールバック
        let configurationName = infoDict["Configuration"] as? String ?? ""

        let defaultUrl: String
        switch configurationName {
        case "Debug":
            defaultUrl = "http://localhost:8787"
        case "Development":
            defaultUrl = "https://prototype-hono-drizzle-backend.linnefromice.workers.dev"
        case "Release":
            defaultUrl = "https://prototype-hono-drizzle-backend.linnefromice.workers.dev"
        default:
            // Configuration名が取得できない場合は #if DEBUG で判定
            #if DEBUG
            defaultUrl = "http://localhost:8787"
            #else
            defaultUrl = "https://prototype-hono-drizzle-backend.linnefromice.workers.dev"
            #endif
        }

        print("⚠️ [Environment] BackendUrl not properly configured in Info.plist")
        print("   Configuration: \(configurationName.isEmpty ? "(unknown)" : configurationName)")
        print("   Using fallback URL: \(defaultUrl)")
        return URL(string: defaultUrl)!
    }

    /// バックエンドURLが安全なコンテキスト（HTTPS）かどうか
    static var isSecureContext: Bool {
        return backendUrl.scheme == "https"
    }

    /// 現在の環境を判定
    static var currentEnvironmentType: EnvironmentType {
        let urlString = backendUrl.absoluteString

        if urlString.contains("localhost") || urlString.contains("127.0.0.1") {
            return .development
        } else {
            return .production
        }
    }

    // MARK: - Optional: API Keys

    /// APIキー（将来的に必要な場合）
    ///
    /// Info.plistに`ApiKey`を追加し、Build Settingsで設定できます
    static var apiKey: String {
        return infoDict["ApiKey"] as? String ?? ""
    }

    // MARK: - Debug Helpers

    #if DEBUG
    /// デバッグ情報を出力
    static func printConfiguration() {
        let configurationName = infoDict["Configuration"] as? String ?? "(unknown)"
        print("🔧 [Environment] Configuration:")
        print("   Build Configuration: \(configurationName)")
        print("   Backend URL: \(backendUrl)")
        print("   Environment: \(currentEnvironmentType.displayName)")
        print("   Secure Context: \(isSecureContext)")
        print("   API Key: \(apiKey.isEmpty ? "(not set)" : "***")")
    }
    #endif
}

/// アプリケーション実行環境タイプ
enum EnvironmentType: String {
    case development = "Development"
    case production = "Production"

    var displayName: String {
        return rawValue
    }
}
