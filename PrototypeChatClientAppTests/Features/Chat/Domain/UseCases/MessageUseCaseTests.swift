import XCTest
@testable import PrototypeChatClientApp

final class MessageUseCaseTests: XCTestCase {
    var sut: MessageUseCase!
    var mockRepository: MockMessageRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockMessageRepository()
        sut = MessageUseCase(messageRepository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - fetchMessages Tests

    func test_fetchMessages_returnsMessagesFromRepository() async throws {
        // Given
        let conversationId = "c1"
        let userId = "user1"
        let expectedMessages = MockData.sampleMessages
        mockRepository.messages = expectedMessages

        // When
        let result = try await sut.fetchMessages(
            conversationId: conversationId,
            userId: userId
        )

        // Then
        XCTAssertEqual(result.count, expectedMessages.count)
        XCTAssertEqual(result, expectedMessages)
    }

    func test_fetchMessages_usesDefaultLimit() async throws {
        // Given
        let conversationId = "conv-1"
        let userId = "user-1"

        // When
        _ = try await sut.fetchMessages(
            conversationId: conversationId,
            userId: userId
        )

        // Then
        XCTAssertEqual(mockRepository.lastFetchLimit, 50, "Default limit should be 50")
    }

    func test_fetchMessages_usesProvidedLimit() async throws {
        // Given
        let conversationId = "conv-1"
        let userId = "user-1"
        let customLimit = 20

        // When
        _ = try await sut.fetchMessages(
            conversationId: conversationId,
            userId: userId,
            limit: customLimit
        )

        // Then
        XCTAssertEqual(mockRepository.lastFetchLimit, customLimit)
    }

    func test_fetchMessages_passesCorrectParameters() async throws {
        // Given
        let conversationId = "conv-1"
        let userId = "user-1"
        let limit = 30

        // When
        _ = try await sut.fetchMessages(
            conversationId: conversationId,
            userId: userId,
            limit: limit
        )

        // Then
        XCTAssertEqual(mockRepository.lastFetchConversationId, conversationId)
        XCTAssertEqual(mockRepository.lastFetchUserId, userId)
        XCTAssertEqual(mockRepository.lastFetchLimit, limit)
    }

    func test_fetchMessages_throwsErrorWhenRepositoryFails() async throws {
        // Given
        let conversationId = "conv-1"
        let userId = "user-1"
        let expectedError = NSError(domain: "test", code: 1, userInfo: nil)
        mockRepository.shouldThrowError = expectedError

        // When/Then
        do {
            _ = try await sut.fetchMessages(
                conversationId: conversationId,
                userId: userId
            )
            XCTFail("Should have thrown error")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    // MARK: - sendMessage Tests

    func test_sendMessage_returnsMessageFromRepository() async throws {
        // Given
        let conversationId = "conv-1"
        let senderUserId = "user-1"
        let text = "Test message"
        let expectedMessage = Message(
            id: "new-msg",
            conversationId: conversationId,
            senderUserId: senderUserId,
            type: .text,
            text: text,
            createdAt: Date(),
            replyToMessageId: nil,
            systemEvent: nil
        )
        mockRepository.messageToReturn = expectedMessage

        // When
        let result = try await sut.sendMessage(
            conversationId: conversationId,
            senderUserId: senderUserId,
            text: text
        )

        // Then
        XCTAssertEqual(result.id, expectedMessage.id)
        XCTAssertEqual(result.text, text)
        XCTAssertEqual(result.senderUserId, senderUserId)
    }

    func test_sendMessage_passesCorrectParameters() async throws {
        // Given
        let conversationId = "conv-1"
        let senderUserId = "user-1"
        let text = "Test message"

        // When
        _ = try await sut.sendMessage(
            conversationId: conversationId,
            senderUserId: senderUserId,
            text: text
        )

        // Then
        XCTAssertEqual(mockRepository.lastSentConversationId, conversationId)
        XCTAssertEqual(mockRepository.lastSentSenderUserId, senderUserId)
        XCTAssertEqual(mockRepository.lastSentText, text)
    }

    func test_sendMessage_throwsErrorForEmptyText() async throws {
        // Given
        let conversationId = "conv-1"
        let senderUserId = "user-1"
        let emptyText = ""

        // When/Then
        do {
            _ = try await sut.sendMessage(
                conversationId: conversationId,
                senderUserId: senderUserId,
                text: emptyText
            )
            XCTFail("Should have thrown MessageError.emptyMessage")
        } catch let error as MessageError {
            XCTAssertEqual(error, MessageError.emptyMessage)
        } catch {
            XCTFail("Should have thrown MessageError.emptyMessage, but got \(error)")
        }
    }

    func test_sendMessage_throwsErrorForWhitespaceOnlyText() async throws {
        // Given
        let conversationId = "conv-1"
        let senderUserId = "user-1"
        let whitespaceText = "   \n\t  "

        // When/Then
        do {
            _ = try await sut.sendMessage(
                conversationId: conversationId,
                senderUserId: senderUserId,
                text: whitespaceText
            )
            XCTFail("Should have thrown MessageError.emptyMessage")
        } catch let error as MessageError {
            XCTAssertEqual(error, MessageError.emptyMessage)
        } catch {
            XCTFail("Should have thrown MessageError.emptyMessage, but got \(error)")
        }
    }

    func test_sendMessage_acceptsTextWithLeadingAndTrailingWhitespace() async throws {
        // Given
        let conversationId = "conv-1"
        let senderUserId = "user-1"
        let text = "  Valid message  "
        let expectedMessage = Message(
            id: "new-msg",
            conversationId: conversationId,
            senderUserId: senderUserId,
            type: .text,
            text: text,
            createdAt: Date(),
            replyToMessageId: nil,
            systemEvent: nil
        )
        mockRepository.messageToReturn = expectedMessage

        // When
        let result = try await sut.sendMessage(
            conversationId: conversationId,
            senderUserId: senderUserId,
            text: text
        )

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result.text, text)
    }

    func test_sendMessage_throwsErrorWhenRepositoryFails() async throws {
        // Given
        let conversationId = "conv-1"
        let senderUserId = "user-1"
        let text = "Test message"
        let expectedError = NSError(domain: "test", code: 1, userInfo: nil)
        mockRepository.shouldThrowError = expectedError

        // When/Then
        do {
            _ = try await sut.sendMessage(
                conversationId: conversationId,
                senderUserId: senderUserId,
                text: text
            )
            XCTFail("Should have thrown error")
        } catch {
            XCTAssertNotNil(error)
        }
    }
}
