# Tasks: Migrate to Backend Auth

**Change ID:** `migrate-to-backend-auth`

## Implementation Order

### 1. Update Domain Models (1-2 hours) ✅ COMPLETED

- [x] Update `AuthSession.swift` to include backend auth_user fields
  - Add `authUserId: String` property
  - Add `username: String` property
  - Add `email: String` property
  - Keep existing `User` for backward compatibility
  - Added computed `userId` property for backward compatibility
- [x] Create `RegistrationRequest.swift` model in Domain/Entities
  - Fields: username, email, password, name
- [x] Create `LoginRequest.swift` model in Domain/Entities
  - Fields: username, password

### 2. Configure URLSession Cookie Storage (1 hour) ✅ COMPLETED

- [x] Create `NetworkConfiguration.swift` in Infrastructure/Network (new file)
- [x] Configure `URLSession.shared` to use `HTTPCookieStorage.shared`
- [x] Enable cookie acceptance for BetterAuth domain
- [x] Add cookie debugging utilities for development
  - Added `printCookies(for:)` debug helper
  - Added `clearAllCookies()` debug helper

### 3. Update Authentication UseCase (2-3 hours) ✅ COMPLETED

- [x] Add `register()` method to `AuthenticationUseCase`
  - Call `POST /api/auth/sign-up/email`
  - Parse response and create `AuthSession`
  - Validate input fields (username, email, password, name)
- [x] Update `login()` method
  - Replace `/users/login` with `/api/auth/sign-in/username`
  - Accept `username` and `password` parameters
  - Store cookies automatically via URLSession
  - Keep legacy `authenticate(idAlias:)` for backward compatibility
- [x] Add `validateSession()` method
  - Call `GET /api/auth/get-session`
  - Return existing session or nil
  - Handle 401 errors
- [x] Add input validation helpers
  - `validateUsername()`: 3-20 chars, alphanumeric + underscore/hyphen
  - `validateEmail()`: basic email format validation
  - `validatePassword()`: minimum 8 characters
  - `validateName()`: 1-50 characters

### 4. Update Authentication Repository (1-2 hours) ✅ COMPLETED

- [x] Create `AuthRepository` protocol in Domain/Repositories
  - `signUp(username:email:password:name:) async throws -> AuthSession`
  - `signIn(username:password:) async throws -> AuthSession`
  - `getSession() async throws -> AuthSession?`
  - `signOut() async throws`
- [x] Create `DefaultAuthRepository` in Data/Repositories
  - Implement backend API calls using URLSession with NetworkConfiguration
  - Handle JSON encoding/decoding
  - Map backend responses to domain models via `AuthResponse.toAuthSession()`
  - Error handling for 400/401/500 status codes
  - Parse error messages for duplicate username/email
- [x] Update `MockAuthRepository` for testing
  - Created with predefined mock users (alice, bob, charlie)
  - Return mock AuthSession with auth_user data
  - Support for shouldFail and delay testing
  - Test helpers: reset(), setSession()
- [x] Update `DependencyContainer` to inject authRepository
  - Added authRepository property
  - Updated AuthenticationUseCase initialization
  - Updated factory methods (makeTestContainer, makePreviewContainer)

### 5. Create Registration UI (2-3 hours)

- [ ] Create `RegistrationView.swift` in Presentation/Views
  - Username field (TextField)
  - Email field (TextField with .emailAddress keyboard)
  - Password field (SecureField)
  - Name field (TextField)
  - Register button
  - Link to switch back to login
- [ ] Add validation UI feedback
  - Show inline errors for invalid inputs
  - Disable button until all fields valid
  - Show loading state during registration
- [ ] Add to navigation from `AuthenticationView`

### 6. Update Login UI (1-2 hours)

- [ ] Update `AuthenticationView.swift`
  - Replace `idAlias` field with `username` field
  - Add `password` field (SecureField)
  - Update labels and placeholders
  - Add "Register" navigation link
- [ ] Update layout for two-field design
- [ ] Add "Forgot Password?" placeholder (disabled for now)

### 7. Update AuthenticationViewModel (2-3 hours)

- [ ] Replace `@Published var idAlias` with `@Published var username`
- [ ] Add `@Published var password`
- [ ] Add `@Published var isRegistering: Bool`
- [ ] Update `login()` method to use new UseCase
- [ ] Add `register()` method
  - Validate inputs
  - Call AuthenticationUseCase.register()
  - Handle success/error states
- [ ] Add `validateSession()` method for app launch
- [ ] Add input validation helpers
  - Username: 3-20 chars, alphanumeric + underscore
  - Password: min 8 chars
  - Email: valid email format

### 8. Update Session Management (1-2 hours)

- [ ] Update `AuthSessionManager.swift`
  - Remove `saveSession()` manual storage
  - Keep `clearSession()` for logout
  - Add `migrateOldSession()` to detect legacy sessions
- [ ] Update `RootView.swift`
  - Call `validateSession()` on appear
  - Show loading state during validation
  - Redirect to login if session invalid
- [ ] Handle session expiration (7 days)
  - Show re-login prompt when session expires

### 9. Handle Migration from Old Sessions (1 hour)

- [ ] Detect old `idAlias`-based sessions in UserDefaults
- [ ] Clear old session data
- [ ] Show migration alert: "認証方式が更新されました。再度ログインしてください。"
- [ ] Redirect to new login screen

### 10. Update API Client (if exists) (1-2 hours)

- [ ] Ensure all API requests include cookies
- [ ] Handle 401 responses globally
  - Clear session
  - Redirect to login
- [ ] Add request/response logging for debugging

### 11. Update Tests (3-4 hours)

- [ ] Update `AuthenticationUseCaseTests.swift`
  - Test new login with username/password
  - Test registration flow
  - Test session validation
  - Test input validation
- [ ] Update `AuthenticationViewModelTests.swift`
  - Test username/password binding
  - Test registration state management
  - Mock new repository methods
- [ ] Add `AuthRepositoryTests.swift`
  - Test API request formatting
  - Test response parsing
  - Test cookie handling
- [ ] Update integration tests
  - Test full registration → login → session flow

### 12. Manual Testing (2-3 hours)

- [ ] Test registration flow
  - Valid inputs → successful registration
  - Invalid inputs → error messages
  - Duplicate username → backend error handling
- [ ] Test login flow
  - Valid credentials → successful login
  - Invalid credentials → error message
  - Cookie persistence across app restarts
- [ ] Test session validation
  - Valid session → auto-login
  - Expired session → redirect to login
  - No session → show login
- [ ] Test old session migration
  - Install old version, create session
  - Update to new version
  - Verify migration prompt appears
- [ ] Test error scenarios
  - Network errors
  - Backend errors (500, 401, etc.)
  - Invalid responses

### 13. Documentation Updates (1 hour)

- [ ] Update `CLAUDE.md` authentication section
  - Remove `idAlias` references
  - Document new username/password flow
  - Document cookie-based sessions
- [ ] Update `Specs/Plans/AUTH_DESIGN_20251211_JA.md`
  - Mark old design as deprecated
  - Reference this OpenSpec change
- [ ] Add migration guide for developers
  - How to clear old sessions
  - How to test cookie behavior

## Progress Summary

### ✅ Completed (Estimated: 6-8 hours, Actual: ~5 hours)
- Domain Models (AuthSession, Request models)
- URLSession Cookie Configuration
- Authentication UseCase (register, login, validateSession)
- Authentication Repository (protocol, DefaultAuthRepository, MockAuthRepository)
- DependencyContainer updates
- Build verification and compilation error fixes

### 🔄 In Progress (Current Phase)
- None currently active

### ⏳ Remaining (Estimated: 14-20 hours)
- Registration UI (2-3 hours)
- Login UI updates (1-2 hours)
- AuthenticationViewModel updates (2-3 hours)
- Session Management updates (1-2 hours)
- Old session migration (1 hour)
- API Client updates (1-2 hours)
- Test updates (3-4 hours)
- Manual testing (2-3 hours)
- Documentation (1 hour)

## Estimated Total Time: 20-28 hours

## Dependencies

- Backend `/api/auth/sign-in/username` endpoint must be accessible
- Backend `/api/auth/sign-up/email` endpoint must be accessible
- Backend `/api/auth/get-session` endpoint must be accessible
- Backend must have email verification disabled (currently true)
- CORS must be configured to allow credentials from iOS app

## Testing Strategy

1. **Unit Tests**: Test all new methods in isolation with mocks
2. **Integration Tests**: Test full flow with mock backend
3. **Manual Tests**: Test on simulator with real backend (development mode)
4. **Regression Tests**: Ensure existing features still work (conversation list, messages, reactions)

## Rollback Plan

If critical issues arise:
1. Revert all commits in this change
2. Re-deploy previous version
3. Users will need to re-login with `idAlias` (stored in backend as fallback)
