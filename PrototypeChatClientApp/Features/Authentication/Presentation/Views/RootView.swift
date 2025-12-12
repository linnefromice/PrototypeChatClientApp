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
#Preview("未認証") {
    let container = DependencyContainer.makePreviewContainer()
    RootView()
        .environmentObject(container.authenticationViewModel)
}

#Preview("認証済み") {
    AuthenticatedRootViewPreview()
}

private struct AuthenticatedRootViewPreview: View {
    @StateObject private var container = DependencyContainer.makePreviewContainer()

    var body: some View {
        let viewModel = container.authenticationViewModel
        viewModel.isAuthenticated = true
        viewModel.currentSession = AuthSession(
            userId: "user-1",
            user: User(id: "user-1", name: "Alice", avatarUrl: nil, createdAt: Date()),
            authenticatedAt: Date()
        )

        return RootView()
            .environmentObject(viewModel)
    }
}
