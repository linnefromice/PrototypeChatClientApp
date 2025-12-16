import Foundation

/// 会話参加者の役割
enum ParticipantRole: String, Codable, Equatable {
    case member
    case admin
}

/// 会話参加者エンティティ
///
/// スコープ: Features/Chat内で使用
struct Participant: Identifiable, Codable, Equatable {
    let id: String
    let conversationId: String
    let userId: String
    let role: ParticipantRole
    let user: User  // Core層のUserを再利用
    let joinedAt: Date
    let leftAt: Date?

    /// 参加者がアクティブかどうか
    var isActive: Bool {
        leftAt == nil
    }
}
