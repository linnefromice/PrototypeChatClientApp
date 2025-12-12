import Foundation

/// 会話詳細（会話 + 参加者リスト）
///
/// スコープ: Features/Chat内で使用
struct ConversationDetail: Identifiable, Equatable {
    let conversation: Conversation
    let participants: [Participant]

    var id: String { conversation.id }
    var type: ConversationType { conversation.type }
    var createdAt: Date { conversation.createdAt }

    /// アクティブな参加者のみ取得
    var activeParticipants: [Participant] {
        participants.filter { $0.isActive }
    }
}
