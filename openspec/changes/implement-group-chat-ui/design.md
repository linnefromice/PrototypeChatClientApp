# Design: Implement Group Chat UI

## Architecture Overview

The implementation extends existing presentation layer components while reusing the fully implemented domain layer.

```
┌─────────────────────────────────────┐
│  CreateConversationView (UI)       │
│  - Mode toggle (Direct/Group)      │
│  - Multi-select UI                 │
│  - Group name input                │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  CreateConversationViewModel        │
│  - selectedUserIds: Set<String>     │
│  - groupName: String                │
│  - conversationType: enum           │
│  - createGroupConversation()        │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  ConversationUseCase (existing)     │
│  - createGroupConversation()        │ ✅ Already implemented
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  ConversationRepository (existing)  │
│  - createConversation(type, ids)    │ ✅ Already implemented
└─────────────────────────────────────┘
```

## UI/UX Design

### Mode Selection
```
┌─────────────────────────────────────┐
│  新しいチャット               [×]   │
├─────────────────────────────────────┤
│  ┌──────────┬──────────┐            │
│  │ ダイレクト │ グループ  │            │
│  └──────────┴──────────┘            │
├─────────────────────────────────────┤
│  [User selection UI]                │
└─────────────────────────────────────┘
```

### Direct Mode (現状維持)
- Single selection (radio button style)
- "作成" button enabled when 1 user selected

### Group Mode (新規)
- Multi-selection (checkmark style)
- Group name text field at top
- Selected user count display: "3人選択中"
- "作成" button enabled when:
  - At least 2 users selected
  - Group name is not empty

## Component Changes

### CreateConversationViewModel

**New Properties:**
```swift
enum ConversationType {
    case direct
    case group
}

@Published var conversationType: ConversationType = .direct
@Published var selectedUserIds: Set<String> = []
@Published var groupName: String = ""
```

**Modified Properties:**
- `selectedUserId: String?` → Keep for direct mode backward compatibility

**New Methods:**
```swift
func createGroupConversation() async
func toggleUserSelection(_ userId: String)
func clearSelections()
```

**Modified Computed Properties:**
```swift
var canCreate: Bool {
    switch conversationType {
    case .direct:
        return selectedUserId != nil && !isLoading
    case .group:
        return selectedUserIds.count >= 2
            && !groupName.trimmingCharacters(in: .whitespaces).isEmpty
            && !isLoading
    }
}
```

### CreateConversationView

**New UI Elements:**
1. **Segmented Control:**
   ```swift
   Picker("Type", selection: $viewModel.conversationType) {
       Text("ダイレクト").tag(ConversationType.direct)
       Text("グループ").tag(ConversationType.group)
   }
   .pickerStyle(.segmented)
   ```

2. **Group Name TextField (conditional):**
   ```swift
   if viewModel.conversationType == .group {
       TextField("グループ名", text: $viewModel.groupName)
           .textFieldStyle(.roundedBorder)
   }
   ```

3. **User List (modified):**
   - Direct mode: Single selection with radio button visual
   - Group mode: Multi-selection with checkmarks

4. **Selection Count (conditional):**
   ```swift
   if viewModel.conversationType == .group {
       Text("\(viewModel.selectedUserIds.count)人選択中")
           .font(.caption)
           .foregroundColor(.secondary)
   }
   ```

## Data Flow

### Direct Chat Creation (existing flow)
```
User taps user → selectedUserId set → canCreate = true
→ User taps 作成 → createDirectConversation()
→ ConversationUseCase.createDirectConversation()
```

### Group Chat Creation (new flow)
```
User switches to Group mode → conversationType = .group
→ User enters group name → groupName set
→ User taps users → selectedUserIds updated → canCreate evaluates
→ User taps 作成 → createGroupConversation()
→ ConversationUseCase.createGroupConversation()
```

## Validation Rules

### Direct Chat
- Exactly 1 user must be selected
- No additional validation needed

### Group Chat
- Minimum 2 users selected (excluding current user)
- Group name must not be empty or whitespace-only
- Group name length: 1-100 characters (enforced by UI)

## Error Handling

- **No users selected (Group):** "参加者を2人以上選択してください"
- **Empty group name:** "グループ名を入力してください"
- **API errors:** Use existing error handling pattern from `createDirectConversation()`

## Testing Strategy

### Unit Tests (ViewModel)

1. **Mode switching:**
   - Test conversationType toggle clears selections appropriately

2. **Direct mode validation:**
   - canCreate = false when no user selected
   - canCreate = true when 1 user selected

3. **Group mode validation:**
   - canCreate = false with 0-1 users
   - canCreate = false with empty group name
   - canCreate = true with 2+ users and valid group name

4. **User selection:**
   - toggleUserSelection adds/removes from Set
   - clearSelections empties Set

5. **Group chat creation:**
   - Success case creates conversation and sets createdConversation
   - Error case shows error message

### UI Tests (optional, manual)

1. Mode toggle works
2. Multi-selection visual feedback
3. Group name text field appears/disappears
4. Selection count updates correctly
5. Create button enables/disables appropriately

## Backward Compatibility

- Existing direct chat functionality remains unchanged
- Default mode is `.direct` to preserve current UX
- `selectedUserId` property kept for direct mode
- No changes to existing API contracts

## Performance Considerations

- Set operations for selectedUserIds are O(1) for add/remove
- UI updates are efficient (SwiftUI automatic diffing)
- No new network calls beyond existing createConversation API

## Accessibility

- Segmented control has clear labels
- Selected state clearly indicated visually
- Error messages are readable by VoiceOver
- All interactive elements have accessibility labels

## Future Enhancements (Out of Scope)

1. Group avatar/icon selection
2. Maximum participant limit enforcement
3. Group admin role assignment at creation
4. Search/filter users for large user lists
5. Preset user groups (favorites, teams)
