import SwiftUI

struct MainView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // ユーザー情報表示
                if let session = authViewModel.currentSession {
                    VStack(spacing: 8) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)

                        Text(session.user.name)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("User ID: \(session.userId)")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("認証日時: \(session.authenticatedAt.formatted())")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }

                Spacer()

                // プレースホルダーメッセージ
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)

                    Text("認証成功")
                        .font(.title3)
                        .fontWeight(.semibold)

                    Text("チャット機能は今後実装予定です")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()

                Spacer()

                // ログアウトボタン
                Button(role: .destructive) {
                    authViewModel.logout()
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("ログアウト")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(10)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
            .navigationTitle("ホーム")
        }
    }
}

// MARK: - Preview
#Preview {
    MainViewPreview()
}

private struct MainViewPreview: View {
    @StateObject private var container = DependencyContainer.makePreviewContainer()

    var body: some View {
        let viewModel = container.authenticationViewModel
        viewModel.isAuthenticated = true
        viewModel.currentSession = AuthSession(
            userId: "user-1",
            user: User(id: "user-1", name: "Alice", avatarUrl: nil, createdAt: Date()),
            authenticatedAt: Date()
        )

        return MainView()
            .environmentObject(viewModel)
    }
}
