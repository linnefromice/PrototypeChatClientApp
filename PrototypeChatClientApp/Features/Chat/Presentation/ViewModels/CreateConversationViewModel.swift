import Foundation
import Combine

/// チャット作成画面のViewModel
class CreateConversationViewModel: ObservableObject {
    // MARK: - Properties
    private let conversationUseCase: ConversationUseCase
    private let userListUseCase: UserListUseCase
    private let currentUserId: String

    @Published var availableUsers: [User] = []
    @Published var selectedUserId: String?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    @Published var createdConversation: ConversationDetail?

    // MARK: - Initialization
    init(
        conversationUseCase: ConversationUseCase,
        userListUseCase: UserListUseCase,
        currentUserId: String
    ) {
        self.conversationUseCase = conversationUseCase
        self.userListUseCase = userListUseCase
        self.currentUserId = currentUserId
    }

    // MARK: - Methods
    /// 選択可能なユーザー一覧を読み込む
    @MainActor
    func loadAvailableUsers() async {
        isLoading = true
        errorMessage = nil
        showError = false

        do {
            availableUsers = try await userListUseCase.fetchAvailableUsers(excludingUserId: currentUserId)
        } catch {
            // Check if the error is a cancellation error (URLError -999)
            if let urlError = error as? URLError, urlError.code == .cancelled {
                print("ℹ️ [CreateConversationViewModel] loadAvailableUsers cancelled")
                // Don't show error to user for cancellation
            } else if (error as NSError).code == NSURLErrorCancelled {
                print("ℹ️ [CreateConversationViewModel] loadAvailableUsers cancelled")
                // Don't show error to user for cancellation
            } else {
                let message = "ユーザー一覧の取得に失敗しました: \(error.localizedDescription)"
                print("❌ [CreateConversationViewModel] loadAvailableUsers failed - \(error)")
                errorMessage = message
                showError = true
            }
        }

        isLoading = false
    }

    /// 1:1チャットを作成
    @MainActor
    func createDirectConversation() async {
        guard let targetUserId = selectedUserId else {
            errorMessage = "ユーザーを選択してください"
            showError = true
            return
        }

        isLoading = true
        errorMessage = nil
        showError = false

        do {
            createdConversation = try await conversationUseCase.createDirectConversation(
                currentUserId: currentUserId,
                targetUserId: targetUserId
            )
        } catch {
            // Check if the error is a cancellation error (URLError -999)
            if let urlError = error as? URLError, urlError.code == .cancelled {
                print("ℹ️ [CreateConversationViewModel] createDirectConversation cancelled")
                // Don't show error to user for cancellation
            } else if (error as NSError).code == NSURLErrorCancelled {
                print("ℹ️ [CreateConversationViewModel] createDirectConversation cancelled")
                // Don't show error to user for cancellation
            } else {
                let message = "チャットの作成に失敗しました: \(error.localizedDescription)"
                print("❌ [CreateConversationViewModel] createDirectConversation failed - \(error)")
                errorMessage = message
                showError = true
            }
        }

        isLoading = false
    }

    /// 作成ボタンが有効かどうか
    var canCreate: Bool {
        selectedUserId != nil && !isLoading
    }
}
