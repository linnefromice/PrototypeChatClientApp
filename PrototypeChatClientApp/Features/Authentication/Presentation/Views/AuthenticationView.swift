import SwiftUI

// MARK: - Container (Dependency Injection)

/// AuthenticationView Container
/// Responsible for dependency injection and ViewModel creation
/// Switches between login and registration views
struct AuthenticationView: View {
    @StateObject private var viewModel: AuthenticationViewModel

    init(viewModel: AuthenticationViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.isRegistering {
                RegistrationView(viewModel: viewModel)
            } else {
                AuthenticationPresenter(viewModel: viewModel)
            }
        }
        .animation(.easeInOut, value: viewModel.isRegistering)
    }
}

// MARK: - Presenter (UI Logic)

/// AuthenticationPresenter
/// Responsible for UI presentation only (no dependency management)
/// This separation enables easy SwiftUI Previews without complex DI setup
struct AuthenticationPresenter: View {
    @ObservedObject var viewModel: AuthenticationViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // ロゴ・タイトル
                VStack(spacing: 8) {
                    Image(systemName: "message.fill")
                        .font(.system(size: 60))
                        .foregroundColor(App.Color.Brand.primary)

                    Text("チャットアプリ")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("開発用認証")
                        .font(.caption)
                        .foregroundColor(App.Color.Text.Default.secondary)
                }
                .padding(.top, 60)

                Spacer()

                // 入力フォーム
                VStack(spacing: 16) {
                    // Username field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ユーザー名")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        TextField("ユーザー名を入力", text: $viewModel.username)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .disabled(viewModel.isAuthenticating)
                    }

                    // Password field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("パスワード")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        HStack {
                            if viewModel.isPasswordVisible {
                                TextField("パスワードを入力", text: $viewModel.password)
                                    .textFieldStyle(.roundedBorder)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .disabled(viewModel.isAuthenticating)
                                    .onSubmit {
                                        Task {
                                            await viewModel.login()
                                        }
                                    }
                            } else {
                                SecureField("パスワードを入力", text: $viewModel.password)
                                    .textFieldStyle(.roundedBorder)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .disabled(viewModel.isAuthenticating)
                                    .onSubmit {
                                        Task {
                                            await viewModel.login()
                                        }
                                    }
                            }

                            Button {
                                viewModel.togglePasswordVisibility()
                            } label: {
                                Image(systemName: viewModel.isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(App.Color.Icon.Default.secondary)
                                    .frame(width: 44, height: 44)
                            }
                            .disabled(viewModel.isAuthenticating)
                        }
                    }

                    // エラーメッセージ
                    if let errorMessage = viewModel.errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text(errorMessage)
                        }
                        .font(.caption)
                        .foregroundColor(App.Color.Semantic.error)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(App.Color.Semantic.error.opacity(0.1))
                        )
                    }

                    // ログインボタン
                    Button {
                        Task {
                            await viewModel.login()
                        }
                    } label: {
                        HStack {
                            if viewModel.isAuthenticating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: App.Color.Text.Default.inversion))
                            }
                            Text(viewModel.isAuthenticating ? "ログイン中..." : "ログイン")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(App.Color.Brand.primary)
                        .foregroundColor(App.Color.Text.Default.inversion)
                        .cornerRadius(10)
                    }
                    .disabled(viewModel.username.isEmpty || viewModel.password.isEmpty || viewModel.isAuthenticating)

                    // 登録画面へのリンク
                    Button {
                        viewModel.toggleRegistrationMode()
                    } label: {
                        Text("アカウントをお持ちでない方はこちら")
                            .font(.subheadline)
                            .foregroundColor(App.Color.Text.Link.primaryActive)
                    }
                    .disabled(viewModel.isAuthenticating)
                }
                .padding(.horizontal, 32)

                Spacer()

                // デバッグ情報（開発環境のみ）
                #if DEBUG
                VStack(spacing: 4) {
                    Text("開発環境")
                        .font(.caption2)
                        .foregroundColor(App.Color.Text.Default.secondary)

                    Text("テストユーザー: alice, bob, charlie")
                        .font(.caption2)
                        .foregroundColor(App.Color.Text.Default.secondary)
                }
                .padding(.bottom, 16)
                #endif
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Preview

#Preview("初期状態") {
    let container = DependencyContainer.makePreviewContainer()
    return AuthenticationPresenter(viewModel: container.authenticationViewModel)
}

#Preview("ID Alias入力済み") {
    let container = DependencyContainer.makePreviewContainer()
    let viewModel = container.authenticationViewModel
    viewModel.idAlias = "alice"
    return AuthenticationPresenter(viewModel: viewModel)
}

#Preview("エラー表示") {
    let container = DependencyContainer.makePreviewContainer()
    let viewModel = container.authenticationViewModel
    viewModel.idAlias = "invalid-user"
    viewModel.errorMessage = "指定されたユーザーが見つかりません"
    return AuthenticationPresenter(viewModel: viewModel)
}

#Preview("認証中") {
    let container = DependencyContainer.makePreviewContainer()
    let viewModel = container.authenticationViewModel
    viewModel.idAlias = "alice"
    viewModel.isAuthenticating = true
    return AuthenticationPresenter(viewModel: viewModel)
}
