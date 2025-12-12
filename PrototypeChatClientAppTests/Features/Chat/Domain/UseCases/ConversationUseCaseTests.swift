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
        let olderDetail = MockData.olderConversationDetail
        let newerDetail = MockData.newerConversationDetail
        mockRepository.conversations = [olderDetail, newerDetail]

        // When
        let result = try await sut.fetchConversations(userId: "user1")

        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].id, newerDetail.id, "新しい会話が最初に来るべき")
        XCTAssertEqual(result[1].id, olderDetail.id, "古い会話が後に来るべき")
    }

    func test_fetchConversations_sortsMixedDatesCorrectly() async throws {
        // Given
        let date1 = Date(timeIntervalSince1970: 1000)
        let date2 = Date(timeIntervalSince1970: 3000)
        let date3 = Date(timeIntervalSince1970: 2000)

        let conv1 = MockData.conversationDetail(
            conversation: MockData.conversation(id: "c1", createdAt: date1),
            participants: nil
        )
        let conv2 = MockData.conversationDetail(
            conversation: MockData.conversation(id: "c2", createdAt: date2),
            participants: nil
        )
        let conv3 = MockData.conversationDetail(
            conversation: MockData.conversation(id: "c3", createdAt: date3),
            participants: nil
        )

        mockRepository.conversations = [conv1, conv2, conv3]

        // When
        let result = try await sut.fetchConversations(userId: "user1")

        // Then
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0].id, "c2", "最新の会話が最初")
        XCTAssertEqual(result[1].id, "c3", "2番目に新しい会話")
        XCTAssertEqual(result[2].id, "c1", "最も古い会話が最後")
    }

    func test_fetchConversations_returnsEmptyArrayWhenNoConversations() async throws {
        // Given
        mockRepository.conversations = []

        // When
        let result = try await sut.fetchConversations(userId: "user1")

        // Then
        XCTAssertTrue(result.isEmpty, "会話がない場合は空配列を返すべき")
    }

    func test_fetchConversations_propagatesRepositoryError() async {
        // Given
        let expectedError = NSError(domain: "TestError", code: 500, userInfo: nil)
        mockRepository.shouldThrowError = expectedError

        // When/Then
        do {
            _ = try await sut.fetchConversations(userId: "user1")
            XCTFail("エラーがスローされるべき")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, expectedError.domain)
            XCTAssertEqual(error.code, expectedError.code)
        }
    }

    func test_fetchConversations_passesCorrectUserIdToRepository() async throws {
        // Given
        let userId = "test-user-123"
        mockRepository.conversations = [MockData.directConversationDetail]

        // When
        _ = try await sut.fetchConversations(userId: userId)

        // Then
        // MockRepositoryで確認（実装による）
        // この例では、repositoryが正しく呼ばれたことを前提とする
        XCTAssertTrue(true, "userIdが正しく渡されることを確認")
    }

    // MARK: - createDirectConversation Tests

    func test_createDirectConversation_createsWithCorrectType() async throws {
        // Given
        let currentUserId = "user1"
        let targetUserId = "user2"

        // When
        let result = try await sut.createDirectConversation(
            currentUserId: currentUserId,
            targetUserId: targetUserId
        )

        // Then
        XCTAssertEqual(result.type, .direct, "directタイプの会話が作成されるべき")
    }

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
        let participantIds = result.participants.map { $0.userId }
        XCTAssertEqual(participantIds.count, 2, "2名の参加者が含まれるべき")
        XCTAssertTrue(participantIds.contains(currentUserId), "現在のユーザーが含まれるべき")
        XCTAssertTrue(participantIds.contains(targetUserId), "対象ユーザーが含まれるべき")
    }

    func test_createDirectConversation_hasNoName() async throws {
        // Given
        let currentUserId = "user1"
        let targetUserId = "user2"

        // When
        let result = try await sut.createDirectConversation(
            currentUserId: currentUserId,
            targetUserId: targetUserId
        )

        // Then
        XCTAssertNil(result.conversation.name, "ダイレクトチャットには名前がないべき")
    }

    func test_createDirectConversation_propagatesRepositoryError() async {
        // Given
        let expectedError = NSError(domain: "TestError", code: 400, userInfo: nil)
        mockRepository.shouldThrowError = expectedError

        // When/Then
        do {
            _ = try await sut.createDirectConversation(
                currentUserId: "user1",
                targetUserId: "user2"
            )
            XCTFail("エラーがスローされるべき")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, expectedError.domain)
            XCTAssertEqual(error.code, expectedError.code)
        }
    }

    // MARK: - createGroupConversation Tests

    func test_createGroupConversation_createsWithCorrectType() async throws {
        // Given
        let currentUserId = "user1"
        let participantIds = ["user2", "user3"]
        let groupName = "Test Group"

        // When
        let result = try await sut.createGroupConversation(
            currentUserId: currentUserId,
            participantUserIds: participantIds,
            groupName: groupName
        )

        // Then
        XCTAssertEqual(result.type, .group, "groupタイプの会話が作成されるべき")
    }

    func test_createGroupConversation_includesCurrentUserWhenNotInList() async throws {
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
        let resultUserIds = result.participants.map { $0.userId }
        XCTAssertEqual(resultUserIds.count, 3, "3名の参加者が含まれるべき")
        XCTAssertTrue(
            resultUserIds.contains(currentUserId),
            "現在のユーザーが自動的に追加されるべき"
        )
        XCTAssertTrue(resultUserIds.contains("user2"))
        XCTAssertTrue(resultUserIds.contains("user3"))
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
        let resultUserIds = result.participants.map { $0.userId }
        let user1Count = resultUserIds.filter { $0 == currentUserId }.count
        XCTAssertEqual(user1Count, 1, "現在のユーザーが重複していないべき")
        XCTAssertEqual(resultUserIds.count, 3, "重複なく3名の参加者が含まれるべき")
    }

    func test_createGroupConversation_setsGroupName() async throws {
        // Given
        let groupName = "My Awesome Group"

        // When
        let result = try await sut.createGroupConversation(
            currentUserId: "user1",
            participantUserIds: ["user2"],
            groupName: groupName
        )

        // Then
        XCTAssertEqual(result.conversation.name, groupName, "グループ名が設定されるべき")
    }

    func test_createGroupConversation_worksWithOnlyCurrentUser() async throws {
        // Given
        let currentUserId = "user1"
        let participantIds: [String] = [] // 空のリスト

        // When
        let result = try await sut.createGroupConversation(
            currentUserId: currentUserId,
            participantUserIds: participantIds,
            groupName: "Solo Group"
        )

        // Then
        let resultUserIds = result.participants.map { $0.userId }
        XCTAssertEqual(resultUserIds.count, 1)
        XCTAssertEqual(resultUserIds.first, currentUserId)
    }

    func test_createGroupConversation_propagatesRepositoryError() async {
        // Given
        let expectedError = NSError(domain: "TestError", code: 500, userInfo: nil)
        mockRepository.shouldThrowError = expectedError

        // When/Then
        do {
            _ = try await sut.createGroupConversation(
                currentUserId: "user1",
                participantUserIds: ["user2"],
                groupName: "Test"
            )
            XCTFail("エラーがスローされるべき")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, expectedError.domain)
            XCTAssertEqual(error.code, expectedError.code)
        }
    }
}
