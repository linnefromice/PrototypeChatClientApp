import Foundation

enum MessageType: String, Codable {
    case text
    case system
}

struct Message: Identifiable, Equatable, Codable {
    let id: String
    let conversationId: String
    let senderUserId: String?
    let type: MessageType
    let text: String?
    let createdAt: Date

    // Optional fields for future use
    let replyToMessageId: String?
    let systemEvent: String?
}
