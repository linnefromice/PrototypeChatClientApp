# Spec Delta: Authentication

**Change ID:** `align-auth-with-backend-updates`
**Capability:** authentication

## MODIFIED Requirements

### Requirement: Authentication Session Management (REQ-AUTH-001)

The authentication session SHALL store both auth user data and optional chat user data. The AuthSession model MUST include a `chatUser: User?` property for explicit chat profile tracking while maintaining the existing `user` property for backward compatibility.

**Change:** Add chat user profile support to authentication session

**Previous Behavior:
- AuthSession only stored auth_user data and a placeholder User entity
- No distinction between auth user and chat user
- Chat user data not explicitly tracked

**New Behavior:**
- AuthSession stores both auth_user data and optional chat_user data
- Explicit `chatUser: User?` property for chat profile
- Backward compatible `user` property maintained

#### Scenario: User with Chat Profile Logs In

**Given** a user with both auth_user and chat_user records exists in the backend
**When** the user successfully logs in
**Then** the AuthSession should contain:
- `authUserId` from auth_user
- `username` and `email` from auth_user
- `chatUser` populated with chat profile data
- `user` maintained for backward compatibility

#### Scenario: User without Chat Profile Logs In

**Given** a user with only auth_user record (no chat_user) exists in the backend
**When** the user successfully logs in
**Then** the AuthSession should contain:
- `authUserId` from auth_user
- `username` and `email` from auth_user
- `chatUser` set to nil
- `user` set to placeholder for backward compatibility

#### Scenario: Profile Data Available in Authentication Response

**Given** the backend returns chat user data in the authentication response
**When** parsing the authentication response
**Then** the chat user should be extracted and stored in the session

### Requirement: Backend API Response Parsing (REQ-AUTH-002)

The authentication response parser SHALL parse the optional `chat` field from backend responses. The parser MUST handle null chat user values gracefully without throwing errors.

**Change:** Parse chat user field from backend authentication responses

**Previous Behavior:**
- AuthResponse only parsed `user` and `session` fields
- Chat user data ignored even if present

**New Behavior:**
- AuthResponse parses optional `chat` field from backend
- Maps chat user data to User entity
- Handles null chat user gracefully

#### Scenario: Backend Returns Chat User in Response

**Given** the backend includes chat user data in authentication response
**When** the response is decoded
**Then** the chat user should be parsed into a User entity
**And** included in the resulting AuthSession

#### Scenario: Backend Returns Null Chat User

**Given** the backend returns null for chat user in authentication response
**When** the response is decoded
**Then** no error should occur
**And** chatUser should be nil in the resulting AuthSession

## ADDED Requirements

### Requirement: User Profile Fetching (REQ-AUTH-005)

The application SHALL support fetching complete user profiles from the `/api/protected/profile` endpoint. The profile fetch MUST include both auth user data and optional chat user data, returning a complete AuthSession.

#### Scenario: Fetch Profile for Authenticated User

**Given** a user is authenticated with a valid session cookie
**When** the profile is fetched via `/api/protected/profile`
**Then** the response should include:
- Auth user data (id, username, email, name)
- Chat user data (id, idAlias, name, avatarUrl) if exists
**And** an AuthSession should be created with both auth and chat user data

#### Scenario: Fetch Profile Returns No Chat User

**Given** a user is authenticated but has no chat profile
**When** the profile is fetched via `/api/protected/profile`
**Then** the response should include:
- Auth user data
- Null chat user
**And** an AuthSession should be created with chatUser set to nil

#### Scenario: Fetch Profile with Expired Session

**Given** a user's session cookie has expired
**When** attempting to fetch profile via `/api/protected/profile`
**Then** a 401 Unauthorized error should be returned
**And** the user should be redirected to login

### Requirement: Profile Repository (REQ-AUTH-006)

The application SHALL provide a ProfileRepository abstraction for user profile operations. The repository MUST support fetching profiles via the `/api/protected/profile` endpoint with cookie-based authentication.

#### Scenario: Profile Repository Fetches from Backend

**Given** a ProfileRepository implementation
**When** fetchProfile() is called
**Then** a GET request should be made to `/api/protected/profile`
**And** cookies should be included for authentication
**And** the response should be parsed into auth and chat user entities

#### Scenario: Profile Repository Handles Network Errors

**Given** a ProfileRepository implementation
**When** fetchProfile() is called and the network request fails
**Then** a NetworkError should be thrown
**And** the error should be propagated to the caller

#### Scenario: Mock Profile Repository for Testing

**Given** a MockProfileRepository implementation
**When** fetchProfile() is called
**Then** mock profile data should be returned
**And** no actual network request should be made
**And** error scenarios can be simulated via configuration

### Requirement: Profile Use Case (REQ-AUTH-007)

The application SHALL provide a ProfileUseCase for managing user profile business logic. The use case MUST orchestrate profile fetching and create updated AuthSession instances with complete user data.

#### Scenario: Fetch Complete Profile After Login

**Given** a user has just logged in successfully
**When** the profile use case fetches the complete profile
**Then** both auth and chat user data should be retrieved
**And** an updated AuthSession should be returned
**And** the session should be ready for use

#### Scenario: Handle Missing Chat Profile

**Given** a user without a chat profile
**When** the profile use case fetches the profile
**Then** the auth user data should be retrieved successfully
**And** the chatUser field should be nil
**And** the app should function normally without chat user data

## Implementation Notes

### Data Models

**AuthSession Updates:**
```swift
struct AuthSession {
    let authUserId: String
    let username: String
    let email: String
    let user: User              // Backward compatibility
    let chatUser: User?         // NEW: Explicit chat profile
    let authenticatedAt: Date

    var userId: String {        // Backward compatibility
        chatUser?.id ?? user.id
    }
}
```

**AuthResponse Updates:**
```swift
struct AuthResponse: Decodable {
    let user: AuthUser
    let session: Session?
    let chat: ChatUserResponse?  // NEW

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

### API Endpoints

**Profile Endpoint:**
- **Method:** GET
- **Path:** `/api/protected/profile`
- **Authentication:** Required (cookie-based)
- **Response:** `{ auth: AuthUser, chat: ChatUser | null }`

### Repository Protocols

**ProfileRepositoryProtocol:**
```swift
protocol ProfileRepositoryProtocol {
    func fetchProfile() async throws -> (authUser: AuthUserData, chatUser: User?)
}
```

### Use Case Methods

**ProfileUseCase:**
```swift
class ProfileUseCase {
    func fetchProfile() async throws -> AuthSession
}
```

## Testing Requirements

### Unit Tests Required

1. **AuthSession Tests:**
   - Initialize with chat user
   - Initialize without chat user
   - Backward compatibility of userId property

2. **ProfileRepository Tests:**
   - Parse response with chat user
   - Parse response without chat user
   - Handle 401 error
   - Handle network errors

3. **ProfileUseCase Tests:**
   - Fetch complete profile
   - Handle missing chat user
   - Error propagation

### Integration Tests Required

1. Test with real backend `/api/protected/profile` endpoint
2. Verify cookie-based authentication works
3. Test both scenarios (with/without chat user)

## Backward Compatibility

**Guaranteed Compatibility:**
- Existing `user` property in AuthSession maintained
- Computed `userId` property behavior unchanged
- All existing authentication flows continue to work
- Profile fetching is optional and additive

**Migration Notes:**
- No migration needed for existing code
- New `chatUser` field is opt-in
- Existing session validation unaffected
