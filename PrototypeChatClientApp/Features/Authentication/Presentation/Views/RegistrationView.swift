import SwiftUI

/// ユーザー登録画面
struct RegistrationView: View {
    @ObservedObject var viewModel: AuthenticationViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // ロゴ・タイトル
                VStack(spacing: 8) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 60))
                        .foregroundColor(App.Color.Brand.primary)

                    Text("新規アカウント登録")
                        .appText(.title2)
                }
                .padding(.top, 40)

                // 登録フォーム
                VStack(spacing: 16) {
                    // Username field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ユーザー名 *")
                            .appText(.subheadline)

                        TextField("ユーザー名を入力", text: $viewModel.username)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .disabled(viewModel.isAuthenticating)

                        Text("3-20文字の英数字、アンダースコア、ハイフン")
                            .appText(.caption2, color: App.Color.Text.Default.secondary)
                    }

                    // Email field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("メールアドレス *")
                            .appText(.subheadline)

                        TextField("メールアドレスを入力", text: $viewModel.email)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.emailAddress)
                            .disabled(viewModel.isAuthenticating)
                    }

                    // Password field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("パスワード *")
                            .appText(.subheadline)

                        HStack {
                            if viewModel.isPasswordVisible {
                                TextField("パスワードを入力", text: $viewModel.password)
                                    .textFieldStyle(.roundedBorder)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .disabled(viewModel.isAuthenticating)
                            } else {
                                SecureField("パスワードを入力", text: $viewModel.password)
                                    .textFieldStyle(.roundedBorder)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .disabled(viewModel.isAuthenticating)
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

                        Text("8文字以上")
                            .appText(.caption2, color: App.Color.Text.Default.secondary)
                    }

                    // Name field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("表示名 *")
                            .appText(.subheadline)

                        TextField("表示名を入力", text: $viewModel.name)
                            .textFieldStyle(.roundedBorder)
                            .disabled(viewModel.isAuthenticating)

                        Text("チャットで表示される名前（1-50文字）")
                            .appText(.caption2, color: App.Color.Text.Default.secondary)
                    }

                    // エラーメッセージ
                    if let errorMessage = viewModel.errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text(errorMessage)
                        }
                        .appText(.caption2, color: App.Color.Semantic.error)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(App.Color.Semantic.error.opacity(0.1))
                        )
                    }

                    // 登録ボタン
                    Button {
                        Task {
                            await viewModel.register()
                        }
                    } label: {
                        HStack {
                            if viewModel.isAuthenticating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: App.Color.Text.Default.inversion))
                            }
                            Text(viewModel.isAuthenticating ? "登録中..." : "登録")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? App.Color.Brand.primary : App.Color.Icon.Default.disable)
                        .foregroundColor(App.Color.Text.Default.inversion)
                        .cornerRadius(10)
                    }
                    .disabled(!isFormValid || viewModel.isAuthenticating)

                    // ログイン画面へのリンク
                    Button {
                        viewModel.toggleRegistrationMode()
                    } label: {
                        Text("既にアカウントをお持ちの方はこちら")
                            .appText(.subheadline, color: App.Color.Text.Link.primaryActive)
                    }
                    .disabled(viewModel.isAuthenticating)
                }
                .padding(.horizontal, 32)

                Spacer()
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }

    /// フォームの入力チェック
    private var isFormValid: Bool {
        !viewModel.username.isEmpty &&
        !viewModel.email.isEmpty &&
        !viewModel.password.isEmpty &&
        !viewModel.name.isEmpty
    }
}

// MARK: - Preview

#Preview("初期状態") {
    let container = DependencyContainer.makePreviewContainer()
    let viewModel = container.authenticationViewModel
    viewModel.isRegistering = true
    return RegistrationView(viewModel: viewModel)
}

#Preview("入力済み") {
    let container = DependencyContainer.makePreviewContainer()
    let viewModel = container.authenticationViewModel
    viewModel.isRegistering = true
    viewModel.username = "newuser"
    viewModel.email = "newuser@example.com"
    viewModel.password = "password123"
    viewModel.name = "New User"
    return RegistrationView(viewModel: viewModel)
}

#Preview("エラー表示") {
    let container = DependencyContainer.makePreviewContainer()
    let viewModel = container.authenticationViewModel
    viewModel.isRegistering = true
    viewModel.username = "alice"
    viewModel.email = "alice@example.com"
    viewModel.errorMessage = "このユーザー名は既に使用されています"
    return RegistrationView(viewModel: viewModel)
}
