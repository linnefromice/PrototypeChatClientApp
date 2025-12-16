# Tasks: Add Logout Navigation Menu

**Change ID:** `add-logout-navigation-menu`

## Implementation Tasks

These tasks deliver the logout functionality through a navigation menu accessible from the conversation list screen.

---

### 1. Create NavigationMenuView component

**File:** `PrototypeChatClientApp/Features/Authentication/Presentation/Views/NavigationMenuView.swift` (new file)

**Description:**
Create a simple menu view that displays logout option in a list format, following iOS standards.

**Steps:**
1. Create new SwiftUI View file `NavigationMenuView.swift`
2. Add `onLogout` callback parameter
3. Implement List with logout button using `.destructive` role
4. Add navigation bar with "閉じる" button
5. Use `@Environment(\.dismiss)` for closing the sheet

**Code Template:**
```swift
import SwiftUI

struct NavigationMenuView: View {
    @Environment(\.dismiss) var dismiss
    let onLogout: () -> Void

    var body: some View {
        NavigationView {
            List {
                Button(role: .destructive, action: {
                    dismiss()
                    onLogout()
                }) {
                    Label("ログアウト", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
            .navigationTitle("メニュー")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("閉じる") {
                dismiss()
            })
        }
    }
}
```

**Expected Outcome:**
- NavigationMenuView component created
- Displays a list with logout option
- Has navigation bar with title and close button
- Callback mechanism works correctly

**Validation:**
- Build succeeds: `make build`
- Preview in Xcode renders correctly

**Estimated Effort:** 10 minutes

---

### 2. Add menu button and state management to ConversationListView

**File:** `PrototypeChatClientApp/Features/Chat/Presentation/Views/ConversationListView.swift`

**Description:**
Add left navigation bar button to open the menu, and state variables to manage menu and logout confirmation.

**Steps:**
1. Add `@Environment(\.dismiss)` if needed (for future use)
2. Add `@EnvironmentObject var authViewModel: AuthenticationViewModel`
3. Add `@State private var showMenu = false`
4. Add `@State private var showLogoutConfirmation = false`
5. Update `.navigationBarItems` to include `leading:` parameter with menu button

**Code Changes:**

Add at the top of struct:
```swift
@EnvironmentObject var authViewModel: AuthenticationViewModel
@State private var showMenu = false
@State private var showLogoutConfirmation = false
```

Update `.navigationBarItems`:
```swift
.navigationBarItems(
    leading: Button(action: {
        showMenu = true
    }) {
        Image(systemName: "line.3.horizontal")
            .imageScale(.large)
    },
    trailing: Button(action: {
        showCreateConversation = true
    }) {
        Image(systemName: "plus")
    }
)
```

**Expected Outcome:**
- Menu button appears in top-left corner
- State variables properly manage UI state
- Tapping menu button triggers state change

**Validation:**
- Build succeeds: `make build`
- No compilation errors
- Menu button is visible in preview

**Estimated Effort:** 10 minutes

---

### 3. Add menu sheet to ConversationListView

**File:** `PrototypeChatClientApp/Features/Chat/Presentation/Views/ConversationListView.swift`

**Description:**
Add `.sheet` modifier to display NavigationMenuView when menu button is tapped.

**Steps:**
1. Add `.sheet(isPresented: $showMenu)` modifier after existing sheet
2. Initialize NavigationMenuView with logout callback
3. Implement logout callback to show confirmation dialog

**Code Changes:**

Add after the existing `.sheet` for CreateConversationView:
```swift
.sheet(isPresented: $showMenu) {
    NavigationMenuView(onLogout: {
        showLogoutConfirmation = true
    })
}
```

**Expected Outcome:**
- Tapping menu button opens NavigationMenuView in a sheet
- Sheet displays correctly with navigation bar
- Tapping logout triggers confirmation state

**Validation:**
- Build succeeds: `make build`
- No compilation errors
- Sheet presentation works in preview

**Estimated Effort:** 5 minutes

---

### 4. Add logout confirmation dialog

**File:** `PrototypeChatClientApp/Features/Chat/Presentation/Views/ConversationListView.swift`

**Description:**
Add confirmation dialog to prevent accidental logout.

**Steps:**
1. Add `.alert` modifier with logout confirmation
2. Include "キャンセル" and "ログアウト" buttons
3. Call `authViewModel.logout()` when confirmed

**Code Changes:**

Add after the menu sheet:
```swift
.alert("ログアウト", isPresented: $showLogoutConfirmation) {
    Button("キャンセル", role: .cancel) { }
    Button("ログアウト", role: .destructive) {
        authViewModel.logout()
    }
} message: {
    Text("ログアウトしますか？")
}
```

**Expected Outcome:**
- Confirmation dialog appears when logout is tapped
- Dialog has "キャンセル" and "ログアウト" buttons
- "ログアウト" is styled as destructive (red)
- Logout is executed only after confirmation

**Validation:**
- Build succeeds: `make build`
- No compilation errors
- Alert shows correct messaging

**Estimated Effort:** 5 minutes

---

### 5. Update MainView to pass authViewModel as EnvironmentObject

**File:** `PrototypeChatClientApp/Features/Authentication/Presentation/Views/MainView.swift`

**Description:**
Ensure authViewModel is passed to ConversationListView via `.environmentObject()`.

**Steps:**
1. Verify ConversationListView is already receiving environment objects
2. If not, add `.environmentObject(authViewModel)` modifier

**Code Changes:**

Update MainView body (if needed):
```swift
var body: some View {
    if let session = authViewModel.currentSession {
        ConversationListView(
            viewModel: ConversationListViewModel(
                conversationUseCase: container.conversationUseCase,
                currentUserId: session.userId
            )
        )
        .environmentObject(authViewModel)  // Add if not present
    } else {
        Text("セッションエラー")
    }
}
```

**Expected Outcome:**
- `authViewModel` is accessible in ConversationListView
- No runtime errors related to missing EnvironmentObject

**Validation:**
- Build succeeds: `make build`
- No runtime errors: `make run`

**Estimated Effort:** 3 minutes

---

### 6. Manual testing in simulator

**Description:**
Test the complete logout flow in the iOS simulator.

**Test Steps:**
1. Run app: `make run`
2. Login as `user-1` (Alice)
3. Verify conversation list loads
4. Tap the menu button (three horizontal lines) in the top-left
5. Verify NavigationMenuView opens in a sheet
6. Verify "ログアウト" option is displayed with red color
7. Tap "ログアウト"
8. Verify confirmation dialog appears with "ログアウトしますか？"
9. Tap "キャンセル" → Dialog closes, still logged in
10. Tap menu button again → Tap "ログアウト" → Tap "ログアウト" in dialog
11. Verify session is cleared
12. Verify app returns to login screen
13. Login as `user-2` (Bob) to confirm fresh session

**Error Scenarios to Test:**
1. Tap "閉じる" on menu → Sheet should close without logout
2. Tap outside alert → Alert should dismiss without logout
3. Rapid tapping → Should not cause multiple dialogs or crashes

**Expected Outcome:**
- All happy path steps work correctly
- Logout confirmation prevents accidental logout
- Session is properly cleared after logout
- App returns to login screen successfully
- No crashes or unexpected behavior

**Validation:**
- Take screenshots of key screens
- Document any issues or unexpected behavior
- Verify with different user accounts (user-1, user-2, user-3)

**Estimated Effort:** 15 minutes

---

### 7. Verify existing tests still pass

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

### 8. Update Preview providers

**File:** `PrototypeChatClientApp/Features/Chat/Presentation/Views/ConversationListView.swift`

**Description:**
Update the SwiftUI Preview to include authViewModel as EnvironmentObject.

**Steps:**
1. Update `ConversationListView_Previews`
2. Add `.environmentObject(mockAuthViewModel)`

**Code Changes:**

```swift
struct ConversationListView_Previews: PreviewProvider {
    static var previews: some View {
        let mockRepository = MockConversationRepository()
        // ... existing mock setup ...

        let useCase = ConversationUseCase(conversationRepository: mockRepository)
        let viewModel = ConversationListViewModel(conversationUseCase: useCase, currentUserId: "user1")

        // Add mock auth view model
        let container = DependencyContainer.makePreviewContainer()
        let authViewModel = container.authenticationViewModel
        authViewModel.isAuthenticated = true
        authViewModel.currentSession = AuthSession(
            userId: "user1",
            user: User(id: "user1", name: "Alice", avatarUrl: nil, createdAt: Date()),
            authenticatedAt: Date()
        )

        return ConversationListView(viewModel: viewModel)
            .environmentObject(authViewModel)
    }
}
```

**Expected Outcome:**
- Preview works in Xcode without errors
- Menu button is visible in preview
- Developers can preview the logout functionality

**Validation:**
- Open ConversationListView.swift in Xcode
- Preview renders without errors
- Tapping menu button in preview shows menu

**Estimated Effort:** 5 minutes

---

## Task Summary

| # | Task | Type | Effort | Dependencies |
|---|------|------|--------|--------------|
| 1 | Create NavigationMenuView | Code | 10 min | None |
| 2 | Add menu button to ConversationListView | Code | 10 min | None |
| 3 | Add menu sheet | Code | 5 min | Task 1, 2 |
| 4 | Add logout confirmation dialog | Code | 5 min | Task 2 |
| 5 | Update MainView | Code | 3 min | Task 2 |
| 6 | Manual testing | Test | 15 min | Task 1-5 |
| 7 | Verify existing tests | Test | 5 min | Task 1-5 |
| 8 | Update Preview | Code | 5 min | Task 1-5 |

**Total Estimated Time:** 58 minutes

---

## Parallel Execution

- Tasks 1 and 2 can be done in parallel
- Tasks 6, 7, 8 can all be done in parallel after Tasks 1-5 are complete

---

## Success Checklist

- [ ] NavigationMenuView component created and working
- [ ] Menu button appears in top-left of conversation list
- [ ] Tapping menu button opens NavigationMenuView
- [ ] Menu displays "ログアウト" option
- [ ] Tapping logout shows confirmation dialog
- [ ] Confirmation dialog has "キャンセル" and "ログアウト" buttons
- [ ] Canceling dismisses dialog without logout
- [ ] Confirming logout executes `authViewModel.logout()`
- [ ] After logout, app returns to login screen
- [ ] Session is cleared (can log in as different user)
- [ ] All existing tests pass (`make test`)
- [ ] App builds successfully (`make build`)
- [ ] Manual testing confirms all flows work
- [ ] Code follows project architecture patterns
- [ ] Previews work correctly in Xcode

---

## Rollback Plan

If issues are discovered:
1. The change is localized to UI layer
2. Revert NavigationMenuView file
3. Remove menu button from ConversationListView
4. Remove `.sheet` and `.alert` modifiers
5. Remove `@EnvironmentObject` declarations if they cause issues
6. No backend or data changes, so no migration needed
