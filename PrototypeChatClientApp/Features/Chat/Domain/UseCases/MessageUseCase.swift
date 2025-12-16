import Foundation

protocol MessageRepositoryProtocol {
    func fetchMessages(conversationId: String, userId: String, limit: Int) async throws -> [Message]
    func sendMessage(conversationId: String, senderUserId: String, text: String) async throws -> Message
}

class MessageUseCase {
    private let messageRepository: MessageRepositoryProtocol

    init(messageRepository: MessageRepositoryProtocol) {
        self.messageRepository = messageRepository
    }

    func fetchMessages(conversationId: String, userId: String, limit: Int = 50) async throws -> [Message] {
        return try await messageRepository.fetchMessages(
            conversationId: conversationId,
            userId: userId,
            limit: limit
        )
    }

    func sendMessage(conversationId: String, senderUserId: String, text: String) async throws -> Message {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw MessageError.emptyMessage
        }

        return try await messageRepository.sendMessage(
            conversationId: conversationId,
            senderUserId: senderUserId,
            text: text
        )
    }
}

enum MessageError: Error {
    case emptyMessage
}
