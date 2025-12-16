# Tasks: Implement Group Chat UI

## Task List

### 1. Update CreateConversationViewModel for group chat support
**Description:** Add properties and methods to support both direct and group chat modes

**Changes:**
- Add `enum ConversationType { case direct, case group }`
- Add `@Published var conversationType: ConversationType = .direct`
- Add `@Published var selectedUserIds: Set<String> = []`
- Add `@Published var groupName: String = ""`
- Add method `func toggleUserSelection(_ userId: String)`
- Add method `func createGroupConversation() async`
- Update `canCreate` computed property to handle both modes

**Validation:**
- Unit tests for mode switching
- Unit tests for multi-user selection logic
- Unit tests for group chat validation rules

**Files:**
- `PrototypeChatClientApp/Features/Chat/Presentation/ViewModels/CreateConversationViewModel.swift`

---

### 2. Add unit tests for CreateConversationViewModel group chat logic
**Description:** Write comprehensive tests for new group chat functionality

**Test Cases:**
- Mode switching behavior
- User selection/deselection in group mode
- canCreate validation for direct mode (existing)
- canCreate validation for group mode (new)
  - False when < 2 users
  - False when group name empty
  - True when >= 2 users and valid group name
- createGroupConversation success flow
- createGroupConversation error handling

**Validation:**
- All tests pass
- Code coverage for new ViewModel code

**Files:**
- `PrototypeChatClientAppTests/Features/Chat/CreateConversationViewModelTests.swift` (new file)

---

### 3. Update CreateConversationView UI for mode selection
**Description:** Add segmented control for switching between Direct and Group modes

**Changes:**
- Add segmented Picker at top of view
- Bind to `viewModel.conversationType`
- Style appropriately for iOS

**Validation:**
- Manual testing: Toggle switches between modes
- UI appears correctly in both modes

**Files:**
- `PrototypeChatClientApp/Features/Chat/Presentation/Views/CreateConversationView.swift`

---

### 4. Add group name input field to CreateConversationView
**Description:** Show text field for group name when in Group mode

**Changes:**
- Add conditional TextField that appears when `conversationType == .group`
- Bind to `viewModel.groupName`
- Add placeholder "グループ名を入力"
- Style with `.textFieldStyle(.roundedBorder)`

**Validation:**
- Manual testing: Field appears/disappears when mode changes
- Text binding works correctly

**Files:**
- `PrototypeChatClientApp/Features/Chat/Presentation/Views/CreateConversationView.swift`

---

### 5. Update user list for multi-selection in group mode
**Description:** Modify user list to support multi-selection with visual feedback

**Changes:**
- Update list row UI to show checkmarks for selected users in group mode
- In Group mode: Tap toggles selection (add/remove from Set)
- In Direct mode: Maintain existing single-selection behavior
- Show selection count in group mode: "X人選択中"

**Validation:**
- Manual testing: Multi-selection works in group mode
- Visual feedback clear (checkmarks appear/disappear)
- Selection count updates correctly

**Files:**
- `PrototypeChatClientApp/Features/Chat/Presentation/Views/CreateConversationView.swift`

---

### 6. Wire up group chat creation action
**Description:** Connect "作成" button to group chat creation logic

**Changes:**
- Update `createConversation()` method to call appropriate ViewModel method based on mode
- Direct mode: Call `createDirectConversation()` (existing)
- Group mode: Call `createGroupConversation()` (new)

**Validation:**
- Manual testing: Group chat creation succeeds
- Navigate to created group chat room
- Verify participants are correct

**Files:**
- `PrototypeChatClientApp/Features/Chat/Presentation/Views/CreateConversationView.swift`

---

### 7. Update mock data and preview for group chat testing
**Description:** Ensure preview and mock data support group chat creation

**Changes:**
- Verify `MockConversationRepository` handles group type correctly
- Update preview data if needed

**Validation:**
- Xcode preview works for CreateConversationView
- Can test group chat creation in preview

**Files:**
- `PrototypeChatClientApp/Features/Chat/Data/Repositories/MockConversationRepository.swift`
- `PrototypeChatClientApp/Features/Chat/Presentation/Views/CreateConversationView.swift` (preview section)

---

### 8. End-to-end testing in simulator
**Description:** Manually test complete group chat creation flow

**Test Steps:**
1. Run app in simulator
2. Login with test user
3. Tap "+" to create new chat
4. Switch to "グループ" mode
5. Enter group name "Test Group"
6. Select 2+ users
7. Tap "作成"
8. Verify:
   - Group chat appears in conversation list
   - Group name displays correctly
   - All participants shown
   - Can send messages in group chat

**Validation:**
- Complete flow works without errors
- Group chat functions correctly

**Files:**
- N/A (manual testing)

---

## Dependency Graph

```
Task 1 (ViewModel logic)
  ├─→ Task 2 (Unit tests)
  └─→ Task 3 (Mode UI)
        └─→ Task 4 (Group name field)
              └─→ Task 5 (Multi-select UI)
                    └─→ Task 6 (Wire up action)
                          └─→ Task 7 (Mock data)
                                └─→ Task 8 (E2E testing)
```

**Critical Path:** 1 → 3 → 5 → 6 → 8

**Parallelizable:** Task 2 (unit tests) can be done in parallel with Tasks 3-6

---

## Estimated Effort

- Task 1: 30 minutes (ViewModel logic)
- Task 2: 45 minutes (Unit tests)
- Task 3: 15 minutes (Mode toggle UI)
- Task 4: 10 minutes (Group name field)
- Task 5: 30 minutes (Multi-select UI)
- Task 6: 15 minutes (Wire up action)
- Task 7: 10 minutes (Mock data)
- Task 8: 15 minutes (E2E testing)

**Total: ~2.5 hours**

---

## Success Criteria

- [ ] All unit tests pass
- [ ] Users can switch between Direct and Group modes
- [ ] Users can select multiple participants in Group mode
- [ ] Users can enter group name
- [ ] Create button validation works correctly for both modes
- [ ] Group chat creation succeeds and navigates to chat room
- [ ] No regressions in direct chat creation
- [ ] Code review approved
