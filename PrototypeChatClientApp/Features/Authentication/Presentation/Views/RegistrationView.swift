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
                        .foregroundColor(.blue)

                    Text("新規アカウント登録")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.top, 40)

                // 登録フォーム
                VStack(spacing: 16) {
                    // Username field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ユーザー名 *")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        TextField("ユーザー名を入力", text: $viewModel.username)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .disabled(viewModel.isAuthenticating)

                        Text("3-20文字の英数字、アンダースコア、ハイフン")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // Email field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("メールアドレス *")
                            .font(.subheadline)
                            .fontWeight(.medium)

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
                            .font(.subheadline)
                            .fontWeight(.medium)

                        SecureField("パスワードを入力", text: $viewModel.password)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .disabled(viewModel.isAuthenticating)

                        Text("8文字以上")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // Name field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("表示名 *")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        TextField("表示名を入力", text: $viewModel.name)
                            .textFieldStyle(.roundedBorder)
                            .disabled(viewModel.isAuthenticating)

                        Text("チャットで表示される名前（1-50文字）")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // エラーメッセージ
                    if let errorMessage = viewModel.errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text(errorMessage)
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.red.opacity(0.1))
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
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                            Text(viewModel.isAuthenticating ? "登録中..." : "登録")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(!isFormValid || viewModel.isAuthenticating)

                    // ログイン画面へのリンク
                    Button {
                        viewModel.toggleRegistrationMode()
                    } label: {
                        Text("既にアカウントをお持ちの方はこちら")
                            .font(.subheadline)
                            .foregroundColor(.blue)
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
