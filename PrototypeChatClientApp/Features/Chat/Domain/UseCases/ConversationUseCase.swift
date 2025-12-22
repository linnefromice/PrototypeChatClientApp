import Foundation

/// 会話に関するユースケースのプロトコル
protocol ConversationUseCaseProtocol {
    func fetchConversations(userId: String) async throws -> [ConversationDetail]
    func createDirectConversation(currentUserId: String, targetUserId: String) async throws -> ConversationDetail
    func createGroupConversation(currentUserId: String, participantUserIds: [String], groupName: String) async throws -> ConversationDetail
}

/// 会話に関するユースケース
class ConversationUseCase: ConversationUseCaseProtocol {
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
    ///   - currentUserId: 現在のユーザーID (should be chatUser.id in UUID format)
    ///   - targetUserId: 相手のユーザーID (should be chatUser.id in UUID format)
    /// - Returns: 作成された会話詳細
    func createDirectConversation(
        currentUserId: String,
        targetUserId: String
    ) async throws -> ConversationDetail {
        print("ℹ️ [ConversationUseCase] Creating direct conversation")
        print("   currentUserId: \(currentUserId)")
        print("   targetUserId: \(targetUserId)")
        print("   participantIds: [\(currentUserId), \(targetUserId)]")

        // Validate that IDs are in UUID format
        let uuidPattern = "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
        let isCurrentUserIdUUID = (try? NSRegularExpression(pattern: uuidPattern))?.firstMatch(
            in: currentUserId,
            range: NSRange(location: 0, length: currentUserId.utf16.count)
        ) != nil
        let isTargetUserIdUUID = (try? NSRegularExpression(pattern: uuidPattern))?.firstMatch(
            in: targetUserId,
            range: NSRange(location: 0, length: targetUserId.utf16.count)
        ) != nil

        if !isCurrentUserIdUUID {
            print("❌ [ConversationUseCase] currentUserId is NOT a valid UUID! This should be chatUser.id, not authUser.id")
        }
        if !isTargetUserIdUUID {
            print("❌ [ConversationUseCase] targetUserId is NOT a valid UUID! This should be chatUser.id, not authUser.id")
        }

        return try await conversationRepository.createConversation(
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
