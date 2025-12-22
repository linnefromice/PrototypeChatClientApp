import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

/// Custom date transcoder to handle backend's various date formats
struct CustomDateTranscoder: DateTranscoder {
    func encode(_ date: Date) throws -> String {
        // For encoding, use ISO8601 format (standard)
        return ISO8601DateFormatter().string(from: date)
    }

    func decode(_ dateString: String) throws -> Date {
        // Try ISO8601 with milliseconds and timezone (e.g., "2025-12-15T17:15:21.202Z")
        let iso8601WithMilliseconds = ISO8601DateFormatter()
        iso8601WithMilliseconds.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = iso8601WithMilliseconds.date(from: dateString) {
            return date
        }

        // Try ISO8601 with timezone (e.g., "2025-12-10T11:03:08Z")
        let iso8601Formatter = ISO8601DateFormatter()
        if let date = iso8601Formatter.date(from: dateString) {
            return date
        }

        // Try ISO8601 without timezone but with milliseconds (e.g., "2025-12-10T11:03:08.123")
        let isoWithMillisFormatter = DateFormatter()
        isoWithMillisFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        isoWithMillisFormatter.locale = Locale(identifier: "en_US_POSIX")
        isoWithMillisFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        if let date = isoWithMillisFormatter.date(from: dateString) {
            return date
        }

        // Try ISO8601 without timezone (e.g., "2025-12-10T11:03:08")
        let isoFormatter = DateFormatter()
        isoFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        isoFormatter.locale = Locale(identifier: "en_US_POSIX")
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        if let date = isoFormatter.date(from: dateString) {
            return date
        }

        // Try custom format with space separator (e.g., "2025-12-10 11:03:08")
        let customFormatter = DateFormatter()
        customFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        customFormatter.locale = Locale(identifier: "en_US_POSIX")
        customFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        if let date = customFormatter.date(from: dateString) {
            return date
        }

        throw DecodingError.dataCorrupted(
            .init(
                codingPath: [],
                debugDescription: "Cannot decode date string: \(dateString). Expected formats: yyyy-MM-dd'T'HH:mm:ss.SSS[Z] or yyyy-MM-dd'T'HH:mm:ss[Z] or yyyy-MM-dd HH:mm:ss"
            )
        )
    }
}

/// Factory for creating OpenAPI Client instances
/// Generated Client code is located in DerivedData during build time
class APIClientFactory {

    /// Creates a configured Client instance
    /// - Parameter environment: Target environment (default: current)
    /// - Returns: Configured OpenAPI Client
    static func createClient(environment: AppEnvironment = .current) -> Client {
        // Configure custom date transcoder for backend's date format
        let configuration = Configuration(
            dateTranscoder: CustomDateTranscoder()
        )

        // Use NetworkConfiguration.session for cookie-based authentication
        let transport = URLSessionTransport(configuration: .init(session: NetworkConfiguration.session))

        #if DEBUG
        // DEBUGビルドではログ出力を有効化
        return Client(
            serverURL: environment.baseURL,
            configuration: configuration,
            transport: transport,
            middlewares: [LoggingMiddleware()]
        )
        #else
        return Client(
            serverURL: environment.baseURL,
            configuration: configuration,
            transport: transport
        )
        #endif
    }
}
