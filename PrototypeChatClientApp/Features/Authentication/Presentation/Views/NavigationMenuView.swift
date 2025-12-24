import SwiftUI

/// ナビゲーションメニュービュー
struct NavigationMenuView: View {
    @SwiftUI.Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject private var colorSchemeManager = ColorSchemeManager.shared
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

                // Color scheme selection
                Section {
                    ForEach(ColorSchemePreference.allCases) { preference in
                        Button(action: {
                            colorSchemeManager.setPreference(preference)
                        }) {
                            HStack {
                                Image(systemName: preference.icon)
                                    .frame(width: 24)
                                Text(preference.displayName)
                                    .foregroundColor(App.Color.Text.Default.primary)
                                Spacer()
                                if colorSchemeManager.preference == preference {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(App.Color.Brand.primary)
                                }
                            }
                        }
                    }
                } header: {
                    Text("カラーテーマ")
                }

                // Logout button
                Section {
                    Button(role: .destructive, action: {
                        dismiss()
                        onLogout()
                    }) {
                        Label("ログアウト", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                    .accessibilityLabel("ログアウト")
                }
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

    return NavigationMenuView(onLogout: {
        print("Logout tapped")
    })
    .environmentObject(viewModel)
}
