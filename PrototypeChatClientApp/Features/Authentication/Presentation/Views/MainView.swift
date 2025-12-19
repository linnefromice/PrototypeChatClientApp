import SwiftUI

struct MainView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var container: DependencyContainer

    var body: some View {
        if let session = authViewModel.currentSession {
            ConversationListView(
                viewModel: ConversationListViewModel(
                    conversationUseCase: container.conversationUseCase,
                    currentUserId: session.userId
                )
            )
        } else {
            Text("セッションエラー")
        }
    }
}

// MARK: - Preview
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let container = DependencyContainer.makePreviewContainer()
        let viewModel = container.authenticationViewModel
        let aliceUser = User(id: "user-1", idAlias: "alice", name: "Alice", avatarUrl: nil, createdAt: Date())
        viewModel.isAuthenticated = true
        viewModel.currentSession = AuthSession(
            authUserId: "auth-1",
            username: "alice",
            email: "alice@example.com",
            user: aliceUser,
            chatUser: aliceUser,
            authenticatedAt: Date()
        )

        return MainView()
            .environmentObject(viewModel)
            .environmentObject(container)
    }
}
