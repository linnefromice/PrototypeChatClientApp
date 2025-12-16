import Foundation
import OpenAPIRuntime

/// OpenAPI DTO → Domain Entity マッピング
extension Components.Schemas.ConversationDetail {
    func toDomain() async throws -> ConversationDetail {
        // allOf で value1 (Conversation) と value2 (participants) に分かれている
        let conversation = value1.toDomain()
        let participants = try await value2.participants.toDomain()

        return ConversationDetail(
            conversation: conversation,
            participants: participants
        )
    }
}

extension Components.Schemas.Conversation {
    func toDomain() -> Conversation {
        Conversation(
            id: id,
            type: ConversationType(rawValue: _type.rawValue) ?? .direct,
            name: name,
            createdAt: createdAt
        )
    }
}

extension Array where Element == Components.Schemas.Participant {
    func toDomain() async throws -> [Participant] {
        return self.map { $0.toDomain() }
    }
}
