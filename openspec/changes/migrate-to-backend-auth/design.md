# Design: Migrate to Backend Auth

**Change ID:** `migrate-to-backend-auth`

## Overview

This document outlines the architectural decisions and design trade-offs for migrating from the simplified `idAlias`-based authentication to the backend's production-ready BetterAuth implementation.

## Architecture Decisions

### 1. Cookie-Based Session Management

**Decision**: Use native `URLSession` cookie storage instead of manual session persistence.

**Rationale**:
- BetterAuth uses HttpOnly cookies for security (prevents XSS attacks)
- URLSession automatically handles cookie storage, expiration, and transmission
- Industry-standard approach for web-based authentication
- Simplifies client-side code (no manual token management)

**Implementation**:
```swift
// Configure URLSession to use shared cookie storage
let configuration = URLSessionConfiguration.default
configuration.httpCookieAcceptPolicy = .always
configuration.httpCookieStorage = HTTPCookieStorage.shared
configuration.httpShouldSetCookies = true
```

**Trade-offs**:
- ✅ Secure: HttpOnly cookies prevent JavaScript access
- ✅ Automatic: URLSession handles persistence and expiration
- ✅ Standard: Well-documented iOS API
- ❌ Debugging: Harder to inspect cookies compared to stored tokens
- ❌ Testing: Requires cookie mocking in unit tests

**Alternatives Considered**:
- Manual token storage in Keychain: More complex, redundant with cookie storage
- JWT tokens in UserDefaults: Less secure, requires manual expiration handling

### 2. Dual Model Architecture (auth_user + chat_user)

**Decision**: Store both backend `auth_user` and `chat_user` data in `AuthSession`.

**Rationale**:
- Backend separates authentication (`auth_user`) from chat profile (`users`)
- iOS app needs both for different purposes:
  - `auth_user`: Username, email, authentication metadata
  - `chat_user`: Display name, profile info, conversation participation
- Maintains backward compatibility with existing `User` entity

**Implementation**:
```swift
struct AuthSession {
    let authUserId: String       // From auth_user table
    let username: String          // From auth_user table
    let email: String             // From auth_user table
    let user: User                // From users table (chat profile)
    let authenticatedAt: Date
}
```

**Trade-offs**:
- ✅ Clear separation: Authentication vs. chat profile concerns
- ✅ Compatible: Works with existing chat features
- ✅ Extensible: Easy to add OAuth fields later
- ❌ Redundancy: Some data duplication (e.g., user ID)
- ❌ Complexity: Two data sources to sync

**Alternatives Considered**:
- Single unified model: Simpler but mixes concerns
- Separate sessions: More complex state management

### 3. Session Validation on App Launch

**Decision**: Call `GET /api/auth/get-session` on every app launch to validate session.

**Rationale**:
- Ensures session hasn't expired (7-day TTL)
- Detects server-side session invalidation
- Provides fresh user data on app start
- Handles edge cases (logout on other device, account deletion)

**Implementation**:
```swift
// In RootView.onAppear
Task {
    if let session = try? await authUseCase.validateSession() {
        self.session = session
        self.showLogin = false
    } else {
        self.showLogin = true
    }
}
```

**Trade-offs**:
- ✅ Accurate: Always reflects server state
- ✅ Secure: Prevents stale session usage
- ✅ Simple: One source of truth (server)
- ❌ Network: Requires API call on every launch
- ❌ Latency: Slight delay before showing UI

**Alternatives Considered**:
- Trust local cookie expiration: Faster but misses server-side invalidation
- Background refresh: More complex, still needs initial validation

### 4. Input Validation Strategy

**Decision**: Client-side validation for UX + server-side validation for security.

**Client-Side Rules**:
- Username: 3-20 characters, alphanumeric + underscore/hyphen
- Password: Minimum 8 characters
- Email: Valid email format (basic regex)
- Name: 1-50 characters, any Unicode

**Server-Side Rules** (enforced by BetterAuth):
- Username uniqueness
- Email uniqueness and format
- Password strength requirements
- Rate limiting

**Rationale**:
- Client validation provides immediate feedback (better UX)
- Server validation ensures security (prevents bypass)
- Defense in depth approach

**Trade-offs**:
- ✅ Fast feedback: No network round-trip for obvious errors
- ✅ Secure: Server is final authority
- ❌ Duplication: Validation logic in two places
- ❌ Drift risk: Client/server rules can get out of sync

**Mitigation**:
- Document validation rules in spec
- Test both client and server validation
- Consider future validation rule API from backend

### 5. Migration Path for Existing Users

**Decision**: Force re-login with informative message for users with old sessions.

**Detection**:
```swift
// Check for old session format in UserDefaults
if let oldSession = UserDefaults.standard.string(forKey: "auth_session"),
   !oldSession.contains("auth_user") {
    // Old idAlias-based session detected
    showMigrationAlert = true
    clearOldSession()
}
```

**Message**:
```
"認証方式が更新されました"
"セキュリティ向上のため、ユーザー名とパスワードでの再ログインが必要です。"
```

**Rationale**:
- Clean break from old system
- Ensures all users on new authentication
- Avoids complex migration logic
- Users only affected once

**Trade-offs**:
- ✅ Simple: No complex data migration
- ✅ Secure: Everyone on new system
- ❌ UX friction: Users must re-login
- ❌ Support burden: May generate support requests

**Alternatives Considered**:
- Automatic migration: Complex, error-prone, security risk
- Parallel support: Maintenance burden, confusing

## Security Considerations

### 1. HTTPS Requirement

**Requirement**: All API calls must use HTTPS in production.

**Rationale**:
- Cookies with Secure flag only sent over HTTPS
- Prevents man-in-the-middle attacks
- Protects username/password during transmission

**Implementation**:
```swift
#if DEBUG
let baseURL = "http://localhost:3000"  // Development only
#else
let baseURL = "https://prototype-hono-drizzle-backend.linnefromice.workers.dev"
#endif
```

### 2. Password Handling

**Rules**:
- Never log passwords
- Clear password from memory after use
- Use SecureField in UI (masked input)
- Let BetterAuth handle hashing (bcrypt)

**Implementation**:
```swift
// ViewModel
@Published var password: String = "" {
    willSet {
        // Clear old value from memory
        password = ""
    }
}

func login() async {
    let passwordCopy = password
    password = "" // Clear UI immediately

    do {
        try await authUseCase.login(username: username, password: passwordCopy)
    } catch {
        // Handle error
    }
}
```

### 3. Session Expiration Handling

**Strategy**: Graceful degradation with re-authentication prompt.

**Implementation**:
- Global 401 handler in API client
- Clear local session state
- Show login screen with message: "セッションが期限切れです。再度ログインしてください。"
- Preserve navigation state if possible

## Error Handling

### Network Errors

**Strategy**: User-friendly messages with retry options.

```swift
switch error {
case URLError.notConnectedToInternet:
    "インターネット接続を確認してください"
case URLError.timedOut:
    "接続がタイムアウトしました。もう一度お試しください。"
default:
    "ネットワークエラーが発生しました"
}
```

### Backend Errors

**Strategy**: Parse backend error messages and display appropriately.

```swift
// Backend returns: { "error": "Username already exists" }
struct BackendError: Decodable {
    let error: String
}

// Map to Japanese
let errorMessages: [String: String] = [
    "Username already exists": "このユーザー名は既に使用されています",
    "Invalid credentials": "ユーザー名またはパスワードが正しくありません",
    "Session expired": "セッションが期限切れです"
]
```

### Validation Errors

**Strategy**: Inline validation with immediate feedback.

```swift
var usernameError: String? {
    guard !username.isEmpty else { return nil }
    if username.count < 3 { return "3文字以上入力してください" }
    if username.count > 20 { return "20文字以内で入力してください" }
    if !username.matches("^[a-zA-Z0-9_-]+$") { return "英数字、_、-のみ使用できます" }
    return nil
}
```

## Testing Strategy

### Unit Tests

**Focus**: Business logic in UseCases and ViewModels

**Approach**:
- Mock `AuthRepository` for UseCase tests
- Mock `AuthenticationUseCase` for ViewModel tests
- Test all validation rules
- Test error handling paths

**Example**:
```swift
func testLogin_ValidCredentials_Success() async throws {
    // Given
    mockRepository.mockSession = AuthSession(...)

    // When
    let session = try await sut.login(username: "alice", password: "password123")

    // Then
    XCTAssertEqual(session.username, "alice")
    XCTAssertEqual(mockRepository.loginCallCount, 1)
}
```

### Integration Tests

**Focus**: Full flow from UI to UseCase (with mocked repository)

**Scenarios**:
- Registration → auto-login → show main screen
- Login → session validation → show main screen
- Invalid credentials → show error → retry → success
- Session expiration → re-login → resume activity

### Manual Tests

**Focus**: Real backend interaction, UI/UX, edge cases

**Checklist**:
- [ ] Register new account
- [ ] Login with valid credentials
- [ ] Login with invalid credentials
- [ ] Session persists after app restart
- [ ] Session expires after 7 days
- [ ] Network error handling
- [ ] Old session migration
- [ ] Cookie visibility in Charles Proxy

## Performance Considerations

### Parallel Reaction Loading Impact

**Current**: Messages load reactions in parallel (TaskGroup)

**Consideration**: Ensure authentication doesn't block message loading.

**Implementation**:
```swift
// Session validation shouldn't block UI
Task {
    await validateSession()
}

// Messages can load independently once authenticated
Task {
    await loadMessages()
}
```

### Cookie Storage Overhead

**Analysis**: HTTPCookieStorage is efficient, minimal overhead

**Monitoring**: Log cookie read/write times in DEBUG builds

```swift
#if DEBUG
let start = Date()
let cookies = HTTPCookieStorage.shared.cookies(for: url)
print("Cookie read time: \(Date().timeIntervalSince(start))s")
#endif
```

## Future Enhancements (Out of Scope)

### OAuth Login
- Add Google/Apple Sign In
- Requires BetterAuth OAuth plugin configuration
- New UI: "Sign in with Google" buttons

### Two-Factor Authentication
- SMS or TOTP codes
- Requires BetterAuth 2FA plugin
- New UI: Code input screen

### Biometric Authentication
- Face ID / Touch ID for quick re-authentication
- Store credentials in Keychain securely
- Requires user opt-in

### Password Reset
- Email-based reset flow
- Requires backend email configuration
- New UI: Forgot password flow

## Open Questions

1. **Q**: Should we support "Remember Me" checkbox?
   **A**: Not needed - cookies persist by default for 7 days

2. **Q**: What if user changes username on web, then opens app?
   **A**: Session validation will fetch updated username automatically

3. **Q**: Should we cache user profile separately from auth session?
   **A**: Future optimization - start with simple approach, cache later if needed

4. **Q**: How to handle multiple devices with same account?
   **A**: BetterAuth supports multiple sessions - each device has its own cookie

## References

- BetterAuth Documentation: https://www.better-auth.com/docs
- Apple URLSession Guide: https://developer.apple.com/documentation/foundation/urlsession
- Backend Implementation: `Temp/AUTHENTICATION.md`, `Temp/AUTHENTICATION_STATUS.md`
- iOS Keychain Guide: https://developer.apple.com/documentation/security/keychain_services
