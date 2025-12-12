import Foundation
import OpenAPIRuntime

/// 会話リポジトリの実装（OpenAPI使用）
class ConversationRepository: ConversationRepositoryProtocol {
    private let client: Client

    init(client: Client) {
        self.client = client
    }

    func fetchConversations(userId: String) async throws -> [ConversationDetail] {
        let input = Operations.get_sol_conversations.Input(
            query: .init(userId: userId)
        )

        let response = try await client.get_sol_conversations(input)

        switch response {
        case .ok(let okResponse):
            let conversationDTOs = try okResponse.body.json
            var result: [ConversationDetail] = []
            for dto in conversationDTOs {
                result.append(try await dto.toDomain())
            }
            return result
        case .undocumented(statusCode: let code, _):
            throw NetworkError.from(statusCode: code)
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

        let response = try await client.post_sol_conversations(input)

        switch response {
        case .created(let createdResponse):
            let conversationDTO = try createdResponse.body.json
            return try await conversationDTO.toDomain()
        case .undocumented(statusCode: let code, _):
            throw NetworkError.from(statusCode: code)
        }
    }
}
