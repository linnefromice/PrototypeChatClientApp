import SwiftUI
import Combine

@MainActor
class AuthenticationViewModel: ObservableObject {
    // MARK: - Published Properties

    // Legacy idAlias field (for backward compatibility)
    @Published var idAlias: String = ""

    // BetterAuth fields
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var email: String = ""
    @Published var name: String = ""

    // UI State
    @Published var currentSession: AuthSession?
    @Published var isAuthenticating: Bool = false
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false
    @Published var isRegistering: Bool = false

    // MARK: - Dependencies
    private let authenticationUseCase: AuthenticationUseCaseProtocol
    private let sessionManager: AuthSessionManagerProtocol

    // MARK: - Initialization
    init(
        authenticationUseCase: AuthenticationUseCaseProtocol,
        sessionManager: AuthSessionManagerProtocol
    ) {
        self.authenticationUseCase = authenticationUseCase
        self.sessionManager = sessionManager
    }

    // MARK: - Public Methods

    /// アプリ起動時の認証チェック（Cookie-based session validation）
    func checkAuthentication() async {
        do {
            // Try to validate session via backend cookie
            if let session = try await authenticationUseCase.validateSession() {
                self.currentSession = session
                self.isAuthenticated = true
                self.username = session.username
                return
            }
        } catch {
            print("⚠️ [AuthenticationViewModel] Session validation failed: \(error)")
        }

        // Fallback: Check for old local session (migration path)
        if let session = authenticationUseCase.loadSavedSession() {
            self.currentSession = session
            self.isAuthenticated = true
            self.username = session.username
        }
    }

    /// BetterAuth username/password login
    func login() async {
        guard !username.isEmpty else {
            errorMessage = "ユーザー名を入力してください"
            return
        }

        guard !password.isEmpty else {
            errorMessage = "パスワードを入力してください"
            return
        }

        isAuthenticating = true
        errorMessage = nil

        do {
            let session = try await authenticationUseCase.login(
                username: username,
                password: password
            )
            self.currentSession = session
            self.isAuthenticated = true
            self.password = "" // Clear password for security
        } catch let error as AuthenticationError {
            print("❌ [AuthenticationViewModel] login failed - AuthenticationError: \(error)")
            errorMessage = error.errorDescription
        } catch {
            print("❌ [AuthenticationViewModel] login failed - Unexpected error: \(error)")
            errorMessage = "ログインに失敗しました: \(error.localizedDescription)"
        }

        isAuthenticating = false
    }

    /// BetterAuth user registration
    func register() async {
        guard !username.isEmpty else {
            errorMessage = "ユーザー名を入力してください"
            return
        }

        guard !email.isEmpty else {
            errorMessage = "メールアドレスを入力してください"
            return
        }

        guard !password.isEmpty else {
            errorMessage = "パスワードを入力してください"
            return
        }

        guard !name.isEmpty else {
            errorMessage = "名前を入力してください"
            return
        }

        isAuthenticating = true
        errorMessage = nil

        do {
            let session = try await authenticationUseCase.register(
                username: username,
                email: email,
                password: password,
                name: name
            )
            self.currentSession = session
            self.isAuthenticated = true
            self.password = "" // Clear password for security
        } catch let error as AuthenticationError {
            print("❌ [AuthenticationViewModel] register failed - AuthenticationError: \(error)")
            errorMessage = error.errorDescription
        } catch {
            print("❌ [AuthenticationViewModel] register failed - Unexpected error: \(error)")
            errorMessage = "登録に失敗しました: \(error.localizedDescription)"
        }

        isAuthenticating = false
    }

    /// ID Aliasによる認証実行（Legacy - backward compatibility）
    func authenticate() async {
        guard !idAlias.isEmpty else {
            errorMessage = "ID Aliasを入力してください"
            return
        }

        isAuthenticating = true
        errorMessage = nil

        do {
            let session = try await authenticationUseCase.authenticate(idAlias: idAlias)
            self.currentSession = session
            self.isAuthenticated = true
        } catch let error as AuthenticationError {
            print("❌ [AuthenticationViewModel] authenticate failed - AuthenticationError: \(error)")
            errorMessage = error.errorDescription
        } catch {
            print("❌ [AuthenticationViewModel] authenticate failed - Unexpected error: \(error)")
            errorMessage = "認証に失敗しました: \(error.localizedDescription)"
        }

        isAuthenticating = false
    }

    /// ログアウト
    func logout() {
        Task {
            do {
                try await authenticationUseCase.logout()
                clearFields()
            } catch {
                print("❌ [AuthenticationViewModel] logout failed: \(error)")
                errorMessage = "ログアウトに失敗しました"
            }
        }
    }

    /// Clear all fields and state
    private func clearFields() {
        currentSession = nil
        isAuthenticated = false
        username = ""
        password = ""
        email = ""
        name = ""
        idAlias = ""
        errorMessage = nil
    }

    /// Toggle between login and registration mode
    func toggleRegistrationMode() {
        isRegistering.toggle()
        errorMessage = nil
    }

    /// 最後に使用したUser IDを取得（後方互換性のため維持）
    func loadLastUserId() -> String? {
        return sessionManager.getLastUserId()
    }
}
