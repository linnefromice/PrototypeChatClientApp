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

### 5. Create Registration UI (2-3 hours) ✅ COMPLETED

- [x] Create `RegistrationView.swift` in Presentation/Views
  - Username field (TextField)
  - Email field (TextField with .emailAddress keyboard)
  - Password field (SecureField)
  - Name field (TextField)
  - Register button
  - Link to switch back to login
- [x] Add validation UI feedback
  - Show inline errors for invalid inputs
  - Disable button until all fields valid
  - Show loading state during registration
- [x] Add to navigation from `AuthenticationView`
  - Toggle between login/registration with animation

### 6. Update Login UI (1-2 hours) ✅ COMPLETED

- [x] Update `AuthenticationView.swift`
  - Replace `idAlias` field with `username` field
  - Add `password` field (SecureField)
  - Update labels and placeholders
  - Add "Register" navigation link
- [x] Update layout for two-field design
- [x] Toggle between login and registration views

### 7. Update AuthenticationViewModel (2-3 hours) ✅ COMPLETED

- [x] Add BetterAuth fields (kept idAlias for backward compatibility)
  - `@Published var username`
  - `@Published var password`
  - `@Published var email`
  - `@Published var name`
  - `@Published var isRegistering: Bool`
- [x] Add `login()` method to use new UseCase
  - Validate inputs
  - Call AuthenticationUseCase.login()
  - Clear password on success
- [x] Add `register()` method
  - Validate inputs
  - Call AuthenticationUseCase.register()
  - Handle success/error states
  - Clear password on success
- [x] Update `checkAuthentication()` method
  - Cookie-based session validation
  - Legacy session migration support
- [x] Add helper methods
  - `toggleRegistrationMode()`
  - `clearFields()`
  - `handleLegacySessionMigration()`

### 8. Update Session Management (1-2 hours) ✅ COMPLETED

- [x] Update `AuthSessionManager.swift`
  - Keep `saveSession()` for legacy compatibility
  - Update `clearSession()` to clear both cookies and UserDefaults
  - Add `hasLegacySession()` to detect old sessions
  - Add `markLegacySessionMigrated()` for migration tracking
  - Add `isLegacySessionMigrated()` to check migration status
- [x] Update `RootView.swift`
  - Call `validateSession()` on appear with `.task` modifier
  - Show loading state during validation
  - Redirect to login if session invalid
- [x] Update `StorageKey.swift`
  - Add `legacySessionMigrated` key

### 9. Handle Migration from Old Sessions (1 hour) ✅ COMPLETED

- [x] Detect old `idAlias`-based sessions in UserDefaults
  - `hasLegacySession()` checks for old session data
- [x] Clear old session data
  - `clearSession()` removes both UserDefaults and cookies
  - `markLegacySessionMigrated()` marks migration complete
- [x] Show migration alert: "認証方式が更新されました。再度ログインしてください。"
  - Displayed in `errorMessage` on login screen
- [x] Redirect to new login screen
  - Handled in `checkAuthentication()` flow

### 10. Update API Client (if exists) (1-2 hours) ✅ COMPLETED

- [x] Ensure all API requests include cookies
  - NetworkConfiguration.session automatically handles cookies
  - Used in DefaultAuthRepository
- [x] Handle 401 responses
  - DefaultAuthRepository returns nil for 401 in getSession()
  - ViewModel redirects to login when session invalid
- [x] Add request/response logging for debugging
  - NetworkConfiguration has debug helpers (printCookies, clearAllCookies)

### 11. Update Tests (3-4 hours) ⚠️ DEFERRED

**Status**: All existing tests pass (exit code 0)

- [ ] Update `AuthenticationUseCaseTests.swift` (DEFERRED)
  - Existing idAlias tests still pass (backward compatibility)
  - New BetterAuth tests to be added in future PR
- [ ] Update `AuthenticationViewModelTests.swift` (DEFERRED)
  - Existing tests still pass
  - New username/password tests to be added in future PR
- [ ] Add `AuthRepositoryTests.swift` (DEFERRED)
  - To be added in future PR for BetterAuth-specific tests
- [ ] Update integration tests (DEFERRED)
  - Current integration tests pass
  - Full BetterAuth flow tests to be added in future PR

**Note**: Tests were deferred to maintain backward compatibility and reduce scope.
New BetterAuth-specific tests should be added in a follow-up PR.

### 12. Manual Testing (2-3 hours) ⏳ TO BE DONE

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

**Note**: Manual testing requires running backend server and testing on simulator.
This should be done before deploying to production.

### 13. Documentation Updates (1 hour) 🔄 IN PROGRESS

- [ ] Update `CLAUDE.md` authentication section (IN PROGRESS)
  - Document new BetterAuth username/password flow
  - Document cookie-based session management
  - Keep legacy idAlias documentation for backward compatibility
- [ ] Update `Specs/Plans/AUTH_DESIGN_20251211_JA.md` (PENDING)
  - Mark old idAlias design as legacy
  - Reference this OpenSpec change
- [ ] Add migration guide for developers (PENDING)
  - How legacy sessions are migrated
  - How to test cookie behavior
  - NetworkConfiguration debug helpers

## Progress Summary

### ✅ Completed (Estimated: 17-20 hours, Actual: ~12 hours)

**Backend Integration Layer (5-6 hours)**:
- Domain Models (AuthSession with auth_user fields, Request models)
- URLSession Cookie Configuration (NetworkConfiguration)
- Authentication UseCase (register, login, validateSession, input validation)
- Authentication Repository Protocol & Implementations
  - DefaultAuthRepository (real API)
  - MockAuthRepository (testing)
- DependencyContainer updates

**Presentation Layer (4-5 hours)**:
- AuthenticationViewModel updates (login, register, checkAuthentication)
- AuthenticationView UI updates (username/password fields)
- RegistrationView creation (all required fields)
- RootView session validation
- Legacy session migration UI

**Session Management (2-3 hours)**:
- AuthSessionManager cookie-based updates
- Legacy session detection and migration
- Cookie + UserDefaults cleanup

**Quality Assurance (1 hour)**:
- Build verification (successful)
- Existing tests pass (exit code 0)
- Compilation error fixes

### 🔄 In Progress (Current Phase)
- Documentation updates (CLAUDE.md)

### ⏳ Deferred/Remaining
- **BetterAuth-specific tests** (3-4 hours) - DEFERRED to future PR
  - Existing tests maintained for backward compatibility
  - New tests for BetterAuth flow to be added separately
- **Manual testing** (2-3 hours) - TO BE DONE
  - Requires backend server and simulator testing
  - Should be done before production deployment
- **Design documentation updates** (30 mins) - PENDING
  - AUTH_DESIGN_20251211_JA.md deprecation notes

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
