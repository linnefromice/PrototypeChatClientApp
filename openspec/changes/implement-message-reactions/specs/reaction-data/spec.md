# Spec: Reaction Data Layer

## ADDED Requirements

### Requirement: Reaction Repository Implementation

The system SHALL provide a concrete repository implementation that calls the OpenAPI-generated client to interact with the backend reaction APIs.

#### Scenario: Fetch reactions via API

**Given** a message with ID "msg-123" exists
**And** the message has reactions from multiple users
**When** the repository fetches reactions for "msg-123"
**Then** the system calls `GET /messages/msg-123/reactions` (if endpoint exists)
**Or** reactions are embedded in the message response
**And** the response DTOs are mapped to domain `Reaction` entities
**And** all reactions for the message are returned

#### Scenario: Add reaction via API

**Given** a user with ID "user-456" wants to add a reaction
**And** the message ID is "msg-123"
**And** the emoji is "👍"
**When** the repository adds the reaction
**Then** the system calls `POST /messages/msg-123/reactions`
**And** the request body contains userId and emoji
**And** the API returns the created reaction with an ID
**And** the DTO is mapped to a domain `Reaction` entity

#### Scenario: Remove reaction via API

**Given** a user with ID "user-456" has reacted with "❤️"
**And** the message ID is "msg-123"
**When** the repository removes the reaction
**Then** the system calls `DELETE /messages/msg-123/reactions/❤️?userId=user-456`
**And** the API confirms deletion (204 No Content or 200 OK)
**And** no error is thrown

#### Scenario: Handle API error during fetch

**Given** the repository attempts to fetch reactions
**And** the API returns a 500 Internal Server Error
**When** the fetch operation executes
**Then** a `NetworkError.serverError` is thrown
**And** the error is propagated to the use case layer
**And** the error message includes relevant debug information

---

### Requirement: DTO to Domain Mapping

The system SHALL map OpenAPI-generated DTOs to domain entities using extension methods.

#### Scenario: Map Reaction DTO to domain entity

**Given** a `Components.Schemas.Reaction` DTO from the API
**And** the DTO has fields: id, messageId, userId, emoji, createdAt
**When** the `toDomain()` extension method is called
**Then** a domain `Reaction` entity is returned
**And** all fields are correctly mapped
**And** the createdAt string is parsed to a Date object

#### Scenario: Map domain entity to request DTO

**Given** a user wants to add a reaction
**And** the userId is "user-456" and emoji is "😂"
**When** creating a `ReactionRequest` DTO
**Then** a `Components.Schemas.ReactionRequest` is created via `from(userId:emoji:)`
**And** the DTO contains the userId and emoji fields
**And** the DTO is ready to be sent in the API request body

---

### Requirement: Mock Reaction Repository

The system SHALL provide a mock repository implementation for offline development and testing.

#### Scenario: Mock repository returns in-memory data

**Given** the mock repository is initialized with test reactions
**When** fetchReactions is called for a message
**Then** the mock returns reactions from in-memory storage
**And** no actual network request is made
**And** responses are returned immediately (no async delay)

#### Scenario: Mock repository simulates add reaction

**Given** the mock repository is being used
**When** addReaction is called with a messageId, userId, and emoji
**Then** a new `Reaction` is created with a mock ID
**And** the reaction is added to the in-memory storage
**And** the created reaction is returned

#### Scenario: Mock repository simulates remove reaction

**Given** the mock repository has a reaction in storage
**And** the reaction has messageId "msg-1", userId "user-1", emoji "👍"
**When** removeReaction is called with those parameters
**Then** the reaction is removed from in-memory storage
**And** subsequent fetch operations do not include the removed reaction

#### Scenario: Mock repository simulates error

**Given** the mock repository is configured to throw errors
**When** any repository method is called
**Then** the configured error is thrown
**And** the error can be used to test error handling in tests

---

### Requirement: Repository Integration with OpenAPI Client

The system SHALL use the OpenAPI-generated `Client` to make HTTP requests following the existing repository pattern.

#### Scenario: Repository uses injected OpenAPI client

**Given** a `ReactionRepository` is initialized
**And** an OpenAPI `Client` instance is injected
**When** any repository method is called
**Then** the repository uses the client to make API requests
**And** follows the same error handling pattern as `MessageRepository`
**And** logs errors with appropriate context

#### Scenario: Handle undocumented API response

**Given** the repository makes an API call
**And** the API returns an undocumented status code (e.g., 418)
**When** the response is processed
**Then** the repository maps the status code to a `NetworkError`
**And** logs the unexpected response
**And** throws the error to the caller

---

## Implementation Notes

### Repository Implementation

**Location**: `Infrastructure/Network/Repositories/ReactionRepository.swift`

```swift
class ReactionRepository: ReactionRepositoryProtocol {
    private let client: Client

    init(client: Client) {
        self.client = client
    }

    func fetchReactions(messageId: String) async throws -> [Reaction] {
        // Implementation using OpenAPI client
        // Maps DTOs to domain entities
    }

    func addReaction(messageId: String, userId: String, emoji: String) async throws -> Reaction {
        // POST /messages/{id}/reactions
    }

    func removeReaction(messageId: String, userId: String, emoji: String) async throws {
        // DELETE /messages/{id}/reactions/{emoji}?userId={userId}
    }
}
```

### Mock Repository

**Location**: `Features/Chat/Data/Repositories/MockReactionRepository.swift`

```swift
class MockReactionRepository: ReactionRepositoryProtocol {
    private var reactions: [String: [Reaction]] = [:] // messageId → reactions
    var shouldThrowError: Error?

    func fetchReactions(messageId: String) async throws -> [Reaction] {
        if let error = shouldThrowError { throw error }
        return reactions[messageId] ?? []
    }

    func addReaction(messageId: String, userId: String, emoji: String) async throws -> Reaction {
        if let error = shouldThrowError { throw error }
        let reaction = Reaction(
            id: UUID().uuidString,
            messageId: messageId,
            userId: userId,
            emoji: emoji,
            createdAt: Date()
        )
        reactions[messageId, default: []].append(reaction)
        return reaction
    }

    func removeReaction(messageId: String, userId: String, emoji: String) async throws {
        if let error = shouldThrowError { throw error }
        reactions[messageId]?.removeAll {
            $0.userId == userId && $0.emoji == emoji
        }
    }
}
```

### DTO Mapping Extensions

**Location**: `Infrastructure/Network/DTOs/ReactionDTO+Extensions.swift`

```swift
extension Components.Schemas.Reaction {
    func toDomain() -> Reaction {
        Reaction(
            id: id,
            messageId: messageId,
            userId: userId,
            emoji: emoji,
            createdAt: ISO8601DateFormatter().date(from: createdAt) ?? Date()
        )
    }
}

extension Components.Schemas.ReactionRequest {
    static func from(userId: String, emoji: String) -> Self {
        Self(userId: userId, emoji: emoji)
    }
}
```

### Error Handling

Follow the same pattern as `MessageRepository`:
- Catch `NetworkError` and re-throw
- Map undocumented status codes to appropriate errors
- Log all errors with context for debugging

### Testing Strategy

1. **Unit Tests for ReactionRepository** (using mock OpenAPI client):
   - Test successful fetch, add, remove
   - Test error handling for each operation
   - Test DTO mapping correctness

2. **Unit Tests for MockReactionRepository**:
   - Test in-memory storage operations
   - Test error simulation
   - Verify no actual network calls

3. **Integration Tests**:
   - Use MockReactionRepository in use case tests
   - Verify end-to-end flow without real API calls

### Dependencies

- OpenAPI-generated `Client` from `swift-openapi-generator`
- Existing `NetworkError` enum
- ISO8601DateFormatter for date parsing
