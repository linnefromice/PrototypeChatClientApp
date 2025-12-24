import SwiftUI

struct MessageInputView: View {
    @Binding var messageText: String
    let canSend: Bool
    let isSending: Bool
    let onSend: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            TextField("メッセージを入力", text: $messageText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...5)
                .accessibilityLabel("メッセージを入力")

            Button(action: onSend) {
                if isSending {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Image(systemName: "paperplane.fill")
                }
            }
            .disabled(!canSend)
            .foregroundColor(canSend ? App.Color.Brand.primary : App.Color.Icon.Default.disable)
            .accessibilityLabel("送信")
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(App.Color.Fill.Default.primaryStrong)
    }
}

#Preview {
    VStack {
        Spacer()
        MessageInputView(
            messageText: .constant(""),
            canSend: false,
            isSending: false,
            onSend: {}
        )
        MessageInputView(
            messageText: .constant("Hello"),
            canSend: true,
            isSending: false,
            onSend: {}
        )
        MessageInputView(
            messageText: .constant("Sending..."),
            canSend: false,
            isSending: true,
            onSend: {}
        )
    }
}
