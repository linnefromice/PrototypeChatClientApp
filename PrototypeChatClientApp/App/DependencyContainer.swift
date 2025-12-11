import Foundation
import SwiftUI

/// 依存性注入コンテナ
///
/// 責務:
/// - アプリ全体で使用するインスタンスの生成と管理
/// - 依存関係の解決
///
/// 将来的なMultiModule化時:
/// - 各Feature Moduleが独自のDependencyContainerを持つ可能性
/// - このコンテナはApp層での統合時に使用
@MainActor
final class DependencyContainer: ObservableObject {
    // MARK: - Shared Instances

    /// ユーザーリポジトリ（現在はMock、将来的に実装に差し替え）
    lazy var userRepository: UserRepositoryProtocol = {
        MockUserRepository()
    }()

    /// 認証セッションマネージャー
    lazy var authSessionManager: AuthSessionManager = {
        AuthSessionManager()
    }()

    // MARK: - Use Cases

    /// 認証UseCase
    lazy var authenticationUseCase: AuthenticationUseCaseProtocol = {
        AuthenticationUseCase(
            userRepository: userRepository,
            sessionManager: authSessionManager
        )
    }()

    // MARK: - View Models

    /// 認証ViewModel（lazy初期化）
    lazy var authenticationViewModel: AuthenticationViewModel = {
        AuthenticationViewModel(
            authenticationUseCase: authenticationUseCase,
            sessionManager: authSessionManager
        )
    }()

    // MARK: - Singleton

    static let shared = DependencyContainer()

    private init() {}
}

// MARK: - 将来的な拡張例（コメントアウト）

/*
extension DependencyContainer {
    // 本番API接続時の実装例
    lazy var apiClient: APIClient = {
        APIClientFactory.createClient(environment: .current)
    }()

    lazy var userRepository: UserRepositoryProtocol = {
        UserRepository(client: apiClient)
    }()

    // 会話機能追加時の例
    lazy var conversationRepository: ConversationRepositoryProtocol = {
        ConversationRepository(client: apiClient)
    }()

    lazy var fetchConversationsUseCase: FetchConversationsUseCaseProtocol = {
        FetchConversationsUseCase(repository: conversationRepository)
    }()
}
*/
