import SwiftUI

/// アカウント情報表示画面
struct AccountProfileView: View {
    @StateObject private var colorSchemeManager = ColorSchemeManager.shared
    let user: User

    var body: some View {
        List {
            Section {
                avatarSection
            }

            Section {
                LabeledContent("ユーザーID", value: user.id)
                LabeledContent("ユーザーエイリアス", value: user.idAlias)
                LabeledContent("名前", value: user.name)
                LabeledContent("作成日時", value: formattedDate)
            }
        }
        .navigationTitle("アカウント")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(colorSchemeManager.preference.colorScheme)
    }

    private var avatarSection: some View {
        HStack {
            Spacer()
            avatarView
            Spacer()
        }
        .listRowBackground(Color.clear)
    }

    @ViewBuilder
    private var avatarView: some View {
        if let avatarUrl = user.avatarUrl, let url = URL(string: avatarUrl) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(App.Color.Stroke.Default.primary, lineWidth: 1))
                        .accessibilityLabel("プロフィール画像")
                case .failure, .empty:
                    initialsPlaceholder
                @unknown default:
                    initialsPlaceholder
                }
            }
        } else {
            initialsPlaceholder
        }
    }

    private var initialsPlaceholder: some View {
        ZStack {
            Circle()
                .fill(App.Color.Fill.Default.secondary)
                .frame(width: 80, height: 80)
                .overlay(Circle().stroke(App.Color.Stroke.Default.primary, lineWidth: 1))

            Text(userInitial)
                .font(.system(size: 36, weight: .medium))
                .foregroundColor(App.Color.Text.Default.primary)
        }
        .accessibilityLabel("\(user.name)のプロフィール画像")
    }

    private var userInitial: String {
        guard let firstChar = user.name.first else {
            return "?"
        }
        return String(firstChar).uppercased()
    }

    private var formattedDate: String {
        user.createdAt.formatted(date: .abbreviated, time: .shortened)
    }
}

// MARK: - Preview
#Preview("Avatar Nil") {
    NavigationStack {
        AccountProfileView(user: User(
            id: "user-1",
            idAlias: "alice",
            name: "Alice",
            avatarUrl: nil,
            createdAt: Date()
        ))
    }
}

#Preview("With Avatar") {
    NavigationStack {
        AccountProfileView(user: User(
            id: "user-1",
            idAlias: "alice",
            name: "Alice",
            avatarUrl: "https://example.com/avatar.jpg",
            createdAt: Date()
        ))
    }
}

#Preview("Long Information") {
    NavigationStack {
        AccountProfileView(user: User(
            id: "user-123456789-very-long-id",
            idAlias: "alice_wonderland_2024",
            name: "Alice in Wonderland",
            avatarUrl: nil,
            createdAt: Date()
        ))
    }
}
