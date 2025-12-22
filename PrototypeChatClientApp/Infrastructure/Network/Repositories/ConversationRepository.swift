import Foundation
import OpenAPIRuntime

/// 会話リポジトリの実装（OpenAPI使用）
class ConversationRepository: ConversationRepositoryProtocol {
    private let client: Client

    init(client: Client) {
        self.client = client
    }

    func fetchConversations(userId: String) async throws -> [ConversationDetail] {
        // userId is no longer needed as query parameter - backend uses authenticated user from cookie
        let input = Operations.get_sol_conversations.Input()

        #if DEBUG
        // Debug: Print cookies before API call
        if let url = URL(string: "http://localhost:8787") {
            NetworkConfiguration.printCookies(for: url)
        }
        #endif

        do {
            let response = try await client.get_sol_conversations(input)

            switch response {
            case .ok(let okResponse):
                let conversationDTOs = try okResponse.body.json
                var result: [ConversationDetail] = []
                for dto in conversationDTOs {
                    result.append(try await dto.toDomain())
                }
                return result
            case .undocumented(statusCode: let code, let body):
                let error = NetworkError.from(statusCode: code)
                var bodyString = "N/A"
                if let httpBody = body.body {
                    bodyString = (try? await String(collecting: httpBody, upTo: 10000)) ?? "N/A"
                }
                print("❌ [ConversationRepository] fetchConversations failed - Status: \(code), Error: \(error), Body: \(bodyString)")
                throw error
            }
        } catch let error as NetworkError {
            print("❌ [ConversationRepository] fetchConversations failed - NetworkError: \(error)")
            throw error
        } catch {
            print("❌ [ConversationRepository] fetchConversations failed - Unexpected error: \(error)")
            throw error
        }
    }

    func createConversation(
        type: ConversationType,
        participantIds: [String],
        name: String?
    ) async throws -> ConversationDetail {
        // ConversationType → OpenAPI enum型にマッピング
        let typePayload: Components.Schemas.CreateConversationRequest._typePayload =
            type == .direct ? .direct : .group

        let input = Operations.post_sol_conversations.Input(
            body: .json(
                Components.Schemas.CreateConversationRequest(
                    _type: typePayload,
                    name: name,
                    participantIds: participantIds
                )
            )
        )

        do {
            let response = try await client.post_sol_conversations(input)

            switch response {
            case .created(let createdResponse):
                let conversationDTO = try createdResponse.body.json
                return try await conversationDTO.toDomain()
            case .undocumented(statusCode: let code, let body):
                let error = NetworkError.from(statusCode: code)
                var bodyString = "N/A"
                if let httpBody = body.body {
                    bodyString = (try? await String(collecting: httpBody, upTo: 10000)) ?? "N/A"
                }
                print("❌ [ConversationRepository] createConversation failed - Status: \(code), Error: \(error), Body: \(bodyString)")
                throw error
            }
        } catch let error as NetworkError {
            print("❌ [ConversationRepository] createConversation failed - NetworkError: \(error)")
            throw error
        } catch {
            print("❌ [ConversationRepository] createConversation failed - Unexpected error: \(error)")
            throw error
        }
    }
}
