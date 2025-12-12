import XCTest
@testable import PrototypeChatClientApp

final class ParticipantTests: XCTestCase {

    // MARK: - isActive Tests

    func test_isActive_returnsTrueWhenLeftAtIsNil() {
        // Given
        let participant = Participant(
            id: "p1",
            conversationId: "c1",
            userId: "u1",
            user: MockData.user1,
            joinedAt: Date(),
            leftAt: nil
        )

        // When/Then
        XCTAssertTrue(participant.isActive, "leftAtがnilの場合、アクティブであるべき")
    }

    func test_isActive_returnsFalseWhenLeftAtIsSet() {
        // Given
        let participant = Participant(
            id: "p1",
            conversationId: "c1",
            userId: "u1",
            user: MockData.user1,
            joinedAt: Date(),
            leftAt: Date()
        )

        // When/Then
        XCTAssertFalse(participant.isActive, "leftAtが設定されている場合、非アクティブであるべき")
    }

    func test_isActive_returnsFalseWhenLeftAtIsInPast() {
        // Given
        let pastDate = Date(timeIntervalSince1970: 1000)
        let participant = Participant(
            id: "p1",
            conversationId: "c1",
            userId: "u1",
            user: MockData.user1,
            joinedAt: Date(timeIntervalSince1970: 500),
            leftAt: pastDate
        )

        // When/Then
        XCTAssertFalse(participant.isActive, "過去の日時でも、leftAtが設定されていれば非アクティブであるべき")
    }

    // MARK: - Equatable Tests

    func test_equatable_returnsTrueForSameParticipants() {
        // Given
        let participant1 = MockData.activeParticipant1
        let participant2 = Participant(
            id: "p1",
            conversationId: "c1",
            userId: "user1",
            user: MockData.user1,
            joinedAt: participant1.joinedAt,
            leftAt: nil
        )

        // When/Then
        XCTAssertEqual(participant1, participant2, "同じ内容のParticipantは等しいべき")
    }

    func test_equatable_returnsFalseForDifferentIds() {
        // Given
        let participant1 = MockData.activeParticipant1
        let participant2 = Participant(
            id: "p999", // Different ID
            conversationId: "c1",
            userId: "user1",
            user: MockData.user1,
            joinedAt: participant1.joinedAt,
            leftAt: nil
        )

        // When/Then
        XCTAssertNotEqual(participant1, participant2, "IDが異なる場合は等しくないべき")
    }

    // MARK: - Codable Tests

    func test_codable_encodesAndDecodesCorrectly() throws {
        // Given
        let participant = MockData.activeParticipant1
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        // When
        let encoded = try encoder.encode(participant)
        let decoded = try decoder.decode(Participant.self, from: encoded)

        // Then
        XCTAssertEqual(participant.id, decoded.id)
        XCTAssertEqual(participant.conversationId, decoded.conversationId)
        XCTAssertEqual(participant.userId, decoded.userId)
        XCTAssertEqual(participant.user.id, decoded.user.id)
        XCTAssertEqual(participant.joinedAt.timeIntervalSince1970, decoded.joinedAt.timeIntervalSince1970, accuracy: 1)
        XCTAssertEqual(participant.leftAt, decoded.leftAt)
    }

    func test_codable_encodesAndDecodesWithLeftAt() throws {
        // Given
        let participant = MockData.leftParticipant
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        // When
        let encoded = try encoder.encode(participant)
        let decoded = try decoder.decode(Participant.self, from: encoded)

        // Then
        XCTAssertNotNil(decoded.leftAt, "leftAtが保持されるべき")
        if let participantLeftAt = participant.leftAt,
           let decodedLeftAt = decoded.leftAt {
            XCTAssertEqual(
                participantLeftAt.timeIntervalSince1970,
                decodedLeftAt.timeIntervalSince1970,
                accuracy: 1
            )
        } else {
            XCTFail("leftAtがnilであってはならない")
        }
    }
}
