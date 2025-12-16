import SwiftUI
import Combine

@MainActor
class AuthenticationViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var idAlias: String = ""
    @Published var currentSession: AuthSession?
    @Published var isAuthenticating: Bool = false
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false

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

    /// アプリ起動時の認証チェック
    func checkAuthentication() {
        if let session = authenticationUseCase.loadSavedSession() {
            self.currentSession = session
            self.isAuthenticated = true
            // セッションから idAlias を表示（後方互換性のため）
            self.idAlias = session.user.idAlias
        }
    }

    /// ID Aliasによる認証実行
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
        authenticationUseCase.logout()
        currentSession = nil
        isAuthenticated = false
        idAlias = ""
    }

    /// 最後に使用したUser IDを取得（後方互換性のため維持）
    func loadLastUserId() -> String? {
        return sessionManager.getLastUserId()
    }
}
