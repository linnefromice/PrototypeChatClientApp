import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

/// Factory for creating OpenAPI Client instances
/// Generated Client code is located in DerivedData during build time
class APIClientFactory {

    /// Creates a configured Client instance
    /// - Parameter environment: Target environment (default: current)
    /// - Returns: Configured OpenAPI Client
    static func createClient(environment: AppEnvironment = .current) -> Client {
        let transport = URLSessionTransport()

        #if DEBUG
        // DEBUGビルドではログ出力を有効化
        return Client(
            serverURL: environment.baseURL,
            transport: transport,
            middlewares: [LoggingMiddleware()]
        )
        #else
        return Client(
            serverURL: environment.baseURL,
            transport: transport
        )
        #endif
    }
}
