# Proposal: Migrate to Backend Auth

**Change ID:** `migrate-to-backend-auth`
**Status:** Proposal
**Created:** 2025-12-19

## Why

The iOS app must adopt the backend's production-ready authentication system (BetterAuth) to enable secure user registration, proper session management, and access to protected endpoints. This migration is essential for production deployment and aligns the iOS app with industry-standard security practices.

## Problem Statement

The iOS app currently uses a simplified `idAlias`-based authentication (`POST /users/login`) that does not align with the backend's production-ready BetterAuth implementation. The backend now provides:

- Username/password authentication via `/api/auth/sign-in/username`
- User registration via `/api/auth/sign-up/email`
- Cookie-based session management (HttpOnly, 7-day expiry)
- Secure endpoints requiring authentication with `requireAuth` middleware
- Separation of `auth_user` (authentication) and `users` (chat profile) tables

**Current Issues:**
1. iOS authentication flow is incompatible with backend's BetterAuth system
2. No password-based authentication in iOS app
3. No session cookie management (currently stores session in UserDefaults)
4. Cannot access protected backend endpoints that require BetterAuth cookies
5. No user registration flow in iOS app

## Proposed Solution

Migrate iOS authentication to use backend's BetterAuth API endpoints with username/password authentication and cookie-based session management.

### Key Changes

1. **Add Username/Password Login**
   - Replace `idAlias` input with `username` and `password` fields
   - Call `POST /api/auth/sign-in/username` instead of `/users/login`
   - Store and send cookies automatically via `URLSession`

2. **Add User Registration**
   - New registration screen with username, email, password, name fields
   - Call `POST /api/auth/sign-up/email`
   - Validate inputs according to backend requirements

3. **Cookie-Based Session Management**
   - Configure `URLSession` with `HTTPCookieStorage` to persist cookies
   - Remove manual session storage (rely on cookies)
   - Handle cookie expiration and renewal

4. **Update AuthSession Model**
   - Store `auth_user` information from backend response
   - Maintain backward compatibility with existing `User` entity
   - Handle `auth_user` <-> `chat_user` mapping

5. **Session Validation**
   - Call `GET /api/auth/get-session` on app launch
   - Validate session before showing main UI
   - Handle 401 errors and redirect to login

### Scope

**In Scope:**
- Username/password login UI and logic
- User registration UI and logic
- Cookie-based session management via URLSession
- Session validation on app launch
- Update `AuthSession` to store backend auth data
- Update authentication tests

**Out of Scope:**
- OAuth/Social login (future enhancement)
- 2FA/TOTP (future enhancement)
- Email verification (backend has it disabled)
- Password reset flow (future enhancement)
- Biometric authentication (future enhancement)

## Benefits

1. **Security**: Aligns with production-ready backend authentication
2. **Feature Parity**: Enables access to all protected backend endpoints
3. **Standards Compliance**: Uses industry-standard cookie-based sessions
4. **User Experience**: Proper registration and login flows
5. **Maintainability**: Single source of truth for authentication (backend)

## Risks & Mitigations

**Risk 1:** Breaking changes for existing users with saved `idAlias` sessions
- **Mitigation**: Detect old sessions and force re-login with migration message

**Risk 2:** Cookie management complexity in iOS
- **Mitigation**: Use `URLSession`'s built-in cookie storage, well-documented API

**Risk 3:** CORS and cookie issues during development
- **Mitigation**: Backend already configured with proper CORS settings

## Dependencies

- Backend BetterAuth API must be deployed and accessible
- Backend must have user registration enabled
- HTTPS required for secure cookie transmission (production)

## Success Criteria

- [ ] Users can register with username, email, password, name
- [ ] Users can login with username and password
- [ ] Session persists across app restarts via cookies
- [ ] Session validation works on app launch
- [ ] All existing authentication tests pass with new implementation
- [ ] Protected API endpoints work with cookie authentication
- [ ] Old `idAlias` sessions trigger re-login prompt

## Related Changes

- Future: Add OAuth login (`add-oauth-login`)
- Future: Add 2FA support (`add-two-factor-auth`)
- Future: Add password reset (`add-password-reset`)
