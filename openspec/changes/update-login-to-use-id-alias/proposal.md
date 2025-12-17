# Proposal: Update Login to Use ID Alias

## Change ID
`update-login-to-use-id-alias`

## Overview
Update the iOS client's authentication flow to use the new `idAlias`-based login endpoint (`POST /users/login`) instead of the existing UUID-based user lookup (`GET /users/{userId}`). This change aligns the client with the backend API update that introduces human-readable user identifiers for login.

## Background
The backend API has been updated to support login via `idAlias` (a unique, human-readable identifier) as documented in https://github.com/linnefromice/prototype-chat-w-hono-drizzle-by-agent/pull/26. The iOS client currently uses UUID-based `userId` for authentication, which is not user-friendly for manual testing and development.

## Current Behavior
- User enters a UUID (e.g., `user-1`) in the login screen
- App calls `GET /users/{userId}` to fetch user data
- If user is found, a session is created and stored locally

## Proposed Behavior
- User enters an `idAlias` (e.g., `john_doe_2024`) in the login screen
- App calls `POST /users/login` with `{"idAlias": "john_doe_2024"}` to authenticate
- If user is found, a session is created and stored locally using the returned user data

## Benefits
- **Improved UX**: Users can use memorable, human-readable identifiers instead of UUIDs
- **API Alignment**: Client matches the new backend authentication pattern
- **Validation**: Enforces `idAlias` format rules (3-30 characters, lowercase alphanumeric with `.`, `_`, `-` symbols)
- **Future-proof**: Prepares the client for potential password-based authentication

## Scope
This change affects:
- **Domain Layer**: `User` entity (add `idAlias` field)
- **Repository Layer**: `UserRepositoryProtocol` and implementations (add login method)
- **Use Case Layer**: `AuthenticationUseCase` (update authentication logic)
- **Presentation Layer**: `AuthenticationView` (update UI labels and validation)
- **Infrastructure Layer**: Update OpenAPI spec and regenerate client code
- **Testing**: Update unit tests and add new test cases for `idAlias` validation

## Implementation Strategy
1. Update OpenAPI specification with new `idAlias` field and `/users/login` endpoint
2. Regenerate OpenAPI client code
3. Update `User` entity to include `idAlias` field
4. Add `loginByIdAlias` method to `UserRepositoryProtocol`
5. Implement `loginByIdAlias` in `UserRepository` and `MockUserRepository`
6. Update `AuthenticationUseCase` to use new login method
7. Update `AuthenticationView` UI to reflect `idAlias` instead of `userId`
8. Add client-side validation for `idAlias` format
9. Update unit tests and add new test cases
10. Test end-to-end with backend API

## Breaking Changes
- **User entity**: Adding `idAlias` as a required field may affect existing code that creates User instances
- **Authentication flow**: Changes from GET to POST endpoint (backward compatible if backend supports both)

## Migration Path
- The `id` field remains unchanged and continues to be used for internal operations
- Both `userId` (UUID) and `idAlias` (human-readable) coexist in the User model
- Existing sessions stored with UUID-based `userId` will continue to work

## Dependencies
- Backend API must be updated with `idAlias` support and `/users/login` endpoint
- OpenAPI specification must include the new schema and endpoint definitions

## Alternatives Considered
1. **Keep UUID-based login**: Rejected because it's not user-friendly for development/testing
2. **Support both UUID and idAlias**: Rejected to keep implementation simple and aligned with backend design
3. **Add username/password auth**: Deferred to future enhancement; this change focuses on idAlias adoption

## Success Criteria
- [ ] OpenAPI spec updated and client code regenerated without errors
- [ ] All existing unit tests pass
- [ ] New unit tests added for `idAlias` validation and login flow
- [ ] User can log in using `idAlias` in the iOS simulator
- [ ] Invalid `idAlias` formats are rejected with appropriate error messages
- [ ] Existing user sessions remain functional after update
