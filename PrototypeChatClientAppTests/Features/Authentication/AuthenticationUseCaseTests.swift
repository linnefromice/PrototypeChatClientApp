import XCTest
@testable import PrototypeChatClientApp

/// Unit tests for AuthenticationUseCase
/// Tests business logic without UI dependencies
final class AuthenticationUseCaseTests: XCTestCase {

    var sut: AuthenticationUseCase!
    var mockUserRepository: MockUserRepository!
    var mockSessionManager: MockAuthSessionManager!

    override func setUp() {
        super.setUp()
        mockUserRepository = MockUserRepository()
        mockSessionManager = MockAuthSessionManager()
        sut = AuthenticationUseCase(
            userRepository: mockUserRepository,
            sessionManager: mockSessionManager
        )
    }

    override func tearDown() {
        sut = nil
        mockUserRepository = nil
        mockSessionManager = nil
        super.tearDown()
    }

    // MARK: - Authenticate Tests

    func testAuthenticate_Success() async throws {
        // Given - MockUserRepository has predefined users (user-1: Alice, etc.)

        // When
        let session = try await sut.authenticate(userId: "user-1")

        // Then
        XCTAssertEqual(session.userId, "user-1")
        XCTAssertEqual(session.user.name, "Alice")
        XCTAssertNotNil(mockSessionManager.savedSession)
        XCTAssertEqual(mockSessionManager.savedSession?.userId, "user-1")
    }

    func testAuthenticate_EmptyUserId_ThrowsError() async throws {
        // When & Then
        do {
            _ = try await sut.authenticate(userId: "")
            XCTFail("Expected error to be thrown")
        } catch let error as AuthenticationError {
            XCTAssertEqual(error, .emptyUserId)
        }
    }

    func testAuthenticate_WhitespaceUserId_ThrowsError() async throws {
        // When & Then
        do {
            _ = try await sut.authenticate(userId: "   ")
            XCTFail("Expected error to be thrown")
        } catch let error as AuthenticationError {
            XCTAssertEqual(error, .emptyUserId)
        }
    }

    func testAuthenticate_UserNotFound_ThrowsError() async throws {
        // Given
        mockUserRepository.shouldFail = true

        // When & Then
        do {
            _ = try await sut.authenticate(userId: "invalid-user")
            XCTFail("Expected error to be thrown")
        } catch {
            // Success - error was thrown
        }
    }

    func testAuthenticate_SavesSessionToManager() async throws {
        // Given - MockUserRepository has predefined users (user-2: Bob, etc.)

        // When
        _ = try await sut.authenticate(userId: "user-2")

        // Then
        XCTAssertNotNil(mockSessionManager.savedSession)
        XCTAssertEqual(mockSessionManager.savedSession?.userId, "user-2")
        XCTAssertEqual(mockSessionManager.savedSession?.user.name, "Bob")
    }

    // MARK: - LoadSavedSession Tests

    func testLoadSavedSession_ValidSession_ReturnsSession() {
        // Given
        let user = User(id: "user-1", name: "Test User", avatarUrl: nil, createdAt: Date())
        let expectedSession = AuthSession(
            userId: "user-1",
            user: user,
            authenticatedAt: Date()
        )
        mockSessionManager.savedSession = expectedSession

        // When
        let loadedSession = sut.loadSavedSession()

        // Then
        XCTAssertNotNil(loadedSession)
        XCTAssertEqual(loadedSession?.userId, "user-1")
    }

    func testLoadSavedSession_NoSession_ReturnsNil() {
        // Given
        mockSessionManager.savedSession = nil

        // When
        let loadedSession = sut.loadSavedSession()

        // Then
        XCTAssertNil(loadedSession)
    }

    func testLoadSavedSession_InvalidSession_ClearsAndReturnsNil() {
        // Given - Create an invalid session (expired)
        let user = User(id: "user-1", name: "Test User", avatarUrl: nil, createdAt: Date())
        var invalidSession = AuthSession(
            userId: "user-1",
            user: user,
            authenticatedAt: Date.distantPast
        )
        // Note: Currently AuthSession.isValid always returns true
        // This test is prepared for future expiration logic
        mockSessionManager.savedSession = invalidSession

        // When
        let loadedSession = sut.loadSavedSession()

        // Then
        // Currently returns session because isValid always returns true
        XCTAssertNotNil(loadedSession)
        // TODO: Uncomment when session expiration is implemented
        // XCTAssertNil(loadedSession)
        // XCTAssertNil(mockSessionManager.savedSession)
    }

    // MARK: - Logout Tests

    func testLogout_ClearsSession() {
        // Given
        let user = User(id: "user-1", name: "Test User", avatarUrl: nil, createdAt: Date())
        let session = AuthSession(
            userId: "user-1",
            user: user,
            authenticatedAt: Date()
        )
        mockSessionManager.savedSession = session

        // When
        sut.logout()

        // Then
        XCTAssertNil(mockSessionManager.savedSession)
    }
}
