# Tasks: Implement Chat Creation User List

**Change ID:** `implement-chat-creation-user-list`

## Implementation Tasks

These tasks are ordered to deliver incremental, verifiable progress toward completing the chat creation feature.

---

### 1. Implement UserListUseCase.fetchAvailableUsers()

**File:** `PrototypeChatClientApp/Features/Chat/Domain/UseCases/UserListUseCase.swift`

**Description:**
Replace the TODO implementation with actual user fetching logic.

**Steps:**
1. Call `userRepository.fetchUsers()` to get all users
2. Filter out the current user: `filter { $0.id != excludingUserId }`
3. Return the filtered user list
4. Preserve the `async throws` signature for error propagation

**Expected Outcome:**
- Method returns actual users from the repository
- Current user is excluded from the list
- Errors from repository are propagated correctly

**Validation:**
- Read the file before editing to understand context
- After editing, run `make build` to verify compilation
- Code review: Check that filtering logic is correct

**Estimated Effort:** 5 minutes

---

### 2. Add unit tests for UserListUseCase

**File:** `PrototypeChatClientAppTests/Features/Chat/Domain/UseCases/UserListUseCaseTests.swift` (new file)

**Description:**
Create comprehensive unit tests to verify the UseCase behavior.

**Test Cases:**
1. `testFetchAvailableUsers_excludesCurrentUser()` - Verify current user is filtered out
2. `testFetchAvailableUsers_returnsAllOtherUsers()` - Verify non-current users are included
3. `testFetchAvailableUsers_handlesEmptyList()` - Verify empty array handling
4. `testFetchAvailableUsers_propagatesRepositoryError()` - Verify error propagation
5. `testFetchAvailableUsers_currentUserNotInList()` - Verify behavior when current user not in original list

**Expected Outcome:**
- All test cases pass
- Code coverage for `UserListUseCase` is complete
- Tests use `MockUserRepository` for isolation

**Validation:**
- Run `make test` to verify all tests pass
- Check test coverage includes all scenarios

**Estimated Effort:** 15 minutes

---

### 3. Manual testing: Verify user list display in UI

**Screen:** `CreateConversationView`

**Description:**
Test the complete flow in the simulator to ensure the feature works end-to-end.

**Test Steps:**
1. Run app in simulator: `make run`
2. Login as `user-1` (Alice)
3. Navigate to conversation list
4. Tap "+" button to open chat creation
5. Verify user list loads and displays other users (user-2, user-3, etc.)
6. Verify Alice (user-1) is NOT in the list
7. Select Bob (user-2)
8. Tap "作成" button
9. Verify 1:1 chat is created
10. Verify navigation back to conversation list
11. Verify new conversation appears

**Expected Outcome:**
- User list displays correctly with names and IDs
- Current user is excluded
- Selection works (checkmark appears)
- Chat creation succeeds
- Navigation flow is smooth

**Validation:**
- Take screenshots if needed
- Test with different user accounts (user-1, user-2, user-3)
- Verify error handling: Try with backend offline

**Estimated Effort:** 10 minutes

---

### 4. Error scenario testing

**Description:**
Verify error handling works correctly in various failure scenarios.

**Test Scenarios:**
1. **Backend offline:** Stop backend server, try to load users
   - Expected: Error alert displays "ユーザー一覧の取得に失敗しました"
2. **Network timeout:** Simulate slow network
   - Expected: Loading indicator shows, eventually timeout error
3. **Empty user list:** Backend returns no users
   - Expected: Shows "ユーザーが見つかりません" message

**Expected Outcome:**
- All error states display appropriate messages
- App remains in recoverable state
- User can retry by dismissing and reopening screen

**Validation:**
- Test each scenario manually
- Verify error messages are user-friendly (in Japanese)

**Estimated Effort:** 10 minutes

---

### 5. Integration with DependencyContainer

**File:** `PrototypeChatClientApp/App/DependencyContainer.swift`

**Description:**
Verify `UserListUseCase` is properly injected with the correct repository.

**Verification:**
1. Check `DependencyContainer` has `userListUseCase` defined
2. Verify it uses `UserRepository` (not `MockUserRepository`) for production
3. Verify `CreateConversationViewModel` receives the UseCase correctly

**Expected Outcome:**
- Production app uses real `UserRepository`
- Test code can inject `MockUserRepository`
- No hardcoded dependencies

**Validation:**
- Read `DependencyContainer.swift` to verify setup
- Confirm `CreateConversationViewModel` initialization is correct

**Estimated Effort:** 5 minutes

---

## Task Summary

| # | Task | Type | Effort | Dependencies |
|---|------|------|--------|--------------|
| 1 | Implement UseCase method | Code | 5 min | None |
| 2 | Add unit tests | Test | 15 min | Task 1 |
| 3 | Manual UI testing | Test | 10 min | Task 1 |
| 4 | Error scenario testing | Test | 10 min | Task 1 |
| 5 | Verify DI setup | Verification | 5 min | None (parallel) |

**Total Estimated Time:** 45 minutes

---

## Parallel Execution

Tasks that can be done in parallel:
- Task 5 (DI verification) can be done anytime, independent of other tasks

Tasks that must be sequential:
- Tasks 2, 3, 4 all depend on Task 1 being completed first

---

## Success Checklist

- [x] `UserListUseCase.fetchAvailableUsers()` is implemented
- [x] All unit tests pass (`make test`)
- [x] App builds successfully (`make build`)
- [x] User list displays in CreateConversationView
- [x] Current user is excluded from the list
- [x] User can select a user and create a 1:1 chat
- [x] Error states display appropriate messages
- [x] Code follows project architecture (MVVM + Clean Architecture)
- [x] No regressions in existing features

---

## Rollback Plan

If issues are discovered:
1. The change is minimal (single method implementation)
2. Revert to TODO implementation: `return []`
3. UI will show "ユーザーが見つかりません" as before
4. No data corruption or state issues possible
