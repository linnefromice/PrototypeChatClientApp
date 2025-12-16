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
                    ProgressView("読み込み中...")
                } else if viewModel.conversations.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("チャットがありません")
                            .font(.headline)
                        Text("右上の + ボタンから新しいチャットを作成できます")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
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
            .alert(isPresented: $viewModel.showError) {
                Alert(
                    title: Text("エラー"),
                    message: Text(viewModel.errorMessage ?? "不明なエラー"),
                    dismissButton: .default(Text("OK"))
                )
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
                .font(.headline)

            Text(viewModel.conversationSubtitle(for: detail))
                .font(.caption)
                .foregroundStyle(.secondary)
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
                        user: User(id: "user1", name: "Alice", avatarUrl: nil, createdAt: Date()),
                        joinedAt: Date(),
                        leftAt: nil
                    ),
                    Participant(
                        id: "p2",
                        conversationId: "1",
                        userId: "user2",
                        role: .member,
                        user: User(id: "user2", name: "Bob", avatarUrl: nil, createdAt: Date()),
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
        authViewModel.currentSession = AuthSession(
            userId: "user1",
            user: User(id: "user1", name: "Alice", avatarUrl: nil, createdAt: Date()),
            authenticatedAt: Date()
        )

        return ConversationListView(viewModel: viewModel)
            .environmentObject(authViewModel)
    }
}
