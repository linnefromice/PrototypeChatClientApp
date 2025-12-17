import Foundation
import Combine

@MainActor
class ChatRoomViewModel: ObservableObject {
    // MARK: - Properties
    private let messageUseCase: MessageUseCase
    private let reactionUseCase: ReactionUseCase
    private let conversationId: String
    let currentUserId: String

    @Published var messages: [Message] = []
    @Published var messageText: String = ""
    @Published var isLoading: Bool = false
    @Published var isSending: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    @Published var messageReactions: [String: [Reaction]] = [:]

    // MARK: - Initialization
    init(
        messageUseCase: MessageUseCase,
        reactionUseCase: ReactionUseCase,
        conversationId: String,
        currentUserId: String
    ) {
        self.messageUseCase = messageUseCase
        self.reactionUseCase = reactionUseCase
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

    // MARK: - Reaction Methods
    func addReaction(to messageId: String, emoji: String) async {
        do {
            let reaction = try await reactionUseCase.addReaction(
                messageId: messageId,
                userId: currentUserId,
                emoji: emoji
            )

            // Update local state
            messageReactions[messageId, default: []].append(reaction)
        } catch {
            let message = "リアクションを追加できませんでした: \(error.localizedDescription)"
            print("❌ [ChatRoomViewModel] addReaction failed - \(error)")
            errorMessage = message
            showError = true
        }
    }

    func removeReaction(from messageId: String, emoji: String) async {
        do {
            try await reactionUseCase.removeReaction(
                messageId: messageId,
                userId: currentUserId,
                emoji: emoji
            )

            // Update local state
            messageReactions[messageId]?.removeAll { reaction in
                reaction.userId == currentUserId && reaction.emoji == emoji
            }
        } catch {
            let message = "リアクションを削除できませんでした: \(error.localizedDescription)"
            print("❌ [ChatRoomViewModel] removeReaction failed - \(error)")
            errorMessage = message
            showError = true
        }
    }

    func toggleReaction(on messageId: String, emoji: String) async {
        // Check if user has already reacted with this emoji
        let hasReacted = messageReactions[messageId]?.contains { reaction in
            reaction.userId == currentUserId && reaction.emoji == emoji
        } ?? false

        if hasReacted {
            await removeReaction(from: messageId, emoji: emoji)
        } else {
            await addReaction(to: messageId, emoji: emoji)
        }
    }

    func reactionSummaries(for messageId: String) -> [ReactionSummary] {
        let reactions = messageReactions[messageId] ?? []
        return reactionUseCase.computeSummaries(
            reactions: reactions,
            currentUserId: currentUserId
        )
    }
}
