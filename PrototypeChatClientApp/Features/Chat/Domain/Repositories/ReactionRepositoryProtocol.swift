import Foundation

protocol ReactionRepositoryProtocol {
    func fetchReactions(messageId: String) async throws -> [Reaction]
    func addReaction(messageId: String, userId: String, emoji: String) async throws -> Reaction
    func removeReaction(messageId: String, userId: String, emoji: String) async throws
}
