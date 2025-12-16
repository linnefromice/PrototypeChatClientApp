# Spec: Chat Messaging

**Capability:** `chat-messaging`
**Type:** Feature
**Status:** Active

## Overview

This spec defines how users can view and send text messages within a conversation. Messages are displayed in a familiar chat bubble format with visual distinction between sent and received messages.

## ADDED Requirements

### Requirement: MSG-001 - Chat Room Navigation

Users MUST be able to navigate from the conversation list to a dedicated chat room screen for viewing and sending messages.

**Rationale:** Users need a clear way to access the messaging interface for each conversation. This follows the standard iOS navigation pattern from list to detail view.

#### Scenario: User taps on a conversation

**Given** the user is viewing the conversation list screen
**And** at least one conversation exists in the list
**When** the user taps on a conversation row
**Then** the app navigates to the chat room screen for that conversation
**And** the navigation bar shows the conversation name
**And** the back button is visible in the top-left corner

---

#### Scenario: Chat room displays conversation title

**Given** the user has navigated to a chat room for a direct conversation with "Bob"
**When** the chat room screen loads
**Then** the navigation bar title displays "Bob"

**Given** the user has navigated to a chat room for a group conversation named "Project Team"
**When** the chat room screen loads
**Then** the navigation bar title displays "Project Team"

---

#### Scenario: User returns to conversation list

**Given** the user is viewing a chat room screen
**When** the user taps the back button in the navigation bar
**Then** the app navigates back to the conversation list
**And** the user can see the updated conversation list

---

### Requirement: MSG-002 - Message List Display

The chat room MUST display a scrollable list of messages with visual distinction between sent and received messages.

**Rationale:** Users need to see the message history in a familiar, easy-to-read format. The bubble chat UI pattern is standard across messaging apps and provides clear visual separation.

#### Scenario: Messages are displayed in chronological order

**Given** the user is viewing a chat room with 10 messages
**And** message A was sent at 10:00
**And** message B was sent at 10:05
**When** the chat room loads
**Then** message A appears above message B in the list
**And** the oldest message is at the top
**And** the newest message is at the bottom

---

#### Scenario: Own messages are right-aligned with blue bubbles

**Given** the user is logged in as "user-1" (Alice)
**And** the chat room contains a message sent by "user-1"
**When** the message is displayed
**Then** the message bubble is aligned to the right side of the screen
**And** the bubble background color is blue
**And** the text color is white
**And** no sender name is displayed

---

#### Scenario: Other users' messages are left-aligned with gray bubbles

**Given** the user is logged in as "user-1" (Alice)
**And** the chat room contains a message sent by "user-2" (Bob)
**When** the message is displayed
**Then** the message bubble is aligned to the left side of the screen
**And** the bubble background color is gray
**And** the text color is black
**And** the sender name "Bob" is displayed above the bubble

---

#### Scenario: Message bubbles display timestamp

**Given** a message was sent at "2025-12-16 14:30:00"
**When** the message is displayed
**Then** the timestamp "14:30" is shown below the message bubble
**And** the timestamp text is small and gray

---

#### Scenario: Auto-scroll to latest message on load

**Given** the chat room contains 50 messages
**When** the chat room screen loads
**Then** the scroll view automatically scrolls to the bottom
**And** the most recent message is visible at the bottom of the screen

---

#### Scenario: Empty chat room displays empty state

**Given** the user is viewing a chat room
**And** no messages have been sent in the conversation yet
**When** the chat room loads
**Then** an empty state message is displayed
**And** the empty state says "まだメッセージがありません"
**And** a speech bubble icon is shown

---

### Requirement: MSG-003 - Message Input

Users MUST be able to compose and send text messages through a text input field fixed at the bottom of the screen.

**Rationale:** The input field must remain accessible while scrolling through message history. Fixing it at the bottom follows iOS messaging conventions and provides consistent access.

#### Scenario: Message input field is always visible

**Given** the user is viewing a chat room
**When** the screen loads
**Then** a text input field is visible at the bottom of the screen
**And** the input field has placeholder text "メッセージを入力"
**And** a send button is visible next to the input field

---

#### Scenario: Send button is disabled when text is empty

**Given** the user is viewing the message input field
**And** no text has been entered
**When** the input field is empty
**Then** the send button is disabled
**And** the send button appears gray

---

#### Scenario: Send button is enabled when text is entered

**Given** the user is viewing the message input field
**When** the user types "Hello" into the text field
**Then** the send button becomes enabled
**And** the send button appears blue

---

#### Scenario: User sends a message successfully

**Given** the user has typed "Hello World" into the message input field
**And** the send button is enabled
**When** the user taps the send button
**Then** the message "Hello World" is sent to the API
**And** the input field is cleared
**And** the send button becomes disabled
**And** a loading indicator appears briefly

---

#### Scenario: Sent message appears in the chat

**Given** the user has sent a message "Hello World"
**When** the API responds with success
**Then** the new message appears at the bottom of the message list
**And** the message bubble is right-aligned (own message)
**And** the scroll view automatically scrolls to show the new message

---

#### Scenario: Keyboard appears above input field

**Given** the user taps on the message input field
**When** the keyboard appears
**Then** the input field moves up to remain above the keyboard
**And** the message list content is still scrollable
**And** the input field remains fixed above the keyboard

---

#### Scenario: Input field dismisses keyboard

**Given** the keyboard is visible
**When** the user taps outside the input field
**Or** the user taps the send button
**Then** the keyboard is dismissed
**And** the input field returns to the bottom of the screen

---

### Requirement: MSG-004 - Loading and Error States

The chat room MUST provide clear feedback during message loading and error conditions.

**Rationale:** Users need to understand when the app is working and when errors occur. Clear loading and error states prevent confusion and improve trust.

#### Scenario: Loading state during message fetch

**Given** the user has navigated to a chat room
**When** the app is fetching messages from the API
**Then** a loading spinner is displayed in the center of the screen
**And** the message "読み込み中..." is shown below the spinner

---

#### Scenario: Loading state during message send

**Given** the user has tapped the send button
**When** the app is sending the message to the API
**Then** the send button shows a small loading spinner
**And** the send button remains disabled
**And** the user cannot send another message

---

#### Scenario: Error state when message fetch fails

**Given** the user has navigated to a chat room
**When** the API returns an error response
**Then** an error alert is displayed
**And** the alert title is "エラー"
**And** the alert message is "メッセージの取得に失敗しました"
**And** the alert has an "OK" button

---

#### Scenario: Error state when message send fails

**Given** the user has tapped the send button
**When** the API returns an error response
**Then** the loading spinner disappears
**And** an error alert is displayed
**And** the alert message is "メッセージの送信に失敗しました"
**And** the message text remains in the input field
**And** the user can retry sending

---

#### Scenario: Network error handling

**Given** the user has no internet connection
**When** the user tries to load messages
**Then** an error alert displays "ネットワークエラー: インターネット接続を確認してください"

---

### Requirement: MSG-005 - Pull-to-Refresh

Users MUST be able to manually refresh the message list to fetch new messages.

**Rationale:** Since Phase 1 does not include real-time updates, users need a manual way to check for new messages. Pull-to-refresh is a familiar iOS pattern.

#### Scenario: User pulls to refresh message list

**Given** the user is viewing a chat room with messages
**When** the user pulls down on the message list from the top
**Then** a refresh indicator appears
**And** the app fetches the latest messages from the API

---

#### Scenario: New messages appear after refresh

**Given** the chat room contains 5 messages
**And** a new message was sent by another user
**When** the user pulls to refresh
**And** the API returns 6 messages
**Then** the new message appears at the bottom of the list
**And** the scroll position remains at the bottom
**And** the refresh indicator disappears

---

#### Scenario: No new messages after refresh

**Given** the chat room contains 5 messages
**And** no new messages were sent
**When** the user pulls to refresh
**And** the API returns the same 5 messages
**Then** the message list remains unchanged
**And** the refresh indicator disappears
**And** no error is shown

---

### Requirement: MSG-006 - Message Data Integrity

The system MUST correctly handle message data including sender information, timestamps, and text content.

**Rationale:** Accurate message display is critical for communication. Users need to trust that messages are displayed correctly with proper attribution.

#### Scenario: Message displays correct sender

**Given** a message was sent by user "user-2" (Bob)
**And** the message sender's User object has name "Bob"
**When** the message is displayed
**Then** the sender name "Bob" is shown
**And** the sender information matches the User entity

---

#### Scenario: Message displays correct timestamp

**Given** a message was created at "2025-12-16T14:30:45.123Z"
**When** the message is displayed
**Then** the timestamp is formatted as "14:30"
**And** the time is displayed in the user's local timezone

---

#### Scenario: Message displays multiline text correctly

**Given** a message contains the text "Line 1\nLine 2\nLine 3"
**When** the message is displayed
**Then** the bubble shows three separate lines
**And** line breaks are preserved
**And** the bubble height adjusts to fit the content

---

#### Scenario: Long message wraps correctly

**Given** a message contains very long text without line breaks
**When** the message is displayed
**Then** the text wraps to multiple lines within the bubble
**And** the bubble width does not exceed the screen width
**And** a maximum width is enforced (e.g., 70% of screen width)

---

#### Scenario: Special characters are displayed correctly

**Given** a message contains emoji "👋 Hello!"
**When** the message is displayed
**Then** the emoji renders correctly
**And** the text "Hello!" is displayed next to the emoji

---

### Requirement: MSG-007 - Integration with Existing Authentication

The chat room MUST correctly integrate with the existing authentication system to identify the current user.

**Rationale:** The app needs to know which messages belong to the current user for proper bubble alignment and styling.

#### Scenario: Current user messages are identified correctly

**Given** the user is logged in as "user-1"
**And** the chat room contains messages from "user-1" and "user-2"
**When** the messages are displayed
**Then** messages from "user-1" are right-aligned (own messages)
**And** messages from "user-2" are left-aligned (other messages)

---

#### Scenario: Message sends with correct sender ID

**Given** the user is logged in as "user-1"
**When** the user sends a message "Test"
**Then** the API request includes `senderUserId: "user-1"`
**And** the API request includes `type: "text"`
**And** the API request includes `text: "Test"`

---

#### Scenario: User can send messages in multiple conversations

**Given** the user is logged in as "user-1"
**And** the user sends a message in conversation A
**And** the user navigates to conversation B
**When** the user sends a message in conversation B
**Then** both messages are sent with the correct conversation IDs
**And** both messages are attributed to "user-1"

---

## Related Specs

- Integrates with: Conversation List (existing)
- Integrates with: Authentication system (existing)
- Depends on: ConversationDetail entity (existing)
- Depends on: User entity (existing)
- Future: Real-time message updates (WebSocket/polling)
- Future: Message reactions
- Future: Message replies

## Implementation Notes

- Uses SwiftUI `.sheet(isPresented:)` or `NavigationLink` for navigation
- Uses SwiftUI `ScrollViewReader` for auto-scroll to bottom
- Uses SwiftUI `.refreshable` for pull-to-refresh
- Leverages `@EnvironmentObject` for `AuthenticationViewModel` access
- Message list uses `LazyVStack` for performance with many messages
- API limits messages to 50 per request (via `limit` parameter)

## Testing Strategy

- **Unit Tests:** `MessageUseCase` message fetch and send logic
- **Unit Tests:** `ChatRoomViewModel` state management
- **Unit Tests:** `Message` entity codable and equatable
- **Manual Tests:** Full messaging flow in simulator with multiple users
- **Edge Cases:** Empty messages, long text, special characters, network errors
- **Regression Tests:** Verify existing auth and conversation list still work

## Accessibility Considerations

- Message bubbles MUST have accessible labels with sender name and message text
- Send button MUST have accessible label "送信"
- Input field MUST have accessible label "メッセージを入力"
- Loading states MUST be announced by VoiceOver
- Error alerts MUST be readable by VoiceOver
- All interactive elements MUST have sufficient touch target size (44x44 points)
