import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

class MessageRepository: MessageRepositoryProtocol {
    private let client: Client

    init(client: Client) {
        self.client = client
    }

    func fetchMessages(conversationId: String, userId: String, limit: Int) async throws -> [Message] {
        // userId is no longer needed as query parameter - backend uses authenticated user from cookie
        let input = Operations.get_sol_conversations_sol__lcub_id_rcub__sol_messages.Input(
            path: .init(id: conversationId),
            query: .init(
                limit: limit,
                before: nil
            )
        )

        do {
            let response = try await client.get_sol_conversations_sol__lcub_id_rcub__sol_messages(input)

            switch response {
            case .ok(let okResponse):
                let messageDTOs = try okResponse.body.json
                return messageDTOs.map { $0.toDomain() }
            case .undocumented(statusCode: let code, let body):
                let error = NetworkError.from(statusCode: code)
                var bodyString = "N/A"
                if let httpBody = body.body {
                    bodyString = (try? await String(collecting: httpBody, upTo: 10000)) ?? "N/A"
                }
                print("❌ [MessageRepository] fetchMessages failed - Status: \(code), Error: \(error), Body: \(bodyString)")
                throw error
            }
        } catch let error as NetworkError {
            print("❌ [MessageRepository] fetchMessages failed - NetworkError: \(error)")
            throw error
        } catch {
            print("❌ [MessageRepository] fetchMessages failed - Unexpected error: \(error)")
            throw error
        }
    }

    func sendMessage(conversationId: String, senderUserId: String, text: String) async throws -> Message {
        // senderUserId is no longer needed - backend uses authenticated user from cookie
        let request = Components.Schemas.SendMessageRequest.from(text: text)

        let input = Operations.post_sol_conversations_sol__lcub_id_rcub__sol_messages.Input(
            path: .init(id: conversationId),
            body: .json(request)
        )

        do {
            let response = try await client.post_sol_conversations_sol__lcub_id_rcub__sol_messages(input)

            switch response {
            case .created(let createdResponse):
                let messageDTO = try createdResponse.body.json
                return messageDTO.toDomain()
            case .undocumented(statusCode: let code, let body):
                let error = NetworkError.from(statusCode: code)
                var bodyString = "N/A"
                if let httpBody = body.body {
                    bodyString = (try? await String(collecting: httpBody, upTo: 10000)) ?? "N/A"
                }
                print("❌ [MessageRepository] sendMessage failed - Status: \(code), Error: \(error), Body: \(bodyString)")
                throw error
            }
        } catch let error as NetworkError {
            print("❌ [MessageRepository] sendMessage failed - NetworkError: \(error)")
            throw error
        } catch {
            print("❌ [MessageRepository] sendMessage failed - Unexpected error: \(error)")
            throw error
        }
    }
}
