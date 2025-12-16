import SwiftUI

// MARK: - Container (Dependency Injection)

/// AuthenticationView Container
/// Responsible for dependency injection and ViewModel creation
struct AuthenticationView: View {
    @StateObject private var viewModel: AuthenticationViewModel

    init(viewModel: AuthenticationViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        AuthenticationPresenter(viewModel: viewModel)
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
                        .foregroundColor(.blue)

                    Text("チャットアプリ")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("開発用認証")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 60)

                Spacer()

                // 入力フォーム
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ユーザー名")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        TextField("ユーザー名を入力（例: alice, bob）", text: $viewModel.idAlias)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .disabled(viewModel.isAuthenticating)
                            .onSubmit {
                                Task {
                                    await viewModel.authenticate()
                                }
                            }

                        // ヘルプテキスト
                        Text("登録済みのユーザー名を入力してください")
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

                    // 認証ボタン
                    Button {
                        Task {
                            await viewModel.authenticate()
                        }
                    } label: {
                        HStack {
                            if viewModel.isAuthenticating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                            Text(viewModel.isAuthenticating ? "認証中..." : "ログイン")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(viewModel.idAlias.isEmpty || viewModel.isAuthenticating)
                }
                .padding(.horizontal, 32)

                Spacer()

                // デバッグ情報（開発環境のみ）
                #if DEBUG
                VStack(spacing: 4) {
                    Text("開発環境")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Text("テストユーザー: alice, bob, charlie")
                        .font(.caption2)
                        .foregroundColor(.secondary)
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
