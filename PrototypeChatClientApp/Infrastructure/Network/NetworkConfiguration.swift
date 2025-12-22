import Foundation

/// ネットワーク設定
///
/// Cookie-based session management用のURLSession設定を提供
enum NetworkConfiguration {
    /// BetterAuth用のCookie設定を含むURLSessionConfiguration
    static var cookieEnabled: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.httpCookieAcceptPolicy = .always
        configuration.httpCookieStorage = HTTPCookieStorage.shared
        configuration.httpShouldSetCookies = true

        // Note: Secure cookies over HTTP localhost are handled by the backend
        // iOS will reject Secure cookies over HTTP, so ensure backend doesn't set Secure in dev

        return configuration
    }

    /// Cookie設定を含むURLSession
    static var session: URLSession {
        URLSession(configuration: cookieEnabled)
    }

    #if DEBUG
    /// 開発用: Cookieデバッグ情報を出力
    static func printCookies(for url: URL) {
        if let cookies = HTTPCookieStorage.shared.cookies(for: url) {
            print("🍪 [NetworkConfiguration] Cookies for \(url.host ?? "unknown"):")
            for cookie in cookies {
                print("  - \(cookie.name): \(cookie.value)")
                print("    Domain: \(cookie.domain), Path: \(cookie.path)")
                print("    Expires: \(cookie.expiresDate?.description ?? "session")")
                print("    HttpOnly: \(cookie.isHTTPOnly), Secure: \(cookie.isSecure)")
            }
        } else {
            print("🍪 [NetworkConfiguration] No cookies for \(url.host ?? "unknown")")
        }
    }

    /// 開発用: すべてのCookieを削除
    static func clearAllCookies() {
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
            print("🍪 [NetworkConfiguration] Cleared \(cookies.count) cookies")
        }
    }
    #endif
}
