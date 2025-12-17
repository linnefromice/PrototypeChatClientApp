import XCTest
@testable import PrototypeChatClientApp

/// Unit tests for CreateConversationViewModel
@MainActor
final class CreateConversationViewModelTests: XCTestCase {

    var sut: CreateConversationViewModel!
    var mockConversationUseCase: MockConversationUseCase!
    var mockUserListUseCase: MockUserListUseCase!

    override func setUp() async throws {
        try await super.setUp()
        mockConversationUseCase = MockConversationUseCase()
        mockUserListUseCase = MockUserListUseCase()
        sut = CreateConversationViewModel(
            conversationUseCase: mockConversationUseCase,
            userListUseCase: mockUserListUseCase,
            currentUserId: "current-user"
        )
    }

    override func tearDown() async throws {
        sut = nil
        mockConversationUseCase = nil
        mockUserListUseCase = nil
        try await super.tearDown()
    }

    // MARK: - Conversation Type Tests

    func testConversationType_DefaultIsDirect() {
        XCTAssertEqual(sut.conversationType, .direct)
    }

    func testConversationType_CanSwitchToGroup() {
        sut.conversationType = .group
        XCTAssertEqual(sut.conversationType, .group)
    }

    // MARK: - User Selection Tests (Group Mode)

    func testToggleUserSelection_AddsUser() {
        sut.conversationType = .group
        sut.toggleUserSelection("user-1")

        XCTAssertTrue(sut.selectedUserIds.contains("user-1"))
        XCTAssertEqual(sut.selectedUserIds.count, 1)
    }

    func testToggleUserSelection_RemovesUser() {
        sut.conversationType = .group
        sut.toggleUserSelection("user-1")
        sut.toggleUserSelection("user-1")

        XCTAssertFalse(sut.selectedUserIds.contains("user-1"))
        XCTAssertEqual(sut.selectedUserIds.count, 0)
    }

    func testToggleUserSelection_MultipleUsers() {
        sut.conversationType = .group
        sut.toggleUserSelection("user-1")
        sut.toggleUserSelection("user-2")
        sut.toggleUserSelection("user-3")

        XCTAssertTrue(sut.selectedUserIds.contains("user-1"))
        XCTAssertTrue(sut.selectedUserIds.contains("user-2"))
        XCTAssertTrue(sut.selectedUserIds.contains("user-3"))
        XCTAssertEqual(sut.selectedUserIds.count, 3)
    }

    // MARK: - canCreate Validation Tests (Direct Mode)

    func testCanCreate_DirectMode_FalseWhenNoUserSelected() {
        sut.conversationType = .direct
        sut.selectedUserId = nil

        XCTAssertFalse(sut.canCreate)
    }

    func testCanCreate_DirectMode_TrueWhenUserSelected() {
        sut.conversationType = .direct
        sut.selectedUserId = "user-1"

        XCTAssertTrue(sut.canCreate)
    }

    func testCanCreate_DirectMode_FalseWhenLoading() {
        sut.conversationType = .direct
        sut.selectedUserId = "user-1"
        sut.isLoading = true

        XCTAssertFalse(sut.canCreate)
    }

    // MARK: - canCreate Validation Tests (Group Mode)

    func testCanCreate_GroupMode_FalseWhenNoUsers() {
        sut.conversationType = .group
        sut.groupName = "Test Group"
        sut.selectedUserIds = []

        XCTAssertFalse(sut.canCreate)
    }

    func testCanCreate_GroupMode_FalseWhenOnlyOneUser() {
        sut.conversationType = .group
        sut.groupName = "Test Group"
        sut.toggleUserSelection("user-1")

        XCTAssertFalse(sut.canCreate)
    }

    func testCanCreate_GroupMode_FalseWhenGroupNameEmpty() {
        sut.conversationType = .group
        sut.groupName = ""
        sut.toggleUserSelection("user-1")
        sut.toggleUserSelection("user-2")

        XCTAssertFalse(sut.canCreate)
    }

    func testCanCreate_GroupMode_FalseWhenGroupNameWhitespace() {
        sut.conversationType = .group
        sut.groupName = "   "
        sut.toggleUserSelection("user-1")
        sut.toggleUserSelection("user-2")

        XCTAssertFalse(sut.canCreate)
    }

    func testCanCreate_GroupMode_TrueWhenValid() {
        sut.conversationType = .group
        sut.groupName = "Test Group"
        sut.toggleUserSelection("user-1")
        sut.toggleUserSelection("user-2")

        XCTAssertTrue(sut.canCreate)
    }

    func testCanCreate_GroupMode_FalseWhenLoading() {
        sut.conversationType = .group
        sut.groupName = "Test Group"
        sut.toggleUserSelection("user-1")
        sut.toggleUserSelection("user-2")
        sut.isLoading = true

        XCTAssertFalse(sut.canCreate)
    }

    // MARK: - Group Chat Creation Tests

    func testCreateGroupConversation_Success() async throws {
        // Given
        sut.conversationType = .group
        sut.groupName = "Test Group"
        sut.toggleUserSelection("user-1")
        sut.toggleUserSelection("user-2")

        let expectedConversation = ConversationDetail(
            conversation: Conversation(
                id: "conv-1",
                type: .group,
                name: "Test Group",
                createdAt: Date()
            ),
            participants: []
        )
        mockConversationUseCase.mockGroupConversation = expectedConversation

        // When
        await sut.createGroupConversation()

        // Then
        XCTAssertNotNil(sut.createdConversation)
        XCTAssertEqual(sut.createdConversation?.id, "conv-1")
        XCTAssertEqual(sut.createdConversation?.conversation.name, "Test Group")
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.showError)
        XCTAssertFalse(sut.isLoading)
    }

    func testCreateGroupConversation_FailsWhenGroupNameEmpty() async throws {
        // Given
        sut.conversationType = .group
        sut.groupName = ""
        sut.toggleUserSelection("user-1")
        sut.toggleUserSelection("user-2")

        // When
        await sut.createGroupConversation()

        // Then
        XCTAssertNil(sut.createdConversation)
        XCTAssertEqual(sut.errorMessage, "グループ名を入力してください")
        XCTAssertTrue(sut.showError)
        XCTAssertFalse(sut.isLoading)
    }

    func testCreateGroupConversation_FailsWhenLessThanTwoUsers() async throws {
        // Given
        sut.conversationType = .group
        sut.groupName = "Test Group"
        sut.toggleUserSelection("user-1")

        // When
        await sut.createGroupConversation()

        // Then
        XCTAssertNil(sut.createdConversation)
        XCTAssertEqual(sut.errorMessage, "参加者を2人以上選択してください")
        XCTAssertTrue(sut.showError)
        XCTAssertFalse(sut.isLoading)
    }

    func testCreateGroupConversation_TrimsGroupName() async throws {
        // Given
        sut.conversationType = .group
        sut.groupName = "  Test Group  "
        sut.toggleUserSelection("user-1")
        sut.toggleUserSelection("user-2")

        let expectedConversation = ConversationDetail(
            conversation: Conversation(
                id: "conv-1",
                type: .group,
                name: "Test Group",
                createdAt: Date()
            ),
            participants: []
        )
        mockConversationUseCase.mockGroupConversation = expectedConversation

        // When
        await sut.createGroupConversation()

        // Then - Verify trimmed name was used
        XCTAssertEqual(mockConversationUseCase.lastGroupName, "Test Group")
    }

    func testCreateGroupConversation_HandlesError() async throws {
        // Given
        sut.conversationType = .group
        sut.groupName = "Test Group"
        sut.toggleUserSelection("user-1")
        sut.toggleUserSelection("user-2")

        struct TestError: Error {}
        mockConversationUseCase.shouldThrowError = TestError()

        // When
        await sut.createGroupConversation()

        // Then
        XCTAssertNil(sut.createdConversation)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.showError)
        XCTAssertFalse(sut.isLoading)
    }
}

// MARK: - Mock ConversationUseCase

class MockConversationUseCase: ConversationUseCase {
    var mockDirectConversation: ConversationDetail?
    var mockGroupConversation: ConversationDetail?
    var shouldThrowError: Error?
    var lastGroupName: String?
    var lastParticipantIds: [String]?

    init() {
        let mockRepo = MockConversationRepository()
        super.init(conversationRepository: mockRepo)
    }

    override func createDirectConversation(currentUserId: String, targetUserId: String) async throws -> ConversationDetail {
        if let error = shouldThrowError {
            throw error
        }
        return mockDirectConversation ?? ConversationDetail(
            conversation: Conversation(id: "conv-1", type: .direct, name: nil, createdAt: Date()),
            participants: []
        )
    }

    override func createGroupConversation(currentUserId: String, participantUserIds: [String], groupName: String) async throws -> ConversationDetail {
        lastGroupName = groupName
        lastParticipantIds = participantUserIds

        if let error = shouldThrowError {
            throw error
        }
        return mockGroupConversation ?? ConversationDetail(
            conversation: Conversation(id: "conv-1", type: .group, name: groupName, createdAt: Date()),
            participants: []
        )
    }
}

// MARK: - Mock UserListUseCase

class MockUserListUseCase: UserListUseCase {
    var mockUsers: [User] = []
    var shouldThrowError: Error?

    init() {
        let mockRepo = MockUserRepository()
        super.init(userRepository: mockRepo)
    }

    override func fetchAvailableUsers(excludingUserId: String) async throws -> [User] {
        if let error = shouldThrowError {
            throw error
        }
        return mockUsers
    }
}
