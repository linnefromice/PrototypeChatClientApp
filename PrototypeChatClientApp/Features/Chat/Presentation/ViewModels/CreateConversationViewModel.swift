import Foundation
import Combine

/// チャット作成画面のViewModel
@MainActor
class CreateConversationViewModel: ObservableObject {
    // MARK: - Properties
    private let conversationUseCase: ConversationUseCaseProtocol
    private let userListUseCase: UserListUseCaseProtocol
    private let currentUserId: String
    let toastManager = ToastManager()

    @Published var state: CreateConversationViewState = .idle
    @Published var conversationType: ConversationType = .direct
    @Published var selectedUserId: String?
    @Published var selectedUserIds: Set<String> = []
    @Published var groupName: String = ""

    // Computed properties for backward compatibility
    var availableUsers: [User] { state.availableUsers }
    var isLoading: Bool { state.isLoading }
    var errorMessage: String? { state.errorMessage }
    var showError: Bool { state.showError }
    var createdConversation: ConversationDetail? { state.createdConversation }

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
    func loadAvailableUsers() async {
        state = .loadingUsers

        do {
            let users = try await userListUseCase.fetchAvailableUsers(excludingUserId: currentUserId)
            state = .usersLoaded(users)
        } catch {
            // Check if the error is a cancellation error (URLError -999)
            if let urlError = error as? URLError, urlError.code == .cancelled {
                print("ℹ️ [CreateConversationViewModel] loadAvailableUsers cancelled")
                // Don't change state for cancellation
            } else if (error as NSError).code == NSURLErrorCancelled {
                print("ℹ️ [CreateConversationViewModel] loadAvailableUsers cancelled")
                // Don't change state for cancellation
            } else {
                let message = "ユーザー一覧の取得に失敗しました: \(error.localizedDescription)"
                print("❌ [CreateConversationViewModel] loadAvailableUsers failed - \(error)")
                state = .error(message)
            }
        }
    }

    /// 1:1チャットを作成
    func createDirectConversation() async {
        guard let targetUserId = selectedUserId else {
            state = .error("ユーザーを選択してください")
            return
        }

        state = .creatingConversation

        do {
            let conversation = try await conversationUseCase.createDirectConversation(
                currentUserId: currentUserId,
                targetUserId: targetUserId
            )

            state = .conversationCreated(conversation)

            // Show success feedback
            toastManager.showSuccess("チャットを作成しました", icon: "bubble.left.and.bubble.right.fill")
        } catch {
            // Check if the error is a cancellation error (URLError -999)
            if let urlError = error as? URLError, urlError.code == .cancelled {
                print("ℹ️ [CreateConversationViewModel] createDirectConversation cancelled")
                // Don't change state for cancellation
            } else if (error as NSError).code == NSURLErrorCancelled {
                print("ℹ️ [CreateConversationViewModel] createDirectConversation cancelled")
                // Don't change state for cancellation
            } else {
                let message = "チャットの作成に失敗しました: \(error.localizedDescription)"
                print("❌ [CreateConversationViewModel] createDirectConversation failed - \(error)")
                state = .error(message)
            }
        }
    }

    /// グループチャットを作成
    func createGroupConversation() async {
        guard !groupName.trimmingCharacters(in: .whitespaces).isEmpty else {
            state = .error("グループ名を入力してください")
            return
        }

        guard selectedUserIds.count >= 2 else {
            state = .error("参加者を2人以上選択してください")
            return
        }

        state = .creatingConversation

        do {
            let conversation = try await conversationUseCase.createGroupConversation(
                currentUserId: currentUserId,
                participantUserIds: Array(selectedUserIds),
                groupName: groupName.trimmingCharacters(in: .whitespaces)
            )

            state = .conversationCreated(conversation)

            // Show success feedback
            toastManager.showSuccess("グループチャットを作成しました", icon: "person.3.fill")
        } catch {
            // Check if the error is a cancellation error (URLError -999)
            if let urlError = error as? URLError, urlError.code == .cancelled {
                print("ℹ️ [CreateConversationViewModel] createGroupConversation cancelled")
                // Don't change state for cancellation
            } else if (error as NSError).code == NSURLErrorCancelled {
                print("ℹ️ [CreateConversationViewModel] createGroupConversation cancelled")
                // Don't change state for cancellation
            } else {
                let message = "グループチャットの作成に失敗しました: \(error.localizedDescription)"
                print("❌ [CreateConversationViewModel] createGroupConversation failed - \(error)")
                state = .error(message)
            }
        }
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
