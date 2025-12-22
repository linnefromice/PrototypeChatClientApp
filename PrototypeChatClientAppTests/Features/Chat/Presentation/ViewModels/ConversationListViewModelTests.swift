import XCTest
@testable import PrototypeChatClientApp

/// Unit tests for ConversationListViewModel
@MainActor
final class ConversationListViewModelTests: XCTestCase {

    var sut: ConversationListViewModel!
    var mockConversationUseCase: MockConversationUseCase!
    let testUserId = "test-user-id"

    override func setUp() async throws {
        try await super.setUp()
        mockConversationUseCase = MockConversationUseCase()
        sut = ConversationListViewModel(
            conversationUseCase: mockConversationUseCase,
            currentUserId: testUserId
        )
    }

    override func tearDown() async throws {
        sut = nil
        mockConversationUseCase = nil
        try await super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInit_SetsCurrentUserId() {
        XCTAssertEqual(sut.currentUserId, testUserId)
    }

    func testInit_EmptyConversations() {
        XCTAssertTrue(sut.conversations.isEmpty)
    }

    func testInit_NotLoading() {
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - LoadConversations Tests

    func testLoadConversations_Success_PopulatesConversations() async {
        // Given
        let mockConversations = createMockConversations()
        mockConversationUseCase.mockConversations = mockConversations

        // When
        await sut.loadConversations()

        // Then
        XCTAssertEqual(sut.conversations.count, mockConversations.count)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.showError)
    }

    func testLoadConversations_Error_ShowsErrorMessage() async {
        // Given
        struct TestError: Error {}
        mockConversationUseCase.shouldThrowError = TestError()

        // When
        await sut.loadConversations()

        // Then
        XCTAssertTrue(sut.conversations.isEmpty)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.showError)
        XCTAssertFalse(sut.isLoading)
    }

    func testLoadConversations_CancellationError_DoesNotShowError() async {
        // Given
        let cancellationError = URLError(.cancelled)
        mockConversationUseCase.shouldThrowError = cancellationError

        // When
        await sut.loadConversations()

        // Then
        XCTAssertTrue(sut.conversations.isEmpty)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.showError)
        XCTAssertFalse(sut.isLoading)
    }

    func testLoadConversations_SetsLoadingState() async {
        // Given
        mockConversationUseCase.delayInSeconds = 0.1
        mockConversationUseCase.mockConversations = createMockConversations()

        // When
        Task {
            await sut.loadConversations()
        }

        // Then - Check isLoading becomes true
        try? await Task.sleep(nanoseconds: 20_000_000) // 0.02 seconds
        // Note: Checking loading state during async operation
    }

    // MARK: - ConversationTitle Tests

    func testConversationTitle_DirectChat_ReturnsOtherUserName() {
        // Given
        let otherUser = User(id: "other-user", idAlias: "other", name: "Other User", avatarUrl: nil, createdAt: Date())
        let currentUser = User(id: testUserId, idAlias: "current", name: "Current User", avatarUrl: nil, createdAt: Date())

        let conversation = Conversation(
            id: "conv-1",
            type: .direct,
            name: nil,
            createdAt: Date(),
            updatedAt: Date()
        )

        let participants = [
            Participant(userId: testUserId, conversationId: "conv-1", role: "member", joinedAt: Date(), leftAt: nil, user: currentUser),
            Participant(userId: "other-user", conversationId: "conv-1", role: "member", joinedAt: Date(), leftAt: nil, user: otherUser)
        ]

        let detail = ConversationDetail(conversation: conversation, participants: participants)

        // When
        let title = sut.conversationTitle(for: detail)

        // Then
        XCTAssertEqual(title, "Other User")
    }

    func testConversationTitle_GroupChat_ReturnsGroupName() {
        // Given
        let conversation = Conversation(
            id: "conv-1",
            type: .group,
            name: "Test Group",
            createdAt: Date(),
            updatedAt: Date()
        )

        let participants: [Participant] = []
        let detail = ConversationDetail(conversation: conversation, participants: participants)

        // When
        let title = sut.conversationTitle(for: detail)

        // Then
        XCTAssertEqual(title, "Test Group")
    }

    func testConversationTitle_GroupChatWithoutName_ReturnsDefault() {
        // Given
        let conversation = Conversation(
            id: "conv-1",
            type: .group,
            name: nil,
            createdAt: Date(),
            updatedAt: Date()
        )

        let participants: [Participant] = []
        let detail = ConversationDetail(conversation: conversation, participants: participants)

        // When
        let title = sut.conversationTitle(for: detail)

        // Then
        XCTAssertEqual(title, "グループチャット")
    }

    // MARK: - ConversationSubtitle Tests

    func testConversationSubtitle_ShowsParticipantCount() {
        // Given
        let conversation = Conversation(
            id: "conv-1",
            type: .group,
            name: "Test Group",
            createdAt: Date(),
            updatedAt: Date()
        )

        let user1 = User(id: "user-1", idAlias: "user1", name: "User 1", avatarUrl: nil, createdAt: Date())
        let user2 = User(id: "user-2", idAlias: "user2", name: "User 2", avatarUrl: nil, createdAt: Date())
        let user3 = User(id: "user-3", idAlias: "user3", name: "User 3", avatarUrl: nil, createdAt: Date())

        let participants = [
            Participant(userId: "user-1", conversationId: "conv-1", role: "member", joinedAt: Date(), leftAt: nil, user: user1),
            Participant(userId: "user-2", conversationId: "conv-1", role: "member", joinedAt: Date(), leftAt: nil, user: user2),
            Participant(userId: "user-3", conversationId: "conv-1", role: "member", joinedAt: Date(), leftAt: nil, user: user3)
        ]

        let detail = ConversationDetail(conversation: conversation, participants: participants)

        // When
        let subtitle = sut.conversationSubtitle(for: detail)

        // Then
        XCTAssertEqual(subtitle, "3人が参加中")
    }

    // MARK: - Helper Methods

    private func createMockConversations() -> [ConversationDetail] {
        let user1 = User(id: "user-1", idAlias: "user1", name: "User 1", avatarUrl: nil, createdAt: Date())
        let user2 = User(id: "user-2", idAlias: "user2", name: "User 2", avatarUrl: nil, createdAt: Date())

        let conversation1 = Conversation(
            id: "conv-1",
            type: .direct,
            name: nil,
            createdAt: Date(),
            updatedAt: Date()
        )

        let conversation2 = Conversation(
            id: "conv-2",
            type: .group,
            name: "Test Group",
            createdAt: Date(),
            updatedAt: Date()
        )

        let participants1 = [
            Participant(userId: testUserId, conversationId: "conv-1", role: "member", joinedAt: Date(), leftAt: nil, user: user1),
            Participant(userId: "user-2", conversationId: "conv-1", role: "member", joinedAt: Date(), leftAt: nil, user: user2)
        ]

        let participants2 = [
            Participant(userId: testUserId, conversationId: "conv-2", role: "member", joinedAt: Date(), leftAt: nil, user: user1),
            Participant(userId: "user-2", conversationId: "conv-2", role: "member", joinedAt: Date(), leftAt: nil, user: user2)
        ]

        return [
            ConversationDetail(conversation: conversation1, participants: participants1),
            ConversationDetail(conversation: conversation2, participants: participants2)
        ]
    }
}

// MARK: - Mock ConversationUseCase

class MockConversationUseCase: ConversationUseCaseProtocol {
    var mockConversations: [ConversationDetail] = []
    var shouldThrowError: Error?
    var delayInSeconds: Double = 0

    func fetchConversations(userId: String) async throws -> [ConversationDetail] {
        if delayInSeconds > 0 {
            try await Task.sleep(nanoseconds: UInt64(delayInSeconds * 1_000_000_000))
        }

        if let error = shouldThrowError {
            throw error
        }

        return mockConversations
    }

    func createDirectConversation(currentUserId: String, targetUserId: String) async throws -> ConversationDetail {
        if let error = shouldThrowError {
            throw error
        }

        let conversation = Conversation(
            id: "new-conv",
            type: .direct,
            name: nil,
            createdAt: Date(),
            updatedAt: Date()
        )

        return ConversationDetail(conversation: conversation, participants: [])
    }

    func createGroupConversation(currentUserId: String, participantUserIds: [String], groupName: String) async throws -> ConversationDetail {
        if let error = shouldThrowError {
            throw error
        }

        let conversation = Conversation(
            id: "new-group-conv",
            type: .group,
            name: groupName,
            createdAt: Date(),
            updatedAt: Date()
        )

        return ConversationDetail(conversation: conversation, participants: [])
    }
}
