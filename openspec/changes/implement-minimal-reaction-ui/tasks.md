# Tasks: Implement Minimal Reaction UI

## Overview

This task list implements a minimal reaction UI on top of the existing domain/data layer. The focus is on simplicity and core functionality, with 6 whitelisted emojis and minimal dynamic behavior.

## Task List

---

### Task 1: Create ReactionPickerView component

**Description:** Build a simple emoji picker with 6 hardcoded emojis displayed in a grid

**Changes:**
- Create `Features/Chat/Presentation/Views/Components/ReactionPickerView.swift`
- Display 6 emojis in a 2×3 grid:
  - Row 1: 👍, ❤️, 😂
  - Row 2: 😮, 🎉, 🔥
- Each emoji is a tappable button (44×44pt minimum)
- On tap: call completion handler with selected emoji
- Styling: Simple grid with spacing, no fancy animations
- Use SwiftUI `GridView` with fixed columns

**Validation:**
- Component compiles without errors
- Preview shows 6 emojis in grid
- Tapping emoji calls callback
- Emojis are large enough for touch targets

**Files:**
- `Features/Chat/Presentation/Views/Components/ReactionPickerView.swift` (new)

**Estimated Time:** 30 minutes

---

### Task 2: Create ReactionSummaryView component

**Description:** Build component to display reaction pills below messages

**Changes:**
- Create `Features/Chat/Presentation/Views/Components/ReactionSummaryView.swift`
- Input parameters:
  - `summaries: [ReactionSummary]` - reaction data
  - `currentUserId: String` - to highlight user's reactions
  - `onTap: (String) -> Void` - callback when pill tapped
- Display: Horizontal flow layout (wrapping if needed)
- Pill styling:
  - Rounded capsule shape
  - Gray background (default)
  - Blue/accent background if `summary.hasUser(currentUserId)` is true
  - Content: "{emoji} {count}" (e.g., "👍 3")
  - Padding: 8pt horizontal, 4pt vertical
- Tap gesture: call `onTap` with emoji

**Validation:**
- Component compiles without errors
- Preview shows various reaction states
- User's reactions have different background
- Tapping pill calls callback
- Layout wraps correctly with many reactions

**Files:**
- `Features/Chat/Presentation/Views/Components/ReactionSummaryView.swift` (new)

**Estimated Time:** 45 minutes

---

### Task 3: Update MessageBubbleView to integrate reactions

**Description:** Add reaction display and picker to existing message bubbles

**Changes:**
- Modify `Features/Chat/Presentation/Views/MessageBubbleView.swift`
- Add new parameters:
  - `reactions: [ReactionSummary]?` (optional, default nil)
  - `currentUserId: String?` (optional, for highlighting)
  - `onReactionTap: ((String) -> Void)?` (callback)
  - `onAddReaction: ((String) -> Void)?` (callback)
  - `showReactionPicker: Bool = false` (control picker visibility)
- Add `ReactionSummaryView` below message text (if reactions not empty)
- Add `.contextMenu` with `ReactionPickerView` on long-press
  - Alternative: Use `.sheet` or `.popover` if context menu doesn't work well
- Maintain existing layout and styling

**Validation:**
- Messages without reactions display unchanged
- Messages with reactions show `ReactionSummaryView`
- Long-press opens reaction picker
- Selecting emoji calls `onAddReaction`
- Tapping reaction pill calls `onReactionTap`
- No layout regressions

**Files:**
- `Features/Chat/Presentation/Views/MessageBubbleView.swift` (modified)

**Estimated Time:** 40 minutes

---

### Task 4: Update ChatRoomViewModel for reaction management

**Description:** Add reaction state and business logic to ViewModel

**Changes:**
- Modify `Features/Chat/Presentation/ViewModels/ChatRoomViewModel.swift`
- Add property: `@Published var messageReactions: [String: [Reaction]] = [:]`
  - Key: messageId, Value: array of reactions
- Inject `ReactionUseCase` via initializer
  - Add parameter: `reactionUseCase: ReactionUseCase`
  - Store as private property
- Add methods:
  - `func addReaction(to messageId: String, emoji: String) async`
    - Call `reactionUseCase.addReaction(messageId:userId:emoji:)`
    - Update `messageReactions[messageId]`
    - Handle errors with `errorMessage`
  - `func removeReaction(from messageId: String, emoji: String) async`
    - Call `reactionUseCase.removeReaction(messageId:userId:emoji:)`
    - Update `messageReactions[messageId]`
    - Handle errors
  - `func toggleReaction(on messageId: String, emoji: String) async`
    - Check if user has reacted with this emoji
    - Call `addReaction` or `removeReaction` accordingly
  - `func reactionSummaries(for messageId: String) -> [ReactionSummary]`
    - Get reactions from `messageReactions[messageId]`
    - Call `reactionUseCase.computeSummaries(reactions:currentUserId:)`
    - Return sorted summaries
- Update `loadMessages()` to also load reactions
  - For now, initialize with empty array (no GET endpoint)
  - Document limitation with TODO comment

**Validation:**
- ViewModel compiles without errors
- Can add/remove reactions
- `@Published` properties trigger UI updates
- Error handling works
- Summaries are computed correctly

**Files:**
- `Features/Chat/Presentation/ViewModels/ChatRoomViewModel.swift` (modified)

**Estimated Time:** 60 minutes

---

### Task 5: Update ChatRoomView to wire reactions

**Description:** Connect reaction UI to ViewModel in main chat view

**Changes:**
- Modify `Features/Chat/Presentation/Views/ChatRoomView.swift`
- Update `MessageBubbleView` instantiation to pass:
  - `reactions: viewModel.reactionSummaries(for: message.id)`
  - `currentUserId: viewModel.currentUserId`
  - `onReactionTap: { emoji in Task { await viewModel.toggleReaction(on: message.id, emoji: emoji) } }`
  - `onAddReaction: { emoji in Task { await viewModel.addReaction(to: message.id, emoji: emoji) } }`
- Ensure UI updates when `viewModel.messageReactions` changes

**Validation:**
- Reactions display for messages
- Long-press opens picker
- Selecting emoji adds reaction
- Tapping reaction toggles it
- UI updates automatically
- No crashes or errors

**Files:**
- `Features/Chat/Presentation/Views/ChatRoomView.swift` (modified)

**Estimated Time:** 30 minutes

---

### Task 6: Update DependencyContainer to inject ReactionUseCase

**Description:** Register reaction dependencies in dependency injection container

**Changes:**
- Modify `App/DependencyContainer.swift`
- Add lazy property:
  ```swift
  lazy var reactionRepository: ReactionRepositoryProtocol = {
      MockReactionRepository() // or ReactionRepository(client: client) for production
  }()
  ```
- Add lazy property:
  ```swift
  lazy var reactionUseCase: ReactionUseCase = {
      ReactionUseCase(reactionRepository: reactionRepository)
  }()
  ```
- Update `chatRoomViewModel` factory to inject `reactionUseCase`:
  ```swift
  func makeChatRoomViewModel(...) -> ChatRoomViewModel {
      ChatRoomViewModel(
          ...,
          reactionUseCase: reactionUseCase
      )
  }
  ```
- Ensure `@MainActor` requirements are met

**Validation:**
- Dependencies resolve correctly
- App compiles without errors
- Injection works in ChatRoomView
- No circular dependencies

**Files:**
- `App/DependencyContainer.swift` (modified)

**Estimated Time:** 20 minutes

---

### Task 7: Manual testing in simulator

**Description:** End-to-end verification of reaction feature

**Test Steps:**
1. Run `make build` to compile
2. Run `make run` to launch simulator
3. Login with test user (e.g., `user-1`)
4. Navigate to a conversation with messages
5. Long-press a message → verify picker appears with 6 emojis
6. Select 👍 → verify reaction appears below message
7. Verify reaction shows "👍 1" with blue background (user's reaction)
8. Tap the 👍 reaction → verify it disappears (removed)
9. Add 👍 again → verify it reappears
10. Add ❤️ to same message → verify both reactions show
11. Switch to different message, add 🎉 → verify reactions are per-message
12. Pull to refresh → verify reactions persist
13. Test error handling: disconnect network, try to add reaction → verify error message

**Validation:**
- All steps pass without crashes
- UI is responsive
- Reactions add/remove correctly
- Error messages display when network fails
- No visual glitches

**Files:**
- N/A (manual testing)

**Estimated Time:** 30 minutes

---

## Dependency Graph

```
Task 1 (ReactionPickerView)
  │
  ├─→ Task 3 (Update MessageBubbleView)
  │      │
  │      └─→ Task 5 (Update ChatRoomView)
  │             │
  │             └─→ Task 7 (Manual Testing)
  │
Task 2 (ReactionSummaryView)
  │
  └─→ Task 3 (Update MessageBubbleView)

Task 4 (Update ChatRoomViewModel)
  │
  ├─→ Task 5 (Update ChatRoomView)
  │
  └─→ Task 6 (Update DependencyContainer)
         │
         └─→ Task 7 (Manual Testing)
```

**Critical Path:** 1 → 2 → 3 → 4 → 5 → 6 → 7

**Parallelizable:**
- Tasks 1 and 2 can be built in parallel
- Task 4 can be started independently and merged later

---

## Estimated Effort

- **Task 1:** 30 minutes
- **Task 2:** 45 minutes
- **Task 3:** 40 minutes
- **Task 4:** 60 minutes
- **Task 5:** 30 minutes
- **Task 6:** 20 minutes
- **Task 7:** 30 minutes

**Total: ~3.5 hours**

---

## Success Criteria

- [ ] All tasks completed
- [ ] App builds without errors (`make build`)
- [ ] Reaction picker displays 6 emojis
- [ ] Reactions appear below messages
- [ ] User can add reactions
- [ ] User can remove their reactions
- [ ] Reaction counts are accurate
- [ ] User's reactions are visually distinct
- [ ] Error handling works for network failures
- [ ] No crashes during manual testing
- [ ] Code follows MVVM + Clean Architecture pattern

---

## Future Enhancements (Out of Scope)

- Real-time reaction updates
- More emojis / custom emoji selection
- Reaction animations
- Detailed reaction list (who reacted)
- Accessibility improvements
- Comprehensive unit tests
- Optimistic UI updates
- Reaction notifications
