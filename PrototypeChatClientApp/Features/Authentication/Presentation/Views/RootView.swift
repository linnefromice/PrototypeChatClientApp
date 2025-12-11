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
    RootView()
        .environmentObject(
            AuthenticationViewModel(
                authenticationUseCase: AuthenticationUseCase(
                    userRepository: MockUserRepository(),
                    sessionManager: AuthSessionManager(userDefaults: UserDefaults(suiteName: "preview")!)
                )
            )
        )
}

#Preview("認証済み") {
    let viewModel = AuthenticationViewModel(
        authenticationUseCase: AuthenticationUseCase(
            userRepository: MockUserRepository(),
            sessionManager: AuthSessionManager(userDefaults: UserDefaults(suiteName: "preview")!)
        )
    )
    // 認証済み状態をシミュレート
    viewModel.isAuthenticated = true
    viewModel.currentSession = AuthSession(
        userId: "user-1",
        user: User(id: "user-1", name: "Alice", avatarUrl: nil, createdAt: Date()),
        authenticatedAt: Date()
    )

    return RootView()
        .environmentObject(viewModel)
}
