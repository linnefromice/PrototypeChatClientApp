import SwiftUI

/// 会話一覧画面
struct ConversationListView: View {
    @StateObject private var viewModel: ConversationListViewModel
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var showCreateConversation = false
    @State private var showMenu = false
    @State private var showLogoutConfirmation = false

    init(viewModel: ConversationListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    LoadingView(message: "会話を読み込み中...")
                } else if viewModel.showError, let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage) {
                        Task {
                            await viewModel.loadConversations()
                        }
                    }
                } else if viewModel.conversations.isEmpty {
                    EmptyStateView(
                        icon: "bubble.left.and.bubble.right",
                        title: "チャットがありません",
                        message: "右上の + ボタンから新しいチャットを作成できます"
                    )
                } else {
                    conversationList
                }
            }
            .navigationTitle("チャット")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                leading: Button(action: {
                    showMenu = true
                }) {
                    Image(systemName: "line.3.horizontal")
                        .imageScale(.large)
                }
                .accessibilityLabel("メニュー"),
                trailing: Button(action: {
                    showCreateConversation = true
                }) {
                    Image(systemName: "plus")
                }
            )
            .sheet(isPresented: $showCreateConversation) {
                CreateConversationView(
                    viewModel: makeCreateConversationViewModel(),
                    onConversationCreated: { _ in
                        Task {
                            await viewModel.loadConversations()
                        }
                    }
                )
            }
            .sheet(isPresented: $showMenu) {
                NavigationMenuView(onLogout: {
                    showLogoutConfirmation = true
                })
            }
            .alert("ログアウト", isPresented: $showLogoutConfirmation) {
                Button("キャンセル", role: .cancel) { }
                Button("ログアウト", role: .destructive) {
                    authViewModel.logout()
                }
            } message: {
                Text("ログアウトしますか？")
            }
            .task {
                await viewModel.loadConversations()
            }
        }
        .navigationViewStyle(.stack)
    }

    private var conversationList: some View {
        List(viewModel.conversations) { detail in
            NavigationLink {
                ChatRoomView(
                    viewModel: makeChatRoomViewModel(for: detail),
                    conversationDetail: detail
                )
            } label: {
                conversationRow(for: detail)
            }
        }
        .refreshable {
            await viewModel.loadConversations()
        }
    }

    private func conversationRow(for detail: ConversationDetail) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(viewModel.conversationTitle(for: detail))
                .appText(.headline)

            Text(viewModel.conversationSubtitle(for: detail))
                .appText(.caption2, color: App.Color.Text.Default.secondary)
        }
        .padding(.vertical, 4)
    }

    private func makeCreateConversationViewModel() -> CreateConversationViewModel {
        let container = DependencyContainer.shared
        return CreateConversationViewModel(
            conversationUseCase: container.conversationUseCase,
            userListUseCase: container.userListUseCase,
            currentUserId: viewModel.currentUserId
        )
    }

    private func makeChatRoomViewModel(for detail: ConversationDetail) -> ChatRoomViewModel {
        let container = DependencyContainer.shared
        return ChatRoomViewModel(
            messageUseCase: container.messageUseCase,
            reactionUseCase: container.reactionUseCase,
            conversationId: detail.id,
            currentUserId: viewModel.currentUserId
        )
    }
}

struct ConversationListView_Previews: PreviewProvider {
    static var previews: some View {
        let mockRepository = MockConversationRepository()
        mockRepository.conversations = [
            ConversationDetail(
                conversation: Conversation(
                    id: "1",
                    type: .direct,
                    name: nil,
                    createdAt: Date()
                ),
                participants: [
                    Participant(
                        id: "p1",
                        conversationId: "1",
                        userId: "user1",
                        role: .member,
                        user: User(id: "user1", idAlias: "alice", name: "Alice", avatarUrl: nil, createdAt: Date()),
                        joinedAt: Date(),
                        leftAt: nil
                    ),
                    Participant(
                        id: "p2",
                        conversationId: "1",
                        userId: "user2",
                        role: .member,
                        user: User(id: "user2", idAlias: "bob", name: "Bob", avatarUrl: nil, createdAt: Date()),
                        joinedAt: Date(),
                        leftAt: nil
                    )
                ]
            )
        ]

        let useCase = ConversationUseCase(conversationRepository: mockRepository)
        let viewModel = ConversationListViewModel(conversationUseCase: useCase, currentUserId: "user1")

        // Add mock auth view model
        let container = DependencyContainer.makePreviewContainer()
        let authViewModel = container.authenticationViewModel
        authViewModel.isAuthenticated = true
        let aliceUser = User(id: "user1", idAlias: "alice", name: "Alice", avatarUrl: nil, createdAt: Date())
        authViewModel.currentSession = AuthSession(
            authUserId: "auth-1",
            username: "alice",
            email: "alice@example.com",
            user: aliceUser,
            chatUser: aliceUser,
            authenticatedAt: Date()
        )

        return ConversationListView(viewModel: viewModel)
            .environmentObject(authViewModel)
    }
}
