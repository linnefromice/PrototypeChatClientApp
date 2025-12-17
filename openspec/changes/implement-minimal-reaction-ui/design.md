# Design: Implement Minimal Reaction UI

## Overview

This design document describes a minimal UI implementation for message reactions. The focus is on simplicity and core functionality, building on top of the existing domain and data layers.

## Goals

1. **Minimal Complexity**: Simple, straightforward UI with no advanced features
2. **Quick to Implement**: ~3.5 hours total (vs 11 hours for full implementation)
3. **Foundation for Future**: Base that can be enhanced later
4. **User Value**: Core reaction functionality (add/remove/display)

## Non-Goals

- Real-time updates (no websockets/polling)
- Custom emoji selection
- Animations and transitions
- Comprehensive accessibility
- Extensive unit testing
- Reaction history or "who reacted" details

## Architecture

### Layer Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  ┌───────────────────────────────────────────────────┐  │
│  │              ChatRoomView (modified)              │  │
│  │  - Wires reactions to MessageBubbleView          │  │
│  │  - Handles user interactions                     │  │
│  └────────────────────┬──────────────────────────────┘  │
│                       │                                  │
│  ┌────────────────────▼──────────────────────────────┐  │
│  │         ChatRoomViewModel (modified)             │  │
│  │  - @Published messageReactions                    │  │
│  │  - addReaction(), removeReaction()               │  │
│  │  - toggleReaction(), reactionSummaries()         │  │
│  └────────────────────┬──────────────────────────────┘  │
│                       │                                  │
│  ┌────────────────────▼──────────────────────────────┐  │
│  │      MessageBubbleView (modified)                │  │
│  │  - Displays ReactionSummaryView                  │  │
│  │  - Context menu with ReactionPickerView          │  │
│  └──────────┬────────────────────────────┬───────────┘  │
│             │                            │               │
│  ┌──────────▼─────────────┐   ┌─────────▼───────────┐  │
│  │ ReactionPickerView     │   │ ReactionSummaryView │  │
│  │ (new component)        │   │ (new component)     │  │
│  │  - 6 emoji grid        │   │  - Reaction pills   │  │
│  └────────────────────────┘   └─────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                       │
                       │ Uses
                       ▼
┌─────────────────────────────────────────────────────────┐
│                     Domain Layer                         │
│  ┌───────────────────────────────────────────────────┐  │
│  │              ReactionUseCase                      │  │
│  │  - addReaction()                                  │  │
│  │  - removeReaction()                               │  │
│  │  - computeSummaries() ← aggregation logic         │  │
│  └────────────────────┬──────────────────────────────┘  │
│                       │                                  │
│  ┌────────────────────▼──────────────────────────────┐  │
│  │       ReactionRepositoryProtocol                  │  │
│  └────────────────────┬──────────────────────────────┘  │
└───────────────────────┼──────────────────────────────────┘
                        │
                        │ Implements
                        ▼
┌─────────────────────────────────────────────────────────┐
│                      Data Layer                          │
│  ┌───────────────────────────────────────────────────┐  │
│  │         MockReactionRepository (for now)          │  │
│  │  - In-memory storage                              │  │
│  │  - No network calls during development           │  │
│  └───────────────────────────────────────────────────┘  │
│                                                          │
│  ┌───────────────────────────────────────────────────┐  │
│  │    ReactionRepository (future production)         │  │
│  │  - POST /messages/{id}/reactions                  │  │
│  │  - DELETE /messages/{id}/reactions/{emoji}        │  │
│  └───────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
```

### Existing Components (Already Implemented)

✅ **Domain Entities:**
- `Reaction` - Individual reaction (id, messageId, userId, emoji, createdAt)
- `ReactionSummary` - Aggregated view (emoji, count, userIds)

✅ **Domain Use Case:**
- `ReactionUseCase` - Business logic layer

✅ **Data Layer:**
- `ReactionRepositoryProtocol` - Data access contract
- `ReactionRepository` - API implementation
- `MockReactionRepository` - In-memory implementation

### New Components (To Be Implemented)

🆕 **Presentation Views:**
- `ReactionPickerView` - Emoji selection grid
- `ReactionSummaryView` - Reaction pill display

🔧 **Modified Components:**
- `MessageBubbleView` - Add reaction UI
- `ChatRoomViewModel` - Reaction state management
- `ChatRoomView` - Wire reactions
- `DependencyContainer` - Inject dependencies

## Data Flow

### Add Reaction Flow

```
User Action: Long-press message
      │
      ▼
MessageBubbleView shows context menu
      │
      ▼
ReactionPickerView displays 6 emojis
      │
      ▼
User taps emoji (e.g., 👍)
      │
      ▼
onAddReaction callback triggered
      │
      ▼
ChatRoomView calls ViewModel.addReaction(messageId, emoji)
      │
      ▼
ChatRoomViewModel calls ReactionUseCase.addReaction()
      │
      ▼
ReactionUseCase calls Repository.addReaction()
      │
      ▼
Repository makes API call (or mock storage)
      │
      ▼
Repository returns Reaction entity
      │
      ▼
ViewModel updates @Published messageReactions[messageId]
      │
      ▼
SwiftUI re-renders MessageBubbleView
      │
      ▼
ReactionSummaryView displays new reaction pill
```

### Remove Reaction Flow

```
User Action: Tap existing reaction pill
      │
      ▼
onReactionTap callback triggered
      │
      ▼
ChatRoomView calls ViewModel.toggleReaction(messageId, emoji)
      │
      ▼
ViewModel checks: hasUser(currentUserId)?
      │
      ├─ Yes → ViewModel calls removeReaction()
      │         │
      │         ▼
      │    ReactionUseCase.removeReaction()
      │         │
      │         ▼
      │    Repository.removeReaction()
      │         │
      │         ▼
      │    API DELETE call (or mock storage)
      │
      └─ No → ViewModel calls addReaction()
              (same flow as add reaction)
      │
      ▼
ViewModel updates @Published messageReactions[messageId]
      │
      ▼
UI re-renders with updated reactions
```

## UI/UX Design

### ReactionPickerView

**Layout:**
```
┌─────────────────────────────┐
│     Reaction Picker         │
├─────────────────────────────┤
│  👍     ❤️      😂         │
│                              │
│  😮     🎉      🔥         │
└─────────────────────────────┘
```

**Specifications:**
- **Grid**: 2 rows × 3 columns
- **Emoji Size**: 44×44pt (minimum touch target)
- **Spacing**: 16pt between emojis
- **Background**: Semi-transparent blur (iOS standard)
- **Interaction**: Tap emoji → callback → dismiss

**SwiftUI Implementation:**
```swift
LazyVGrid(columns: [
    GridItem(.flexible()),
    GridItem(.flexible()),
    GridItem(.flexible())
], spacing: 16) {
    ForEach(emojis, id: \.self) { emoji in
        Button(emoji) {
            onSelect(emoji)
        }
        .font(.system(size: 40))
        .frame(width: 44, height: 44)
    }
}
```

### ReactionSummaryView

**Layout:**
```
┌────────────────────────────────────────┐
│  Message text here...                  │
│                                        │
│  ┌─────┐  ┌─────┐  ┌─────┐           │
│  │👍 3 │  │❤️ 1│  │😂 2│           │
│  └─────┘  └─────┘  └─────┘           │
└────────────────────────────────────────┘
         ^          ^
    user's own   other's
    (blue bg)   (gray bg)
```

**Specifications:**
- **Pill Shape**: Rounded capsule
- **Background Colors**:
  - User's reaction: `.blue` or `.accentColor`
  - Others' reaction: `.gray.opacity(0.2)`
- **Content**: "{emoji} {count}" (e.g., "👍 3")
- **Padding**: 8pt horizontal, 4pt vertical
- **Font**: System font, 14pt
- **Layout**: Horizontal flow, wrapping if needed

**SwiftUI Implementation:**
```swift
FlowLayout(spacing: 8) {
    ForEach(summaries, id: \.emoji) { summary in
        Button {
            onTap(summary.emoji)
        } label: {
            HStack(spacing: 4) {
                Text(summary.emoji)
                Text("\(summary.count)")
                    .font(.caption)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                summary.hasUser(currentUserId) ? Color.blue : Color.gray.opacity(0.2)
            )
            .foregroundColor(
                summary.hasUser(currentUserId) ? .white : .primary
            )
            .clipShape(Capsule())
        }
    }
}
```

### MessageBubbleView Integration

**Before (existing):**
```
┌────────────────────────────┐
│  Sender Name               │
│  Message text here...      │
│  12:34 PM                  │
└────────────────────────────┘
```

**After (with reactions):**
```
┌────────────────────────────┐
│  Sender Name               │
│  Message text here...      │
│  ┌─────┐  ┌─────┐         │
│  │👍 3 │  │❤️ 1│         │
│  └─────┘  └─────┘         │
│  12:34 PM                  │
└────────────────────────────┘
```

**Interaction:**
- **Long-press message** → Context menu with `ReactionPickerView`
- **Tap reaction pill** → Toggle reaction (add if not reacted, remove if reacted)

## State Management

### ChatRoomViewModel State

```swift
@Published var messageReactions: [String: [Reaction]] = [:]
// Key: messageId
// Value: Array of Reaction entities
```

**Update Triggers:**
1. `loadMessages()` completes → Initialize empty reactions (no GET endpoint)
2. `addReaction()` succeeds → Append to array
3. `removeReaction()` succeeds → Remove from array

**Computed Properties:**
```swift
func reactionSummaries(for messageId: String) -> [ReactionSummary] {
    let reactions = messageReactions[messageId] ?? []
    return reactionUseCase.computeSummaries(
        reactions: reactions,
        currentUserId: currentUserId
    )
}
```

### Reaction Aggregation Logic (Existing in ReactionUseCase)

```swift
func computeSummaries(reactions: [Reaction], currentUserId: String) -> [ReactionSummary] {
    // Group reactions by emoji
    var emojiGroups: [String: [Reaction]] = [:]
    for reaction in reactions {
        emojiGroups[reaction.emoji, default: []].append(reaction)
    }

    // Create summaries and sort by count descending
    return emojiGroups.map { emoji, groupedReactions in
        ReactionSummary(
            emoji: emoji,
            count: groupedReactions.count,
            userIds: groupedReactions.map { $0.userId }
        )
    }.sorted { $0.count > $1.count }
}
```

## Whitelisted Emojis

**6 Emojis (Hardcoded):**

| Emoji | Name | Unicode | Use Case |
|-------|------|---------|----------|
| 👍 | Thumbs Up | U+1F44D | Agreement, approval |
| ❤️ | Red Heart | U+2764 | Love, appreciation |
| 😂 | Laughing Face | U+1F602 | Humor, funny |
| 😮 | Surprised Face | U+1F62E | Surprise, shock |
| 🎉 | Party Popper | U+1F389 | Celebration, congrats |
| 🔥 | Fire | U+1F525 | Exciting, hot take |

**Rationale:**
- Covers common emotional responses
- Universally understood
- No ambiguity or cultural sensitivity issues
- Small enough set to implement quickly
- Can be expanded later based on user feedback

## Error Handling

### Network Errors

**Scenario**: API call fails (network down, server error)

**Handling**:
1. Catch error in ViewModel
2. Set `@Published var errorMessage: String?`
3. Display `Alert` in ChatRoomView
4. Do NOT update local state (keep previous reactions)

**User Experience**:
- Alert shows: "リアクションを追加できませんでした" (Failed to add reaction)
- User can retry or dismiss

### Known Limitations

**No GET Endpoint for Reactions:**
- **Problem**: Cannot fetch reactions independently
- **Current Solution**: Initialize with empty array
- **Future Solution**: Either embed reactions in Message entity or add GET endpoint
- **User Impact**: Reactions won't persist across app restarts (using mock repo)

**No Real-Time Updates:**
- **Problem**: Other users' reactions won't appear automatically
- **Current Solution**: Pull-to-refresh to reload messages
- **Future Solution**: Implement websockets or polling
- **User Impact**: Manual refresh required to see others' reactions

## Performance Considerations

### Reaction Aggregation

**Complexity**: O(n) where n = number of reactions per message
- Expected: <20 reactions per message
- Impact: Negligible

**Optimization** (future):
- Aggregate on backend instead of client
- Cache summaries in ViewModel

### UI Rendering

**ReactionSummaryView:**
- Renders on every message
- Expected: 0-5 reactions per message
- Impact: Minimal

**No animations initially:**
- Reduces complexity
- Improves performance
- Can add later with `.animation()` modifier

## Testing Strategy

### Manual Testing (Task 7)

**Focus Areas:**
1. Add reaction flow
2. Remove reaction flow
3. Multiple reactions per message
4. User's own reactions highlighted
5. Error handling (network failures)

**No Unit Tests Initially:**
- Minimal implementation prioritizes functionality
- Tests can be added in future iteration
- ViewModel logic is simple enough to verify manually

## Dependency Injection

### DependencyContainer Updates

```swift
// Add these lazy properties:

lazy var reactionRepository: ReactionRepositoryProtocol = {
    MockReactionRepository() // Use mock for development
    // Or: ReactionRepository(client: client) for production
}()

lazy var reactionUseCase: ReactionUseCase = {
    ReactionUseCase(reactionRepository: reactionRepository)
}()

// Update ViewModel factory:
func makeChatRoomViewModel(...) -> ChatRoomViewModel {
    ChatRoomViewModel(
        // ... existing params
        reactionUseCase: reactionUseCase
    )
}
```

## Future Enhancements (Out of Scope)

1. **More Emojis**: Expand from 6 to 12-20
2. **Custom Emoji Picker**: Full emoji keyboard integration
3. **Animations**: Bounce/fade effects on add/remove
4. **Real-Time Updates**: Websockets for instant reactions
5. **Reaction Details**: Modal showing "Who reacted"
6. **Accessibility**: VoiceOver labels, Dynamic Type support
7. **Unit Tests**: Comprehensive test coverage
8. **Optimistic UI**: Show reaction immediately, rollback on error
9. **Reaction Notifications**: Notify when someone reacts to your message
10. **Reaction Analytics**: Track most popular emojis

## Technical Constraints

- **iOS 16.0+**: Minimum deployment target
- **SwiftUI**: All UI components
- **MVVM + Clean Architecture**: Existing pattern
- **@MainActor**: ViewModels must be main actor
- **OpenAPI Client**: API integration (when using real repository)

## Security Considerations

- **User ID Validation**: Ensure user can only remove their own reactions
- **Emoji Validation**: Only accept whitelisted emojis (frontend + backend)
- **Rate Limiting**: Backend should prevent spam (not implemented in this proposal)

## Migration Path

**Phase 1 (This Proposal)**: Minimal UI with 6 emojis
**Phase 2**: Add unit tests, accessibility
**Phase 3**: Expand emoji set, add animations
**Phase 4**: Real-time updates, reaction details
**Phase 5**: Advanced features (custom emojis, analytics)

## Success Metrics

- ✅ Users can add reactions to messages
- ✅ Users can remove their reactions
- ✅ Reactions display correctly
- ✅ App doesn't crash
- ✅ Error handling works

**User Feedback Needed:**
- Are 6 emojis sufficient?
- Is the UI intuitive?
- Any missing functionality?

## Open Questions

1. **Should we show reaction counts in real-time or require refresh?**
   - Decision: Require refresh (minimal implementation)

2. **Should we limit reactions per user per message?**
   - Decision: One reaction per emoji per user (backend enforces)

3. **Should we use context menu or sheet for picker?**
   - Decision: Context menu (native iOS pattern)

4. **Should we use MockRepository or ReactionRepository initially?**
   - Decision: MockRepository for development, switch to real later

5. **Should we implement optimistic UI updates?**
   - Decision: No (minimal implementation, add later)

All questions resolved with bias toward simplicity.
