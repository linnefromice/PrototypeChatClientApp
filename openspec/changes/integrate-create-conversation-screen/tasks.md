# Tasks: Integrate Create Conversation Screen

**Change ID:** `integrate-create-conversation-screen`

## Implementation Tasks

These tasks deliver the integration of the chat creation screen into the conversation list, enabling users to create 1:1 chats.

---

### 1. Add currentUserId property to ConversationListViewModel

**File:** `PrototypeChatClientApp/Features/Chat/Presentation/ViewModels/ConversationListViewModel.swift`

**Description:**
Expose the `currentUserId` as a public property so that ConversationListView can pass it to CreateConversationViewModel.

**Steps:**
1. Change `private let currentUserId: String` to `let currentUserId: String` (remove `private`)
2. No other changes needed

**Expected Outcome:**
- `currentUserId` is accessible from ConversationListView
- Existing functionality is unchanged

**Validation:**
- Build succeeds: `make build`
- Existing tests pass: `make test`

**Estimated Effort:** 2 minutes

---

### 2. Integrate CreateConversationView into ConversationListView

**File:** `PrototypeChatClientApp/Features/Chat/Presentation/Views/ConversationListView.swift`

**Description:**
Replace the placeholder text with the actual CreateConversationView and wire up the callback to refresh the conversation list.

**Steps:**
1. Replace lines 43-46 (the `.sheet` modifier) with proper CreateConversationView initialization
2. Add a private helper method `makeCreateConversationViewModel()` to create the ViewModel with proper dependency injection
3. Wire the `onConversationCreated` callback to refresh the conversation list

**Code Changes:**

Replace:
```swift
.sheet(isPresented: $showCreateConversation) {
    // チャット作成画面は後で実装
    Text("チャット作成画面（未実装）")
}
```

With:
```swift
.sheet(isPresented: $showCreateConversation) {
    CreateConversationView(
        viewModel: makeCreateConversationViewModel(),
        onConversationCreated: { _ in
            Task {
                await viewModel.loadConversations()
            }
        }
    )
}
```

Add new method at the end of ConversationListView (before the closing brace):
```swift
private func makeCreateConversationViewModel() -> CreateConversationViewModel {
    let container = DependencyContainer.shared
    return CreateConversationViewModel(
        conversationUseCase: container.conversationUseCase,
        userListUseCase: container.userListUseCase,
        currentUserId: viewModel.currentUserId
    )
}
```

**Expected Outcome:**
- Tapping the "+" button opens CreateConversationView in a sheet
- User list is loaded and displayed
- Selecting a user and tapping "作成" creates a 1:1 chat
- After creation, the sheet closes and the conversation list refreshes
- The new conversation appears at the top of the list

**Validation:**
- Build succeeds: `make build`
- No compilation errors
- Code follows existing patterns (similar to MainView)

**Estimated Effort:** 10 minutes

---

### 3. Manual testing in simulator

**Description:**
Test the complete user flow in the iOS simulator to ensure everything works end-to-end.

**Test Steps:**
1. Run app: `make run`
2. Login as `user-1` (Alice)
3. Verify conversation list loads
4. Tap the "+" button in the top-right
5. Verify CreateConversationView opens in a sheet
6. Verify user list displays (user-2, user-3, etc., excluding user-1)
7. Select `user-2` (Bob)
8. Verify checkmark appears next to Bob
9. Tap "作成" button
10. Verify sheet closes
11. Verify conversation list refreshes
12. Verify new conversation with Bob appears in the list

**Error Scenarios to Test:**
1. Tap "作成" without selecting a user → Should show "ユーザーを選択してください" error
2. Tap "キャンセル" → Should close sheet without creating anything
3. Backend offline → Should show "ユーザー一覧の取得に失敗しました" error

**Expected Outcome:**
- All happy path steps work correctly
- All error scenarios display appropriate error messages
- UI is responsive and intuitive
- No crashes or unexpected behavior

**Validation:**
- Take screenshots of key screens
- Document any issues or unexpected behavior
- Verify with different user accounts (user-1, user-2, user-3)

**Estimated Effort:** 15 minutes

---

### 4. Verify existing tests still pass

**Description:**
Run the full test suite to ensure no regressions were introduced.

**Steps:**
1. Run all tests: `make test`
2. Verify all existing tests pass
3. Check for any new warnings or errors

**Expected Outcome:**
- All tests pass without errors
- No new warnings introduced
- Test coverage remains the same or improves

**Validation:**
- `make test` exits with success code
- Test output shows no failures

**Estimated Effort:** 5 minutes

---

### 5. Update Preview to use real CreateConversationView

**File:** `PrototypeChatClientApp/Features/Chat/Presentation/Views/ConversationListView.swift`

**Description:**
Update the SwiftUI Preview to properly demonstrate the create conversation functionality.

**Steps:**
1. Keep the existing preview implementation (it's already good)
2. Optionally add a comment explaining the preview uses mock data

**Expected Outcome:**
- Preview still works in Xcode
- Developers can preview the conversation list with mock data

**Validation:**
- Open ConversationListView.swift in Xcode
- Preview renders without errors
- Tapping "+" button in preview shows CreateConversationView

**Estimated Effort:** 3 minutes

---

## Task Summary

| # | Task | Type | Effort | Dependencies |
|---|------|------|--------|--------------|
| 1 | Expose currentUserId property | Code | 2 min | None |
| 2 | Integrate CreateConversationView | Code | 10 min | Task 1 |
| 3 | Manual testing in simulator | Test | 15 min | Task 2 |
| 4 | Verify existing tests pass | Test | 5 min | Task 2 |
| 5 | Update Preview (optional) | Code | 3 min | Task 2 |

**Total Estimated Time:** 35 minutes

---

## Parallel Execution

- Task 1 must be completed first
- Tasks 3, 4, 5 can all be done in parallel after Task 2 is complete

---

## Success Checklist

- [x] `currentUserId` is accessible from ConversationListView
- [x] `CreateConversationView` is properly integrated into the sheet
- [x] Tapping "+" button opens the create conversation screen
- [x] User list loads and displays correctly
- [x] User can select a user from the list
- [x] "作成" button creates a 1:1 chat successfully
- [x] Sheet closes after successful creation
- [x] Conversation list refreshes automatically
- [x] New conversation appears in the list
- [x] Error scenarios display appropriate messages
- [x] All existing tests pass (`make test`)
- [x] App builds successfully (`make build`)
- [x] Manual testing confirms all flows work
- [x] Code follows project architecture patterns

---

## Rollback Plan

If issues are discovered:
1. The change is minimal (1 file, <20 lines of code)
2. Revert to placeholder text: `Text("チャット作成画面（未実装）")`
3. Remove the `makeCreateConversationViewModel()` method
4. Revert `currentUserId` to `private` if needed
5. No database or API changes, so no data migration needed
