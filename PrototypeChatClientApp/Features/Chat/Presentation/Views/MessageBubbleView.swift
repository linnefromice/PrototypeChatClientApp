import SwiftUI

struct MessageBubbleView: View {
    let message: Message
    let isOwnMessage: Bool
    let senderName: String?

    var body: some View {
        HStack {
            if isOwnMessage {
                Spacer()
            }

            VStack(alignment: isOwnMessage ? .trailing : .leading, spacing: 4) {
                if !isOwnMessage, let senderName = senderName {
                    Text(senderName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text(message.text ?? "")
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(isOwnMessage ? Color.blue : Color(.systemGray5))
                    .foregroundColor(isOwnMessage ? .white : .primary)
                    .cornerRadius(16)

                Text(formattedTime)
                    .font(.caption2)
                    .foregroundColor(.secondary)
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
            senderName: nil
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
            senderName: "Bob"
        )
    }
}
