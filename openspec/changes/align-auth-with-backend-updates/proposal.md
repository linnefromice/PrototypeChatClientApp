# Proposal: Align Auth with Backend Updates

**Change ID:** `align-auth-with-backend-updates`
**Status:** Proposal
**Created:** 2025-12-20

## Why

The backend authentication system has been updated with enhanced security and user profile management. The iOS app needs to align with these changes to:
1. Properly handle the full user profile response from `/api/protected/profile`
2. Parse the `chat` field containing chat user information returned by the backend
3. Ensure all API calls work with cookie-based authentication (`credentials: 'include'` equivalent)
4. Support the backend's `auth_user` → `chat_user` mapping

## Problem Statement

The backend has made several updates to the authentication system:

**Backend Changes:**
1. Added `/api/protected/profile` endpoint returning both `auth` and `chat` user data
2. All chat APIs now require `requireAuth` middleware (cookie-based authentication)
3. Backend automatically maps `auth_user` to `chat_user` via `getChatUserId` utility
4. Session responses now include `chat_user_id` reference when available

**Current iOS Implementation Gaps:**
1. ❌ No implementation of `/api/protected/profile` endpoint
2. ⚠️ `AuthResponse` model doesn't parse the `chat` field from backend
3. ⚠️ Missing explicit `chat_user_id` handling in session flow
4. ❓ Need to verify all chat API calls properly send cookies (URLSession handles this, but needs verification)

**Impact:**
- Cannot fetch full user profile with chat user information
- May not properly handle users who don't have a chat profile yet
- Missing visibility into chat user data returned by backend

## What Changes

This change adds support for the `/api/protected/profile` endpoint and enhances authentication response models to properly parse and store chat user information returned by the backend.

## Proposed Solution

Add support for `/api/protected/profile` endpoint and enhance the authentication response models to properly parse and store chat user information from the backend.

### Key Changes

1. **Add Profile Repository**
   - Create `ProfileRepositoryProtocol` in Authentication feature
   - Implement `DefaultProfileRepository` with `GET /api/protected/profile`
   - Return both auth and chat user data

2. **Update Response Models**
   - Add `ChatUserResponse` nested model in `AuthResponse`
   - Parse `chat` field from backend response
   - Handle `null` chat user (user without chat profile)

3. **Add Profile Use Case**
   - Create `ProfileUseCase` for fetching user profile
   - Call after successful login/registration
   - Store chat user reference in `AuthSession`

4. **Update AuthSession Model**
   - Add `chatUser: User?` property
   - Update initialization to accept optional chat user
   - Maintain backward compatibility

### Scope

**In Scope:**
- Add `/api/protected/profile` endpoint support
- Parse `chat` field from backend responses
- Store chat user data in session
- Update response models for new backend format

**Out of Scope:**
- Creating chat users from iOS (handled by backend)
- Modifying existing authentication flow (login/register/session validation)
- UI changes (no user-facing impact)
- Migration of existing sessions (already handled)

## Benefits

1. **Complete Backend Alignment**: iOS matches backend's authentication response format
2. **Chat User Visibility**: App knows whether user has a chat profile
3. **Future-Ready**: Prepared for features that require chat user data
4. **Better Error Handling**: Can detect and handle users without chat profiles

## Risks & Mitigations

**Risk 1:** Backend may not always return `chat` field
- **Mitigation**: Make `chat` field optional, gracefully handle `null`

**Risk 2:** Existing sessions may not have chat user data
- **Mitigation**: Fetch profile on next session validation, update session

**Risk 3:** Profile endpoint may fail while auth succeeds
- **Mitigation**: Treat chat user as optional, allow app to function without it

## Dependencies

- Backend `/api/protected/profile` endpoint must be accessible
- Backend must return both `auth` and `chat` fields
- Cookie-based authentication must be working (already implemented)

## Success Criteria

- [ ] Can fetch full user profile via `/api/protected/profile`
- [ ] `AuthSession` properly stores chat user data when available
- [ ] Handles users without chat profiles gracefully
- [ ] Existing authentication flow continues to work
- [ ] All tests pass with enhanced models

## Related Changes

- Builds upon: `migrate-to-backend-auth` (already deployed)
- Future: May enable chat-specific features that require chat user data
