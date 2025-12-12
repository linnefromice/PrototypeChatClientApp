import SwiftUI

/// チャット作成画面
struct CreateConversationView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CreateConversationViewModel

    var onConversationCreated: ((ConversationDetail) -> Void)?

    init(
        viewModel: CreateConversationViewModel,
        onConversationCreated: ((ConversationDetail) -> Void)? = nil
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onConversationCreated = onConversationCreated
    }

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("読み込み中...")
                } else if viewModel.availableUsers.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.3")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("ユーザーが見つかりません")
                            .font(.headline)
                        Text("チャットを開始できるユーザーがいません")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    userList
                }
            }
            .navigationTitle("新しいチャット")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("キャンセル") {
                    dismiss()
                },
                trailing: Button("作成") {
                    Task {
                        await createConversation()
                    }
                }
                .disabled(!viewModel.canCreate)
            )
            .alert(isPresented: $viewModel.showError) {
                Alert(
                    title: Text("エラー"),
                    message: Text(viewModel.errorMessage ?? "不明なエラー"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .task {
                await viewModel.loadAvailableUsers()
            }
            .onChange(of: viewModel.createdConversation) { newValue in
                if let conversation = newValue {
                    onConversationCreated?(conversation)
                    dismiss()
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    private var userList: some View {
        List(viewModel.availableUsers) { user in
            Button {
                viewModel.selectedUserId = user.id
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.name)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text("ID: \(user.id)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if viewModel.selectedUserId == user.id {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.blue)
                    }
                }
            }
        }
    }

    private func createConversation() async {
        await viewModel.createDirectConversation()
    }
}

struct CreateConversationView_Previews: PreviewProvider {
    static var previews: some View {
        let mockConversationRepo = MockConversationRepository()
        let mockUserRepo = MockUserRepository()

        let conversationUseCase = ConversationUseCase(conversationRepository: mockConversationRepo)
        let userListUseCase = UserListUseCase(userRepository: mockUserRepo)
        let viewModel = CreateConversationViewModel(
            conversationUseCase: conversationUseCase,
            userListUseCase: userListUseCase,
            currentUserId: "user-1"
        )

        return CreateConversationView(viewModel: viewModel)
    }
}
