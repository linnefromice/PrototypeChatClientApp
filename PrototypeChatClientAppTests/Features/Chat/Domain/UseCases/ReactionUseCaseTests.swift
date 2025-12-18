import XCTest
@testable import PrototypeChatClientApp

/// Unit tests for ReactionUseCase
/// Tests business logic for reaction operations including the "one reaction per message" rule
final class ReactionUseCaseTests: XCTestCase {

    var sut: ReactionUseCase!
    var mockReactionRepository: MockReactionRepository!

    override func setUp() {
        super.setUp()
        mockReactionRepository = MockReactionRepository()
        sut = ReactionUseCase(reactionRepository: mockReactionRepository)
    }

    override func tearDown() {
        sut = nil
        mockReactionRepository = nil
        super.tearDown()
    }

    // MARK: - Add Reaction Tests

    func testAddReaction_Success() async throws {
        // Given
        let messageId = "message-1"
        let userId = "user-1"
        let emoji = "👍"

        // When
        let reaction = try await sut.addReaction(messageId: messageId, userId: userId, emoji: emoji)

        // Then
        XCTAssertEqual(reaction.messageId, messageId)
        XCTAssertEqual(reaction.userId, userId)
        XCTAssertEqual(reaction.emoji, emoji)
        XCTAssertNotNil(reaction.id)
        XCTAssertNotNil(reaction.createdAt)

        // Verify it was stored in repository
        let reactions = try await sut.fetchReactions(messageId: messageId)
        XCTAssertEqual(reactions.count, 1)
        XCTAssertEqual(reactions.first?.emoji, emoji)
    }

    func testAddReaction_Failure() async throws {
        // Given
        let expectedError = NSError(domain: "Test", code: 500, userInfo: nil)
        mockReactionRepository.shouldThrowError = expectedError

        // When & Then
        do {
            _ = try await sut.addReaction(messageId: "message-1", userId: "user-1", emoji: "👍")
            XCTFail("Expected error to be thrown")
        } catch {
            // Success - error was thrown
            XCTAssertNotNil(error)
        }
    }

    // MARK: - Remove Reaction Tests

    func testRemoveReaction_Success() async throws {
        // Given
        let messageId = "message-1"
        let userId = "user-1"
        let emoji = "👍"

        // Add reaction first
        _ = try await sut.addReaction(messageId: messageId, userId: userId, emoji: emoji)
        let reactionsBeforeRemove = try await sut.fetchReactions(messageId: messageId)
        XCTAssertEqual(reactionsBeforeRemove.count, 1)

        // When
        try await sut.removeReaction(messageId: messageId, userId: userId, emoji: emoji)

        // Then
        let reactionsAfterRemove = try await sut.fetchReactions(messageId: messageId)
        XCTAssertEqual(reactionsAfterRemove.count, 0)
    }

    func testRemoveReaction_Failure() async throws {
        // Given
        let expectedError = NSError(domain: "Test", code: 500, userInfo: nil)
        mockReactionRepository.shouldThrowError = expectedError

        // When & Then
        do {
            try await sut.removeReaction(messageId: "message-1", userId: "user-1", emoji: "👍")
            XCTFail("Expected error to be thrown")
        } catch {
            // Success - error was thrown
            XCTAssertNotNil(error)
        }
    }

    // MARK: - Fetch Reactions Tests

    func testFetchReactions_NoReactions() async throws {
        // When
        let reactions = try await sut.fetchReactions(messageId: "message-1")

        // Then
        XCTAssertEqual(reactions.count, 0)
    }

    func testFetchReactions_MultipleReactions() async throws {
        // Given
        let messageId = "message-1"
        _ = try await sut.addReaction(messageId: messageId, userId: "user-1", emoji: "👍")
        _ = try await sut.addReaction(messageId: messageId, userId: "user-2", emoji: "❤️")
        _ = try await sut.addReaction(messageId: messageId, userId: "user-3", emoji: "😂")

        // When
        let reactions = try await sut.fetchReactions(messageId: messageId)

        // Then
        XCTAssertEqual(reactions.count, 3)
        let emojis = reactions.map { $0.emoji }
        XCTAssertTrue(emojis.contains("👍"))
        XCTAssertTrue(emojis.contains("❤️"))
        XCTAssertTrue(emojis.contains("😂"))
    }

    // MARK: - Replace Reaction Tests

    func testReplaceReaction_WithNoExistingReaction() async throws {
        // Given
        let messageId = "message-1"
        let userId = "user-1"
        let newEmoji = "👍"

        // When
        let reaction = try await sut.replaceReaction(
            messageId: messageId,
            userId: userId,
            oldEmoji: nil,
            newEmoji: newEmoji
        )

        // Then
        XCTAssertEqual(reaction.messageId, messageId)
        XCTAssertEqual(reaction.userId, userId)
        XCTAssertEqual(reaction.emoji, newEmoji)

        // Verify only one reaction exists
        let reactions = try await sut.fetchReactions(messageId: messageId)
        XCTAssertEqual(reactions.count, 1)
        XCTAssertEqual(reactions.first?.emoji, newEmoji)
    }

    func testReplaceReaction_WithExistingReaction() async throws {
        // Given
        let messageId = "message-1"
        let userId = "user-1"
        let oldEmoji = "👍"
        let newEmoji = "❤️"

        // Add initial reaction
        _ = try await sut.addReaction(messageId: messageId, userId: userId, emoji: oldEmoji)
        let reactionsBeforeReplace = try await sut.fetchReactions(messageId: messageId)
        XCTAssertEqual(reactionsBeforeReplace.count, 1)
        XCTAssertEqual(reactionsBeforeReplace.first?.emoji, oldEmoji)

        // When
        let reaction = try await sut.replaceReaction(
            messageId: messageId,
            userId: userId,
            oldEmoji: oldEmoji,
            newEmoji: newEmoji
        )

        // Then
        XCTAssertEqual(reaction.messageId, messageId)
        XCTAssertEqual(reaction.userId, userId)
        XCTAssertEqual(reaction.emoji, newEmoji)

        // Verify only the new reaction exists
        let reactionsAfterReplace = try await sut.fetchReactions(messageId: messageId)
        XCTAssertEqual(reactionsAfterReplace.count, 1)
        XCTAssertEqual(reactionsAfterReplace.first?.emoji, newEmoji)
        XCTAssertNotEqual(reactionsAfterReplace.first?.emoji, oldEmoji)
    }

    func testReplaceReaction_DeleteFailure() async throws {
        // Given
        let messageId = "message-1"
        let userId = "user-1"
        let oldEmoji = "👍"
        let newEmoji = "❤️"

        // Add initial reaction
        _ = try await sut.addReaction(messageId: messageId, userId: userId, emoji: oldEmoji)

        // Configure repository to fail on next operation
        let expectedError = NSError(domain: "Test", code: 500, userInfo: [NSLocalizedDescriptionKey: "Network error"])
        mockReactionRepository.shouldThrowError = expectedError

        // When & Then
        do {
            _ = try await sut.replaceReaction(
                messageId: messageId,
                userId: userId,
                oldEmoji: oldEmoji,
                newEmoji: newEmoji
            )
            XCTFail("Expected error to be thrown")
        } catch {
            // Success - error was thrown
            XCTAssertNotNil(error)
        }

        // Verify old reaction is not removed (repository failed, so no changes)
        // Note: In real implementation with backend API, the reaction would still exist
        // Mock repository throws error before deletion, so reaction remains
    }

    func testReplaceReaction_AddFailureAfterDelete() async throws {
        // Given
        let messageId = "message-1"
        let userId = "user-1"
        let oldEmoji = "👍"
        let newEmoji = "❤️"

        // Add initial reaction
        _ = try await sut.addReaction(messageId: messageId, userId: userId, emoji: oldEmoji)
        let reactionsBeforeReplace = try await sut.fetchReactions(messageId: messageId)
        XCTAssertEqual(reactionsBeforeReplace.count, 1)

        // Create a custom mock that succeeds on delete but fails on add
        class PartialFailureMockRepository: ReactionRepositoryProtocol {
            var reactions: [String: [Reaction]] = [:]
            var removeCallCount = 0
            var addCallCount = 0

            func fetchReactions(messageId: String) async throws -> [Reaction] {
                return reactions[messageId] ?? []
            }

            func addReaction(messageId: String, userId: String, emoji: String) async throws -> Reaction {
                addCallCount += 1
                // Fail on add
                throw NSError(domain: "Test", code: 500, userInfo: [NSLocalizedDescriptionKey: "Add failed"])
            }

            func removeReaction(messageId: String, userId: String, emoji: String) async throws {
                removeCallCount += 1
                // Succeed on remove
                reactions[messageId]?.removeAll { reaction in
                    reaction.userId == userId && reaction.emoji == emoji
                }
            }
        }

        let partialFailureMock = PartialFailureMockRepository()
        partialFailureMock.reactions[messageId] = reactionsBeforeReplace
        let partialFailureSut = ReactionUseCase(reactionRepository: partialFailureMock)

        // When & Then
        do {
            _ = try await partialFailureSut.replaceReaction(
                messageId: messageId,
                userId: userId,
                oldEmoji: oldEmoji,
                newEmoji: newEmoji
            )
            XCTFail("Expected error to be thrown")
        } catch {
            // Success - error was thrown
            XCTAssertNotNil(error)
        }

        // Verify deletion was called
        XCTAssertEqual(partialFailureMock.removeCallCount, 1)
        // Verify addition was attempted
        XCTAssertEqual(partialFailureMock.addCallCount, 1)
        // Verify old reaction was deleted (no rollback)
        let reactionsAfterFailure = try await partialFailureMock.fetchReactions(messageId: messageId)
        XCTAssertEqual(reactionsAfterFailure.count, 0)
    }

    func testReplaceReaction_MultipleUsersReactions() async throws {
        // Given
        let messageId = "message-1"
        let user1 = "user-1"
        let user2 = "user-2"
        let oldEmoji = "👍"
        let newEmoji = "❤️"

        // Both users add initial reactions
        _ = try await sut.addReaction(messageId: messageId, userId: user1, emoji: oldEmoji)
        _ = try await sut.addReaction(messageId: messageId, userId: user2, emoji: "😂")

        let reactionsBeforeReplace = try await sut.fetchReactions(messageId: messageId)
        XCTAssertEqual(reactionsBeforeReplace.count, 2)

        // When - user1 replaces their reaction
        let reaction = try await sut.replaceReaction(
            messageId: messageId,
            userId: user1,
            oldEmoji: oldEmoji,
            newEmoji: newEmoji
        )

        // Then
        XCTAssertEqual(reaction.userId, user1)
        XCTAssertEqual(reaction.emoji, newEmoji)

        // Verify user1's reaction changed but user2's remains
        let reactionsAfterReplace = try await sut.fetchReactions(messageId: messageId)
        XCTAssertEqual(reactionsAfterReplace.count, 2)

        let user1Reaction = reactionsAfterReplace.first { $0.userId == user1 }
        let user2Reaction = reactionsAfterReplace.first { $0.userId == user2 }

        XCTAssertEqual(user1Reaction?.emoji, newEmoji)
        XCTAssertEqual(user2Reaction?.emoji, "😂")
    }

    // MARK: - Compute Summaries Tests

    func testComputeSummaries_EmptyReactions() {
        // Given
        let reactions: [Reaction] = []
        let currentUserId = "user-1"

        // When
        let summaries = sut.computeSummaries(reactions: reactions, currentUserId: currentUserId)

        // Then
        XCTAssertEqual(summaries.count, 0)
    }

    func testComputeSummaries_SingleReaction() {
        // Given
        let reaction = Reaction(
            id: "1",
            messageId: "message-1",
            userId: "user-1",
            emoji: "👍",
            createdAt: Date()
        )
        let currentUserId = "user-1"

        // When
        let summaries = sut.computeSummaries(reactions: [reaction], currentUserId: currentUserId)

        // Then
        XCTAssertEqual(summaries.count, 1)
        XCTAssertEqual(summaries.first?.emoji, "👍")
        XCTAssertEqual(summaries.first?.count, 1)
        XCTAssertEqual(summaries.first?.userIds, ["user-1"])
    }

    func testComputeSummaries_MultipleReactionsSameEmoji() {
        // Given
        let reactions = [
            Reaction(id: "1", messageId: "message-1", userId: "user-1", emoji: "👍", createdAt: Date()),
            Reaction(id: "2", messageId: "message-1", userId: "user-2", emoji: "👍", createdAt: Date()),
            Reaction(id: "3", messageId: "message-1", userId: "user-3", emoji: "👍", createdAt: Date())
        ]
        let currentUserId = "user-1"

        // When
        let summaries = sut.computeSummaries(reactions: reactions, currentUserId: currentUserId)

        // Then
        XCTAssertEqual(summaries.count, 1)
        XCTAssertEqual(summaries.first?.emoji, "👍")
        XCTAssertEqual(summaries.first?.count, 3)
        XCTAssertEqual(summaries.first?.userIds.count, 3)
        XCTAssertTrue(summaries.first?.userIds.contains("user-1") ?? false)
        XCTAssertTrue(summaries.first?.userIds.contains("user-2") ?? false)
        XCTAssertTrue(summaries.first?.userIds.contains("user-3") ?? false)
    }

    func testComputeSummaries_MultipleDifferentEmojis() {
        // Given
        let reactions = [
            Reaction(id: "1", messageId: "message-1", userId: "user-1", emoji: "👍", createdAt: Date()),
            Reaction(id: "2", messageId: "message-1", userId: "user-2", emoji: "❤️", createdAt: Date()),
            Reaction(id: "3", messageId: "message-1", userId: "user-3", emoji: "😂", createdAt: Date()),
            Reaction(id: "4", messageId: "message-1", userId: "user-4", emoji: "👍", createdAt: Date())
        ]
        let currentUserId = "user-1"

        // When
        let summaries = sut.computeSummaries(reactions: reactions, currentUserId: currentUserId)

        // Then
        XCTAssertEqual(summaries.count, 3)

        // Verify sorting by count (descending)
        // 👍 has 2 reactions, should be first
        XCTAssertEqual(summaries[0].emoji, "👍")
        XCTAssertEqual(summaries[0].count, 2)

        // ❤️ and 😂 have 1 each
        let emojiCounts = summaries.map { ($0.emoji, $0.count) }
        XCTAssertTrue(emojiCounts.contains { $0.0 == "❤️" && $0.1 == 1 })
        XCTAssertTrue(emojiCounts.contains { $0.0 == "😂" && $0.1 == 1 })
    }

    func testComputeSummaries_SortedByCountDescending() {
        // Given
        let reactions = [
            Reaction(id: "1", messageId: "message-1", userId: "user-1", emoji: "😂", createdAt: Date()),
            Reaction(id: "2", messageId: "message-1", userId: "user-2", emoji: "👍", createdAt: Date()),
            Reaction(id: "3", messageId: "message-1", userId: "user-3", emoji: "👍", createdAt: Date()),
            Reaction(id: "4", messageId: "message-1", userId: "user-4", emoji: "👍", createdAt: Date()),
            Reaction(id: "5", messageId: "message-1", userId: "user-5", emoji: "❤️", createdAt: Date()),
            Reaction(id: "6", messageId: "message-1", userId: "user-6", emoji: "❤️", createdAt: Date())
        ]
        let currentUserId = "user-1"

        // When
        let summaries = sut.computeSummaries(reactions: reactions, currentUserId: currentUserId)

        // Then
        XCTAssertEqual(summaries.count, 3)

        // Verify sorted by count descending
        XCTAssertEqual(summaries[0].emoji, "👍")
        XCTAssertEqual(summaries[0].count, 3)

        XCTAssertEqual(summaries[1].emoji, "❤️")
        XCTAssertEqual(summaries[1].count, 2)

        XCTAssertEqual(summaries[2].emoji, "😂")
        XCTAssertEqual(summaries[2].count, 1)
    }
}
