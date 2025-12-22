//
//  PrototypeChatClientAppApp.swift
//  PrototypeChatClientApp
//
//  Created by arata.haruyama on 2025/12/11.
//

import SwiftUI

@main
struct PrototypeChatClientAppApp: App {
    @StateObject private var container = DependencyContainer.shared

    init() {
        #if DEBUG
        // Print configuration on app launch
        AppConfig.printConfiguration()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(container.authenticationViewModel)
                .environmentObject(container)
        }
    }
}
