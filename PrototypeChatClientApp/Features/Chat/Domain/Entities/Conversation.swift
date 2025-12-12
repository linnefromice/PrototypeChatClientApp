import Foundation

/// 会話エンティティ
///
/// スコープ: Features/Chat内で使用
struct Conversation: Identifiable, Codable, Equatable {
    let id: String
    let type: ConversationType
    let name: String?
    let createdAt: Date
}
