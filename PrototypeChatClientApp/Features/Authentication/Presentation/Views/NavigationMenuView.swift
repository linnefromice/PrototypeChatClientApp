import SwiftUI

/// ナビゲーションメニュービュー
struct NavigationMenuView: View {
    @Environment(\.dismiss) var dismiss
    let onLogout: () -> Void

    var body: some View {
        NavigationView {
            List {
                Button(role: .destructive, action: {
                    dismiss()
                    onLogout()
                }) {
                    Label("ログアウト", systemImage: "rectangle.portrait.and.arrow.right")
                }
                .accessibilityLabel("ログアウト")
            }
            .navigationTitle("メニュー")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("閉じる") {
                dismiss()
            })
        }
    }
}

#Preview {
    NavigationMenuView(onLogout: {
        print("Logout tapped")
    })
}
