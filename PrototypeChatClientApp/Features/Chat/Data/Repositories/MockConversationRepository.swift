import Foundation

/// テスト用のモック会話リポジトリ
class MockConversationRepository: ConversationRepositoryProtocol {
    var conversations: [ConversationDetail] = []
    var shouldThrowError: Error?

    func fetchConversations(userId: String) async throws -> [ConversationDetail] {
        if let error = shouldThrowError {
            throw error
        }
        return conversations.filter { detail in
            detail.activeParticipants.contains { $0.userId == userId }
        }
    }

    func createConversation(
        type: ConversationType,
        participantIds: [String],
        name: String?
    ) async throws -> ConversationDetail {
        if let error = shouldThrowError {
            throw error
        }

        // モックデータ生成
        let newConversation = ConversationDetail(
            conversation: Conversation(
                id: UUID().uuidString,
                type: type,
                name: name,
                createdAt: Date()
            ),
            participants: participantIds.map { userId in
                Participant(
                    id: UUID().uuidString,
                    conversationId: UUID().uuidString,
                    userId: userId,
                    role: .member,
                    user: User(
                        id: userId,
                        idAlias: "user\(userId)",
                        name: "User \(userId)",
                        avatarUrl: nil,
                        createdAt: Date()
                    ),
                    joinedAt: Date(),
                    leftAt: nil
                )
            }
        )
        conversations.insert(newConversation, at: 0)
        return newConversation
    }
}
