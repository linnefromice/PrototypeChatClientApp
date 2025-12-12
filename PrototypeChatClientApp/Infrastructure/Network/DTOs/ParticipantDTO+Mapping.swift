import Foundation
import OpenAPIRuntime

/// OpenAPI DTO → Domain Entity マッピング
/// 注意: Participantにはuserフィールドがないため、userIdのみ持っている
/// 実際のUser情報は別途取得が必要
extension Components.Schemas.Participant {
    func toDomainWithUser(_ user: User) -> Participant {
        Participant(
            id: id,
            conversationId: conversationId,
            userId: userId,
            user: user,
            joinedAt: joinedAt,
            leftAt: leftAt
        )
    }
}
