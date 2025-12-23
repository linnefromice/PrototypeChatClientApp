# リファクタリング分析レポート

**分析対象コミット**: `b86b109` - Add conversation list feature with domain entities, repositories, and ViewModels for chat functionality
**分析日時**: 2025-12-12
**分析者**: Claude Code

---

## 📊 現状分析

### ファイルサイズ分析
```
ConversationListView.swift       : 125行
CreateConversationView.swift     : 120行
ConversationListViewModel.swift  :  63行
CreateConversationViewModel.swift:  77行
```

### 現在の構成
```
Features/Chat/
├── Data/
│   └── Repositories/
│       └── MockConversationRepository.swift
├── Domain/
│   ├── Entities/
│   │   ├── Conversation.swift
│   │   ├── ConversationDetail.swift
│   │   ├── ConversationType.swift
│   │   └── Participant.swift
│   └── UseCases/
│       ├── ConversationUseCase.swift
│       └── UserListUseCase.swift
└── Presentation/
    ├── ViewModels/
    │   ├── ConversationListViewModel.swift
    │   └── CreateConversationViewModel.swift
    └── Views/
        ├── ConversationListView.swift
        └── CreateConversationView.swift
```

---

## 🎯 リファクタリング提案

### 1. コンポーネント分離（優先度: 高）

#### 1.1 EmptyStateView の共通化
**現状の問題**:
- `ConversationListView` と `CreateConversationView` で類似の Empty State UI が重複
- ビルド速度への影響は小さいが、保守性が低い

**提案**:
```swift
// Features/Chat/Presentation/Components/EmptyStateView.swift
struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 48))
                .foregroundColor(.gray)
            Text(title)
                .font(.headline)
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}
```

**効果**:
- コード重複削減: 約30行
- Preview の簡易化
- 一貫性の向上

---

#### 1.2 ConversationRowView の分離
**現状の問題**:
- `conversationRow` が `ConversationListView` 内に private で定義
- Previewが困難
- 再利用性が低い

**提案**:
```swift
// Features/Chat/Presentation/Components/ConversationRowView.swift
struct ConversationRowView: View {
    let detail: ConversationDetail
    let currentUserId: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(conversationTitle)
                .font(.headline)

            Text(conversationSubtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private var conversationTitle: String {
        switch detail.type {
        case .group:
            return detail.conversation.name ?? "グループチャット"
        case .direct:
            let otherParticipant = detail.activeParticipants.first {
                $0.userId != currentUserId
            }
            return otherParticipant?.user.name ?? "チャット"
        }
    }

    private var conversationSubtitle: String {
        "\(detail.activeParticipants.count)人が参加中"
    }
}

// Preview
struct ConversationRowView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationRowView(
            detail: MockData.sampleConversationDetail,
            currentUserId: "user1"
        )
        .previewLayout(.sizeThatFits)
    }
}
```

**効果**:
- ビルド速度改善: 行の小さなコンポーネントとして独立
- Preview が簡単（Layout Preview可能）
- ViewModelから表示ロジックを分離（現在ViewModelに `conversationTitle`/`conversationSubtitle` があるが、Viewに移動できる）

---

#### 1.3 UserSelectionRowView の分離
**現状の問題**:
- `CreateConversationView` の `userList` 内に埋め込み
- Previewが困難

**提案**:
```swift
// Features/Chat/Presentation/Components/UserSelectionRowView.swift
struct UserSelectionRowView: View {
    let user: User
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.name)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text("ID: \(user.id)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.blue)
                }
            }
        }
    }
}
```

**効果**:
- ビルド速度改善
- Preview が簡単
- 再利用性向上（他の画面でユーザー選択が必要になった場合）

---

### 2. Preview 実装状況と改善提案（優先度: 中）

#### 2.1 現状のPreview実装
✅ **実装済み**:
- `ConversationListView_Previews`
- `CreateConversationView_Previews`
- `RootView_Previews`
- `MainView_Previews`

❌ **未実装**:
- 個別コンポーネントのPreview（分離後に実装）
- ViewModelのテスト用Preview
- エラー状態のPreview
- ローディング状態のPreview

#### 2.2 Preview改善提案

**MockDataファイルの作成**:
```swift
// Features/Chat/Testing/MockData.swift
enum MockData {
    static let sampleUser1 = User(
        id: "user1",
        name: "Alice",
        avatarUrl: nil,
        createdAt: Date()
    )

    static let sampleUser2 = User(
        id: "user2",
        name: "Bob",
        avatarUrl: nil,
        createdAt: Date()
    )

    static let sampleConversationDetail = ConversationDetail(
        conversation: Conversation(
            id: "1",
            type: .direct,
            name: nil,
            createdAt: Date()
        ),
        participants: [
            Participant(
                id: "p1",
                conversationId: "1",
                userId: "user1",
                user: sampleUser1,
                joinedAt: Date(),
                leftAt: nil
            ),
            Participant(
                id: "p2",
                conversationId: "1",
                userId: "user2",
                user: sampleUser2,
                joinedAt: Date(),
                leftAt: nil
            )
        ]
    )

    static let multipleConversations: [ConversationDetail] = [
        sampleConversationDetail,
        // ... more samples
    ]
}
```

**複数状態のPreview**:
```swift
struct ConversationListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 正常状態
            normalStatePreview
                .previewDisplayName("通常")

            // ローディング状態
            loadingStatePreview
                .previewDisplayName("読み込み中")

            // 空状態
            emptyStatePreview
                .previewDisplayName("空")

            // エラー状態
            errorStatePreview
                .previewDisplayName("エラー")
        }
    }

    // ... helper methods
}
```

---

### 3. テスト実装提案（優先度: 高）

#### 3.1 現状
**テストファイル数**: 0
**テストカバレッジ**: 0%

#### 3.2 優先的にテストすべきロジック

**Domain Layer** (最優先):
```swift
// PrototypeChatClientAppTests/Features/Chat/Domain/UseCases/ConversationUseCaseTests.swift
import XCTest
@testable import PrototypeChatClientApp

final class ConversationUseCaseTests: XCTestCase {
    var sut: ConversationUseCase!
    var mockRepository: MockConversationRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockConversationRepository()
        sut = ConversationUseCase(conversationRepository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - fetchConversations Tests

    func test_fetchConversations_sortsByCreatedDateDescending() async throws {
        // Given
        let older = ConversationDetail(
            conversation: Conversation(
                id: "1",
                type: .direct,
                name: nil,
                createdAt: Date(timeIntervalSince1970: 1000)
            ),
            participants: []
        )
        let newer = ConversationDetail(
            conversation: Conversation(
                id: "2",
                type: .direct,
                name: nil,
                createdAt: Date(timeIntervalSince1970: 2000)
            ),
            participants: []
        )
        mockRepository.conversations = [older, newer]

        // When
        let result = try await sut.fetchConversations(userId: "user1")

        // Then
        XCTAssertEqual(result.first?.id, "2", "新しい会話が最初に来るべき")
        XCTAssertEqual(result.last?.id, "1", "古い会話が最後に来るべき")
    }

    func test_fetchConversations_propagatesRepositoryError() async {
        // Given
        mockRepository.shouldThrowError = NSError(
            domain: "Test",
            code: 500,
            userInfo: nil
        )

        // When/Then
        do {
            _ = try await sut.fetchConversations(userId: "user1")
            XCTFail("エラーがスローされるべき")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    // MARK: - createDirectConversation Tests

    func test_createDirectConversation_includesBothUsers() async throws {
        // Given
        let currentUserId = "user1"
        let targetUserId = "user2"

        // When
        let result = try await sut.createDirectConversation(
            currentUserId: currentUserId,
            targetUserId: targetUserId
        )

        // Then
        XCTAssertEqual(result.type, .direct)
        XCTAssertEqual(result.activeParticipants.count, 2)
        XCTAssertTrue(result.activeParticipants.contains { $0.userId == currentUserId })
        XCTAssertTrue(result.activeParticipants.contains { $0.userId == targetUserId })
    }

    // MARK: - createGroupConversation Tests

    func test_createGroupConversation_includesCurrentUserIfNotInList() async throws {
        // Given
        let currentUserId = "user1"
        let participantIds = ["user2", "user3"] // user1が含まれていない

        // When
        let result = try await sut.createGroupConversation(
            currentUserId: currentUserId,
            participantUserIds: participantIds,
            groupName: "Test Group"
        )

        // Then
        XCTAssertEqual(result.type, .group)
        XCTAssertEqual(result.activeParticipants.count, 3)
        XCTAssertTrue(
            result.activeParticipants.contains { $0.userId == currentUserId },
            "現在のユーザーが自動的に追加されるべき"
        )
    }

    func test_createGroupConversation_doesNotDuplicateCurrentUser() async throws {
        // Given
        let currentUserId = "user1"
        let participantIds = ["user1", "user2", "user3"] // user1が既に含まれている

        // When
        let result = try await sut.createGroupConversation(
            currentUserId: currentUserId,
            participantUserIds: participantIds,
            groupName: "Test Group"
        )

        // Then
        XCTAssertEqual(result.activeParticipants.count, 3, "user1が重複していないべき")
    }
}
```

**ViewModel Tests**:
```swift
// PrototypeChatClientAppTests/Features/Chat/Presentation/ViewModels/ConversationListViewModelTests.swift
@MainActor
final class ConversationListViewModelTests: XCTestCase {
    var sut: ConversationListViewModel!
    var mockUseCase: MockConversationUseCase! // 新規作成が必要

    override func setUp() {
        super.setUp()
        mockUseCase = MockConversationUseCase()
        sut = ConversationListViewModel(
            conversationUseCase: mockUseCase,
            currentUserId: "user1"
        )
    }

    func test_loadConversations_setsLoadingStateCorrectly() async {
        // Given
        XCTAssertFalse(sut.isLoading, "初期状態ではローディング中でないべき")

        // When
        let loadTask = Task {
            await sut.loadConversations()
        }

        // Then - ローディング中
        try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
        // Note: タイミング依存のテストは避けるべき、mockUseCaseで制御可能にする

        await loadTask.value
        XCTAssertFalse(sut.isLoading, "完了後はローディング中でないべき")
    }

    func test_loadConversations_populatesConversations() async {
        // Given
        let expected = [MockData.sampleConversationDetail]
        mockUseCase.conversationsToReturn = expected

        // When
        await sut.loadConversations()

        // Then
        XCTAssertEqual(sut.conversations.count, 1)
        XCTAssertEqual(sut.conversations.first?.id, expected.first?.id)
    }

    func test_loadConversations_setsErrorOnFailure() async {
        // Given
        mockUseCase.shouldThrowError = true

        // When
        await sut.loadConversations()

        // Then
        XCTAssertTrue(sut.showError)
        XCTAssertNotNil(sut.errorMessage)
    }

    func test_conversationTitle_returnsOtherUserNameForDirectChat() {
        // Given
        let detail = MockData.sampleConversationDetail // direct chat

        // When
        let title = sut.conversationTitle(for: detail)

        // Then
        XCTAssertEqual(title, "Bob") // user1視点でuser2の名前
    }

    func test_conversationTitle_returnsGroupNameForGroupChat() {
        // Given
        let groupDetail = ConversationDetail(
            conversation: Conversation(
                id: "1",
                type: .group,
                name: "My Group",
                createdAt: Date()
            ),
            participants: []
        )

        // When
        let title = sut.conversationTitle(for: groupDetail)

        // Then
        XCTAssertEqual(title, "My Group")
    }
}
```

**Entity Tests** (軽量だが重要):
```swift
// PrototypeChatClientAppTests/Features/Chat/Domain/Entities/ParticipantTests.swift
final class ParticipantTests: XCTestCase {
    func test_isActive_returnsTrueWhenLeftAtIsNil() {
        // Given
        let participant = Participant(
            id: "1",
            conversationId: "c1",
            userId: "u1",
            user: MockData.sampleUser1,
            joinedAt: Date(),
            leftAt: nil
        )

        // When/Then
        XCTAssertTrue(participant.isActive)
    }

    func test_isActive_returnsFalseWhenLeftAtIsSet() {
        // Given
        let participant = Participant(
            id: "1",
            conversationId: "c1",
            userId: "u1",
            user: MockData.sampleUser1,
            joinedAt: Date(),
            leftAt: Date()
        )

        // When/Then
        XCTAssertFalse(participant.isActive)
    }
}

// PrototypeChatClientAppTests/Features/Chat/Domain/Entities/ConversationDetailTests.swift
final class ConversationDetailTests: XCTestCase {
    func test_activeParticipants_filtersOutLeftParticipants() {
        // Given
        let activeParticipant = Participant(
            id: "p1",
            conversationId: "c1",
            userId: "u1",
            user: MockData.sampleUser1,
            joinedAt: Date(),
            leftAt: nil
        )
        let leftParticipant = Participant(
            id: "p2",
            conversationId: "c1",
            userId: "u2",
            user: MockData.sampleUser2,
            joinedAt: Date(),
            leftAt: Date()
        )
        let detail = ConversationDetail(
            conversation: Conversation(
                id: "c1",
                type: .group,
                name: "Test",
                createdAt: Date()
            ),
            participants: [activeParticipant, leftParticipant]
        )

        // When
        let active = detail.activeParticipants

        // Then
        XCTAssertEqual(active.count, 1)
        XCTAssertEqual(active.first?.id, "p1")
    }
}
```

---

### 4. 実装優先順位

#### Phase 1: 即座に実施可能（リスク低）
1. ✅ MockDataファイルの作成
2. ✅ EmptyStateViewの分離
3. ✅ 既存Previewの改善（複数状態対応）

#### Phase 2: テスト基盤構築（重要度高）
1. ✅ Domain層のテスト実装
   - `ConversationUseCaseTests`
   - Entity tests
2. ✅ Mock helper の作成
   - `MockConversationUseCase`

#### Phase 3: コンポーネント分離（ビルド速度改善）
1. ✅ `ConversationRowView` 分離
2. ✅ `UserSelectionRowView` 分離
3. ✅ 個別コンポーネントのPreview追加

#### Phase 4: ViewModel テスト（保守性向上）
1. ✅ `ConversationListViewModelTests`
2. ✅ `CreateConversationViewModelTests`

---

## 📈 期待される効果

### ビルド速度
- **現状**: 単一ファイル変更でも関連View全体が再コンパイル
- **改善後**: コンポーネント分離により、変更範囲が限定される
- **予想改善率**: 10-20% (小規模プロジェクトのため効果は限定的)

### Preview効率
- **現状**: 大きなViewのPreviewは重い
- **改善後**: 個別コンポーネントのPreviewで高速確認可能
- **予想改善**: Preview起動時間 50%削減

### 保守性
- **現状**: テストなし、変更の影響範囲が不明
- **改善後**: テストによる安全なリファクタリングが可能
- **リグレッション検出率**: 80%以上

### コード品質
- **重複コード削減**: 約50行
- **テストカバレッジ**: 0% → 60%+ (Domain/ViewModel層)
- **コンポーネント再利用性**: 向上

---

## 🚨 注意事項

### リファクタリング時の懸念点
1. **@StateObject の挙動**: コンポーネント分離時にStateObjectの扱いに注意
2. **環境オブジェクトの伝播**: 分離後も`@EnvironmentObject`が正しく伝わるか確認
3. **テスト対象の`@MainActor`**: ViewModelテストは`@MainActor`で実行する必要がある

### 段階的実施の推奨
- 一度に全てを実施せず、Phaseごとに確認しながら進める
- 各Phase後にビルド成功とPreview動作を確認
- テストを先に書いてからリファクタリング（理想的）

---

## 📝 結論

### 推奨アクション
1. **即座に実施**: MockDataファイル作成とEmptyStateView分離
2. **優先実施**: Domain層のテスト実装（最も価値が高い）
3. **段階的実施**: コンポーネント分離とViewModel テスト

### 実施しなくても良いケース
- プロトタイプ段階で今後大幅な変更が予定されている場合
- チーム規模が1名で保守性よりスピード優先の場合

### 実施すべきケース
- 本番リリースを見据えている場合
- 複数人での開発を予定している場合
- 長期的な保守を想定している場合

**総合評価**: 現在のコードは**許容範囲内**だが、**テスト実装は優先度高**で推奨。コンポーネント分離は中期的な改善として検討価値あり。
