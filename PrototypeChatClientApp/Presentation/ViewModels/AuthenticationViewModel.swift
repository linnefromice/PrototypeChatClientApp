import SwiftUI
import Combine

@MainActor
class AuthenticationViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var userId: String = ""
    @Published var currentSession: AuthSession?
    @Published var isAuthenticating: Bool = false
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false

    // MARK: - Dependencies
    private let authenticationUseCase: AuthenticationUseCaseProtocol
    private let sessionManager: AuthSessionManager

    // MARK: - Initialization
    init(
        authenticationUseCase: AuthenticationUseCaseProtocol,
        sessionManager: AuthSessionManager = AuthSessionManager()
    ) {
        self.authenticationUseCase = authenticationUseCase
        self.sessionManager = sessionManager
    }

    // MARK: - Public Methods

    /// アプリ起動時の認証チェック
    func checkAuthentication() {
        if let session = authenticationUseCase.loadSavedSession() {
            self.currentSession = session
            self.isAuthenticated = true
            self.userId = session.userId
        }
    }

    /// ユーザーIDによる認証実行
    func authenticate() async {
        guard !userId.isEmpty else {
            errorMessage = "User IDを入力してください"
            return
        }

        isAuthenticating = true
        errorMessage = nil

        do {
            let session = try await authenticationUseCase.authenticate(userId: userId)
            self.currentSession = session
            self.isAuthenticated = true
        } catch let error as AuthenticationError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "認証に失敗しました: \(error.localizedDescription)"
        }

        isAuthenticating = false
    }

    /// ログアウト
    func logout() {
        authenticationUseCase.logout()
        currentSession = nil
        isAuthenticated = false
        userId = ""
    }

    /// 最後に使用したUser IDを取得
    func loadLastUserId() -> String? {
        return sessionManager.getLastUserId()
    }
}
