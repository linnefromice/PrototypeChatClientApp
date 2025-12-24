import SwiftUI

struct MessageBubbleView: View {
    let message: Message
    let isOwnMessage: Bool
    let senderName: String?
    let reactions: [ReactionSummary]?
    let currentUserId: String?
    let onReactionTap: ((String) -> Void)?
    let onAddReaction: ((String) -> Void)?

    @State private var showReactionPicker = false

    var body: some View {
        HStack {
            if isOwnMessage {
                Spacer()
            }

            VStack(alignment: isOwnMessage ? .trailing : .leading, spacing: 4) {
                if !isOwnMessage, let senderName = senderName {
                    Text(senderName)
                        .appText(.caption2, color: App.Color.Text.Default.secondary)
                }

                Text(message.text ?? "")
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(isOwnMessage ? App.Color.Brand.primary : App.Color.Fill.Default.secondary)
                    .foregroundColor(isOwnMessage ? App.Color.Text.Default.inversion : App.Color.Text.Default.primary)
                    .cornerRadius(16)
                    .onLongPressGesture {
                        if onAddReaction != nil {
                            showReactionPicker = true
                        }
                    }
                    .sheet(isPresented: $showReactionPicker) {
                        if let onAddReaction = onAddReaction {
                            VStack(spacing: 16) {
                                Text("リアクションを選択")
                                    .appText(.headline)
                                    .padding(.top)

                                ReactionPickerView(onSelect: { emoji in
                                    onAddReaction(emoji)
                                    showReactionPicker = false
                                })

                                Button("キャンセル") {
                                    showReactionPicker = false
                                }
                                .padding(.bottom)
                            }
                            .presentationDetents([.height(250)])
                        }
                    }

                if let reactions = reactions, !reactions.isEmpty,
                   let currentUserId = currentUserId,
                   let onReactionTap = onReactionTap {
                    ReactionSummaryView(
                        summaries: reactions,
                        currentUserId: currentUserId,
                        alignment: isOwnMessage ? .trailing : .leading,
                        onTap: onReactionTap
                    )
                }

                Text(formattedTime)
                    .appText(.caption2, color: App.Color.Text.Default.secondary)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: isOwnMessage ? .trailing : .leading)

            if !isOwnMessage {
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: message.createdAt)
    }
}

#Preview {
    VStack {
        MessageBubbleView(
            message: Message(
                id: "1",
                conversationId: "c1",
                senderUserId: "user-1",
                type: .text,
                text: "Hello from me!",
                createdAt: Date(),
                replyToMessageId: nil,
                systemEvent: nil
            ),
            isOwnMessage: true,
            senderName: nil,
            reactions: [
                ReactionSummary(emoji: "👍", count: 2, userIds: ["user-2", "user-3"]),
                ReactionSummary(emoji: "❤️", count: 1, userIds: ["user-2"])
            ],
            currentUserId: "user-1",
            onReactionTap: { emoji in print("Tapped: \(emoji)") },
            onAddReaction: { emoji in print("Added: \(emoji)") }
        )

        MessageBubbleView(
            message: Message(
                id: "2",
                conversationId: "c1",
                senderUserId: "user-2",
                type: .text,
                text: "Hello from Bob!",
                createdAt: Date(),
                replyToMessageId: nil,
                systemEvent: nil
            ),
            isOwnMessage: false,
            senderName: "Bob",
            reactions: [
                ReactionSummary(emoji: "😂", count: 1, userIds: ["user-1"])
            ],
            currentUserId: "user-1",
            onReactionTap: { emoji in print("Tapped: \(emoji)") },
            onAddReaction: { emoji in print("Added: \(emoji)") }
        )
    }
}
