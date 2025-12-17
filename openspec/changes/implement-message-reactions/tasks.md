# Tasks: Implement Message Reactions

## Task List

### Phase 1: Domain Layer (3 tasks)

---

#### Task 1: Create Reaction and ReactionSummary entities

**Description:** Define domain entities for reactions and their aggregated summaries

**Changes:**
- Create `Features/Chat/Domain/Entities/Reaction.swift`
  - `Reaction` struct with fields: id, messageId, userId, emoji, createdAt
  - Conformance to `Identifiable`, `Equatable`, `Codable`
- Create `Features/Chat/Domain/Entities/ReactionSummary.swift`
  - `ReactionSummary` struct with fields: emoji, count, userIds
  - Helper method: `hasUser(_:)` to check if a user reacted

**Validation:**
- Entities compile without errors
- Can create instances in tests
- Codable conformance works for API serialization

**Files:**
- `Features/Chat/Domain/Entities/Reaction.swift` (new)
- `Features/Chat/Domain/Entities/ReactionSummary.swift` (new)

---

#### Task 2: Define ReactionRepositoryProtocol

**Description:** Create protocol for reaction data access

**Changes:**
- Create `Features/Chat/Domain/Repositories/ReactionRepositoryProtocol.swift`
- Define methods:
  - `fetchReactions(messageId:) async throws -> [Reaction]`
  - `addReaction(messageId:userId:emoji:) async throws -> Reaction`
  - `removeReaction(messageId:userId:emoji:) async throws`

**Validation:**
- Protocol compiles
- Protocol can be adopted by concrete implementations
- Method signatures match OpenAPI schema

**Files:**
- `Features/Chat/Domain/Repositories/ReactionRepositoryProtocol.swift` (new)

---

#### Task 3: Implement ReactionUseCase

**Description:** Create business logic layer for managing reactions

**Changes:**
- Create `Features/Chat/Domain/UseCases/ReactionUseCase.swift`
- Inject `ReactionRepositoryProtocol` via initializer
- Implement methods:
  - `addReaction(messageId:userId:emoji:) async throws -> Reaction`
  - `removeReaction(messageId:userId:emoji:) async throws`
  - `fetchReactions(messageId:) async throws -> [Reaction]`
  - `computeSummaries(reactions:currentUserId:) -> [ReactionSummary]`
- Aggregation logic: Group reactions by emoji, count users, sort by count descending

**Validation:**
- Use case compiles
- Can be initialized with repository
- Business logic is testable

**Files:**
- `Features/Chat/Domain/UseCases/ReactionUseCase.swift` (new)

---

### Phase 2: Data Layer (3 tasks)

---

#### Task 4: Create DTO mapping extensions

**Description:** Map OpenAPI-generated DTOs to domain entities

**Changes:**
- Create `Infrastructure/Network/DTOs/ReactionDTO+Extensions.swift`
- Extension on `Components.Schemas.Reaction`:
  - `toDomain() -> Reaction` method
  - Parse ISO8601 date string to `Date`
- Extension on `Components.Schemas.ReactionRequest`:
  - `static func from(userId:emoji:) -> Self`

**Validation:**
- Extensions compile
- Date parsing works correctly
- DTOs map to domain entities without data loss

**Files:**
- `Infrastructure/Network/DTOs/ReactionDTO+Extensions.swift` (new)

---

#### Task 5: Implement ReactionRepository (real API)

**Description:** Create repository that calls OpenAPI client

**Changes:**
- Create `Infrastructure/Network/Repositories/ReactionRepository.swift`
- Inject OpenAPI `Client` via initializer
- Implement `ReactionRepositoryProtocol`:
  - `fetchReactions`: Call API (determine endpoint - may need to check if reactions are embedded in messages or separate endpoint)
  - `addReaction`: Call `POST /messages/{id}/reactions` with `ReactionRequest` body
  - `removeReaction`: Call `DELETE /messages/{id}/reactions/{emoji}?userId={userId}`
- Follow existing error handling pattern from `MessageRepository`
- Log errors with context for debugging

**Validation:**
- Repository compiles
- Can make API calls using OpenAPI client
- Error handling matches existing pattern
- DTOs are correctly mapped

**Files:**
- `Infrastructure/Network/Repositories/ReactionRepository.swift` (new)

---

#### Task 6: Implement MockReactionRepository

**Description:** Create mock repository for offline development and testing

**Changes:**
- Create `Features/Chat/Data/Repositories/MockReactionRepository.swift`
- In-memory storage: `var reactions: [String: [Reaction]]` (messageId → reactions)
- Implement `ReactionRepositoryProtocol`:
  - `fetchReactions`: Return from in-memory storage
  - `addReaction`: Create reaction with mock ID, store in memory, return it
  - `removeReaction`: Remove from in-memory storage
- Add `var shouldThrowError: Error?` for testing error scenarios

**Validation:**
- Mock repository compiles
- Can be used in tests without network calls
- Error simulation works

**Files:**
- `Features/Chat/Data/Repositories/MockReactionRepository.swift` (new)

---

### Phase 3: Unit Tests (3 tasks)

---

#### Task 7: Write ReactionUseCase unit tests

**Description:** Test business logic for reaction management

**Test Cases:**
- `test_addReaction_success()` - Verify use case calls repository and returns reaction
- `test_addReaction_propagatesError()` - Verify errors are propagated
- `test_removeReaction_success()` - Verify use case calls repository
- `test_removeReaction_propagatesError()` - Verify errors are propagated
- `test_fetchReactions_success()` - Verify reactions are fetched and returned
- `test_computeSummaries_aggregatesCorrectly()` - Verify reactions are grouped by emoji
- `test_computeSummaries_sortsbyCountDescending()` - Verify most popular reactions first
- `test_computeSummaries_identifiesCurrentUser()` - Verify `hasUser` works correctly
- `test_computeSummaries_emptyReactions()` - Verify empty input returns empty array

**Validation:**
- All tests pass
- Code coverage >80% for ReactionUseCase
- Mock repository is used (no real API calls)

**Files:**
- `PrototypeChatClientAppTests/Features/Chat/Domain/UseCases/ReactionUseCaseTests.swift` (new)

---

#### Task 8: Write ReactionRepository unit tests

**Description:** Test API integration for reaction repository

**Test Cases:**
- `test_fetchReactions_returnsMappedDomain()` - Verify DTOs are mapped correctly
- `test_fetchReactions_handlesNetworkError()` - Verify network errors are handled
- `test_addReaction_callsCorrectEndpoint()` - Verify API call is made
- `test_addReaction_returnsCreatedReaction()` - Verify created reaction is returned
- `test_addReaction_handlesError()` - Verify error handling
- `test_removeReaction_callsCorrectEndpoint()` - Verify DELETE is called
- `test_removeReaction_handlesError()` - Verify error handling

**Validation:**
- All tests pass
- Mock OpenAPI client is used
- Error scenarios are covered

**Files:**
- `PrototypeChatClientAppTests/Infrastructure/Network/Repositories/ReactionRepositoryTests.swift` (new)

---

#### Task 9: Write MockReactionRepository unit tests

**Description:** Test mock repository implementation

**Test Cases:**
- `test_fetchReactions_returnsInMemoryData()` - Verify in-memory storage works
- `test_addReaction_storesInMemory()` - Verify reactions are stored
- `test_removeReaction_removesFromMemory()` - Verify deletion works
- `test_errorSimulation_throwsConfiguredError()` - Verify error injection works

**Validation:**
- All tests pass
- Mock repository is fully tested

**Files:**
- `PrototypeChatClientAppTests/Features/Chat/Data/Repositories/MockReactionRepositoryTests.swift` (new)

---

### Phase 4: Presentation Layer - Views (4 tasks)

---

#### Task 10: Create ReactionSummaryView component

**Description:** Create UI component to display reaction summaries

**Changes:**
- Create `Features/Chat/Presentation/Views/ReactionSummaryView.swift`
- Input: Array of `ReactionSummary`, current user ID, callbacks for tap
- Display: Horizontal scroll of reaction pills
- Styling:
  - Pill shape with rounded corners
  - Gray background for others' reactions
  - Blue/accent background for user's own reactions
  - Emoji + count layout (e.g., "👍 3")
- Tap gesture: Call callback with emoji

**Validation:**
- View compiles
- Preview shows various reaction states
- Tap gestures work
- Styling matches iOS design guidelines

**Files:**
- `Features/Chat/Presentation/Views/ReactionSummaryView.swift` (new)

---

#### Task 11: Create ReactionPickerView component

**Description:** Create emoji picker UI for selecting reactions

**Changes:**
- Create `Features/Chat/Presentation/Views/ReactionPickerView.swift`
- Display: Grid of 12 common emojis (2 rows × 6 columns)
- Emojis: 👍, ❤️, 😂, 😮, 😢, 🎉, 👏, 🔥, ✨, 🙏, 👀, 🚀
- Tap gesture: Call callback with selected emoji, dismiss picker
- Styling: iOS context menu style with blur background

**Validation:**
- View compiles
- Preview shows emoji grid
- Tap gestures work
- Emojis are large enough (44x44pt minimum)

**Files:**
- `Features/Chat/Presentation/Views/ReactionPickerView.swift` (new)

---

#### Task 12: Update MessageBubbleView to display reactions

**Description:** Integrate ReactionSummaryView into existing message bubbles

**Changes:**
- Modify `Features/Chat/Presentation/Views/MessageBubbleView.swift`
- Add parameters:
  - `reactions: [ReactionSummary]` (optional)
  - `onReactionTap: (String) -> Void` callback
  - `onReactionPickerSelect: (String) -> Void` callback
- Add `ReactionSummaryView` below message text
- Add `.contextMenu` with `ReactionPickerView` on long press
- Maintain existing layout and styling

**Validation:**
- Messages without reactions display unchanged
- Messages with reactions show summary
- Long press opens reaction picker
- Tap on reaction calls callback
- No layout issues or visual regressions

**Files:**
- `Features/Chat/Presentation/Views/MessageBubbleView.swift` (modified)

---

#### Task 13: Add accessibility support to reaction views

**Description:** Ensure reaction UI is accessible

**Changes:**
- Add `.accessibilityLabel` to ReactionSummaryView pills
  - Example: "3 people reacted with thumbs up, including you"
- Add `.accessibilityLabel` to ReactionPickerView emojis
  - Example: "Thumbs up", "Red heart"
- Add `.accessibilityAddTraits(.isButton)` to tappable elements
- Test with VoiceOver enabled
- Ensure Dynamic Type support

**Validation:**
- VoiceOver announces reactions correctly
- Emoji names are announced in picker
- Tap gestures work with VoiceOver
- Text scales with Dynamic Type

**Files:**
- `Features/Chat/Presentation/Views/ReactionSummaryView.swift` (modified)
- `Features/Chat/Presentation/Views/ReactionPickerView.swift` (modified)

---

### Phase 5: ViewModel Integration (2 tasks)

---

#### Task 14: Update ChatRoomViewModel for reactions

**Description:** Integrate reaction management into chat room ViewModel

**Changes:**
- Modify `Features/Chat/Presentation/ViewModels/ChatRoomViewModel.swift`
- Add property: `@Published var reactions: [String: [Reaction]] = [:]`
- Inject `ReactionUseCase` via initializer
- Add methods:
  - `loadReactions(for messageId: String) async`
  - `addReaction(to messageId: String, emoji: String) async`
  - `removeReaction(from messageId: String, emoji: String) async`
  - `reactionSummary(for messageId: String) -> [ReactionSummary]`
- Update `loadMessages()` to also fetch reactions for each message
- Handle errors with `@Published var errorMessage: String?`

**Validation:**
- ViewModel compiles
- Can load reactions for messages
- Add/remove reactions update state
- `@Published` properties trigger UI updates

**Files:**
- `Features/Chat/Presentation/ViewModels/ChatRoomViewModel.swift` (modified)

---

#### Task 15: Update ChatRoomView to use reactions

**Description:** Connect reaction UI to ViewModel

**Changes:**
- Modify `Features/Chat/Presentation/Views/ChatRoomView.swift`
- Pass reaction data to `MessageBubbleView`:
  - `reactions: viewModel.reactionSummary(for: message.id)`
  - `onReactionTap: { emoji in Task { await viewModel.addReaction(to: message.id, emoji: emoji) } }`
  - `onReactionPickerSelect: { emoji in Task { await viewModel.addReaction(to: message.id, emoji: emoji) } }`
- Handle remove reaction: Check if user has reacted, call `removeReaction` instead

**Validation:**
- Reactions display for messages
- Long press opens picker
- Tapping reaction adds/removes it
- UI updates automatically

**Files:**
- `Features/Chat/Presentation/Views/ChatRoomView.swift` (modified)

---

### Phase 6: Testing and Integration (3 tasks)

---

#### Task 16: Write ChatRoomViewModel reaction tests

**Description:** Test ViewModel reaction logic

**Test Cases:**
- `test_loadReactions_updatesState()` - Verify reactions are loaded
- `test_addReaction_callsUseCase()` - Verify use case is called
- `test_addReaction_updatesPublishedState()` - Verify state updates
- `test_removeReaction_callsUseCase()` - Verify use case is called
- `test_removeReaction_updatesPublishedState()` - Verify state updates
- `test_reactionSummary_computesCorrectly()` - Verify aggregation works
- `test_addReaction_handlesError()` - Verify error handling

**Validation:**
- All tests pass
- MockReactionUseCase is used
- State updates are verified

**Files:**
- `PrototypeChatClientAppTests/Features/Chat/Presentation/ViewModels/ChatRoomViewModelTests.swift` (modified)

---

#### Task 17: Update DependencyContainer for reactions

**Description:** Register reaction dependencies in DI container

**Changes:**
- Modify `App/DependencyContainer.swift`
- Add lazy property: `var reactionRepository: ReactionRepositoryProtocol`
  - Use `ReactionRepository` for production
  - Use `MockReactionRepository` for previews/tests
- Add lazy property: `var reactionUseCase: ReactionUseCase`
  - Inject `reactionRepository`
- Update `chatRoomViewModel` to inject `reactionUseCase`

**Validation:**
- Dependencies resolve correctly
- App compiles and runs
- Reactions work in simulator

**Files:**
- `App/DependencyContainer.swift` (modified)

---

#### Task 18: End-to-end testing in simulator

**Description:** Manually verify complete reaction feature

**Test Steps:**
1. Run app in simulator
2. Login with test user
3. Open a conversation with messages
4. Long press a message → verify picker appears
5. Select emoji → verify reaction appears
6. Tap reaction → verify it removes
7. Add reaction again → verify count increments
8. Test with multiple emojis
9. Switch users, verify reactions persist
10. Test offline behavior (if implemented)

**Validation:**
- Complete flow works without errors
- Reactions persist across app restarts
- UI is responsive and smooth
- No crashes or visual glitches

**Files:**
- N/A (manual testing)

---

## Dependency Graph

```
Phase 1: Domain Layer
  Task 1 (Entities)
    └→ Task 2 (Protocol)
         └→ Task 3 (UseCase)

Phase 2: Data Layer
  Task 3 (UseCase) + OpenAPI schema
    └→ Task 4 (DTO mappings)
         ├→ Task 5 (Real Repository)
         └→ Task 6 (Mock Repository)

Phase 3: Unit Tests
  Task 3 (UseCase) + Task 6 (Mock Repo)
    └→ Task 7 (UseCase Tests)
  Task 5 (Real Repo)
    └→ Task 8 (Repository Tests)
  Task 6 (Mock Repo)
    └→ Task 9 (Mock Repo Tests)

Phase 4: Presentation Views
  Task 1 (Entities)
    ├→ Task 10 (ReactionSummaryView)
    └→ Task 11 (ReactionPickerView)
         └→ Task 12 (Update MessageBubbleView)
              └→ Task 13 (Accessibility)

Phase 5: ViewModel Integration
  Task 3 (UseCase) + Task 12 (MessageBubbleView)
    └→ Task 14 (Update ChatRoomViewModel)
         └→ Task 15 (Update ChatRoomView)

Phase 6: Testing and Integration
  Task 14 (ChatRoomViewModel)
    └→ Task 16 (ViewModel Tests)
  Task 15 (ChatRoomView) + Dependencies
    └→ Task 17 (DependencyContainer)
         └→ Task 18 (E2E Testing)
```

**Critical Path:** 1 → 2 → 3 → 4 → 5 → 10 → 11 → 12 → 14 → 15 → 17 → 18

**Parallelizable:**
- Tasks 7, 8, 9 (all unit tests) can run in parallel after their dependencies
- Tasks 10, 11 (view components) can be built in parallel
- Task 13 (accessibility) can overlap with Task 14

---

## Estimated Effort

- **Phase 1 (Domain)**: 1.5 hours
  - Task 1: 20 minutes
  - Task 2: 15 minutes
  - Task 3: 50 minutes

- **Phase 2 (Data)**: 2 hours
  - Task 4: 30 minutes
  - Task 5: 60 minutes
  - Task 6: 30 minutes

- **Phase 3 (Tests)**: 2 hours
  - Task 7: 60 minutes
  - Task 8: 40 minutes
  - Task 9: 20 minutes

- **Phase 4 (Views)**: 2.5 hours
  - Task 10: 45 minutes
  - Task 11: 40 minutes
  - Task 12: 50 minutes
  - Task 13: 25 minutes

- **Phase 5 (ViewModel)**: 1.5 hours
  - Task 14: 60 minutes
  - Task 15: 30 minutes

- **Phase 6 (Integration)**: 1.5 hours
  - Task 16: 45 minutes
  - Task 17: 20 minutes
  - Task 18: 25 minutes

**Total: ~11 hours**

---

## Success Criteria

- [ ] All domain entities and use cases implemented
- [ ] Repository protocol and implementations (real + mock) working
- [ ] All unit tests pass (>80% code coverage)
- [ ] Reaction picker UI displays correctly
- [ ] Reactions appear below messages
- [ ] Add/remove reaction functionality works
- [ ] Reactions persist across app restarts
- [ ] Accessibility support (VoiceOver, Dynamic Type)
- [ ] No performance degradation in message scrolling
- [ ] No crashes or visual glitches
- [ ] Code review approved
- [ ] E2E manual testing passed
