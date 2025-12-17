# Spec: Reaction Domain Layer

## ADDED Requirements

### Requirement: Reaction Entity

The system SHALL provide a `Reaction` domain entity that represents a single emoji reaction to a message.

#### Scenario: Reaction entity structure

**Given** a reaction is created from API data
**When** the reaction is initialized with id, messageId, userId, emoji, and createdAt
**Then** the reaction entity contains all required fields
**And** the entity conforms to Identifiable, Equatable, and Codable protocols
**And** the id uniquely identifies the reaction

---

### Requirement: Reaction Summary Aggregation

The system SHALL aggregate reactions by emoji and provide counts and user lists for efficient UI display.

#### Scenario: Aggregate reactions by emoji

**Given** a message has multiple reactions
**And** three users reacted with "👍"
**And** two users reacted with "❤️"
**When** reactions are aggregated into summaries
**Then** the system returns a ReactionSummary for "👍" with count 3
**And** the system returns a ReactionSummary for "❤️" with count 2
**And** each summary includes the list of user IDs who reacted

#### Scenario: Identify current user's reactions

**Given** the current user has reacted with "😂" to a message
**And** other users have also reacted with "😂"
**When** generating the reaction summary for "😂"
**Then** the summary indicates that the current user has reacted
**And** the UI can highlight the user's own reaction differently

---

### Requirement: Reaction Repository Protocol

The system SHALL define a repository protocol for fetching, adding, and removing reactions.

#### Scenario: Repository protocol methods

**Given** a reaction repository protocol is defined
**Then** it provides a method to fetch all reactions for a message
**And** it provides a method to add a reaction to a message
**And** it provides a method to remove a reaction from a message
**And** all methods are asynchronous and can throw errors

---

### Requirement: Reaction Use Case

The system SHALL provide business logic for managing reactions through a use case layer.

#### Scenario: Add reaction to message

**Given** a user wants to react to a message
**And** the message ID is "msg-123"
**And** the user ID is "user-456"
**And** the selected emoji is "👍"
**When** the use case adds the reaction
**Then** the repository is called with messageId, userId, and emoji
**And** the newly created reaction is returned
**And** the reaction has a unique ID assigned by the backend

#### Scenario: Remove reaction from message

**Given** a user has previously reacted with "❤️" to a message
**And** the message ID is "msg-123"
**And** the user ID is "user-456"
**When** the use case removes the reaction
**Then** the repository deletes the reaction for that emoji and user
**And** no error is thrown
**And** subsequent fetches do not include the removed reaction

#### Scenario: Fetch reactions for message

**Given** a message has several reactions
**When** the use case fetches reactions for the message
**Then** the repository is queried with the message ID
**And** all reactions for that message are returned as domain entities
**And** reactions from different users are included

#### Scenario: Handle duplicate reaction attempt

**Given** a user has already reacted with "👍" to a message
**When** the user tries to add "👍" again to the same message
**Then** the API handles deduplication (backend responsibility)
**And** no duplicate reaction is created
**Or** the existing reaction is returned without error

#### Scenario: Handle network error during add reaction

**Given** the user attempts to add a reaction
**And** the network is unavailable
**When** the use case tries to add the reaction
**Then** a network error is thrown
**And** the error is propagated to the caller
**And** the user is notified of the failure

---

### Requirement: Reaction Summary Computation

The system SHALL compute reaction summaries from a list of reactions for efficient UI rendering.

#### Scenario: Compute summaries for multiple emojis

**Given** a message has the following reactions:
  - User A: "👍"
  - User B: "👍"
  - User C: "❤️"
  - User D: "😂"
  - User E: "😂"
  - User F: "😂"
**When** the use case computes reaction summaries
**Then** the summary for "👍" has count 2 and users [A, B]
**And** the summary for "❤️" has count 1 and users [C]
**And** the summary for "😂" has count 3 and users [D, E, F]
**And** summaries are sorted by count descending (most popular first)

#### Scenario: Empty reaction list

**Given** a message has no reactions
**When** the use case computes reaction summaries
**Then** an empty array is returned
**And** the UI displays no reactions below the message

---

## Implementation Notes

### Domain Entities

**Reaction Entity**:
```swift
struct Reaction: Identifiable, Equatable, Codable {
    let id: String
    let messageId: String
    let userId: String
    let emoji: String
    let createdAt: Date
}
```

**ReactionSummary**:
```swift
struct ReactionSummary: Equatable {
    let emoji: String
    let count: Int
    let userIds: [String]

    func hasUser(_ userId: String) -> Bool {
        userIds.contains(userId)
    }
}
```

### Repository Protocol

```swift
protocol ReactionRepositoryProtocol {
    func fetchReactions(messageId: String) async throws -> [Reaction]
    func addReaction(messageId: String, userId: String, emoji: String) async throws -> Reaction
    func removeReaction(messageId: String, userId: String, emoji: String) async throws
}
```

### Use Case

**Location**: `Features/Chat/Domain/UseCases/ReactionUseCase.swift`

**Methods**:
- `addReaction(messageId: String, userId: String, emoji: String) async throws -> Reaction`
- `removeReaction(messageId: String, userId: String, emoji: String) async throws`
- `fetchReactions(messageId: String) async throws -> [Reaction]`
- `computeSummaries(reactions: [Reaction], currentUserId: String) -> [ReactionSummary]`

### Validation Rules

1. **Emoji**: Must be a non-empty string (backend validates Unicode emoji)
2. **Message ID**: Must be a valid UUID format
3. **User ID**: Must be a valid UUID format
4. **Network errors**: Propagate to caller for UI handling

### Error Handling

- `NetworkError.notFound`: Message does not exist
- `NetworkError.unauthorized`: User not authorized to react
- `NetworkError.serverError`: Backend error, show retry option
- `NetworkError.noConnection`: Offline, queue operation or show error
