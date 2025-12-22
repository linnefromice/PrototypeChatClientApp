# Design: Align Auth with Backend Updates

**Change ID:** `align-auth-with-backend-updates`

## Overview

This change enhances the iOS authentication layer to fully align with the backend's updated authentication system, specifically adding support for the `/api/protected/profile` endpoint and properly parsing chat user data returned by the backend.

## Current State

### Existing Implementation

**Authentication Flow:**
```
User → Login/Register → BetterAuth API → Cookie-based Session → AuthSession
```

**Current Models:**
```swift
struct AuthSession {
    let authUserId: String
    let username: String
    let email: String
    let user: User  // Chat user (backward compatibility)
    let authenticatedAt: Date
}

struct AuthResponse {
    let user: AuthUser
    let session: Session?
    // Missing: chat field
}
```

**Current Repositories:**
- `DefaultAuthRepository`: Handles `/api/auth/*` endpoints
- No profile repository yet

### Backend API Structure

**Current Endpoints Used:**
- `POST /api/auth/sign-up/email` - Registration
- `POST /api/auth/sign-in/username` - Login
- `GET /api/auth/get-session` - Session validation
- `POST /api/auth/sign-out` - Logout

**New Endpoint Available:**
- `GET /api/protected/profile` - Full profile with auth + chat data

## Proposed Architecture

### Component Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                       │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  AuthenticationViewModel                              │  │
│  │  - login() / register()                               │  │
│  │  - checkAuthentication()                              │  │
│  │  - NEW: fetchProfile() (optional)                     │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      Domain Layer                            │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  AuthenticationUseCase                                │  │
│  │  - login() / register() / validateSession()           │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  NEW: ProfileUseCase                                  │  │
│  │  - fetchProfile() -> AuthSession                      │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  AuthSession (Enhanced)                               │  │
│  │  + authUserId, username, email                        │  │
│  │  + user: User (backward compat)                       │  │
│  │  + NEW: chatUser: User? (explicit chat profile)       │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  DefaultAuthRepository (Existing)                     │  │
│  │  - signUp() / signIn() / getSession()                 │  │
│  │  - UPDATED: Parse chat field from responses           │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  NEW: DefaultProfileRepository                        │  │
│  │  - fetchProfile() -> (AuthUser, User?)                │  │
│  │  - GET /api/protected/profile                         │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   Infrastructure Layer                       │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  NetworkConfiguration (Existing)                      │  │
│  │  - Cookie-based URLSession                            │  │
│  │  - HTTPCookieStorage integration                      │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

**Profile Fetch Flow:**
```
1. User authenticates (login/register)
   ↓
2. AuthSession created with auth_user data
   ↓
3. (Optional) ProfileUseCase.fetchProfile()
   ↓
4. ProfileRepository → GET /api/protected/profile
   ↓
5. Backend returns { auth: {...}, chat: {...} }
   ↓
6. Parse both auth and chat user data
   ↓
7. Update AuthSession with chatUser
   ↓
8. App has complete user profile
```

## Key Design Decisions

### 1. Separation of Auth and Profile Repositories

**Decision:** Create separate `ProfileRepository` instead of adding to `AuthRepository`

**Rationale:**
- **Single Responsibility**: Auth repo handles authentication, profile repo handles profile data
- **Clean API**: `/api/auth/*` vs `/api/protected/*` are different concerns
- **Future Extensibility**: Profile may expand with more endpoints (update profile, preferences, etc.)

**Trade-offs:**
- ✅ Better separation of concerns
- ✅ Easier to test independently
- ❌ Slightly more code (minimal)

### 2. Optional chatUser in AuthSession

**Decision:** Make `chatUser: User?` optional instead of required

**Rationale:**
- Backend may not always return chat user (new users, backend issues)
- Allows authentication to succeed even without chat profile
- Graceful degradation of features

**Implementation:**
```swift
struct AuthSession {
    let authUserId: String
    let username: String
    let email: String
    let user: User              // Backward compatibility (may be placeholder)
    let chatUser: User?         // NEW: Explicit chat profile (nil if not exists)
    let authenticatedAt: Date
}
```

### 3. Response Model Updates

**Decision:** Update `AuthResponse` to parse `chat` field but keep backward compatible

**Current:**
```swift
private struct AuthResponse: Decodable {
    let user: AuthUser
    let session: Session?
}
```

**Proposed:**
```swift
private struct AuthResponse: Decodable {
    let user: AuthUser
    let session: Session?
    let chat: ChatUserResponse?  // NEW: Optional chat user

    struct ChatUserResponse: Decodable {
        let id: String
        let idAlias: String
        let name: String
        let avatarUrl: String?

        enum CodingKeys: String, CodingKey {
            case id
            case idAlias = "id_alias"
            case name
            case avatarUrl = "avatar_url"
        }
    }
}
```

**Rationale:**
- Matches backend response format exactly
- Optional field doesn't break existing flows
- Can parse chat user when available

### 4. Profile Fetch Strategy

**Decision:** Make profile fetching optional, not automatic

**Options Considered:**

A. **Auto-fetch on every login/session validation**
   - ✅ Always have latest data
   - ❌ Extra API call on every auth check
   - ❌ Slows down app launch

B. **Fetch on-demand when needed**
   - ✅ Minimal API calls
   - ✅ Faster app launch
   - ❌ May not have data when needed

C. **Fetch once after login, cache in session** (CHOSEN)
   - ✅ Balance between freshness and performance
   - ✅ Available when needed
   - ✅ Can refresh on-demand
   - ❌ May be stale (acceptable for most use cases)

**Implementation:**
- Call profile fetch after successful login/register
- Store in AuthSession
- Provide refresh method for on-demand updates

## API Integration

### Endpoint Specifications

#### GET /api/protected/profile

**Request:**
```http
GET /api/protected/profile HTTP/1.1
Cookie: better-auth.session_token=<token>
```

**Response (200 OK):**
```json
{
  "auth": {
    "id": "cm5abc123...",
    "username": "alice",
    "name": "Alice",
    "email": "alice@example.com"
  },
  "chat": {
    "id": "uuid-chat-user",
    "id_alias": "user_alias",
    "name": "Alice Chat",
    "avatar_url": "https://example.com/avatar.png"
  }
}
```

**Response (200 OK - No Chat Profile):**
```json
{
  "auth": {
    "id": "cm5abc123...",
    "username": "alice",
    "name": "Alice",
    "email": "alice@example.com"
  },
  "chat": null
}
```

**Response (401 Unauthorized):**
```json
{
  "error": "Unauthorized"
}
```

### Error Handling

**Error Cases:**
1. **401 Unauthorized**: Session expired → Redirect to login
2. **500 Server Error**: Backend issue → Retry with exponential backoff
3. **Network Error**: No connection → Show error, allow retry
4. **Null chat user**: Normal case → Continue without chat profile

## Testing Strategy

### Unit Tests

**ProfileUseCase Tests:**
```swift
func testFetchProfile_WithChatUser_ReturnsCompleteSession()
func testFetchProfile_WithoutChatUser_ReturnsSessionWithNilChatUser()
func testFetchProfile_Unauthorized_ThrowsError()
```

**ProfileRepository Tests:**
```swift
func testFetchProfile_SuccessWithChat_ParsesCorrectly()
func testFetchProfile_SuccessWithoutChat_HandlesNullGracefully()
func testFetchProfile_401_ThrowsAuthError()
```

### Integration Tests

- Test with real backend in development mode
- Verify cookie-based auth works
- Test both scenarios (with/without chat user)

## Migration Plan

This change is **fully backward compatible**:

1. **Existing authentication flow unchanged**
   - Login/register still works as before
   - Session validation unchanged
   - Existing code continues to function

2. **New functionality is additive**
   - Profile fetching is optional
   - `chatUser` field is optional
   - No breaking changes to public APIs

3. **Rollout Strategy**
   - Deploy as feature addition
   - Monitor profile endpoint success rate
   - Gradually adopt in features that need chat user data

## Future Enhancements

1. **Profile Updates**: Add `PUT /api/protected/profile/name` support
2. **Avatar Upload**: Support updating avatar via profile endpoint
3. **Profile Cache**: Add local caching to reduce API calls
4. **Profile Refresh**: Add pull-to-refresh for profile data
5. **Multi-user Sessions**: Support switching between multiple logged-in users

## Alternatives Considered

### Alternative 1: Extend AuthRepository Instead of New Repository

**Rejected because:**
- Violates single responsibility principle
- `/api/auth/*` and `/api/protected/*` are semantically different
- Would make AuthRepository more complex

### Alternative 2: Always Auto-Fetch Profile

**Rejected because:**
- Adds latency to every authentication check
- Wastes bandwidth when chat user not needed
- Complicates error handling (what if profile fails but auth succeeds?)

### Alternative 3: Make chatUser Required (Not Optional)

**Rejected because:**
- Backend may legitimately return null (new users)
- Requires all users to have chat profiles
- Reduces resilience to backend issues

## Security Considerations

1. **Cookie Security**: Already handled by `NetworkConfiguration`
   - HttpOnly cookies prevent XSS
   - Secure flag for HTTPS
   - SameSite protection

2. **Profile Endpoint Authorization**: Backend enforces `requireAuth`
   - Only authenticated users can access
   - Session validation on every request

3. **Data Privacy**: Profile data only fetched when needed
   - No unnecessary data exposure
   - User controls when profile is accessed

## Performance Impact

**Estimated Impact:**
- Profile fetch adds ~200-500ms per call
- Only called once per login (not on every API request)
- Negligible impact on overall app performance

**Optimization Opportunities:**
- Cache profile data locally
- Use background fetch to pre-load
- Batch with other startup API calls
