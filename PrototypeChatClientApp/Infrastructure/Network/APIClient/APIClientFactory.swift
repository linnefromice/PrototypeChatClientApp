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
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60

        let transport = URLSessionTransport(configuration: configuration)

        return Client(
            serverURL: environment.baseURL,
            transport: transport
        )
    }

    /// Creates a Client with custom URLSessionConfiguration
    /// - Parameters:
    ///   - environment: Target environment
    ///   - configuration: Custom URLSession configuration
    /// - Returns: Configured OpenAPI Client
    static func createClient(
        environment: AppEnvironment,
        configuration: URLSessionConfiguration
    ) -> Client {
        let transport = URLSessionTransport(configuration: configuration)

        return Client(
            serverURL: environment.baseURL,
            transport: transport
        )
    }
}
