# Spec: User List for Chat Creation

**Capability:** `user-list`
**Related Change:** `implement-chat-creation-user-list`

## ADDED Requirements

### Requirement: User List UseCase SHALL fetch available users excluding current user

The `UserListUseCase.fetchAvailableUsers()` method SHALL retrieve all users from the system via `UserRepository` and MUST exclude the current user from the returned list.

**ID:** `user-list-001`
**Priority:** High
**Type:** Functional

#### Scenario: Successfully fetch available users

**Given:**
- Backend API returns a list of 3 users: `user-1`, `user-2`, `user-3`
- Current user is `user-1`

**When:**
- `fetchAvailableUsers(excludingUserId: "user-1")` is called

**Then:**
- The method returns a list containing only `user-2` and `user-3`
- `user-1` is not included in the result
- The method completes successfully without throwing errors

#### Scenario: Fetch users when current user not in list

**Given:**
- Backend API returns a list of 2 users: `user-2`, `user-3`
- Current user is `user-1` (not in the returned list)

**When:**
- `fetchAvailableUsers(excludingUserId: "user-1")` is called

**Then:**
- The method returns all users: `user-2` and `user-3`
- No filtering is needed since current user is not present
- The method completes successfully

#### Scenario: Handle empty user list

**Given:**
- Backend API returns an empty list
- Current user is `user-1`

**When:**
- `fetchAvailableUsers(excludingUserId: "user-1")` is called

**Then:**
- The method returns an empty array
- No errors are thrown
- UI displays "ユーザーが見つかりません" message

#### Scenario: Propagate repository errors

**Given:**
- Backend API is unavailable or returns error
- UserRepository throws `NetworkError.serverError`

**When:**
- `fetchAvailableUsers(excludingUserId: "user-1")` is called

**Then:**
- The error is propagated to the caller (ViewModel)
- ViewModel displays error message to user
- App remains in a recoverable state

---

### Requirement: Chat creation view SHALL display selectable user list

The `CreateConversationView` SHALL display the list of available users fetched by `UserListUseCase` and MUST allow the user to select one user for 1:1 chat creation.

**ID:** `user-list-002`
**Priority:** High
**Type:** Functional

#### Scenario: Display available users in list

**Given:**
- `UserListUseCase` returns 2 users: Alice (user-2) and Bob (user-3)
- User opens the chat creation screen

**When:**
- The view loads

**Then:**
- The list displays Alice and Bob with their names and IDs
- Each user is selectable
- Current user (e.g., user-1) is not in the list

#### Scenario: Enable create button only when user selected

**Given:**
- User list is displayed with 2 users
- No user is selected initially

**When:**
- User has not selected any user

**Then:**
- The "作成" (Create) button is disabled

**When:**
- User taps on Alice to select

**Then:**
- Alice is highlighted with a checkmark
- The "作成" button becomes enabled

#### Scenario: Successfully create direct conversation

**Given:**
- User has selected Bob (user-3)
- Current user is user-1

**When:**
- User taps the "作成" button

**Then:**
- `ConversationUseCase.createDirectConversation()` is called with currentUserId: "user-1", targetUserId: "user-3"
- A new 1:1 conversation is created
- User is navigated back to conversation list
- The new conversation appears in the list

#### Scenario: Handle user list loading error

**Given:**
- Backend API returns error when fetching users

**When:**
- The view attempts to load users

**Then:**
- An error alert is displayed with message "ユーザー一覧の取得に失敗しました"
- User can dismiss the alert
- User can retry by closing and reopening the screen

---

### Requirement: User List UseCase MUST support dependency injection for testing

The `UserListUseCase` MUST accept `UserRepositoryProtocol` via constructor injection to enable unit testing with mock repositories.

**ID:** `user-list-003`
**Priority:** Medium
**Type:** Non-Functional

#### Scenario: Inject mock repository for testing

**Given:**
- Test case needs to verify `fetchAvailableUsers()` behavior
- A `MockUserRepository` is created with predefined test data

**When:**
- `UserListUseCase` is initialized with the mock repository
- `fetchAvailableUsers()` is called in the test

**Then:**
- The UseCase uses the mock repository instead of real API
- Test can verify filtering logic without network calls
- Test is fast and repeatable

---

## MODIFIED Requirements

None. This change only implements existing TODOs without modifying existing requirements.

---

## REMOVED Requirements

None. This is an additive change that completes existing functionality.
