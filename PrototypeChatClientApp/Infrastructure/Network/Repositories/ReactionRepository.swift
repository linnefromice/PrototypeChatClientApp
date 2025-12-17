import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

class ReactionRepository: ReactionRepositoryProtocol {
    private let client: Client

    init(client: Client) {
        self.client = client
    }

    func fetchReactions(messageId: String) async throws -> [Reaction] {
        // NOTE: The current OpenAPI schema does not have a GET /messages/{id}/reactions endpoint.
        // Reactions would typically be included in the Message response or fetched separately.
        // For now, this returns an empty array. In a real implementation, reactions might be:
        // 1. Embedded in the Message entity from GET /conversations/{id}/messages
        // 2. Fetched via a dedicated GET endpoint (needs to be added to API spec)
        //
        // TODO: Implement actual reaction fetching when API endpoint is available
        print("ℹ️ [ReactionRepository] fetchReactions not yet implemented - returning empty array")
        return []
    }

    func addReaction(messageId: String, userId: String, emoji: String) async throws -> Reaction {
        let request = Components.Schemas.ReactionRequest.from(
            userId: userId,
            emoji: emoji
        )

        let input = Operations.post_sol_messages_sol__lcub_id_rcub__sol_reactions.Input(
            path: .init(id: messageId),
            body: .json(request)
        )

        do {
            let response = try await client.post_sol_messages_sol__lcub_id_rcub__sol_reactions(input)

            switch response {
            case .created(let createdResponse):
                let reactionDTO = try createdResponse.body.json
                return reactionDTO.toDomain()
            case .undocumented(statusCode: let code, _):
                let error = NetworkError.from(statusCode: code)
                print("❌ [ReactionRepository] addReaction failed - Status: \(code), Error: \(error)")
                throw error
            }
        } catch let error as NetworkError {
            print("❌ [ReactionRepository] addReaction failed - NetworkError: \(error)")
            throw error
        } catch {
            print("❌ [ReactionRepository] addReaction failed - Unexpected error: \(error)")
            throw error
        }
    }

    func removeReaction(messageId: String, userId: String, emoji: String) async throws {
        let input = Operations.delete_sol_messages_sol__lcub_id_rcub__sol_reactions_sol__lcub_emoji_rcub_.Input(
            path: .init(id: messageId, emoji: emoji),
            query: .init(userId: userId)
        )

        do {
            let response = try await client.delete_sol_messages_sol__lcub_id_rcub__sol_reactions_sol__lcub_emoji_rcub_(input)

            switch response {
            case .ok:
                // Successfully removed
                print("✅ [ReactionRepository] removeReaction succeeded")
                return
            case .undocumented(statusCode: let code, _):
                let error = NetworkError.from(statusCode: code)
                print("❌ [ReactionRepository] removeReaction failed - Status: \(code), Error: \(error)")
                throw error
            }
        } catch let error as NetworkError {
            print("❌ [ReactionRepository] removeReaction failed - NetworkError: \(error)")
            throw error
        } catch {
            print("❌ [ReactionRepository] removeReaction failed - Unexpected error: \(error)")
            throw error
        }
    }
}
