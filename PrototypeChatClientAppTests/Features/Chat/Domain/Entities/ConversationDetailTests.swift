import XCTest
@testable import PrototypeChatClientApp

final class ConversationDetailTests: XCTestCase {

    // MARK: - activeParticipants Tests

    func test_activeParticipants_returnsOnlyActiveParticipants() {
        // Given
        let activeParticipant = MockData.activeParticipant1
        let leftParticipant = MockData.leftParticipant

        let detail = ConversationDetail(
            conversation: MockData.directConversation,
            participants: [activeParticipant, leftParticipant]
        )

        // When
        let active = detail.activeParticipants

        // Then
        XCTAssertEqual(active.count, 1, "アクティブな参加者のみが返されるべき")
        XCTAssertEqual(active.first?.id, activeParticipant.id)
    }

    func test_activeParticipants_returnsAllWhenNoneLeft() {
        // Given
        let detail = MockData.directConversationDetail

        // When
        let active = detail.activeParticipants

        // Then
        XCTAssertEqual(active.count, 2, "全員がアクティブな場合、全員が返されるべき")
    }

    func test_activeParticipants_returnsEmptyWhenAllLeft() {
        // Given
        let leftParticipant1 = Participant(
            id: "p1",
            conversationId: "c1",
            userId: "u1",
            role: .member,
            user: MockData.user1,
            joinedAt: Date(),
            leftAt: Date()
        )
        let leftParticipant2 = Participant(
            id: "p2",
            conversationId: "c1",
            userId: "u2",
            role: .member,
            user: MockData.user2,
            joinedAt: Date(),
            leftAt: Date()
        )

        let detail = ConversationDetail(
            conversation: MockData.directConversation,
            participants: [leftParticipant1, leftParticipant2]
        )

        // When
        let active = detail.activeParticipants

        // Then
        XCTAssertTrue(active.isEmpty, "全員が退出している場合、空配列が返されるべき")
    }

    func test_activeParticipants_filtersCorrectlyWithMultipleLeft() {
        // Given
        let active1 = MockData.activeParticipant1
        let active2 = MockData.activeParticipant2
        let left1 = MockData.leftParticipant
        let left2 = Participant(
            id: "p4",
            conversationId: "c1",
            userId: "u4",
            role: .member,
            user: MockData.user3,
            joinedAt: Date(),
            leftAt: Date()
        )

        let detail = ConversationDetail(
            conversation: MockData.groupConversation,
            participants: [active1, left1, active2, left2]
        )

        // When
        let active = detail.activeParticipants

        // Then
        XCTAssertEqual(active.count, 2, "アクティブな参加者2名のみが返されるべき")
        XCTAssertTrue(active.contains { $0.id == active1.id })
        XCTAssertTrue(active.contains { $0.id == active2.id })
    }

    // MARK: - Computed Properties Tests

    func test_id_returnsConversationId() {
        // Given
        let detail = MockData.directConversationDetail

        // When
        let id = detail.id

        // Then
        XCTAssertEqual(id, detail.conversation.id, "idはconversation.idと同じであるべき")
    }

    func test_type_returnsConversationType() {
        // Given
        let directDetail = MockData.directConversationDetail
        let groupDetail = MockData.groupConversationDetail

        // When/Then
        XCTAssertEqual(directDetail.type, .direct)
        XCTAssertEqual(groupDetail.type, .group)
    }

    func test_createdAt_returnsConversationCreatedAt() {
        // Given
        let createdAt = Date(timeIntervalSince1970: 12345)
        let conversation = Conversation(
            id: "c1",
            type: .direct,
            name: nil,
            createdAt: createdAt
        )
        let detail = ConversationDetail(
            conversation: conversation,
            participants: []
        )

        // When/Then
        XCTAssertEqual(detail.createdAt, createdAt)
    }

    // MARK: - Equatable Tests

    func test_equatable_returnsTrueForSameDetails() {
        // Given
        let detail1 = MockData.directConversationDetail
        let detail2 = ConversationDetail(
            conversation: detail1.conversation,
            participants: detail1.participants
        )

        // When/Then
        XCTAssertEqual(detail1, detail2)
    }

    func test_equatable_returnsFalseForDifferentConversations() {
        // Given
        let detail1 = MockData.directConversationDetail
        let detail2 = ConversationDetail(
            conversation: MockData.groupConversation, // Different conversation
            participants: detail1.participants
        )

        // When/Then
        XCTAssertNotEqual(detail1, detail2)
    }

    func test_equatable_returnsFalseForDifferentParticipants() {
        // Given
        let detail1 = MockData.directConversationDetail
        let detail2 = ConversationDetail(
            conversation: detail1.conversation,
            participants: [MockData.activeParticipant1] // Different participants
        )

        // When/Then
        XCTAssertNotEqual(detail1, detail2)
    }

    // MARK: - Identifiable Tests

    func test_identifiable_usesConversationId() {
        // Given
        let detail = MockData.directConversationDetail

        // When/Then
        XCTAssertEqual(detail.id, detail.conversation.id, "Identifiable.idはconversation.idを使うべき")
    }
}
