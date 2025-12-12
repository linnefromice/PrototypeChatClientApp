import Foundation
import Combine

/// 会話一覧画面のViewModel
class ConversationListViewModel: ObservableObject {
    // MARK: - Properties
    private let conversationUseCase: ConversationUseCase
    private let currentUserId: String

    @Published var conversations: [ConversationDetail] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false

    // MARK: - Initialization
    init(
        conversationUseCase: ConversationUseCase,
        currentUserId: String
    ) {
        self.conversationUseCase = conversationUseCase
        self.currentUserId = currentUserId
    }

    // MARK: - Methods
    /// 会話一覧を読み込む
    @MainActor
    func loadConversations() async {
        isLoading = true
        errorMessage = nil
        showError = false

        do {
            conversations = try await conversationUseCase.fetchConversations(userId: currentUserId)
        } catch {
            errorMessage = "会話一覧の取得に失敗しました: \(error.localizedDescription)"
            showError = true
        }

        isLoading = false
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
