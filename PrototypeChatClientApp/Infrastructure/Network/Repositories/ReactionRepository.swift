import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

class ReactionRepository: ReactionRepositoryProtocol {
    private let client: Client

    init(client: Client) {
        self.client = client
    }

    func fetchReactions(messageId: String) async throws -> [Reaction] {
        let input = Operations.get_sol_messages_sol__lcub_id_rcub__sol_reactions.Input(
            path: .init(id: messageId)
        )

        do {
            let response = try await client.get_sol_messages_sol__lcub_id_rcub__sol_reactions(input)

            switch response {
            case .ok(let okResponse):
                let reactionDTOs = try okResponse.body.json
                return reactionDTOs.map { $0.toDomain() }
            case .notFound:
                print("❌ [ReactionRepository] fetchReactions - Message not found")
                throw NetworkError.notFound
            case .undocumented(statusCode: let code, let body):
                let error = NetworkError.from(statusCode: code)
                var bodyString = "N/A"
                if let httpBody = body.body {
                    bodyString = (try? await String(collecting: httpBody, upTo: 10000)) ?? "N/A"
                }
                print("❌ [ReactionRepository] fetchReactions failed - Status: \(code), Error: \(error), Body: \(bodyString)")
                throw error
            }
        } catch let error as NetworkError {
            print("❌ [ReactionRepository] fetchReactions failed - NetworkError: \(error)")
            throw error
        } catch {
            print("❌ [ReactionRepository] fetchReactions failed - Unexpected error: \(error)")
            throw error
        }
    }

    func addReaction(messageId: String, userId: String, emoji: String) async throws -> Reaction {
        // userId is no longer needed - backend uses authenticated user from cookie
        let request = Components.Schemas.ReactionRequest.from(emoji: emoji)

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
            case .undocumented(statusCode: let code, let body):
                let error = NetworkError.from(statusCode: code)
                var bodyString = "N/A"
                if let httpBody = body.body {
                    bodyString = (try? await String(collecting: httpBody, upTo: 10000)) ?? "N/A"
                }
                print("❌ [ReactionRepository] addReaction failed - Status: \(code), Error: \(error), Body: \(bodyString)")
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
        // userId is no longer needed as query parameter - backend uses authenticated user from cookie
        let input = Operations.delete_sol_messages_sol__lcub_id_rcub__sol_reactions_sol__lcub_emoji_rcub_.Input(
            path: .init(id: messageId, emoji: emoji)
        )

        do {
            let response = try await client.delete_sol_messages_sol__lcub_id_rcub__sol_reactions_sol__lcub_emoji_rcub_(input)

            switch response {
            case .ok:
                // Successfully removed
                print("✅ [ReactionRepository] removeReaction succeeded")
                return
            case .undocumented(statusCode: let code, let body):
                let error = NetworkError.from(statusCode: code)
                var bodyString = "N/A"
                if let httpBody = body.body {
                    bodyString = (try? await String(collecting: httpBody, upTo: 10000)) ?? "N/A"
                }
                print("❌ [ReactionRepository] removeReaction failed - Status: \(code), Error: \(error), Body: \(bodyString)")
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
