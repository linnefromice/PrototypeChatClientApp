import Foundation

/// テストとPreview用のモックデータ
enum MockData {
    // MARK: - Users

    static let user1 = User(
        id: "user1",
        name: "Alice",
        avatarUrl: nil,
        createdAt: Date(timeIntervalSince1970: 1000)
    )

    static let user2 = User(
        id: "user2",
        name: "Bob",
        avatarUrl: nil,
        createdAt: Date(timeIntervalSince1970: 1000)
    )

    static let user3 = User(
        id: "user3",
        name: "Charlie",
        avatarUrl: nil,
        createdAt: Date(timeIntervalSince1970: 1000)
    )

    static let allUsers = [user1, user2, user3]

    // MARK: - Participants

    static func participant(
        id: String = "p1",
        conversationId: String = "c1",
        userId: String = "user1",
        role: ParticipantRole = .member,
        user: User? = nil,
        joinedAt: Date = Date(timeIntervalSince1970: 1000),
        leftAt: Date? = nil
    ) -> Participant {
        Participant(
            id: id,
            conversationId: conversationId,
            userId: userId,
            role: role,
            user: user ?? user1,
            joinedAt: joinedAt,
            leftAt: leftAt
        )
    }

    static let activeParticipant1 = participant(
        id: "p1",
        conversationId: "c1",
        userId: "user1",
        user: user1,
        leftAt: nil
    )

    static let activeParticipant2 = participant(
        id: "p2",
        conversationId: "c1",
        userId: "user2",
        user: user2,
        leftAt: nil
    )

    static let leftParticipant = participant(
        id: "p3",
        conversationId: "c1",
        userId: "user3",
        user: user3,
        leftAt: Date(timeIntervalSince1970: 2000)
    )

    // MARK: - Conversations

    static func conversation(
        id: String = "c1",
        type: ConversationType = .direct,
        name: String? = nil,
        createdAt: Date = Date(timeIntervalSince1970: 1000)
    ) -> Conversation {
        Conversation(
            id: id,
            type: type,
            name: name,
            createdAt: createdAt
        )
    }

    static let directConversation = conversation(
        id: "c1",
        type: .direct,
        name: nil,
        createdAt: Date(timeIntervalSince1970: 1000)
    )

    static let groupConversation = conversation(
        id: "c2",
        type: .group,
        name: "Test Group",
        createdAt: Date(timeIntervalSince1970: 2000)
    )

    static let olderConversation = conversation(
        id: "c-old",
        type: .direct,
        name: nil,
        createdAt: Date(timeIntervalSince1970: 1000)
    )

    static let newerConversation = conversation(
        id: "c-new",
        type: .direct,
        name: nil,
        createdAt: Date(timeIntervalSince1970: 3000)
    )

    // MARK: - ConversationDetails

    static func conversationDetail(
        conversation: Conversation? = nil,
        participants: [Participant]? = nil
    ) -> ConversationDetail {
        ConversationDetail(
            conversation: conversation ?? directConversation,
            participants: participants ?? [activeParticipant1, activeParticipant2]
        )
    }

    static let directConversationDetail = conversationDetail(
        conversation: directConversation,
        participants: [activeParticipant1, activeParticipant2]
    )

    static let groupConversationDetail = conversationDetail(
        conversation: groupConversation,
        participants: [activeParticipant1, activeParticipant2, activeParticipant2]
    )

    static let conversationWithLeftParticipant = conversationDetail(
        conversation: directConversation,
        participants: [activeParticipant1, leftParticipant]
    )

    static let olderConversationDetail = conversationDetail(
        conversation: olderConversation,
        participants: [activeParticipant1, activeParticipant2]
    )

    static let newerConversationDetail = conversationDetail(
        conversation: newerConversation,
        participants: [activeParticipant1, activeParticipant2]
    )

    static let multipleConversations: [ConversationDetail] = [
        directConversationDetail,
        groupConversationDetail,
        olderConversationDetail,
        newerConversationDetail
    ]
}
