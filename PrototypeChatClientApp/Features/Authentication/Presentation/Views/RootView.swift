import SwiftUI

struct RootView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
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
                userId: "user-1",
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
