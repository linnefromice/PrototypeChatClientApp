# Spec: Minimal Reaction UI

## Capability Overview

Provides a minimal user interface for message reactions in the chat application, allowing users to add and remove emoji reactions from messages using a whitelist of 6 predefined emojis.

## ADDED Requirements

### Requirement: Reaction Picker Component

The system SHALL provide a reaction picker component that displays a selectable grid of whitelisted emojis.

**Constraints:**
- The picker MUST display exactly 6 emojis: 👍, ❤️, 😂, 😮, 🎉, 🔥
- The picker MUST use a 2×3 grid layout (2 rows, 3 columns)
- Each emoji button MUST have a minimum touch target of 44×44 points
- The picker MUST call a completion handler when an emoji is selected
- The picker MUST be dismissible after emoji selection

#### Scenario: User opens reaction picker

**Given** a message exists in the chat
**When** the user long-presses the message
**Then** a context menu SHALL appear
**And** the reaction picker SHALL display 6 emojis in a grid
**And** each emoji SHALL be tappable

#### Scenario: User selects emoji from picker

**Given** the reaction picker is visible
**When** the user taps an emoji (e.g., 👍)
**Then** the picker SHALL call the `onSelect` callback with the selected emoji
**And** the picker SHALL dismiss automatically

---

### Requirement: Reaction Summary Display

The system SHALL display reaction summaries below message content as interactive pills.

**Constraints:**
- Each reaction pill MUST show emoji and count (format: "{emoji} {count}")
- Pills MUST use capsule shape with rounded corners
- Pills MUST be arranged in a horizontal flow layout
- User's own reactions MUST have distinct visual styling (blue/accent background)
- Other users' reactions MUST use gray background
- Pills MUST be tappable to toggle reaction state
- Pills MUST display reactions sorted by count (descending)

#### Scenario: Message with reactions displays summary

**Given** a message has 3 reactions:
- 👍 from user-1 and user-2
- ❤️ from user-3
**When** user-1 views the message
**Then** the reaction summary SHALL display 2 pills
**And** the first pill SHALL show "👍 2" with blue background (user's own)
**And** the second pill SHALL show "❤️ 1" with gray background (other's)

#### Scenario: Message without reactions shows no summary

**Given** a message has no reactions
**When** the message is displayed
**Then** no reaction summary SHALL be shown
**And** the message layout SHALL be unchanged

#### Scenario: User taps own reaction pill

**Given** a message displays "👍 2" where user has reacted
**When** the user taps the "👍 2" pill
**Then** the system SHALL remove the user's reaction
**And** the pill SHALL update to "👍 1" or disappear if count becomes 0
**And** the background color SHALL change to gray if other reactions remain

#### Scenario: User taps other's reaction pill

**Given** a message displays "❤️ 1" where user has NOT reacted
**When** the user taps the "❤️ 1" pill
**Then** the system SHALL add the user's reaction
**And** the pill SHALL update to "❤️ 2"
**And** the background color SHALL change to blue (user's own)

---

### Requirement: Message Bubble Integration

The system SHALL integrate reaction UI components into existing message bubbles.

**Constraints:**
- `MessageBubbleView` MUST accept optional `reactions` parameter
- `MessageBubbleView` MUST accept optional `currentUserId` parameter
- `MessageBubbleView` MUST accept `onReactionTap` callback
- `MessageBubbleView` MUST accept `onAddReaction` callback
- Reaction summary MUST appear below message text
- Long-press gesture MUST trigger context menu with reaction picker
- Existing message layout MUST NOT regress

#### Scenario: Message bubble shows reactions

**Given** a message has reactions
**When** the message bubble is rendered
**Then** the reaction summary component SHALL appear below the message text
**And** the message sender, text, and timestamp SHALL remain unchanged

#### Scenario: User long-presses message to add reaction

**Given** a message is displayed
**When** the user performs a long-press gesture on the message
**Then** a context menu SHALL appear
**And** the reaction picker SHALL be visible
**And** the user SHALL be able to select an emoji

---

### Requirement: ViewModel Reaction Management

The system SHALL manage reaction state and operations in the `ChatRoomViewModel`.

**Constraints:**
- ViewModel MUST maintain `@Published var messageReactions: [String: [Reaction]]`
- ViewModel MUST inject `ReactionUseCase` via initializer
- ViewModel MUST provide `addReaction(to:emoji:)` method
- ViewModel MUST provide `removeReaction(from:emoji:)` method
- ViewModel MUST provide `toggleReaction(on:emoji:)` method
- ViewModel MUST provide `reactionSummaries(for:)` method
- Methods MUST be async and handle errors
- Errors MUST update `@Published errorMessage` property

#### Scenario: User adds reaction via ViewModel

**Given** a message with ID "msg-123" has no reactions
**When** `addReaction(to: "msg-123", emoji: "👍")` is called
**Then** the ViewModel SHALL call `reactionUseCase.addReaction()`
**And** the ViewModel SHALL update `messageReactions["msg-123"]` with the new reaction
**And** the UI SHALL automatically re-render via `@Published` property

#### Scenario: User toggles reaction they already have

**Given** user has reacted with 👍 to message "msg-123"
**When** `toggleReaction(on: "msg-123", emoji: "👍")` is called
**Then** the ViewModel SHALL detect user has reacted
**And** the ViewModel SHALL call `removeReaction()`
**And** the reaction SHALL be removed from `messageReactions["msg-123"]`

#### Scenario: User toggles reaction they don't have

**Given** user has NOT reacted with ❤️ to message "msg-123"
**When** `toggleReaction(on: "msg-123", emoji: "❤️")` is called
**Then** the ViewModel SHALL detect user has not reacted
**And** the ViewModel SHALL call `addReaction()`
**And** the reaction SHALL be added to `messageReactions["msg-123"]`

#### Scenario: Reaction operation fails with error

**Given** the network is unavailable
**When** `addReaction(to: "msg-123", emoji: "👍")` is called
**Then** the operation SHALL throw an error
**And** the ViewModel SHALL catch the error
**And** the ViewModel SHALL set `errorMessage` to a user-friendly message
**And** `messageReactions` SHALL NOT be updated

---

### Requirement: Chat View Integration

The system SHALL connect reaction UI components to the ViewModel in `ChatRoomView`.

**Constraints:**
- `ChatRoomView` MUST pass `reactionSummaries(for:)` to each `MessageBubbleView`
- `ChatRoomView` MUST pass `currentUserId` to each `MessageBubbleView`
- `ChatRoomView` MUST provide `onReactionTap` callback that calls `toggleReaction()`
- `ChatRoomView` MUST provide `onAddReaction` callback that calls `addReaction()`
- Callbacks MUST be async tasks
- UI MUST update automatically when `messageReactions` changes

#### Scenario: Reactions display in chat view

**Given** a conversation is loaded with messages
**And** some messages have reactions
**When** `ChatRoomView` is rendered
**Then** each message SHALL display its reaction summaries
**And** the summaries SHALL be computed by `viewModel.reactionSummaries(for:)`

#### Scenario: User interacts with reaction in chat

**Given** a message is displayed with a reaction pill
**When** the user taps the pill
**Then** `ChatRoomView` SHALL call `viewModel.toggleReaction()` in an async task
**And** the UI SHALL update when the operation completes

---

### Requirement: Dependency Injection

The system SHALL register reaction dependencies in the dependency injection container.

**Constraints:**
- `DependencyContainer` MUST provide lazy `reactionRepository` property
- `DependencyContainer` MUST provide lazy `reactionUseCase` property
- `DependencyContainer` MUST inject `reactionUseCase` into `chatRoomViewModel`
- Dependency resolution MUST respect `@MainActor` requirements
- Circular dependencies MUST NOT exist

#### Scenario: Dependencies resolve correctly

**Given** the app is initialized
**When** `DependencyContainer.shared` is accessed
**Then** `reactionRepository` SHALL be lazily initialized
**And** `reactionUseCase` SHALL be lazily initialized with `reactionRepository`
**And** `chatRoomViewModel` SHALL receive `reactionUseCase` in its initializer

---

### Requirement: Error Handling and User Feedback

The system SHALL handle errors gracefully and provide user feedback.

**Constraints:**
- Network failures MUST be caught and displayed as alerts
- Error alerts MUST show user-friendly messages in Japanese
- Failed operations MUST NOT update local state
- Users MUST be able to retry failed operations
- Users MUST be able to dismiss error alerts

#### Scenario: Network error when adding reaction

**Given** the network is unavailable
**When** the user attempts to add a reaction
**Then** an alert SHALL appear with message "リアクションを追加できませんでした"
**And** the local state SHALL remain unchanged
**And** the user SHALL be able to dismiss the alert

#### Scenario: Network error when removing reaction

**Given** the network is unavailable
**When** the user attempts to remove their reaction
**Then** an alert SHALL appear with message "リアクションを削除できませんでした"
**And** the local state SHALL remain unchanged
**And** the user SHALL be able to dismiss the alert

---

### Requirement: Emoji Whitelist

The system SHALL restrict reactions to a predefined whitelist of 6 emojis.

**Constraints:**
- The whitelist MUST contain exactly these emojis: 👍, ❤️, 😂, 😮, 🎉, 🔥
- The whitelist MUST be hardcoded in `ReactionPickerView`
- The system MUST NOT accept emojis outside the whitelist
- The whitelist MAY be expanded in future iterations

#### Scenario: Only whitelisted emojis are selectable

**Given** the reaction picker is displayed
**Then** exactly 6 emojis SHALL be shown: 👍, ❤️, 😂, 😮, 🎉, 🔥
**And** no other emojis SHALL be selectable

---

### Requirement: Minimal Dynamic Behavior

The system SHALL implement minimal dynamic UI behavior, deferring advanced features to future iterations.

**Constraints:**
- NO animations for adding/removing reactions
- NO real-time updates (requires manual refresh)
- NO optimistic UI updates (wait for API response)
- NO "who reacted" details modal
- NO reaction count limits (enforced by backend)
- NO accessibility enhancements (VoiceOver, Dynamic Type)

#### Scenario: Reaction changes require manual refresh

**Given** user A adds a reaction to a message
**When** user B views the same message
**Then** the new reaction SHALL NOT appear automatically
**And** user B MUST pull-to-refresh to see the updated reactions

#### Scenario: No animations when reacting

**Given** a message is displayed
**When** the user adds or removes a reaction
**Then** the reaction SHALL appear/disappear immediately without animation

---

## Implementation Notes

### Leverages Existing Implementation

This specification builds on the existing domain and data layer implementation:
- ✅ `Reaction` entity (Features/Chat/Domain/Entities/Reaction.swift)
- ✅ `ReactionSummary` entity (Features/Chat/Domain/Entities/ReactionSummary.swift)
- ✅ `ReactionRepositoryProtocol` (Features/Chat/Domain/Repositories/)
- ✅ `ReactionUseCase` (Features/Chat/Domain/UseCases/ReactionUseCase.swift)
- ✅ `ReactionRepository` (Infrastructure/Network/Repositories/)
- ✅ `MockReactionRepository` (Features/Chat/Data/Repositories/)

### Architecture Pattern

Follows **MVVM + Clean Architecture**:
- **View**: ReactionPickerView, ReactionSummaryView, MessageBubbleView (modified)
- **ViewModel**: ChatRoomViewModel (modified) - manages state, calls use case
- **Use Case**: ReactionUseCase (existing) - business logic
- **Repository**: ReactionRepositoryProtocol (existing) - data access

### Future Enhancements (Out of Scope)

- Expand emoji whitelist beyond 6
- Add animations and transitions
- Implement real-time updates via websockets
- Add "who reacted" details
- Comprehensive accessibility support
- Reaction notifications
- Custom emoji selection
- Optimistic UI updates

### Known Limitations

- No GET endpoint for reactions in OpenAPI schema
- Reactions use `MockReactionRepository` initially
- No real-time synchronization
- Limited to 6 emojis initially

## Validation

### Manual Testing

The implementation SHALL be validated via manual testing in simulator (Task 7):
1. ✅ Long-press message shows picker
2. ✅ Picker displays 6 emojis
3. ✅ Selecting emoji adds reaction
4. ✅ Reaction appears as pill below message
5. ✅ User's reaction has blue background
6. ✅ Tapping reaction removes it
7. ✅ Multiple reactions can coexist
8. ✅ Error handling works (network failures)
9. ✅ No crashes or visual regressions

### Code Review

The implementation SHALL:
- Follow existing Swift style guide
- Use MVVM + Clean Architecture pattern
- Maintain SwiftUI best practices
- Include inline documentation for public APIs
- Use `@MainActor` for ViewModels

## Success Criteria

- [ ] All 7 tasks completed
- [ ] App builds without errors (`make build`)
- [ ] Manual testing passes all scenarios
- [ ] No crashes or visual regressions
- [ ] Error handling works
- [ ] Code follows architecture patterns
- [ ] User can add/remove reactions
- [ ] Reactions display correctly
