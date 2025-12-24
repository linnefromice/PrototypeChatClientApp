import SwiftUI

struct RootView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject private var colorSchemeManager = ColorSchemeManager.shared
    @State private var isValidatingSession = true

    var body: some View {
        Group {
            if isValidatingSession {
                // セッション検証中
                LoadingView(message: "認証情報を確認中...")
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
        .preferredColorScheme(colorSchemeManager.preference.colorScheme)
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
            unauthenticatedPreview

            // 認証済み
            authenticatedPreview
        }
    }

    static var unauthenticatedPreview: some View {
        let container = DependencyContainer.makePreviewContainer()
        return RootView()
            .environmentObject(container.authenticationViewModel)
            .environmentObject(container)
            .previewDisplayName("未認証")
    }

    static var authenticatedPreview: some View {
        let container = DependencyContainer.makePreviewContainer()
        let authViewModel = container.authenticationViewModel
        let aliceUser = User(id: "user-1", idAlias: "alice", name: "Alice", avatarUrl: nil, createdAt: Date())
        authViewModel.isAuthenticated = true
        authViewModel.currentSession = AuthSession(
            authUserId: "auth-1",
            username: "alice",
            email: "alice@example.com",
            user: aliceUser,
            chatUser: aliceUser,
            authenticatedAt: Date()
        )

        return RootView()
            .environmentObject(authViewModel)
            .environmentObject(container)
            .previewDisplayName("認証済み")
    }
}
