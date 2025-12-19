# Tasks: Align Auth with Backend Updates

**Change ID:** `align-auth-with-backend-updates`

## Implementation Order

### 1. Update Response Models (30 mins) ⏳

- [ ] Add `ChatUserResponse` struct to `DefaultAuthRepository.swift`
  - Fields: `id`, `idAlias`, `name`, `avatarUrl`
  - Map snake_case backend fields to camelCase
- [ ] Update `AuthResponse` struct to include optional `chat` field
  - `let chat: ChatUserResponse?`
- [ ] Update `toAuthSession()` method to parse chat user
  - Create `User` entity from `ChatUserResponse` when present
  - Pass to `AuthSession` initializer

**Validation:**
- Compile successfully
- No breaking changes to existing auth flow

### 2. Update AuthSession Model (15 mins) ⏳

- [ ] Add `chatUser: User?` property to `AuthSession`
- [ ] Update initializer to accept optional `chatUser` parameter
- [ ] Maintain computed `userId` property (existing behavior)
- [ ] Update all call sites to provide `chatUser: nil` for now

**Validation:**
- All existing tests pass
- Backward compatible with current usage

### 3. Create Profile Repository Protocol (20 mins) ⏳

- [ ] Create `ProfileRepositoryProtocol.swift` in `Features/Authentication/Domain/Repositories/`
  - Method: `func fetchProfile() async throws -> (authUser: AuthUser, chatUser: User?)`
- [ ] Create response model for profile endpoint
  - Struct with `auth` and `chat` fields matching backend format

**Validation:**
- Protocol compiles
- Clear separation of concerns

### 4. Implement DefaultProfileRepository (45 mins) ⏳

- [ ] Create `DefaultProfileRepository.swift` in `Features/Authentication/Data/Repositories/`
- [ ] Implement `GET /api/protected/profile` call
  - Use `NetworkConfiguration.session` for cookie support
  - Parse response with `auth` and `chat` fields
- [ ] Handle error cases (401, 500, network errors)
- [ ] Map response to domain models (`User`, `AuthUser`)

**Validation:**
- API call structure matches backend format
- Error handling covers all cases
- Cookie authentication works

### 5. Create MockProfileRepository (20 mins) ⏳

- [ ] Create `MockProfileRepository.swift` for testing
- [ ] Return mock data matching real response format
- [ ] Support both users with/without chat profiles
- [ ] Add `shouldFail` flag for error testing

**Validation:**
- Mock data matches production format
- Useful for unit tests and previews

### 6. Add Profile Use Case (30 mins) ⏳

- [ ] Create `ProfileUseCase.swift` in `Features/Authentication/Domain/UseCases/`
- [ ] Method: `func fetchProfile() async throws -> AuthSession`
  - Call profile repository
  - Create/update `AuthSession` with both auth and chat data
- [ ] Handle users without chat profiles gracefully

**Validation:**
- Use case orchestrates repository calls correctly
- Returns complete session data

### 7. Update Dependency Container (15 mins) ⏳

- [ ] Add `profileRepository` property to `DependencyContainer`
- [ ] Add `profileUseCase` lazy property
- [ ] Update factory methods (`makeTestContainer`, `makePreviewContainer`)
- [ ] Inject profile repository into use case

**Validation:**
- DI properly wired
- Factory methods updated

### 8. Optional: Enhance Session Validation (30 mins) 🔄

- [ ] Consider calling `/api/protected/profile` after session validation
- [ ] Update `AuthenticationViewModel.checkAuthentication()` to fetch profile
- [ ] Store chat user data in session on app launch

**Note:** This is optional enhancement. Profile endpoint can be called on-demand instead.

### 9. Update Tests (45 mins) ⏳

- [ ] Update `AuthenticationUseCaseTests` for new response format
- [ ] Add `ProfileUseCaseTests`
- [ ] Test null chat user handling
- [ ] Verify backward compatibility

**Validation:**
- All tests pass
- Coverage for new code paths

### 10. Documentation (20 mins) ⏳

- [ ] Update `CLAUDE.md` with profile endpoint information
- [ ] Document `chatUser` field in `AuthSession`
- [ ] Add notes about optional chat profiles

## Progress Summary

### ⏳ To Do
- All tasks pending

### Estimated Total Time: 4-5 hours

## Dependencies

- Backend `/api/protected/profile` must be deployed and accessible
- Cookie authentication must be working (already implemented)
- `NetworkConfiguration.session` properly configured (already done)

## Testing Strategy

1. **Unit Tests**: Test all new repository and use case methods with mocks
2. **Integration Tests**: Test with real backend (development mode)
3. **Manual Tests**:
   - Login and fetch profile
   - Handle users with/without chat profiles
   - Verify cookie-based auth works for protected endpoint

## Rollback Plan

If issues arise:
1. This change is additive and non-breaking
2. Can be rolled back by removing new files
3. Existing auth flow continues to work without profile fetching
