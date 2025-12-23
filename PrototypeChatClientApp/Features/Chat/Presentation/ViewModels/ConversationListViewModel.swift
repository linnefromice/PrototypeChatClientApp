import Foundation
import Combine

/// 会話一覧画面のViewModel
@MainActor
class ConversationListViewModel: ObservableObject {
    // MARK: - Properties
    private let conversationUseCase: ConversationUseCaseProtocol
    let currentUserId: String

    @Published var state: ConversationListViewState = .idle

    // Computed properties for backward compatibility
    var conversations: [ConversationDetail] { state.conversations }
    var isLoading: Bool { state.isLoading }
    var errorMessage: String? { state.errorMessage }
    var showError: Bool { state.showError }

    // MARK: - Initialization
    init(
        conversationUseCase: ConversationUseCaseProtocol,
        currentUserId: String
    ) {
        self.conversationUseCase = conversationUseCase
        self.currentUserId = currentUserId
    }

    // MARK: - Methods
    /// 会話一覧を読み込む
    func loadConversations() async {
        // Keep existing conversations during loading for better UX
        let currentConversations = state.conversations
        state = .loading

        do {
            let fetchedConversations = try await conversationUseCase.fetchConversations(userId: currentUserId)
            state = .loaded(fetchedConversations)
        } catch {
            // Check if the error is a cancellation error (URLError -999)
            if let urlError = error as? URLError, urlError.code == .cancelled {
                print("ℹ️ [ConversationListViewModel] loadConversations cancelled - This is normal during refresh")
                // Restore previous conversations on cancellation
                state = .loaded(currentConversations)
            } else if (error as NSError).code == NSURLErrorCancelled {
                print("ℹ️ [ConversationListViewModel] loadConversations cancelled - This is normal during refresh")
                // Restore previous conversations on cancellation
                state = .loaded(currentConversations)
            } else {
                let message = "会話一覧の取得に失敗しました: \(error.localizedDescription)"
                print("❌ [ConversationListViewModel] loadConversations failed - \(error)")
                state = .error(message, currentConversations)
            }
        }
    }

    /// 会話のタイトルを取得
    /// - Parameter conversation: 会話詳細
    /// - Returns: 表示用タイトル
    func conversationTitle(for detail: ConversationDetail) -> String {
        switch detail.type {
        case .group:
            return detail.conversation.name ?? "グループチャット"
        case .direct:
            // 1:1チャットの場合は相手の名前を表示
            let otherParticipant = detail.activeParticipants.first { $0.userId != currentUserId }
            return otherParticipant?.user.name ?? "チャット"
        }
    }

    /// 会話のサブタイトル（参加者数など）を取得
    /// - Parameter conversation: 会話詳細
    /// - Returns: 表示用サブタイトル
    func conversationSubtitle(for detail: ConversationDetail) -> String {
        let count = detail.activeParticipants.count
        return "\(count)人が参加中"
    }
}
