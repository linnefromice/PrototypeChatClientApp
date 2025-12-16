# Spec: Chat Creation UI Integration

**Capability:** `chat-creation-ui`
**Type:** Feature
**Status:** Active

## Overview

This spec defines how users create new 1:1 conversations through the conversation list screen. The chat creation flow is initiated from the conversation list and presented as a modal sheet.

## ADDED Requirements

### Requirement: UI-001 - Chat Creation Button Accessibility

The conversation list MUST provide a clear, accessible way to initiate chat creation.

**Rationale:** Users need an obvious entry point to create new conversations. Following iOS conventions, this is typically a "+" button in the navigation bar.

#### Scenario: User taps create button from conversation list

**Given** the user is viewing the conversation list screen
**And** the screen has finished loading
**When** the user taps the "+" button in the navigation bar
**Then** the create conversation screen opens as a modal sheet
**And** the conversation list remains visible in the background

#### Scenario: Create button is visible and discoverable

**Given** the user is viewing the conversation list screen
**When** the screen loads
**Then** a "+" button is visible in the top-right corner of the navigation bar
**And** the button uses the standard iOS "plus" system icon

---

### Requirement: UI-002 - Modal Sheet Presentation

The chat creation screen MUST be presented as a modal sheet that can be dismissed.

**Rationale:** Modal sheets are the iOS-standard pattern for focused, temporary tasks like creating new items. This follows the pattern used in Messages, Mail, and other system apps.

#### Scenario: Sheet displays create conversation view

**Given** the user has tapped the "+" button
**When** the sheet animation completes
**Then** the CreateConversationView is displayed
**And** the view shows a user list interface
**And** the view has "キャンセル" (Cancel) and "作成" (Create) buttons
**And** the navigation title is "新しいチャット" (New Chat)

#### Scenario: User cancels chat creation

**Given** the create conversation sheet is open
**When** the user taps the "キャンセル" button
**Then** the sheet closes with animation
**And** no conversation is created
**And** the conversation list is shown again
**And** the conversation list remains unchanged

---

### Requirement: UI-003 - User Selection Interface

Users MUST be able to browse and select a contact to chat with from the available users list.

**Rationale:** The chat creation flow requires selecting a target user. The interface must clearly show available users and indicate the current selection.

#### Scenario: User list displays available contacts

**Given** the create conversation sheet is open
**When** the view finishes loading user data
**Then** a list of available users is displayed
**And** each user item shows the user's name
**And** each user item shows the user's ID
**And** the current user is excluded from the list
**And** users are displayed in a scrollable list

#### Scenario: User selects a contact from list

**Given** the user list is displayed
**And** no user is currently selected
**When** the user taps on "Bob" in the list
**Then** a checkmark icon appears next to Bob's name
**And** the "作成" button becomes enabled
**And** other users in the list do not show a checkmark

#### Scenario: User changes selection

**Given** "Bob" is currently selected (checkmark visible)
**When** the user taps on "Charlie" in the list
**Then** the checkmark moves from Bob to Charlie
**And** only Charlie shows a checkmark
**And** the "作成" button remains enabled

---

### Requirement: UI-004 - Chat Creation Execution

The user MUST be able to create a 1:1 chat with the selected user.

**Rationale:** After selecting a user, the system must create the conversation and provide feedback on success or failure.

#### Scenario: User creates chat successfully

**Given** the user has selected "Bob" from the user list
**And** the "作成" button is enabled
**When** the user taps the "作成" button
**Then** a loading indicator is displayed
**And** the system creates a 1:1 conversation with Bob
**And** the sheet closes automatically
**And** the conversation list screen is shown
**And** the conversation list refreshes
**And** the new conversation with Bob appears in the list

#### Scenario: Create button is disabled when no user selected

**Given** the create conversation sheet is open
**And** no user is selected
**When** the user views the navigation bar
**Then** the "作成" button is visible but disabled (grayed out)
**And** tapping the button has no effect

#### Scenario: Error handling for failed chat creation

**Given** the user has selected "Bob"
**And** the backend API is unavailable
**When** the user taps "作成"
**Then** a loading indicator is displayed briefly
**And** an error alert appears with title "エラー"
**And** the alert message indicates chat creation failed
**And** the alert has an "OK" button to dismiss
**And** the sheet remains open
**And** the user can retry or cancel

---

### Requirement: UI-005 - Conversation List Refresh

After successfully creating a conversation, the conversation list MUST update to show the new conversation.

**Rationale:** Users need immediate visual feedback that their action succeeded. The new conversation should appear without requiring manual refresh.

#### Scenario: New conversation appears in list after creation

**Given** the user has successfully created a chat with Bob
**And** the create conversation sheet has closed
**When** the conversation list finishes refreshing
**Then** a conversation with Bob is visible in the list
**And** the conversation appears at the top of the list (most recent)
**And** the conversation shows Bob's name
**And** the conversation type is "direct" (1:1)

#### Scenario: List maintains scroll position for existing conversations

**Given** the user had scrolled down in the conversation list before creating a chat
**And** the user creates a new conversation with Bob
**When** the sheet closes and the list refreshes
**Then** the new conversation appears at the top
**And** the user can scroll to see their previous conversations
**And** the scroll position resets to top (showing the new conversation)

---

### Requirement: UI-006 - Loading and Empty States

The create conversation view MUST handle loading states and cases where no users are available.

**Rationale:** Users need feedback during data loading and clear messaging when no contacts are available for chat creation.

#### Scenario: Loading state while fetching users

**Given** the create conversation sheet has just opened
**And** the user list is being fetched from the API
**When** the fetch is in progress
**Then** a loading indicator is displayed
**And** the loading indicator shows text "読み込み中..." (Loading...)
**And** the user list is not yet visible

#### Scenario: Empty state when no users available

**Given** the create conversation sheet is open
**And** the user list fetch has completed
**And** no other users exist (or all users are already in conversations)
**When** the empty state is displayed
**Then** an icon is shown (person.3 system icon)
**And** a headline reads "ユーザーが見つかりません" (No users found)
**And** a subtitle explains "チャットを開始できるユーザーがいません" (No users available to start a chat with)

#### Scenario: Error state when user fetch fails

**Given** the create conversation sheet is open
**And** the user list fetch failed due to network error
**When** the error occurs
**Then** an error alert is displayed
**And** the alert title is "エラー"
**And** the alert message reads "ユーザー一覧の取得に失敗しました:" followed by error details
**And** the user can dismiss the alert
**And** the sheet remains open for retry or cancellation

---

## Related Specs

- Depends on: `user-list` capability (from `implement-chat-creation-user-list` change)
- Integrates with: Conversation list screen (existing)
- Future: Chat detail view integration (not yet implemented)

## Implementation Notes

- Uses SwiftUI `.sheet(isPresented:)` modifier for modal presentation
- Leverages existing `CreateConversationView` and `CreateConversationViewModel`
- Dependencies injected via `DependencyContainer.shared`
- Callback pattern used for post-creation refresh: `onConversationCreated`
- State management via `@State private var showCreateConversation`

## Testing Strategy

- **Unit Tests:** ViewModel behavior for state management and error handling
- **Integration Tests:** Full create conversation flow with mock repositories
- **Manual Tests:** End-to-end user flow in iOS simulator with real API
- **Error Scenarios:** Network failures, empty states, validation errors
