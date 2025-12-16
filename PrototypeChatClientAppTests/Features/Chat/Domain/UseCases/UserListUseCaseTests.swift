import XCTest
@testable import PrototypeChatClientApp

final class UserListUseCaseTests: XCTestCase {
    var sut: UserListUseCase!
    var mockRepository: MockUserRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockUserRepository()
        mockRepository.delay = 0 // テストを高速化
        sut = UserListUseCase(userRepository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - fetchAvailableUsers Tests

    func test_fetchAvailableUsers_excludesCurrentUser() async throws {
        // Given
        let currentUserId = "user-1"

        // When
        let result = try await sut.fetchAvailableUsers(excludingUserId: currentUserId)

        // Then
        let resultIds = result.map { $0.id }
        XCTAssertFalse(resultIds.contains(currentUserId), "現在のユーザーが結果に含まれないべき")
        XCTAssertEqual(result.count, 2, "Alice以外の2名のユーザーが返されるべき")
    }

    func test_fetchAvailableUsers_returnsAllOtherUsers() async throws {
        // Given
        let currentUserId = "user-1"

        // When
        let result = try await sut.fetchAvailableUsers(excludingUserId: currentUserId)

        // Then
        let resultIds = result.map { $0.id }
        XCTAssertTrue(resultIds.contains("user-2"), "Bobが含まれるべき")
        XCTAssertTrue(resultIds.contains("user-3"), "Charlieが含まれるべき")
        XCTAssertEqual(result.count, 2, "2名のユーザーが返されるべき")
    }

    func test_fetchAvailableUsers_handlesEmptyList() async throws {
        // Given
        let currentUserId = "user-999"
        // MockUserRepositoryは3名のユーザーを返すが、全員除外されない

        // When
        let result = try await sut.fetchAvailableUsers(excludingUserId: currentUserId)

        // Then
        XCTAssertEqual(result.count, 3, "除外するユーザーがいない場合は全員返されるべき")
    }

    func test_fetchAvailableUsers_propagatesRepositoryError() async {
        // Given
        let currentUserId = "user-1"
        mockRepository.shouldFail = true

        // When/Then
        do {
            _ = try await sut.fetchAvailableUsers(excludingUserId: currentUserId)
            XCTFail("エラーがスローされるべき")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, "MockError")
            XCTAssertEqual(error.code, 500)
        }
    }

    func test_fetchAvailableUsers_currentUserNotInList() async throws {
        // Given
        let currentUserId = "user-999" // リストに存在しないユーザー

        // When
        let result = try await sut.fetchAvailableUsers(excludingUserId: currentUserId)

        // Then
        XCTAssertEqual(result.count, 3, "フィルタリング対象がいない場合は全ユーザーが返されるべき")
        let resultIds = result.map { $0.id }
        XCTAssertTrue(resultIds.contains("user-1"))
        XCTAssertTrue(resultIds.contains("user-2"))
        XCTAssertTrue(resultIds.contains("user-3"))
    }

    func test_fetchAvailableUsers_differentCurrentUser() async throws {
        // Given
        let currentUserId = "user-2" // Bob

        // When
        let result = try await sut.fetchAvailableUsers(excludingUserId: currentUserId)

        // Then
        let resultIds = result.map { $0.id }
        XCTAssertFalse(resultIds.contains("user-2"), "Bobが除外されるべき")
        XCTAssertTrue(resultIds.contains("user-1"), "Aliceが含まれるべき")
        XCTAssertTrue(resultIds.contains("user-3"), "Charlieが含まれるべき")
        XCTAssertEqual(result.count, 2)
    }

    func test_fetchAvailableUsers_preservesUserData() async throws {
        // Given
        let currentUserId = "user-1"

        // When
        let result = try await sut.fetchAvailableUsers(excludingUserId: currentUserId)

        // Then
        let bob = result.first { $0.id == "user-2" }
        XCTAssertNotNil(bob, "Bobが結果に含まれるべき")
        XCTAssertEqual(bob?.name, "Bob", "ユーザー名が保持されるべき")
        XCTAssertNotNil(bob?.createdAt, "作成日時が保持されるべき")
    }
}
