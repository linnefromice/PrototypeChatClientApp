# Proposal: Implement Message Reactions

## Problem Statement

Currently, users can send and view messages in conversations, but there is no way to react to messages with emoji reactions. This limits user engagement and expressiveness in conversations. The backend API already provides reaction endpoints (`POST /messages/{id}/reactions` and `DELETE /messages/{id}/reactions/{emoji}`), but the iOS client does not have the domain logic, data layer, or UI to support this feature.

## Proposed Solution

Implement a complete message reactions feature that allows users to:
1. Add emoji reactions to any message (including their own)
2. View reactions on messages with aggregated counts
3. Remove their own reactions
4. See who reacted with each emoji

The implementation will follow the existing MVVM + Clean Architecture pattern with three main components:

### Domain Layer
- Create `Reaction` and `ReactionSummary` domain entities
- Define `ReactionRepositoryProtocol` for data access
- Implement `ReactionUseCase` for business logic (add/remove reactions, aggregate counts)

### Data Layer
- Implement `ReactionRepository` using OpenAPI client for real API calls
- Implement `MockReactionRepository` for offline development and testing
- Add DTO-to-domain mapping extensions

### Presentation Layer
- Create reaction picker UI component for selecting emojis
- Display reaction summaries below message bubbles
- Handle add/remove reaction interactions
- Update `MessageBubbleView` to show reactions
- Integrate reactions into `ChatRoomViewModel`

## Scope

**In Scope:**
- Domain entities and use cases for reactions
- Repository protocol and implementations (real + mock)
- Reaction picker UI component
- Reaction display in message bubbles
- Add/remove reaction functionality
- Reaction count aggregation and display
- Unit tests for domain and use case logic
- Integration with existing chat room view

**Out of Scope:**
- Custom emoji support (only standard Unicode emojis)
- Reaction animations or haptic feedback
- Reaction search or frequently used reactions
- Push notifications for reactions
- Reaction analytics or reporting

## Dependencies

- Existing OpenAPI schema with reaction endpoints (already defined)
- swift-openapi-generator (already integrated)
- Current `Message` entity structure (no changes needed)
- Existing `MessageRepository` pattern (will follow same approach)

## Risks & Considerations

1. **API Compatibility**: The OpenAPI schema must match backend implementation
   - Mitigation: Use mock repository for offline development

2. **Performance**: Frequent reaction updates could cause UI lag
   - Mitigation: Aggregate reactions locally before displaying

3. **State Management**: Reactions must stay synchronized with message list
   - Mitigation: Use `@Published` properties in ViewModel for reactivity

4. **Testing Complexity**: Async reaction operations need proper test coverage
   - Mitigation: Follow existing test patterns from `MessageUseCaseTests`

## Success Criteria

- Users can tap a message to open reaction picker
- Users can add emoji reactions (👍, ❤️, 😂, 😮, 😢, 🎉, etc.)
- Reactions appear below message bubbles with aggregated counts
- Users can tap their own reaction to remove it
- All reactions persist across app restarts (via API)
- Unit tests achieve >80% coverage for reaction logic
- Mock repository enables offline development
- No performance degradation in message scrolling

## Alternatives Considered

1. **Embedding reactions in Message entity**
   - Rejected: Would require changing Message schema and all existing code
   - Chosen approach: Separate Reaction entity fetched independently

2. **Real-time reaction updates via WebSocket**
   - Rejected: Out of scope for MVP, adds significant complexity
   - Chosen approach: Poll reactions when loading messages

3. **Inline emoji picker vs modal picker**
   - Chosen: Context menu with emoji grid (iOS standard pattern)
   - Alternative: Bottom sheet modal (more space but extra tap)
