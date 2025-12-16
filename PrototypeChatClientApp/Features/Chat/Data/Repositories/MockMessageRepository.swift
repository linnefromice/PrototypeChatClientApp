import Foundation

class MockMessageRepository: MessageRepositoryProtocol {
    var messages: [Message] = []

    // Test helper properties
    var shouldThrowError: Error?
    var messageToReturn: Message?

    // Track method calls for testing
    var lastFetchConversationId: String?
    var lastFetchUserId: String?
    var lastFetchLimit: Int?

    var lastSentConversationId: String?
    var lastSentSenderUserId: String?
    var lastSentText: String?

    init() {
        // Pre-populate with sample messages
        let now = Date()
        messages = [
            Message(
                id: "msg-1",
                conversationId: "conv-1",
                senderUserId: "user-1",
                type: .text,
                text: "Hello!",
                createdAt: now.addingTimeInterval(-3600),
                replyToMessageId: nil,
                systemEvent: nil
            ),
            Message(
                id: "msg-2",
                conversationId: "conv-1",
                senderUserId: "user-2",
                type: .text,
                text: "Hi there!",
                createdAt: now.addingTimeInterval(-1800),
                replyToMessageId: nil,
                systemEvent: nil
            )
        ]
    }

    func fetchMessages(conversationId: String, userId: String, limit: Int) async throws -> [Message] {
        // Track method call for testing
        lastFetchConversationId = conversationId
        lastFetchUserId = userId
        lastFetchLimit = limit

        // Throw error if configured for testing
        if let error = shouldThrowError {
            throw error
        }

        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        return messages
            .filter { $0.conversationId == conversationId }
            .sorted { $0.createdAt < $1.createdAt }
            .prefix(limit)
            .map { $0 }
    }

    func sendMessage(conversationId: String, senderUserId: String, text: String) async throws -> Message {
        // Track method call for testing
        lastSentConversationId = conversationId
        lastSentSenderUserId = senderUserId
        lastSentText = text

        // Throw error if configured for testing
        if let error = shouldThrowError {
            throw error
        }

        // Return pre-configured message if set (for testing)
        if let message = messageToReturn {
            messages.append(message)
            return message
        }

        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds

        let newMessage = Message(
            id: UUID().uuidString,
            conversationId: conversationId,
            senderUserId: senderUserId,
            type: .text,
            text: text,
            createdAt: Date(),
            replyToMessageId: nil,
            systemEvent: nil
        )

        messages.append(newMessage)
        return newMessage
    }
}
