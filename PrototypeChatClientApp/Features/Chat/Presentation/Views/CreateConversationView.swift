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
            VStack(spacing: 0) {
                // Mode selector
                Picker("タイプ", selection: $viewModel.conversationType) {
                    Text("ダイレクト").tag(ConversationType.direct)
                    Text("グループ").tag(ConversationType.group)
                }
                .pickerStyle(.segmented)
                .padding()

                // Group name input and selection count (only for group mode)
                if viewModel.conversationType == .group {
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("グループ名を入力", text: $viewModel.groupName)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)

                        if !viewModel.selectedUserIds.isEmpty {
                            Text("\(viewModel.selectedUserIds.count)人選択中")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 8)
                }

                Divider()

                // User list
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
                switch viewModel.conversationType {
                case .direct:
                    viewModel.selectedUserId = user.id
                case .group:
                    viewModel.toggleUserSelection(user.id)
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.name)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text("@\(user.idAlias)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    // Selection indicator
                    switch viewModel.conversationType {
                    case .direct:
                        if viewModel.selectedUserId == user.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.blue)
                        }
                    case .group:
                        if viewModel.selectedUserIds.contains(user.id) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.blue)
                        } else {
                            Image(systemName: "circle")
                                .foregroundStyle(.gray)
                        }
                    }
                }
            }
        }
    }

    private func createConversation() async {
        switch viewModel.conversationType {
        case .direct:
            await viewModel.createDirectConversation()
        case .group:
            await viewModel.createGroupConversation()
        }
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
