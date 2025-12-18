import SwiftUI

/// ナビゲーションメニュービュー
struct NavigationMenuView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    let onLogout: () -> Void

    var body: some View {
        NavigationView {
            List {
                // Account menu item
                if let user = authViewModel.currentSession?.user {
                    NavigationLink {
                        AccountProfileView(user: user)
                    } label: {
                        Label("アカウント", systemImage: "person.circle")
                    }
                    .accessibilityLabel("アカウント")
                }

                // Logout button
                Button(role: .destructive, action: {
                    dismiss()
                    onLogout()
                }) {
                    Label("ログアウト", systemImage: "rectangle.portrait.and.arrow.right")
                }
                .accessibilityLabel("ログアウト")
            }
            .navigationTitle("メニュー")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("閉じる") {
                dismiss()
            })
        }
    }
}

#Preview {
    let container = DependencyContainer.makePreviewContainer()
    let viewModel = container.authenticationViewModel
    viewModel.isAuthenticated = true
    viewModel.currentSession = AuthSession(
        authUserId: "auth-1",
        username: "alice",
        email: "alice@example.com",
        user: User(id: "user-1", idAlias: "alice", name: "Alice", avatarUrl: nil, createdAt: Date()),
        authenticatedAt: Date()
    )

    return NavigationMenuView(onLogout: {
        print("Logout tapped")
    })
    .environmentObject(viewModel)
}
