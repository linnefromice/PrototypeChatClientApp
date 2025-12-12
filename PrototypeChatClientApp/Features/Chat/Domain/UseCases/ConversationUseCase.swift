import Foundation

/// 会話に関するユースケース
class ConversationUseCase {
    private let conversationRepository: ConversationRepositoryProtocol

    init(conversationRepository: ConversationRepositoryProtocol) {
        self.conversationRepository = conversationRepository
    }

    /// ユーザーの会話一覧を取得
    /// - Parameter userId: ユーザーID
    /// - Returns: 会話詳細リスト（作成日時降順）
    func fetchConversations(userId: String) async throws -> [ConversationDetail] {
        let conversations = try await conversationRepository.fetchConversations(userId: userId)
        return conversations.sorted { $0.createdAt > $1.createdAt }
    }

    /// 1:1チャットを作成
    /// - Parameters:
    ///   - currentUserId: 現在のユーザーID
    ///   - targetUserId: 相手のユーザーID
    /// - Returns: 作成された会話詳細
    func createDirectConversation(
        currentUserId: String,
        targetUserId: String
    ) async throws -> ConversationDetail {
        try await conversationRepository.createConversation(
            type: .direct,
            participantIds: [currentUserId, targetUserId],
            name: nil
        )
    }

    /// グループチャットを作成
    /// - Parameters:
    ///   - currentUserId: 現在のユーザーID
    ///   - participantUserIds: 参加者のユーザーIDリスト
    ///   - groupName: グループ名
    /// - Returns: 作成された会話詳細
    func createGroupConversation(
        currentUserId: String,
        participantUserIds: [String],
        groupName: String
    ) async throws -> ConversationDetail {
        var allParticipants = participantUserIds
        if !allParticipants.contains(currentUserId) {
            allParticipants.append(currentUserId)
        }

        return try await conversationRepository.createConversation(
            type: .group,
            participantIds: allParticipants,
            name: groupName
        )
    }
}
