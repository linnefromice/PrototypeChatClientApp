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
    /// - Release: `https://prototype-hono-drizzle-backend.linnefromice.workers.dev`
    static var backendUrl: URL {
        guard let urlString = infoDict["BackendUrl"] as? String,
              !urlString.isEmpty,
              !urlString.contains("$("),  // 未設定の場合は$(BACKEND_URL)のまま
              let url = URL(string: urlString) else {
            #if DEBUG
            // DEBUGビルドではデフォルトでlocalhostを使用
            print("⚠️ [Environment] BackendUrl not configured, using default localhost:8787")
            return URL(string: "http://localhost:8787")!
            #else
            fatalError("BackendUrlが設定されていません。Build SettingsでBACKEND_URLを設定してください。")
            #endif
        }
        return url
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
        print("🔧 [Environment] Configuration:")
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
