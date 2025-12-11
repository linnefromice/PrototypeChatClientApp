import Foundation
import OpenAPIRuntime

/// Mapping extensions for Conversation-related OpenAPI types
/// Generated types are available after build

// Note: Domain Conversation entities will be created in Features/Conversation module
// For now, this provides the mapping structure

extension Components.Schemas.Conversation {
    /// Convert OpenAPI Conversation to Domain entity
    /// - Returns: Domain Conversation (to be defined in Features/Conversation)
    func toDomain() -> ConversationBasic {
        ConversationBasic(
            id: id,
            type: ConversationType(rawValue: type.rawValue) ?? .direct,
            name: name,
            createdAt: createdAt
        )
    }
}

extension Components.Schemas.ConversationDetail {
    /// Convert OpenAPI ConversationDetail to Domain entity
    /// - Returns: Domain ConversationDetail with participants
    func toDomain() -> ConversationDetail {
        ConversationDetail(
            id: id,
            type: ConversationType(rawValue: type.rawValue) ?? .direct,
            name: name,
            createdAt: createdAt,
            participants: participants.map { $0.toDomain() }
        )
    }
}

extension Components.Schemas.Participant {
    /// Convert OpenAPI Participant to Domain entity
    func toDomain() -> Participant {
        Participant(
            id: id,
            conversationId: conversationId,
            userId: userId,
            role: ParticipantRole(rawValue: role.rawValue) ?? .member,
            joinedAt: joinedAt,
            leftAt: leftAt
        )
    }
}

// MARK: - Temporary Domain Types (will move to Features/Conversation)

enum ConversationType: String, Codable {
    case direct
    case group
}

enum ParticipantRole: String, Codable {
    case member
    case admin
}

struct ConversationBasic: Identifiable {
    let id: String
    let type: ConversationType
    let name: String?
    let createdAt: Date
}

struct ConversationDetail: Identifiable {
    let id: String
    let type: ConversationType
    let name: String?
    let createdAt: Date
    let participants: [Participant]
}

struct Participant: Identifiable {
    let id: String
    let conversationId: String
    let userId: String
    let role: ParticipantRole
    let joinedAt: Date
    let leftAt: Date?
}
