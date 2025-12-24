import SwiftUI

/// 共通のローディング表示コンポーネント
struct LoadingView: View {
    var message: String = "読み込み中..."

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)

            Text(message)
                .foregroundColor(App.Color.Text.Default.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(App.Color.Fill.Default.primaryStrong)
    }
}

#Preview {
    LoadingView()
}

#Preview("Custom Message") {
    LoadingView(message: "データを取得しています...")
}
