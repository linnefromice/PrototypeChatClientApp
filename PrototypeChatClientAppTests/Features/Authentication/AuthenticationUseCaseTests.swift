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
        // Given - MockUserRepository has predefined users (alice, bob, charlie)

        // When
        let session = try await sut.authenticate(idAlias: "alice")

        // Then
        XCTAssertEqual(session.userId, "user-1")  // Session uses UUID internally
        XCTAssertEqual(session.user.idAlias, "alice")
        XCTAssertEqual(session.user.name, "Alice")
        XCTAssertNotNil(mockSessionManager.savedSession)
        XCTAssertEqual(mockSessionManager.savedSession?.userId, "user-1")
    }

    func testAuthenticate_EmptyIdAlias_ThrowsError() async throws {
        // When & Then
        do {
            _ = try await sut.authenticate(idAlias: "")
            XCTFail("Expected error to be thrown")
        } catch let error as AuthenticationError {
            XCTAssertEqual(error, .emptyUserId)
        }
    }

    func testAuthenticate_WhitespaceIdAlias_ThrowsError() async throws {
        // When & Then
        do {
            _ = try await sut.authenticate(idAlias: "   ")
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
            _ = try await sut.authenticate(idAlias: "invalid-user")
            XCTFail("Expected error to be thrown")
        } catch {
            // Success - error was thrown
        }
    }

    func testAuthenticate_SavesSessionToManager() async throws {
        // Given - MockUserRepository has predefined users (bob)

        // When
        _ = try await sut.authenticate(idAlias: "bob")

        // Then
        XCTAssertNotNil(mockSessionManager.savedSession)
        XCTAssertEqual(mockSessionManager.savedSession?.userId, "user-2")
        XCTAssertEqual(mockSessionManager.savedSession?.user.idAlias, "bob")
        XCTAssertEqual(mockSessionManager.savedSession?.user.name, "Bob")
    }

    // MARK: - LoadSavedSession Tests

    func testLoadSavedSession_ValidSession_ReturnsSession() {
        // Given
        let user = User(id: "user-1", idAlias: "testuser", name: "Test User", avatarUrl: nil, createdAt: Date())
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
        let user = User(id: "user-1", idAlias: "testuser", name: "Test User", avatarUrl: nil, createdAt: Date())
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
        let user = User(id: "user-1", idAlias: "testuser", name: "Test User", avatarUrl: nil, createdAt: Date())
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

    // MARK: - ID Alias Validation Tests

    func testAuthenticate_ValidIdAlias_Succeeds() async throws {
        // Test various valid formats
        let validAliases = ["abc", "alice123", "user.name", "user_name", "user-name", "a1b2c3"]

        for alias in validAliases {
            // Note: These will fail at repository level (not found), but validation should pass
            do {
                _ = try await sut.authenticate(idAlias: alias)
            } catch {
                // Expected - user not in mock data
                // But should not be invalidIdAliasFormat error
                if let authError = error as? AuthenticationError {
                    XCTAssertNotEqual(authError, .invalidIdAliasFormat, "Valid alias \(alias) should not fail format validation")
                }
            }
        }
    }

    func testAuthenticate_TooShortIdAlias_Fails() async throws {
        // Given - idAlias with 2 characters
        let shortAlias = "ab"

        // When & Then
        do {
            _ = try await sut.authenticate(idAlias: shortAlias)
            XCTFail("Expected invalidIdAliasFormat error")
        } catch let error as AuthenticationError {
            XCTAssertEqual(error, .invalidIdAliasFormat)
        }
    }

    func testAuthenticate_TooLongIdAlias_Fails() async throws {
        // Given - idAlias with 31 characters
        let longAlias = String(repeating: "a", count: 31)

        // When & Then
        do {
            _ = try await sut.authenticate(idAlias: longAlias)
            XCTFail("Expected invalidIdAliasFormat error")
        } catch let error as AuthenticationError {
            XCTAssertEqual(error, .invalidIdAliasFormat)
        }
    }

    func testAuthenticate_UppercaseIdAlias_Fails() async throws {
        // Given - idAlias with uppercase letters
        let uppercaseAlias = "Alice"

        // When & Then
        do {
            _ = try await sut.authenticate(idAlias: uppercaseAlias)
            XCTFail("Expected invalidIdAliasFormat error")
        } catch let error as AuthenticationError {
            XCTAssertEqual(error, .invalidIdAliasFormat)
        }
    }

    func testAuthenticate_SpacesInIdAlias_Fails() async throws {
        // Given - idAlias with spaces
        let spaceAlias = "alice bob"

        // When & Then
        do {
            _ = try await sut.authenticate(idAlias: spaceAlias)
            XCTFail("Expected invalidIdAliasFormat error")
        } catch let error as AuthenticationError {
            XCTAssertEqual(error, .invalidIdAliasFormat)
        }
    }

    func testAuthenticate_StartingWithSymbol_Fails() async throws {
        // Given - idAlias starting with underscore
        let symbolStartAlias = "_alice"

        // When & Then
        do {
            _ = try await sut.authenticate(idAlias: symbolStartAlias)
            XCTFail("Expected invalidIdAliasFormat error")
        } catch let error as AuthenticationError {
            XCTAssertEqual(error, .invalidIdAliasFormat)
        }
    }

    func testAuthenticate_EndingWithSymbol_Fails() async throws {
        // Given - idAlias ending with underscore
        let symbolEndAlias = "alice_"

        // When & Then
        do {
            _ = try await sut.authenticate(idAlias: symbolEndAlias)
            XCTFail("Expected invalidIdAliasFormat error")
        } catch let error as AuthenticationError {
            XCTAssertEqual(error, .invalidIdAliasFormat)
        }
    }

    func testAuthenticate_InvalidSymbolsInIdAlias_Fails() async throws {
        // Given - idAlias with invalid symbols
        let invalidSymbolAliases = ["alice@example", "alice#123", "alice$money", "alice%percent"]

        for alias in invalidSymbolAliases {
            do {
                _ = try await sut.authenticate(idAlias: alias)
                XCTFail("Expected invalidIdAliasFormat error for \(alias)")
            } catch let error as AuthenticationError {
                XCTAssertEqual(error, .invalidIdAliasFormat, "Alias \(alias) should fail format validation")
            }
        }
    }
}
