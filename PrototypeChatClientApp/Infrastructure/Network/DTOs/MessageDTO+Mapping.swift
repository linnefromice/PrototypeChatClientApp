import Foundation
import OpenAPIRuntime

/// Mapping extensions for Message-related OpenAPI types
/// Generated types are available after build

extension Components.Schemas.Message {
    /// Convert OpenAPI Message to Domain entity
    func toDomain() -> Message {
        Message(
            id: id,
            conversationId: conversationId,
            senderUserId: senderUserId,
            type: MessageType(rawValue: type.rawValue) ?? .text,
            text: text,
            replyToMessageId: replyToMessageId,
            systemEvent: systemEvent.flatMap { SystemEvent(rawValue: $0.rawValue) },
            createdAt: createdAt
        )
    }
}

extension Components.Schemas.Reaction {
    /// Convert OpenAPI Reaction to Domain entity
    func toDomain() -> Reaction {
        Reaction(
            id: id,
            messageId: messageId,
            userId: userId,
            emoji: emoji,
            createdAt: createdAt
        )
    }
}

extension Components.Schemas.Bookmark {
    /// Convert OpenAPI Bookmark to Domain entity
    func toDomain() -> Bookmark {
        Bookmark(
            id: id,
            messageId: messageId,
            userId: userId,
            createdAt: createdAt
        )
    }
}

extension Components.Schemas.BookmarkListItem {
    /// Convert OpenAPI BookmarkListItem to Domain entity
    func toDomain() -> BookmarkListItem {
        BookmarkListItem(
            messageId: messageId,
            conversationId: conversationId,
            text: text,
            createdAt: createdAt,
            messageCreatedAt: messageCreatedAt
        )
    }
}

// MARK: - Temporary Domain Types (will move to Features/Message)

enum MessageType: String, Codable {
    case text
    case system
}

enum SystemEvent: String, Codable {
    case join
    case leave
}

struct Message: Identifiable {
    let id: String
    let conversationId: String
    let senderUserId: String?
    let type: MessageType
    let text: String?
    let replyToMessageId: String?
    let systemEvent: SystemEvent?
    let createdAt: Date
}

struct Reaction: Identifiable {
    let id: String
    let messageId: String
    let userId: String
    let emoji: String
    let createdAt: Date
}

struct Bookmark: Identifiable {
    let id: String
    let messageId: String
    let userId: String
    let createdAt: Date
}

struct BookmarkListItem {
    let messageId: String
    let conversationId: String
    let text: String?
    let createdAt: Date
    let messageCreatedAt: Date
}
