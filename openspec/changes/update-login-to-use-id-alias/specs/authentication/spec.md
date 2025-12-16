# Spec: Authentication with ID Alias

## MODIFIED Requirements

### Requirement: User Authentication
The system SHALL authenticate users using their unique ID Alias instead of UUID-based user IDs.

#### Scenario: Successful login with valid ID Alias
- **Given** a user with idAlias "alice" exists in the system
- **When** the user enters "alice" in the login field and submits
- **Then** the system calls POST /users/login with {"idAlias": "alice"}
- **And** the system receives the user data with id, idAlias, name, avatarUrl, createdAt
- **And** a local session is created using the returned user.id (UUID)
- **And** the user is navigated to the main application screen

#### Scenario: Login failure with non-existent ID Alias
- **Given** no user with idAlias "unknown_user" exists
- **When** the user enters "unknown_user" and submits
- **Then** the system calls POST /users/login with {"idAlias": "unknown_user"}
- **And** the system receives a 404 Not Found response
- **And** an error message "指定されたユーザーが見つかりません" is displayed
- **And** the user remains on the login screen

#### Scenario: Login with empty ID Alias
- **Given** the user is on the login screen
- **When** the user submits with an empty idAlias field
- **Then** the login button remains disabled
- **Or** if validation occurs on submit, an error "ID Aliasを入力してください" is shown
- **And** no API call is made

---

## ADDED Requirements

### Requirement: ID Alias Format Validation
The system SHALL validate ID Alias format according to backend specifications before making API requests.

#### Scenario: Valid ID Alias formats accepted
- **Given** the user is on the login screen
- **When** the user enters idAlias "alice" (lowercase alphanumeric)
- **Then** the idAlias passes client-side validation
- **When** the user enters idAlias "bob_2024" (with underscore)
- **Then** the idAlias passes client-side validation
- **When** the user enters idAlias "user.name" (with dot)
- **Then** the idAlias passes client-side validation
- **When** the user enters idAlias "user-123" (with hyphen)
- **Then** the idAlias passes client-side validation

#### Scenario: ID Alias with uppercase letters rejected
- **Given** the user is on the login screen
- **When** the user enters idAlias "Alice" (contains uppercase)
- **Then** the system displays error "ID Aliasは小文字の英数字のみ使用できます"
- **And** no API call is made

#### Scenario: ID Alias with spaces rejected
- **Given** the user is on the login screen
- **When** the user enters idAlias "alice bob" (contains space)
- **Then** the system displays error "ID Aliasにスペースは使用できません"
- **And** no API call is made

#### Scenario: ID Alias too short rejected
- **Given** the user is on the login screen
- **When** the user enters idAlias "ab" (2 characters)
- **Then** the system displays error "ID Aliasは3文字以上30文字以下で入力してください"
- **And** no API call is made

#### Scenario: ID Alias too long rejected
- **Given** the user is on the login screen
- **When** the user enters idAlias with 31 characters
- **Then** the system displays error "ID Aliasは3文字以上30文字以下で入力してください"
- **And** no API call is made

#### Scenario: ID Alias starting with symbol rejected
- **Given** the user is on the login screen
- **When** the user enters idAlias "_alice" (starts with underscore)
- **Then** the system displays error "ID Aliasは英数字で始まる必要があります"
- **And** no API call is made

#### Scenario: ID Alias ending with symbol rejected
- **Given** the user is on the login screen
- **When** the user enters idAlias "alice_" (ends with underscore)
- **Then** the system displays error "ID Aliasは英数字で終わる必要があります"
- **And** no API call is made

#### Scenario: ID Alias with invalid symbols rejected
- **Given** the user is on the login screen
- **When** the user enters idAlias "alice@example" (contains @)
- **Then** the system displays error "ID Aliasに使用できない文字が含まれています"
- **And** no API call is made

---

### Requirement: User Entity Enhancement
The User entity SHALL include the idAlias field for all user data operations.

#### Scenario: User entity includes idAlias field
- **Given** a user is successfully authenticated
- **When** the user data is retrieved from the API
- **Then** the User entity contains: id (UUID), idAlias (string), name, avatarUrl, createdAt
- **And** the idAlias is stored in the session along with other user data

#### Scenario: User displayed with idAlias in UI
- **Given** a user is logged in with idAlias "alice"
- **When** the user views their profile or settings
- **Then** the idAlias "alice" may be displayed as a user identifier
- **And** the internal UUID id is not visible to the user

---

### Requirement: Backward Compatibility with UUID Sessions
The system SHALL maintain compatibility with existing sessions that use UUID-based userId.

#### Scenario: Existing UUID session remains valid
- **Given** a user has an existing session saved with userId (UUID)
- **When** the app launches and loads the saved session
- **Then** the session is recognized as valid
- **And** the user is automatically logged in
- **And** no re-authentication is required

#### Scenario: Session stores UUID after idAlias login
- **Given** a user logs in with idAlias "alice"
- **When** the authentication succeeds and returns user data
- **Then** the session stores userId = user.id (UUID, e.g., "user-1")
- **And** the session also stores the full user object including idAlias
- **And** subsequent API calls use the UUID for userId parameters

---

### Requirement: UI/UX Updates for ID Alias
The login screen SHALL be updated to reflect ID Alias terminology and provide appropriate guidance.

#### Scenario: Login screen displays ID Alias terminology
- **Given** the user opens the app and sees the login screen
- **Then** the input field label reads "ユーザー名" or "ID Alias"
- **And** the placeholder text reads "ユーザー名を入力（例: alice, bob_2024）"
- **And** help text explains: "登録済みのユーザー名を入力してください"

#### Scenario: Real-time validation feedback
- **Given** the user is typing in the idAlias field
- **When** the user enters invalid characters (e.g., uppercase, symbols)
- **Then** real-time validation feedback may be provided (optional enhancement)
- **Or** validation occurs only on submit for simpler implementation

---

## REMOVED Requirements

### Requirement: UUID-based User Lookup (DEPRECATED)
The previous requirement to authenticate using `GET /users/{userId}` with UUID-based user IDs is removed in favor of the ID Alias login endpoint.

#### Scenario: Direct UUID lookup for authentication (REMOVED)
- **Given** a user with UUID "user-1"
- **When** attempting to authenticate with userId "user-1"
- **Then** the system NO LONGER calls `GET /users/{userId}` for authentication
- **Instead** users must use idAlias-based login via `POST /users/login`

**Note**: The `GET /users/{userId}` endpoint may still exist for other purposes (e.g., fetching user profiles by ID), but it is not used for authentication flow.

---

## Implementation Notes

1. **API Endpoint Change**:
   - Old: `GET /users/{userId}` → fetches user by UUID
   - New: `POST /users/login` → authenticates user by idAlias

2. **Session Storage**:
   - Session continues to store `userId` (UUID) for internal use
   - User entity now includes both `id` (UUID) and `idAlias` (human-readable)
   - API calls that require userId continue to use the UUID

3. **Validation Strategy**:
   - Client-side validation prevents invalid API requests
   - Server-side validation provides authoritative rejection
   - Error messages should be user-friendly and actionable

4. **Migration Path**:
   - Existing sessions with UUID-based userId remain valid
   - No forced re-login required for users with active sessions
   - New logins must use idAlias

5. **Testing Strategy**:
   - Unit tests cover all validation scenarios
   - Mock repository includes idAlias in test data
   - Integration tests verify end-to-end flow with backend API
