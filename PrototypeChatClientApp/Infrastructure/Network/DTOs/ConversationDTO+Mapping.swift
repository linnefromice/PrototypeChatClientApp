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
        // 各ParticipantのuserIdからUserを取得する必要がある
        // ただし、現在はConversationDetail取得時にユーザー情報が含まれていないため、
        // 一旦簡易的な実装とする（後で改善）
        return self.map { participantDTO in
            Participant(
                id: participantDTO.id,
                conversationId: participantDTO.conversationId,
                userId: participantDTO.userId,
                user: User(
                    id: participantDTO.userId,
                    name: "User \(participantDTO.userId)",  // 仮の名前
                    avatarUrl: nil,
                    createdAt: participantDTO.joinedAt
                ),
                joinedAt: participantDTO.joinedAt,
                leftAt: participantDTO.leftAt
            )
        }
    }
}
