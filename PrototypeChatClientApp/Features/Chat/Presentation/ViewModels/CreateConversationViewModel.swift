import Foundation
import Combine

/// チャット作成画面のViewModel
class CreateConversationViewModel: ObservableObject {
    // MARK: - Properties
    private let conversationUseCase: ConversationUseCaseProtocol
    private let userListUseCase: UserListUseCaseProtocol
    private let currentUserId: String

    @Published var availableUsers: [User] = []
    @Published var conversationType: ConversationType = .direct
    @Published var selectedUserId: String?
    @Published var selectedUserIds: Set<String> = []
    @Published var groupName: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    @Published var createdConversation: ConversationDetail?

    // MARK: - Initialization
    init(
        conversationUseCase: ConversationUseCaseProtocol,
        userListUseCase: UserListUseCaseProtocol,
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

    /// グループチャットを作成
    @MainActor
    func createGroupConversation() async {
        guard !groupName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "グループ名を入力してください"
            showError = true
            return
        }

        guard selectedUserIds.count >= 2 else {
            errorMessage = "参加者を2人以上選択してください"
            showError = true
            return
        }

        isLoading = true
        errorMessage = nil
        showError = false

        do {
            createdConversation = try await conversationUseCase.createGroupConversation(
                currentUserId: currentUserId,
                participantUserIds: Array(selectedUserIds),
                groupName: groupName.trimmingCharacters(in: .whitespaces)
            )
        } catch {
            // Check if the error is a cancellation error (URLError -999)
            if let urlError = error as? URLError, urlError.code == .cancelled {
                print("ℹ️ [CreateConversationViewModel] createGroupConversation cancelled")
                // Don't show error to user for cancellation
            } else if (error as NSError).code == NSURLErrorCancelled {
                print("ℹ️ [CreateConversationViewModel] createGroupConversation cancelled")
                // Don't show error to user for cancellation
            } else {
                let message = "グループチャットの作成に失敗しました: \(error.localizedDescription)"
                print("❌ [CreateConversationViewModel] createGroupConversation failed - \(error)")
                errorMessage = message
                showError = true
            }
        }

        isLoading = false
    }

    /// ユーザー選択を切り替え（グループモード用）
    func toggleUserSelection(_ userId: String) {
        if selectedUserIds.contains(userId) {
            selectedUserIds.remove(userId)
        } else {
            selectedUserIds.insert(userId)
        }
    }

    /// 作成ボタンが有効かどうか
    var canCreate: Bool {
        if isLoading {
            return false
        }

        switch conversationType {
        case .direct:
            return selectedUserId != nil
        case .group:
            return selectedUserIds.count >= 2
                && !groupName.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }
}
