import Foundation
import Combine

@MainActor
class ChatRoomViewModel: ObservableObject {
    // MARK: - Properties
    private let messageUseCase: MessageUseCase
    private let conversationId: String
    let currentUserId: String

    @Published var messages: [Message] = []
    @Published var messageText: String = ""
    @Published var isLoading: Bool = false
    @Published var isSending: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false

    // MARK: - Initialization
    init(
        messageUseCase: MessageUseCase,
        conversationId: String,
        currentUserId: String
    ) {
        self.messageUseCase = messageUseCase
        self.conversationId = conversationId
        self.currentUserId = currentUserId
    }

    // MARK: - Methods
    func loadMessages() async {
        isLoading = true
        errorMessage = nil
        showError = false

        do {
            messages = try await messageUseCase.fetchMessages(
                conversationId: conversationId,
                userId: currentUserId,
                limit: 50
            )
        } catch {
            if let urlError = error as? URLError, urlError.code == .cancelled {
                print("ℹ️ [ChatRoomViewModel] loadMessages cancelled")
            } else if (error as NSError).code == NSURLErrorCancelled {
                print("ℹ️ [ChatRoomViewModel] loadMessages cancelled")
            } else {
                let message = "メッセージの取得に失敗しました: \(error.localizedDescription)"
                print("❌ [ChatRoomViewModel] loadMessages failed - \(error)")
                errorMessage = message
                showError = true
            }
        }

        isLoading = false
    }

    func sendMessage() async {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        let textToSend = messageText
        messageText = "" // Clear immediately for better UX

        isSending = true
        errorMessage = nil
        showError = false

        do {
            let newMessage = try await messageUseCase.sendMessage(
                conversationId: conversationId,
                senderUserId: currentUserId,
                text: textToSend
            )

            // Add to local messages array
            messages.append(newMessage)
        } catch {
            let message = "メッセージの送信に失敗しました: \(error.localizedDescription)"
            print("❌ [ChatRoomViewModel] sendMessage failed - \(error)")
            errorMessage = message
            showError = true

            // Restore text on error
            messageText = textToSend
        }

        isSending = false
    }

    var canSendMessage: Bool {
        !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSending
    }

    func isOwnMessage(_ message: Message) -> Bool {
        message.senderUserId == currentUserId
    }
}
