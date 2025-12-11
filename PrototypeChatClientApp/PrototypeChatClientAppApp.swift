//
//  PrototypeChatClientAppApp.swift
//  PrototypeChatClientApp
//
//  Created by arata.haruyama on 2025/12/11.
//

import SwiftUI

@main
struct PrototypeChatClientAppApp: App {
    @StateObject private var authViewModel: AuthenticationViewModel

    init() {
        // 依存性注入
        let userRepository = MockUserRepository()
        let sessionManager = AuthSessionManager()
        let authUseCase = AuthenticationUseCase(
            userRepository: userRepository,
            sessionManager: sessionManager
        )
        let viewModel = AuthenticationViewModel(
            authenticationUseCase: authUseCase,
            sessionManager: sessionManager
        )

        _authViewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
                .onAppear {
                    authViewModel.checkAuthentication()
                }
        }
    }
}
