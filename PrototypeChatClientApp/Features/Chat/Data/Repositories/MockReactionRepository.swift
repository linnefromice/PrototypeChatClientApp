import Foundation

class MockReactionRepository: ReactionRepositoryProtocol {
    private var reactions: [String: [Reaction]] = [:] // messageId → reactions
    var shouldThrowError: Error?

    func fetchReactions(messageId: String) async throws -> [Reaction] {
        if let error = shouldThrowError {
            throw error
        }
        return reactions[messageId] ?? []
    }

    func addReaction(messageId: String, userId: String, emoji: String) async throws -> Reaction {
        if let error = shouldThrowError {
            throw error
        }

        let reaction = Reaction(
            id: UUID().uuidString,
            messageId: messageId,
            userId: userId,
            emoji: emoji,
            createdAt: Date()
        )

        reactions[messageId, default: []].append(reaction)
        return reaction
    }

    func removeReaction(messageId: String, userId: String, emoji: String) async throws {
        if let error = shouldThrowError {
            throw error
        }

        reactions[messageId]?.removeAll { reaction in
            reaction.userId == userId && reaction.emoji == emoji
        }
    }
}
