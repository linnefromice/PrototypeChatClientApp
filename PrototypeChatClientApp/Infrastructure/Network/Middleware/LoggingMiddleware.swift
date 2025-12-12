import Foundation
import OpenAPIRuntime
import HTTPTypes

/// HTTP request/response logging middleware for debugging
struct LoggingMiddleware: ClientMiddleware {

    func intercept(
        _ request: HTTPTypes.HTTPRequest,
        body: OpenAPIRuntime.HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPTypes.HTTPRequest, OpenAPIRuntime.HTTPBody?, URL) async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?)
    ) async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?) {

        // Log request
        let fullURL = baseURL.appendingPathComponent(request.path ?? "")
        print("🌐 [API Request]")
        print("   Operation: \(operationID)")
        print("   Method: \(request.method)")
        print("   URL: \(fullURL.absoluteString)")
        print("   Headers: \(request.headerFields)")

        // Log request body if exists
        if let body = body {
            do {
                let data = try await Data(collecting: body, upTo: 1024 * 1024) // 1MB limit
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("   Body: \(jsonString)")
                }
            } catch {
                print("   Body: (unable to read)")
            }
        }

        // Execute request
        let start = Date()
        let (response, responseBody) = try await next(request, body, baseURL)
        let duration = Date().timeIntervalSince(start)

        // Log response
        print("📥 [API Response]")
        print("   Operation: \(operationID)")
        print("   Status: \(response.status.code)")
        print("   Duration: \(String(format: "%.2f", duration))s")
        print("   Headers: \(response.headerFields)")

        // Log response body if exists
        if let responseBody = responseBody {
            do {
                let data = try await Data(collecting: responseBody, upTo: 1024 * 1024)
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("   Body: \(jsonString)")
                }
                // Re-create body for downstream consumption
                return (response, OpenAPIRuntime.HTTPBody(data))
            } catch {
                print("   Body: (unable to read)")
                return (response, responseBody)
            }
        }

        return (response, responseBody)
    }
}
