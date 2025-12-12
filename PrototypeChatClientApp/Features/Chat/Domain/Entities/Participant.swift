import Foundation

/// 会話参加者エンティティ
///
/// スコープ: Features/Chat内で使用
struct Participant: Identifiable, Codable, Equatable {
    let id: String
    let conversationId: String
    let userId: String
    let user: User  // Core層のUserを再利用
    let joinedAt: Date
    let leftAt: Date?

    /// 参加者がアクティブかどうか
    var isActive: Bool {
        leftAt == nil
    }
}
