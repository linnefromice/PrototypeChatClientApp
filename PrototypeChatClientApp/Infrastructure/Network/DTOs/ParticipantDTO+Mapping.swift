import Foundation
import OpenAPIRuntime

/// OpenAPI DTO → Domain Entity マッピング
extension Components.Schemas.Participant {
    func toDomain() -> Participant {
        Participant(
            id: id,
            conversationId: conversationId,
            userId: userId,
            role: ParticipantRole(rawValue: role.rawValue) ?? .member,
            user: user.toDomain(),
            joinedAt: joinedAt,
            leftAt: leftAt
        )
    }
}
