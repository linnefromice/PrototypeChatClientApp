# Spec: Reaction UI

## ADDED Requirements

### Requirement: Reaction Picker UI

The system SHALL provide a reaction picker interface that allows users to select an emoji to react with.

#### Scenario: Open reaction picker via long press

**Given** the user is viewing a message in the chat room
**When** the user performs a long press gesture on the message bubble
**Then** a reaction picker appears as a context menu
**And** the picker displays a grid of common emojis
**And** the picker shows at least 12 emoji options

#### Scenario: Select emoji from picker

**Given** the reaction picker is visible
**When** the user taps on an emoji (e.g., "👍")
**Then** the picker dismisses
**And** the selected emoji is added as a reaction to the message
**And** the reaction appears in the reaction summary below the message

#### Scenario: Cancel reaction picker

**Given** the reaction picker is visible
**When** the user taps outside the picker or presses back
**Then** the picker dismisses without adding a reaction
**And** no API call is made

---

### Requirement: Reaction Summary Display

The system SHALL display aggregated reactions below each message bubble with counts.

#### Scenario: Display single reaction

**Given** a message has one reaction: "👍" from one user
**When** the message is displayed
**Then** a reaction summary appears below the message bubble
**And** the summary shows "👍 1"
**And** the emoji and count are clearly visible

#### Scenario: Display multiple different reactions

**Given** a message has reactions: "👍" (3 users), "❤️" (2 users), "😂" (1 user)
**When** the message is displayed
**Then** the summary shows "👍 3", "❤️ 2", "😂 1" in order
**And** reactions are sorted by count descending (most popular first)
**And** each reaction is displayed as a pill-shaped button

#### Scenario: Highlight current user's reaction

**Given** the current user has reacted with "❤️" to a message
**And** other users have also reacted with "❤️"
**When** the reaction summary is displayed
**Then** the "❤️" reaction is visually highlighted (e.g., filled background)
**And** other reactions (not from current user) appear with a different style
**And** the user can easily identify their own reactions

#### Scenario: No reactions to display

**Given** a message has no reactions
**When** the message is displayed
**Then** no reaction summary is shown below the message
**And** the message bubble appears as normal without extra space

---

### Requirement: Toggle Reaction Interaction

The system SHALL allow users to add or remove their reactions by tapping on the reaction summary.

#### Scenario: Add reaction via tap on summary

**Given** a message has an existing "👍" reaction from other users
**And** the current user has not reacted with "👍"
**When** the user taps the "👍 3" reaction summary
**Then** the current user's "👍" reaction is added
**And** the summary updates to "👍 4"
**And** the reaction is visually highlighted as the user's own reaction

#### Scenario: Remove reaction via tap on summary

**Given** the current user has reacted with "👍" to a message
**And** the summary shows "👍 4" (including the user's reaction)
**When** the user taps the "👍 4" reaction summary
**Then** the current user's reaction is removed
**And** the summary updates to "👍 3"
**And** the reaction is no longer highlighted

#### Scenario: Remove last reaction of an emoji

**Given** only the current user has reacted with "😂" to a message
**And** the summary shows "😂 1"
**When** the user taps the "😂 1" summary
**Then** the reaction is removed
**And** the "😂" reaction disappears from the summary entirely
**And** if no other reactions exist, the entire summary is hidden

---

### Requirement: ChatRoomViewModel Integration

The system SHALL integrate reaction management into the ChatRoomViewModel to handle state and API calls.

#### Scenario: Load reactions when loading messages

**Given** the chat room view is opened for a conversation
**When** messages are loaded via the ViewModel
**Then** reactions for each message are also fetched
**And** the reactions are stored in the ViewModel state
**And** the UI displays reaction summaries for each message

#### Scenario: Add reaction updates ViewModel state

**Given** the user adds a "👍" reaction to a message
**When** the ViewModel processes the add reaction action
**Then** the ViewModel calls `ReactionUseCase.addReaction`
**And** the new reaction is added to the local state
**And** the `@Published reactions` property updates
**And** the UI automatically refreshes to show the new reaction

#### Scenario: Remove reaction updates ViewModel state

**Given** the user removes their "❤️" reaction
**When** the ViewModel processes the remove reaction action
**Then** the ViewModel calls `ReactionUseCase.removeReaction`
**And** the reaction is removed from local state
**And** the `@Published reactions` property updates
**And** the UI automatically hides the removed reaction

#### Scenario: Handle reaction operation error

**Given** the user tries to add a reaction
**And** the network is unavailable
**When** the ViewModel attempts the add reaction operation
**Then** an error is thrown by the use case
**And** the ViewModel sets an error state
**And** an error alert is displayed to the user
**And** the user is offered a retry option

---

### Requirement: MessageBubbleView Updates

The system MUST update the MessageBubbleView to display reaction summaries below the message text.

#### Scenario: Render reaction summary in message bubble

**Given** a message has reactions
**When** the MessageBubbleView is rendered
**Then** the reaction summary view appears below the message text
**And** the summary is aligned with the message bubble (left for others, right for own messages)
**And** the summary does not overflow the message bubble width

#### Scenario: Long press gesture on message

**Given** the user is viewing a message
**When** the user performs a long press on the MessageBubbleView
**Then** a context menu appears with the reaction picker
**And** the message text remains visible during the gesture
**And** the picker is positioned near the message

---

### Requirement: Visual Design and Styling

The system SHALL follow iOS design guidelines for reaction UI components.

#### Scenario: Reaction pill styling

**Given** a reaction summary is displayed
**Then** each reaction is styled as a rounded pill
**And** the pill has a light gray background (system fill color)
**And** the emoji is displayed with the count next to it (e.g., "👍 3")
**And** the pill has appropriate padding and corner radius

#### Scenario: User's own reaction highlighting

**Given** the current user has reacted to a message
**Then** their reaction pill has a blue background (or accent color)
**And** the text and emoji are white (high contrast)
**And** the pill stands out visually from other reactions

#### Scenario: Reaction picker layout

**Given** the reaction picker is displayed
**Then** emojis are arranged in a 6x2 grid
**And** each emoji is at least 44x44 points (tappable size)
**And** the picker has a subtle shadow and background blur (iOS style)

---

### Requirement: Loading States and Feedback

The system SHALL provide appropriate loading and feedback states during reaction operations.

#### Scenario: Loading indicator during add reaction

**Given** the user adds a reaction
**When** the API call is in progress
**Then** a subtle loading indicator appears on the reaction pill
**And** the user can still interact with other messages
**And** the indicator disappears when the operation completes

#### Scenario: Optimistic UI update

**Given** the user adds a reaction
**When** the add reaction request is sent to the API
**Then** the reaction immediately appears in the UI (optimistic update)
**And** the reaction count increments instantly
**And** if the API call fails, the reaction is removed and an error is shown

#### Scenario: Error feedback on failed operation

**Given** adding a reaction fails due to network error
**When** the error occurs
**Then** the optimistic update is rolled back
**And** a brief error message appears (e.g., toast or alert)
**And** the user can retry the operation

---

### Requirement: Accessibility

The system SHALL ensure reaction UI is accessible to users with disabilities.

#### Scenario: VoiceOver support for reactions

**Given** VoiceOver is enabled
**When** the user navigates to a message with reactions
**Then** VoiceOver announces "3 people reacted with thumbs up"
**And** if the user has reacted, it announces "including you"
**And** the user can navigate to individual reaction pills

#### Scenario: VoiceOver for reaction picker

**Given** VoiceOver is enabled
**And** the reaction picker is open
**When** the user navigates through the picker
**Then** each emoji is announced by name (e.g., "thumbs up", "red heart")
**And** the user can select an emoji using VoiceOver gestures

#### Scenario: Dynamic Type support

**Given** the user has enabled larger text sizes
**When** reactions are displayed
**Then** the emoji and count scale appropriately
**And** the reaction pills remain readable and tappable
**And** the layout does not break with larger text

---

## MODIFIED Requirements

### Requirement: Message Bubble Rendering

The existing MessageBubbleView MUST be extended to include reaction summaries without breaking existing functionality.

#### Scenario: Backward compatibility with no reactions

**Given** a message has no reactions
**When** the updated MessageBubbleView is used
**Then** the message displays exactly as before (no visual changes)
**And** no extra spacing or layout issues appear
**And** existing functionality (timestamp, sender name) remains unchanged

---

## Implementation Notes

### View Components

**ReactionSummaryView** (new):
- Displays array of `ReactionSummary`
- Pill-shaped buttons for each emoji
- Tap gesture to add/remove reactions
- Highlights user's own reactions

**ReactionPickerView** (new):
- Grid of emoji buttons
- Quick reactions: 👍, ❤️, 😂, 😮, 😢, 🎉, 👏, 🔥, ✨, 🙏, 👀, 🚀
- Optional: "More" button for full emoji picker

**MessageBubbleView** (modified):
- Add `ReactionSummaryView` below message text
- Add `.contextMenu` with `ReactionPickerView`
- Pass reaction data and callbacks from ViewModel

### ChatRoomViewModel Changes

```swift
class ChatRoomViewModel: ObservableObject {
    @Published var reactions: [String: [Reaction]] = [:] // messageId → reactions
    private let reactionUseCase: ReactionUseCase

    func loadReactions(for messageId: String) async {
        // Fetch and store reactions
    }

    func addReaction(to messageId: String, emoji: String) async {
        // Call use case, update state
    }

    func removeReaction(from messageId: String, emoji: String) async {
        // Call use case, update state
    }

    func reactionSummary(for messageId: String) -> [ReactionSummary] {
        let messageReactions = reactions[messageId] ?? []
        return reactionUseCase.computeSummaries(
            reactions: messageReactions,
            currentUserId: currentUserId
        )
    }
}
```

### State Management

- Reactions stored as `@Published` property in ViewModel
- Automatic UI updates via Combine
- Optimistic updates for better UX

### Error Handling

- Network errors: Show alert with retry option
- Validation errors: Prevent invalid emoji selection
- Offline mode: Queue reactions for later (out of scope for MVP)

### Performance

- Lazy load reactions for visible messages only
- Cache reactions in memory during chat session
- Debounce rapid taps to prevent API spam

### Testing

- Unit tests for ReactionSummaryView rendering
- Snapshot tests for reaction UI states
- Integration tests for add/remove flows
- Accessibility tests for VoiceOver
