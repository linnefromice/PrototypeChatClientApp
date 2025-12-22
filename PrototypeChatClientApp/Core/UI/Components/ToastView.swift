import SwiftUI

/// Toast notification view for brief success/info messages
struct ToastView: View {
    let message: String
    let icon: String?
    let type: ToastType

    enum ToastType {
        case success
        case info
        case warning

        var color: Color {
            switch self {
            case .success: return .green
            case .info: return .blue
            case .warning: return .orange
            }
        }

        var defaultIcon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .info: return "info.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            }
        }
    }

    init(message: String, icon: String? = nil, type: ToastType = .success) {
        self.message = message
        self.icon = icon
        self.type = type
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon ?? type.defaultIcon)
                .foregroundColor(type.color)
                .imageScale(.medium)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.primary)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 16)
    }
}

struct ToastView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ToastView(message: "メッセージを送信しました", type: .success)
            ToastView(message: "リアクションを追加しました", type: .info)
            ToastView(message: "接続が不安定です", type: .warning)
            ToastView(message: "会話を作成しました", icon: "bubble.left.and.bubble.right.fill", type: .success)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
