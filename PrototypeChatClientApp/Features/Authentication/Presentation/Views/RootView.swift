import SwiftUI

struct RootView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var isValidatingSession = true

    var body: some View {
        Group {
            if isValidatingSession {
                // セッション検証中
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Text("認証情報を確認中...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else if authViewModel.isAuthenticated {
                // 認証済み: メイン画面へ
                MainView()
                    .transition(.opacity)
            } else {
                // 未認証: 認証画面表示
                AuthenticationView(viewModel: authViewModel)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: authViewModel.isAuthenticated)
        .task {
            await validateSession()
        }
    }

    private func validateSession() async {
        await authViewModel.checkAuthentication()
        isValidatingSession = false
    }
}

// MARK: - Preview
struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 未認証
            let unauthContainer = DependencyContainer.makePreviewContainer()
            RootView()
                .environmentObject(unauthContainer.authenticationViewModel)
                .environmentObject(unauthContainer)
                .previewDisplayName("未認証")

            // 認証済み
            let authContainer = DependencyContainer.makePreviewContainer()
            let authViewModel = authContainer.authenticationViewModel
            authViewModel.isAuthenticated = true
            authViewModel.currentSession = AuthSession(
                authUserId: "auth-1",
                username: "alice",
                email: "alice@example.com",
                user: User(id: "user-1", idAlias: "alice", name: "Alice", avatarUrl: nil, createdAt: Date()),
                authenticatedAt: Date()
            )

            return RootView()
                .environmentObject(authViewModel)
                .environmentObject(authContainer)
                .previewDisplayName("認証済み")
        }
    }
}
