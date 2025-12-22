# Spec: Username/Password Authentication

## ADDED Requirements

### Requirement: User Registration with Username and Password
The system SHALL allow new users to register accounts using username, email, password, and display name via the BetterAuth registration endpoint.

#### Scenario: New user registration success
- **Given** User has never used the app before
- **When** User opens app for first time
- **Then** Login screen shown with "登録" (Register) link
- **When** User taps "登録"
- **Then** Registration screen shown with fields: username, email, password, name
- **When** User enters valid data:
  - Username: "alice" (3-20 chars, alphanumeric/underscore/hyphen)
  - Email: "alice@example.com" (valid email format)
  - Password: "mypassword123" (minimum 8 chars)
  - Name: "Alice Smith" (1-50 chars)
- **And** User taps "登録" button
- **Then** System calls POST /api/auth/sign-up/email
- **And** Response 200 received with user data
- **And** Cookie stored automatically in HTTPCookieStorage
- **And** AuthSession created with auth_user and chat_user data
- **And** Main screen shown
- **And** User sees conversation list

#### Scenario: Duplicate username registration
- **Given** User "alice" already exists in the system
- **When** New user tries to register with username "alice"
- **Then** API call to POST /api/auth/sign-up/email returns 400
- **And** Error message shown: "このユーザー名は既に使用されています"
- **And** Other fields preserved
- **And** User can change username and retry

### Requirement: User Login with Username and Password
The system SHALL authenticate users using username and password via the BetterAuth login endpoint.

#### Scenario: Successful login with valid credentials
- **Given** User has registered with username "alice" and password "mypassword123"
- **When** User opens app and sees login screen
- **When** User enters username "alice" and password "mypassword123"
- **And** User taps "ログイン" button
- **Then** System calls POST /api/auth/sign-in/username
- **And** Response 200 received
- **And** Session cookie stored in HTTPCookieStorage
- **And** Cookie has HttpOnly, Secure, SameSite=Lax flags
- **And** Cookie has 7-day expiration (604800 seconds)
- **And** AuthSession created with user data
- **And** Main screen shown
- **And** User can access conversations and messages

#### Scenario: Login with invalid credentials
- **Given** User is on login screen
- **When** User enters username "alice" and password "wrongpassword"
- **And** User taps "ログイン"
- **Then** System calls POST /api/auth/sign-in/username
- **And** Response 401 received
- **And** Error message shown: "ユーザー名またはパスワードが正しくありません"
- **And** Password field cleared
- **And** User can retry

#### Scenario: Login with network error
- **Given** User is on login screen
- **And** Device has no internet connection
- **When** User enters credentials and taps "ログイン"
- **Then** URLError.notConnectedToInternet thrown
- **And** Error message shown: "インターネット接続を確認してください"
- **And** User can retry when connection restored

### Requirement: Cookie-Based Session Persistence
The system SHALL persist user sessions across app restarts using HTTP cookies managed by URLSession.

#### Scenario: Session persists across app restarts
- **Given** User has logged in successfully
- **When** User closes app completely (terminate process)
- **And** User reopens app after termination
- **Then** Loading screen shown with "読み込み中..."
- **And** System calls GET /api/auth/get-session
- **And** Cookie sent automatically with request
- **And** Response 200 received
- **And** AuthSession recreated from response
- **And** Main screen shown without login prompt
- **And** User can immediately access conversations

### Requirement: Session Validation on App Launch
The system SHALL validate session on every app launch to ensure it hasn't expired or been invalidated.

#### Scenario: Valid session on app launch
- **Given** User has valid active session cookie
- **When** User launches app
- **Then** Loading screen displayed
- **And** GET /api/auth/get-session API call made with cookie
- **And** Response 200 received
- **And** User data parsed and AuthSession created
- **And** Main screen displayed
- **And** User can start using app immediately

#### Scenario: Expired session on app launch
- **Given** User's session cookie has expired (7 days passed)
- **When** User launches app
- **Then** Loading screen displayed
- **And** GET /api/auth/get-session API call made
- **And** Response 401 received
- **And** Local session state cleared
- **And** Login screen displayed
- **And** User must re-authenticate

### Requirement: Session Expiration During Active Use
The system SHALL handle session expiration that occurs while user is actively using the app.

#### Scenario: Session expires during message sending
- **Given** User is logged in and using the app
- **And** Session cookie has expired (7 days passed)
- **When** User types a message and taps send
- **Then** API call to POST /conversations/{id}/messages returns 401
- **And** Local session state cleared
- **And** Alert displayed: "セッションが期限切れです。再度ログインしてください。"
- **And** Login screen displayed
- **And** Message text preserved in text field
- **And** After successful re-login, user returns to chat
- **And** Message text still available for sending

### Requirement: User Logout
The system SHALL allow users to log out, clearing session locally and preventing further authenticated requests.

#### Scenario: User logs out from profile screen
- **Given** User is logged in and viewing profile
- **When** User taps "ログアウト" (Logout) button
- **Then** All cookies cleared from HTTPCookieStorage
- **And** Local session data cleared
- **And** User redirected to login screen
- **And** User cannot access authenticated features
- **And** User must log in again to use app

### Requirement: Input Validation with User Feedback
The system SHALL validate user inputs and provide real-time feedback for registration and login forms.

#### Scenario: Registration form validation
- **Given** User is on registration screen
- **When** User enters username "ab" (too short) and moves to next field
- **Then** Error message "3文字以上で入力してください" displayed below username field
- **When** User enters valid username "alice123"
- **Then** Error message disappears
- **When** User enters password "pass" (too short) and moves to next field
- **Then** Error message "8文字以上で入力してください" displayed below password field
- **When** User enters valid password "mypassword123"
- **Then** Error message disappears
- **When** All fields contain valid data
- **Then** "登録" button is enabled and user can submit

**Validation Rules**:
- Username: 3-20 chars, alphanumeric + underscore/hyphen
- Email: Valid email format (contains @ and domain)
- Password: Minimum 8 chars
- Display name: 1-50 chars

### Requirement: Loading States for Authentication Operations
The system SHALL display appropriate loading states during all authentication operations.

#### Scenario: Loading state during login
- **Given** User is on login screen with valid credentials entered
- **When** User taps "ログイン" button
- **Then** Button changes to "ログイン中..." with spinner
- **And** Button is disabled (gray, unclickable)
- **And** API request is made to backend
- **And** User cannot double-submit
- **When** Response is received (success or error)
- **Then** Loading state is cleared
- **And** Button returns to normal state

**Loading States**:
- Login button: "ログイン" → "ログイン中..." (with spinner, disabled)
- Registration button: "登録" → "登録中..." (with spinner, disabled)
- App launch: Full-screen spinner with "読み込み中..." (min 300ms, max 5s)

### Requirement: Old Session Migration
The system SHALL detect and migrate users with old idAlias-based sessions to the new authentication system.

#### Scenario: Old session migration on app update
- **Given** User has app installed with old `idAlias`-based session in UserDefaults
- **When** User opens updated app version
- **Then** Old session detected in UserDefaults
- **And** Old session data cleared immediately
- **And** Alert displayed:
  - Title: "認証方式が更新されました"
  - Message: "セキュリティ向上のため、ユーザー名とパスワードでの再ログインが必要です。"
  - Button: "OK"
- **And** After tapping "OK", login screen displayed
- **And** User can log in with username/password credentials

---

## MODIFIED Requirements

### Requirement: AuthSession Model
The AuthSession model SHALL be updated to store both auth_user (authentication) and chat_user (profile) data.

**Before**:
```swift
struct AuthSession {
    let user: User                // Only chat profile data
    let authenticatedAt: Date
}
```

**After**:
```swift
struct AuthSession {
    let authUserId: String        // From auth_user table
    let username: String          // From auth_user table
    let email: String             // From auth_user table
    let user: User                // From users table (chat profile)
    let authenticatedAt: Date
}
```

#### Scenario: AuthSession stores dual user data
- **Given** User logs in with username "alice" and password "mypassword123"
- **When** Backend returns authentication response
- **Then** AuthSession is created with:
  - authUserId: "auth-user-123" (from auth_user table)
  - username: "alice" (from auth_user table)
  - email: "alice@example.com" (from auth_user table)
  - user: User object (from users table via auth_user.chat_user_id)
  - authenticatedAt: Current timestamp
- **And** Both auth and chat data are available to the app

---

## REMOVED Requirements

### Requirement: ID Alias Authentication (DEPRECATED)
The previous requirement to authenticate using POST /users/login with idAlias is removed in favor of BetterAuth username/password authentication.

**Removed Authentication Flow**:
- Old endpoint: POST /users/login with {"idAlias": "alice"}
- Old session storage: Manual UserDefaults storage
- Old session type: Simple user ID only

**New Authentication Flow**:
- New endpoint: POST /api/auth/sign-in/username with {"username": "alice", "password": "..."}
- New session storage: HTTPCookieStorage managed by URLSession
- New session type: Dual auth_user + chat_user data

---

## Non-Functional Requirements

### NFR: Security
- Passwords MUST never be logged to console or crash reports
- All production API calls MUST use HTTPS protocol
- Cookies MUST have HttpOnly and Secure flags in production
- Password input fields MUST use SecureField (masked input)
- Password MUST be cleared from memory immediately after use

### NFR: Performance
- Session validation MUST complete within 2 seconds on typical network
- Login/registration MUST complete within 3 seconds
- Cookie read/write operations MUST NOT block UI thread
- Loading indicators MUST appear within 100ms of user action

### NFR: Accessibility
- All input fields MUST have proper labels for VoiceOver
- Error messages MUST be announced by VoiceOver
- Loading states MUST be announced to screen readers
- Minimum touch target size MUST be 44x44 points

### NFR: Compatibility
- iOS 16.0+ support MUST be maintained
- UI MUST work on all iPhone screen sizes (SE to Pro Max)
- Dark mode MUST be supported for all authentication screens
- UI MUST adapt to Dynamic Type size settings

---

## Implementation Notes

**URLSession Configuration**:
```swift
let configuration = URLSessionConfiguration.default
configuration.httpCookieAcceptPolicy = .always
configuration.httpCookieStorage = HTTPCookieStorage.shared
configuration.httpShouldSetCookies = true
```

**Global 401 Handler**:
```swift
func handleResponse(_ response: HTTPURLResponse) async throws {
    if response.statusCode == 401 {
        await clearSession()
        await showReauthenticationRequired()
        throw AuthenticationError.sessionExpired
    }
}
```

**Old Session Detection**:
```swift
let oldSessionKey = "auth_session"
if let oldSessionData = UserDefaults.standard.data(forKey: oldSessionKey) {
    UserDefaults.standard.removeObject(forKey: oldSessionKey)
    showMigrationAlert = true
}
```

**Backend API Endpoints**:
- `POST /api/auth/sign-up/email` - User registration
- `POST /api/auth/sign-in/username` - User login
- `GET /api/auth/get-session` - Session validation
- `POST /api/auth/sign-out` - User logout (future)

**Dependencies**:
- Backend BetterAuth API must be deployed and accessible
- Backend must have user registration enabled
- Backend CORS must allow credentials from iOS app
- HTTPS required for secure cookie transmission (production)
