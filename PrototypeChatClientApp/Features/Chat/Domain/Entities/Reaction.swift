import Foundation

struct Reaction: Identifiable, Equatable, Codable {
    let id: String
    let messageId: String
    let userId: String
    let emoji: String
    let createdAt: Date
}
