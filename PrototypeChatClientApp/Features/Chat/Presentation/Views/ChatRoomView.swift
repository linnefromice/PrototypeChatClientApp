import SwiftUI

struct ChatRoomView: View {
    @StateObject private var viewModel: ChatRoomViewModel
    let conversationDetail: ConversationDetail

    init(
        viewModel: ChatRoomViewModel,
        conversationDetail: ConversationDetail
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.conversationDetail = conversationDetail
    }

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading && viewModel.messages.isEmpty {
                loadingView
            } else if viewModel.messages.isEmpty {
                emptyStateView
            } else {
                messageListView
            }

            Divider()

            MessageInputView(
                messageText: $viewModel.messageText,
                canSend: viewModel.canSendMessage,
                isSending: viewModel.isSending,
                onSend: {
                    Task {
                        await viewModel.sendMessage()
                    }
                }
            )
        }
        .navigationTitle(conversationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $viewModel.showError) {
            Alert(
                title: Text("エラー"),
                message: Text(viewModel.errorMessage ?? "不明なエラー"),
                dismissButton: .default(Text("OK"))
            )
        }
        .task {
            await viewModel.loadMessages()
        }
    }

    private var messageListView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.messages) { message in
                        MessageBubbleView(
                            message: message,
                            isOwnMessage: viewModel.isOwnMessage(message),
                            senderName: senderName(for: message)
                        )
                        .id(message.id)
                    }
                }
                .padding(.vertical, 8)
            }
            .refreshable {
                await viewModel.loadMessages()
            }
            .onChange(of: viewModel.messages.count) { _ in
                // Auto-scroll to bottom when new message is added
                if let lastMessage = viewModel.messages.last {
                    withAnimation {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            .onAppear {
                // Scroll to bottom on initial load
                if let lastMessage = viewModel.messages.last {
                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
                Image(systemName: "bubble.left.and.bubble.right")
                    .font(.system(size: 48))
                    .foregroundColor(.gray)
                Text("まだメッセージがありません")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .frame(maxHeight: .infinity)
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
                ProgressView()
                Text("読み込み中...")
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .frame(maxHeight: .infinity)
    }

    private var conversationTitle: String {
        switch conversationDetail.type {
        case .group:
            return conversationDetail.conversation.name ?? "グループチャット"
        case .direct:
            let otherParticipant = conversationDetail.activeParticipants.first {
                $0.userId != viewModel.currentUserId
            }
            return otherParticipant?.user.name ?? "チャット"
        }
    }

    private func senderName(for message: Message) -> String? {
        guard !viewModel.isOwnMessage(message) else { return nil }

        let participant = conversationDetail.activeParticipants.first {
            $0.userId == message.senderUserId
        }
        return participant?.user.name
    }
}
