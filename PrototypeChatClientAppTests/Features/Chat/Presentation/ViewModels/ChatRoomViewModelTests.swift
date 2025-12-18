import XCTest
@testable import PrototypeChatClientApp

/// Unit tests for ChatRoomViewModel
/// Tests reaction validation including preventing reactions to own messages
@MainActor
final class ChatRoomViewModelTests: XCTestCase {

    var sut: ChatRoomViewModel!
    var mockMessageUseCase: MockMessageUseCase!
    var mockReactionUseCase: ReactionUseCase!
    var mockReactionRepository: MockReactionRepository!
    let testConversationId = "conversation-1"
    let testCurrentUserId = "user-1"
    let testOtherUserId = "user-2"

    override func setUp() async throws {
        try await super.setUp()

        mockMessageUseCase = MockMessageUseCase()
        mockReactionRepository = MockReactionRepository()
        mockReactionUseCase = ReactionUseCase(reactionRepository: mockReactionRepository)

        sut = ChatRoomViewModel(
            messageUseCase: mockMessageUseCase,
            reactionUseCase: mockReactionUseCase,
            conversationId: testConversationId,
            currentUserId: testCurrentUserId
        )
    }

    override func tearDown() async throws {
        sut = nil
        mockMessageUseCase = nil
        mockReactionUseCase = nil
        mockReactionRepository = nil
        try await super.tearDown()
    }

    // MARK: - Prevent Reacting to Own Messages Tests

    func testToggleReaction_OwnMessage_ShowsError() async {
        // Given - Own message
        let ownMessage = Message(
            id: "msg-1",
            conversationId: testConversationId,
            senderUserId: testCurrentUserId,
            text: "My message",
            createdAt: Date()
        )
        sut.messages = [ownMessage]

        // When - Try to react to own message
        await sut.toggleReaction(on: ownMessage.id, emoji: "👍")

        // Then
        XCTAssertTrue(sut.showError, "Should show error")
        XCTAssertEqual(sut.errorMessage, "自分のメッセージにはリアクションできません")

        // Verify no reaction was added
        let reactions = sut.messageReactions[ownMessage.id] ?? []
        XCTAssertEqual(reactions.count, 0, "Should not add any reactions")
    }

    func testToggleReaction_OtherMessage_Success() async throws {
        // Given - Other user's message
        let otherMessage = Message(
            id: "msg-1",
            conversationId: testConversationId,
            senderUserId: testOtherUserId,
            text: "Other's message",
            createdAt: Date()
        )
        sut.messages = [otherMessage]

        // When - React to other's message
        await sut.toggleReaction(on: otherMessage.id, emoji: "👍")

        // Then
        XCTAssertFalse(sut.showError, "Should not show error")
        XCTAssertNil(sut.errorMessage)

        // Verify reaction was added
        let reactions = sut.messageReactions[otherMessage.id] ?? []
        XCTAssertEqual(reactions.count, 1, "Should add one reaction")
        XCTAssertEqual(reactions.first?.emoji, "👍")
        XCTAssertEqual(reactions.first?.userId, testCurrentUserId)
    }

    func testAddReaction_OwnMessage_ShowsError() async {
        // Given - Own message
        let ownMessage = Message(
            id: "msg-1",
            conversationId: testConversationId,
            senderUserId: testCurrentUserId,
            text: "My message",
            createdAt: Date()
        )
        sut.messages = [ownMessage]

        // When - Try to add reaction to own message
        await sut.addReaction(to: ownMessage.id, emoji: "❤️")

        // Then
        XCTAssertTrue(sut.showError, "Should show error")
        XCTAssertEqual(sut.errorMessage, "自分のメッセージにはリアクションできません")

        // Verify no reaction was added
        let reactions = sut.messageReactions[ownMessage.id] ?? []
        XCTAssertEqual(reactions.count, 0, "Should not add any reactions")
    }

    func testAddReaction_OtherMessage_Success() async throws {
        // Given - Other user's message
        let otherMessage = Message(
            id: "msg-1",
            conversationId: testConversationId,
            senderUserId: testOtherUserId,
            text: "Other's message",
            createdAt: Date()
        )
        sut.messages = [otherMessage]

        // When - Add reaction to other's message
        await sut.addReaction(to: otherMessage.id, emoji: "❤️")

        // Then
        XCTAssertFalse(sut.showError, "Should not show error")
        XCTAssertNil(sut.errorMessage)

        // Verify reaction was added
        let reactions = sut.messageReactions[otherMessage.id] ?? []
        XCTAssertEqual(reactions.count, 1, "Should add one reaction")
        XCTAssertEqual(reactions.first?.emoji, "❤️")
    }

    func testRemoveReaction_OwnMessage_ShowsError() async {
        // Given - Own message with existing reaction (shouldn't happen, but defensive)
        let ownMessage = Message(
            id: "msg-1",
            conversationId: testConversationId,
            senderUserId: testCurrentUserId,
            text: "My message",
            createdAt: Date()
        )
        sut.messages = [ownMessage]

        // When - Try to remove reaction from own message
        await sut.removeReaction(from: ownMessage.id, emoji: "👍")

        // Then
        XCTAssertTrue(sut.showError, "Should show error")
        XCTAssertEqual(sut.errorMessage, "自分のメッセージにはリアクションできません")
    }

    func testRemoveReaction_OtherMessage_Success() async throws {
        // Given - Other user's message with existing reaction
        let otherMessage = Message(
            id: "msg-1",
            conversationId: testConversationId,
            senderUserId: testOtherUserId,
            text: "Other's message",
            createdAt: Date()
        )
        sut.messages = [otherMessage]

        // Add reaction first
        await sut.addReaction(to: otherMessage.id, emoji: "😂")
        XCTAssertEqual(sut.messageReactions[otherMessage.id]?.count, 1)

        // When - Remove the reaction
        await sut.removeReaction(from: otherMessage.id, emoji: "😂")

        // Then
        XCTAssertFalse(sut.showError, "Should not show error")
        XCTAssertNil(sut.errorMessage)

        // Verify reaction was removed
        let reactions = sut.messageReactions[otherMessage.id] ?? []
        XCTAssertEqual(reactions.count, 0, "Should remove the reaction")
    }

    // MARK: - isOwnMessage Tests

    func testIsOwnMessage_OwnMessage_ReturnsTrue() {
        // Given
        let ownMessage = Message(
            id: "msg-1",
            conversationId: testConversationId,
            senderUserId: testCurrentUserId,
            text: "My message",
            createdAt: Date()
        )

        // When
        let result = sut.isOwnMessage(ownMessage)

        // Then
        XCTAssertTrue(result, "Should return true for own message")
    }

    func testIsOwnMessage_OtherMessage_ReturnsFalse() {
        // Given
        let otherMessage = Message(
            id: "msg-1",
            conversationId: testConversationId,
            senderUserId: testOtherUserId,
            text: "Other's message",
            createdAt: Date()
        )

        // When
        let result = sut.isOwnMessage(otherMessage)

        // Then
        XCTAssertFalse(result, "Should return false for other's message")
    }
}

// MARK: - Mock MessageUseCase

class MockMessageUseCase: MessageUseCase {
    var shouldThrowError: Error?
    var messagesToReturn: [Message] = []
    var messageSent: Message?

    init() {
        // Initialize with a mock repository (not used in these tests)
        super.init(messageRepository: MockMessageRepository())
    }

    override func fetchMessages(conversationId: String, userId: String, limit: Int) async throws -> [Message] {
        if let error = shouldThrowError {
            throw error
        }
        return messagesToReturn
    }

    override func sendMessage(conversationId: String, senderUserId: String, text: String) async throws -> Message {
        if let error = shouldThrowError {
            throw error
        }
        let message = Message(
            id: UUID().uuidString,
            conversationId: conversationId,
            senderUserId: senderUserId,
            text: text,
            createdAt: Date()
        )
        messageSent = message
        return message
    }
}

// MARK: - Mock MessageRepository

class MockMessageRepository: MessageRepositoryProtocol {
    var shouldThrowError: Error?
    var messages: [Message] = []

    func fetchMessages(conversationId: String, userId: String, limit: Int) async throws -> [Message] {
        if let error = shouldThrowError {
            throw error
        }
        return messages
    }

    func sendMessage(conversationId: String, senderUserId: String, text: String) async throws -> Message {
        if let error = shouldThrowError {
            throw error
        }
        let message = Message(
            id: UUID().uuidString,
            conversationId: conversationId,
            senderUserId: senderUserId,
            text: text,
            createdAt: Date()
        )
        messages.append(message)
        return message
    }
}
