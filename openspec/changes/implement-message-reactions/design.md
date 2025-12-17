# Design: Implement Message Reactions

## Architecture Overview

This feature follows the existing MVVM + Clean Architecture pattern with clear separation of concerns across Domain, Data, and Presentation layers.

```
Presentation Layer (UI)
├── Views
│   ├── MessageBubbleView (modified)
│   ├── ReactionPickerView (new)
│   └── ReactionSummaryView (new)
└── ViewModels
    └── ChatRoomViewModel (modified)

Domain Layer (Business Logic)
├── Entities
│   ├── Reaction (new)
│   └── ReactionSummary (new)
├── Protocols
│   └── ReactionRepositoryProtocol (new)
└── UseCases
    └── ReactionUseCase (new)

Data Layer (Data Access)
├── Repositories
│   ├── ReactionRepository (new - real API)
│   └── MockReactionRepository (new - offline)
└── DTOs
    └── ReactionDTO mapping extensions (new)
```

## Domain Model

### Reaction Entity

```swift
struct Reaction: Identifiable, Equatable, Codable {
    let id: String
    let messageId: String
    let userId: String
    let emoji: String
    let createdAt: Date
}
```

**Rationale**: Matches OpenAPI schema exactly. Each reaction is a separate entity to support multiple reactions per user and per message.

### ReactionSummary

```swift
struct ReactionSummary: Equatable {
    let emoji: String
    let count: Int
    let users: [String] // User IDs who reacted

    var hasCurrentUser: Bool {
        // Computed when creating summary
    }
}
```

**Rationale**: Aggregates reactions by emoji for efficient UI rendering. Avoids showing "👍 1, 👍 1, 👍 1" and instead shows "👍 3".

## Data Flow

### Adding a Reaction

```
User taps message
  ↓
Long press gesture detected
  ↓
ReactionPickerView appears
  ↓
User selects emoji (e.g., "👍")
  ↓
ChatRoomViewModel.addReaction(messageId, emoji)
  ↓
ReactionUseCase.addReaction(messageId, userId, emoji)
  ↓
ReactionRepository.addReaction(messageId, userId, emoji)
  ↓
API POST /messages/{id}/reactions
  ↓
Reaction entity returned
  ↓
ViewModel updates @Published reactions
  ↓
UI refreshes to show new reaction
```

### Removing a Reaction

```
User taps their reaction
  ↓
ChatRoomViewModel.removeReaction(messageId, emoji)
  ↓
ReactionUseCase.removeReaction(messageId, userId, emoji)
  ↓
ReactionRepository.removeReaction(messageId, userId, emoji)
  ↓
API DELETE /messages/{id}/reactions/{emoji}?userId={userId}
  ↓
ViewModel removes reaction from state
  ↓
UI updates to hide removed reaction
```

### Fetching Reactions

**Option 1**: Embed in Message fetch (current approach - no changes to Message entity)
- Fetch reactions separately when displaying messages
- Store in ViewModel as `[String: [Reaction]]` (messageId → reactions)

**Option 2**: Extend Message entity with reactions array (not chosen)
- Would require API changes and Message schema updates
- More coupling between Message and Reaction

**Chosen**: Option 1 - Fetch reactions separately via `ReactionRepository.fetchReactions(messageId: String)`

## UI/UX Design

### Message Bubble with Reactions

```
┌─────────────────────────┐
│ Hello, how are you?     │ ← Message bubble
│                         │
│ 👍 3  ❤️ 2  😂 1       │ ← Reaction summary
└─────────────────────────┘
  [timestamp]
```

### Reaction Picker (Context Menu Style)

```
Long press on message
  ↓
┌───────────────────────────┐
│  Quick Reactions          │
│  👍  ❤️  😂  😮  😢  🎉  │
│  👏  🔥  ✨  🙏  👀  🚀  │
│                           │
│  [More Emojis...]         │ ← Optional: Full emoji picker
└───────────────────────────┘
```

### Interaction States

1. **Default**: Message shows reaction summary if reactions exist
2. **Long Press**: Reaction picker appears
3. **Tap Reaction**:
   - If user hasn't reacted: Add reaction
   - If user has reacted: Remove reaction (toggle behavior)
4. **Visual Feedback**: User's own reactions highlighted differently

## Repository Pattern

### ReactionRepositoryProtocol

```swift
protocol ReactionRepositoryProtocol {
    func fetchReactions(messageId: String) async throws -> [Reaction]
    func addReaction(messageId: String, userId: String, emoji: String) async throws -> Reaction
    func removeReaction(messageId: String, userId: String, emoji: String) async throws
}
```

### ReactionRepository (Real)

- Uses OpenAPI client
- Calls actual API endpoints
- Handles network errors

### MockReactionRepository (Mock)

- In-memory storage
- Returns mock data immediately
- Enables offline development

## State Management

### ChatRoomViewModel Changes

```swift
class ChatRoomViewModel: ObservableObject {
    // Existing
    @Published var messages: [Message] = []

    // New
    @Published var reactions: [String: [Reaction]] = [:] // messageId → reactions
    private let reactionUseCase: ReactionUseCase

    // New methods
    func loadReactions(for messageId: String) async
    func addReaction(to messageId: String, emoji: String) async
    func removeReaction(from messageId: String, emoji: String) async
    func reactionSummary(for messageId: String) -> [ReactionSummary]
}
```

**Rationale**:
- Centralized state management in ViewModel
- Reactions stored separately from messages
- Automatic UI updates via `@Published`

## Error Handling

### Network Errors
- **Offline**: Show cached reactions, queue reaction operations
- **API Error**: Display error alert, allow retry
- **Timeout**: Show loading indicator, auto-retry once

### Validation
- **Empty emoji**: Prevent submission
- **Invalid messageId**: Guard against crashes
- **Duplicate reactions**: API handles deduplication

## Performance Considerations

### Optimization Strategies

1. **Lazy Loading**: Fetch reactions only for visible messages
2. **Caching**: Store reactions in memory during chat session
3. **Debouncing**: Aggregate rapid reaction taps (prevent spam)
4. **Pagination**: Limit reactions fetched per message if count is high

### Memory Management

- Reactions cleared when leaving chat room
- Weak references in closures to prevent retain cycles
- Efficient aggregation algorithm (O(n) complexity)

## Testing Strategy

### Unit Tests

1. **ReactionUseCase**
   - `test_addReaction_success()`
   - `test_addReaction_propagatesError()`
   - `test_removeReaction_success()`
   - `test_aggregateReactions_correctCounts()`

2. **ReactionRepository**
   - `test_fetchReactions_returnsMappedDomain()`
   - `test_addReaction_callsCorrectEndpoint()`
   - `test_removeReaction_handlesNetworkError()`

3. **ViewModel**
   - `test_loadReactions_updatesState()`
   - `test_addReaction_callsUseCase()`
   - `test_reactionSummary_aggregatesCorrectly()`

### Integration Tests

- Test full flow: display message → add reaction → verify UI update
- Mock API responses using `MockReactionRepository`

## Migration & Rollout

### Phase 1: Domain & Data (No UI Impact)
- Add entities and use cases
- Implement repositories
- Write unit tests
- **Risk**: None, no user-facing changes

### Phase 2: UI Components (Controlled Rollout)
- Add reaction picker view
- Add reaction summary view
- Feature flag to enable/disable
- **Risk**: Low, additive changes only

### Phase 3: Integration (Full Feature)
- Integrate into MessageBubbleView
- Update ChatRoomViewModel
- Enable by default
- **Risk**: Medium, visible to all users

## Security & Privacy

### Considerations

1. **Authorization**: API enforces userId matches authenticated user
2. **Validation**: Backend validates emoji is valid Unicode character
3. **Rate Limiting**: API prevents spam reactions (backend responsibility)
4. **Privacy**: Reaction authors visible to all conversation participants

## Accessibility

### Requirements

1. **VoiceOver**: "3 people reacted with thumbs up, including you"
2. **Dynamic Type**: Emoji size adjusts with text size
3. **Color Contrast**: User's own reactions highlighted accessibly
4. **Haptics**: Provide feedback when adding/removing reactions

## Open Questions

1. **Should we show reaction details (who reacted)?**
   - Current design: Tap reaction to see list of users
   - Alternative: Show on long press
   - **Decision needed**: UX preference

2. **Maximum reactions per message?**
   - Current: No client-side limit (rely on API)
   - Alternative: Limit to 10 unique emojis
   - **Decision needed**: Product requirement

3. **Reaction picker emoji set?**
   - Current: Pre-defined set of 12 common emojis
   - Alternative: Full emoji keyboard
   - **Decision needed**: Scope vs. complexity trade-off

## Future Enhancements (Out of Scope)

- Real-time reaction updates via WebSocket
- Custom emoji/sticker reactions
- Reaction animations (emoji fly-in effects)
- Reaction notifications
- Frequently used reactions personalization
- Reaction analytics dashboard
