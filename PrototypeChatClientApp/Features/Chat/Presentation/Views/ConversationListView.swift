import SwiftUI

/// 会話一覧画面
struct ConversationListView: View {
    @StateObject private var viewModel: ConversationListViewModel
    @State private var showCreateConversation = false

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
            .navigationBarItems(trailing:
                Button(action: {
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
            .alert(isPresented: $viewModel.showError) {
                Alert(
                    title: Text("エラー"),
                    message: Text(viewModel.errorMessage ?? "不明なエラー"),
                    dismissButton: .default(Text("OK"))
                )
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
                // チャット詳細画面は後で実装
                Text("チャット詳細画面（未実装）")
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

        return ConversationListView(viewModel: viewModel)
    }
}
