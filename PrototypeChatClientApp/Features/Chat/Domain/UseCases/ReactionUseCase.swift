import Foundation

/// リアクションに関するユースケースのプロトコル
protocol ReactionUseCaseProtocol {
    func addReaction(messageId: String, userId: String, emoji: String) async throws -> Reaction
    func removeReaction(messageId: String, userId: String, emoji: String) async throws
    func fetchReactions(messageId: String) async throws -> [Reaction]
    func replaceReaction(messageId: String, userId: String, oldEmoji: String?, newEmoji: String) async throws -> Reaction
    func computeSummaries(reactions: [Reaction], currentUserId: String) -> [ReactionSummary]
}

class ReactionUseCase: ReactionUseCaseProtocol {
    private let reactionRepository: ReactionRepositoryProtocol

    init(reactionRepository: ReactionRepositoryProtocol) {
        self.reactionRepository = reactionRepository
    }

    func addReaction(messageId: String, userId: String, emoji: String) async throws -> Reaction {
        return try await reactionRepository.addReaction(messageId: messageId, userId: userId, emoji: emoji)
    }

    func removeReaction(messageId: String, userId: String, emoji: String) async throws {
        try await reactionRepository.removeReaction(messageId: messageId, userId: userId, emoji: emoji)
    }

    func fetchReactions(messageId: String) async throws -> [Reaction] {
        return try await reactionRepository.fetchReactions(messageId: messageId)
    }

    func replaceReaction(
        messageId: String,
        userId: String,
        oldEmoji: String?,
        newEmoji: String
    ) async throws -> Reaction {
        // 1. 既存のリアクションがあれば削除
        if let oldEmoji = oldEmoji {
            try await removeReaction(
                messageId: messageId,
                userId: userId,
                emoji: oldEmoji
            )
        }

        // 2. 新しいリアクションを追加
        return try await addReaction(
            messageId: messageId,
            userId: userId,
            emoji: newEmoji
        )
    }

    func computeSummaries(reactions: [Reaction], currentUserId: String) -> [ReactionSummary] {
        // Group reactions by emoji
        var emojiGroups: [String: [Reaction]] = [:]
        for reaction in reactions {
            emojiGroups[reaction.emoji, default: []].append(reaction)
        }

        // Create summaries and sort by count descending
        return emojiGroups.map { emoji, groupedReactions in
            ReactionSummary(
                emoji: emoji,
                count: groupedReactions.count,
                userIds: groupedReactions.map { $0.userId }
            )
        }.sorted { $0.count > $1.count }
    }
}
