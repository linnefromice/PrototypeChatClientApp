# Spec: Group Chat UI

## ADDED Requirements

### Requirement: Chat Type Selection

The chat creation interface SHALL provide a mode selector that allows users to choose between creating a direct (1:1) chat or a group chat.

#### Scenario: User switches to group chat mode

**Given** the user opens the chat creation screen
**When** the user taps the "グループ" segment in the type selector
**Then** the interface switches to group chat mode
**And** a group name input field appears
**And** the user list allows multiple selections
**And** a participant count is displayed

#### Scenario: User switches back to direct chat mode

**Given** the user is in group chat mode
**When** the user taps the "ダイレクト" segment in the type selector
**Then** the interface switches to direct chat mode
**And** the group name input field disappears
**And** the user list allows single selection only
**And** any previously selected users are cleared

---

### Requirement: Group Name Input

The system MUST require users to provide a non-empty name for group chats before creation is allowed.

#### Scenario: User enters valid group name

**Given** the user is in group chat mode
**When** the user enters "Team Discussion" in the group name field
**Then** the group name is stored
**And** the create button validation considers the group name valid

#### Scenario: Create button disabled when group name is empty

**Given** the user is in group chat mode
**And** the user has selected 2 or more participants
**When** the group name field is empty
**Then** the create button is disabled

#### Scenario: Create button disabled when group name is whitespace only

**Given** the user is in group chat mode
**And** the user has selected 2 or more participants
**When** the group name field contains only spaces
**Then** the create button is disabled

---

### Requirement: Multiple Participant Selection

The system SHALL allow users to select multiple participants (minimum 2) for group chat creation, with visual feedback for selected and deselected states.

#### Scenario: User selects multiple participants

**Given** the user is in group chat mode
**When** the user taps on "Alice" in the user list
**And** the user taps on "Bob" in the user list
**Then** both Alice and Bob are marked as selected with checkmarks
**And** the participant count shows "2人選択中"
**And** the create button is enabled (assuming group name is filled)

#### Scenario: User deselects a participant

**Given** the user is in group chat mode
**And** the user has selected "Alice" and "Bob"
**When** the user taps on "Alice" again
**Then** Alice is deselected and the checkmark disappears
**And** the participant count shows "1人選択中"
**And** the create button is disabled

#### Scenario: Minimum participant validation

**Given** the user is in group chat mode
**And** the user has entered a group name
**When** the user has selected fewer than 2 participants
**Then** the create button is disabled

---

### Requirement: Group Chat Creation

The system SHALL create group chats with the specified name and selected participants when the user confirms creation, and MUST handle both success and error cases appropriately.

#### Scenario: Successful group chat creation

**Given** the user is in group chat mode
**And** the user has entered group name "Project Team"
**And** the user has selected "Alice" and "Bob"
**When** the user taps the create button
**Then** a group chat is created via `ConversationUseCase.createGroupConversation()`
**And** the group includes the current user, Alice, and Bob
**And** the chat creation screen dismisses
**And** the user is taken to the conversation list
**And** the new group chat "Project Team" appears in the list

#### Scenario: Group chat creation with many participants

**Given** the user is in group chat mode
**And** the user has entered group name "Large Group"
**And** the user has selected 5 participants
**When** the user taps the create button
**Then** a group chat is created with all 5 selected participants plus the current user (6 total)
**And** the chat creation succeeds

#### Scenario: Group chat creation fails due to network error

**Given** the user is in group chat mode
**And** the user has valid group name and participants
**And** the network is unavailable
**When** the user taps the create button
**Then** an error message is displayed
**And** the user remains on the chat creation screen
**And** the user can retry the operation

---

### Requirement: Visual Feedback

The UI SHALL provide clear visual feedback for selection states, participant counts, and loading states during group chat creation.

#### Scenario: Selected users have checkmarks

**Given** the user is in group chat mode
**When** the user taps on a user in the list
**Then** a checkmark icon appears next to that user
**And** the user row remains visually distinct from unselected users

#### Scenario: Participant count updates in real-time

**Given** the user is in group chat mode
**When** the user selects or deselects participants
**Then** the participant count label updates immediately
**And** shows the format "X人選択中" where X is the number of selected participants

#### Scenario: Loading state during creation

**Given** the user has initiated group chat creation
**When** the API call is in progress
**Then** a loading indicator is displayed
**And** the create button is disabled
**And** user interaction with the participant list is still possible

---

## MODIFIED Requirements

### Requirement: Direct Chat Creation (Backward Compatibility)

The system MUST preserve the existing direct chat creation functionality without any behavioral changes or regressions.

#### Scenario: Create direct chat (existing behavior preserved)

**Given** the user is in direct chat mode (default)
**When** the user selects a single user "Alice"
**And** the user taps the create button
**Then** a direct (1:1) chat is created
**And** the behavior is identical to the previous implementation

---

## Implementation Notes

### Technical Details

**ViewModel Changes:**
- `conversationType` enum property with cases `.direct` and `.group`
- `selectedUserIds: Set<String>` for multi-selection
- `groupName: String` for group name input
- `canCreate` computed property logic updated for both modes

**View Changes:**
- Segmented Picker for mode selection
- Conditional TextField for group name (group mode only)
- Updated user list tap handling for multi-selection
- Conditional participant count label (group mode only)

**Domain Layer (No Changes Required):**
- `ConversationUseCase.createGroupConversation()` already exists
- `ConversationRepository` already supports group creation

### Validation Rules

**Direct Mode:**
- Exactly 1 user selected → Create enabled
- 0 users selected → Create disabled

**Group Mode:**
- 2+ users selected AND non-empty group name → Create enabled
- < 2 users OR empty group name → Create disabled

### Error Messages

- Group mode with no participants: "参加者を2人以上選択してください"
- Group mode with no name: "グループ名を入力してください"
- Network/API errors: "チャットの作成に失敗しました: [error details]"

### Accessibility

- Segmented control accessible via VoiceOver
- Selected/unselected state announced clearly
- Error messages readable by screen readers
- All interactive elements have accessibility labels
