# Proposal: Implement Minimal Reaction UI

## Problem Statement

The chat application currently lacks a way for users to react to messages with emojis. While the domain and data layers for reactions are already implemented (entities, repositories, use cases), there is no user interface to:
- Display reactions on messages
- Allow users to add reactions to messages
- Remove reactions they've added

This creates a functional gap where the backend capability exists but users cannot interact with it.

## Proposed Solution

Implement a **minimal, whitelist-based reaction UI** that allows users to react to messages using a predefined set of 6 emojis. This approach prioritizes:

1. **Simplicity**: Hardcoded emoji list, minimal dynamic behavior
2. **Functionality**: Core add/remove reaction flow working end-to-end
3. **Foundation**: Base implementation that can be enhanced later

### Key Design Decisions

**Whitelisted Emojis (6 total):**
- 👍 (Thumbs Up)
- ❤️ (Red Heart)
- 😂 (Laughing Face)
- 😮 (Surprised Face)
- 🎉 (Party Popper)
- 🔥 (Fire)

**UI Approach:**
- Static emoji picker (no search, no custom emojis)
- Simple pill-style reaction display
- Context menu for adding reactions (long-press message)
- Tap reaction to toggle on/off
- No animations initially
- No real-time updates (manual refresh)

**Leverages Existing Implementation:**
- `Reaction` and `ReactionSummary` domain entities (already exist)
- `ReactionRepositoryProtocol` and implementations (already exist)
- `ReactionUseCase` with aggregation logic (already exists)
- OpenAPI endpoints for POST/DELETE reactions (already defined)

## Scope

### In Scope

**UI Components:**
- Simple reaction picker view (6 emojis in a grid)
- Reaction summary display (pills below message)
- Integration with `MessageBubbleView`
- Integration with `ChatRoomViewModel` and `ChatRoomView`

**Functionality:**
- Add reaction via long-press context menu
- Remove reaction by tapping existing reaction
- Display reaction counts
- Highlight user's own reactions
- Basic error handling

**Infrastructure:**
- Update `DependencyContainer` to inject reaction dependencies
- Wire ViewModel to use existing `ReactionUseCase`

### Out of Scope (Future Enhancements)

- Custom emoji selection
- Emoji search
- Real-time reaction updates (websockets/polling)
- Reaction animations
- Reaction history/who reacted
- More than 6 emojis
- Skin tone variations
- Comprehensive unit tests (only basic ViewModel tests)
- Accessibility enhancements (VoiceOver, Dynamic Type)

## Dependencies

### Existing Code (Already Implemented)
- ✅ `Features/Chat/Domain/Entities/Reaction.swift`
- ✅ `Features/Chat/Domain/Entities/ReactionSummary.swift`
- ✅ `Features/Chat/Domain/Repositories/ReactionRepositoryProtocol.swift`
- ✅ `Features/Chat/Domain/UseCases/ReactionUseCase.swift`
- ✅ `Infrastructure/Network/DTOs/ReactionDTO+Mapping.swift`
- ✅ `Infrastructure/Network/Repositories/ReactionRepository.swift`
- ✅ `Features/Chat/Data/Repositories/MockReactionRepository.swift`

### Code to Create
- 🆕 `Features/Chat/Presentation/Views/Components/ReactionPickerView.swift`
- 🆕 `Features/Chat/Presentation/Views/Components/ReactionSummaryView.swift`
- 🔧 Modify `Features/Chat/Presentation/Views/MessageBubbleView.swift`
- 🔧 Modify `Features/Chat/Presentation/ViewModels/ChatRoomViewModel.swift`
- 🔧 Modify `Features/Chat/Presentation/Views/ChatRoomView.swift`
- 🔧 Modify `App/DependencyContainer.swift`

### External Dependencies
- OpenAPI backend with existing endpoints:
  - `POST /messages/{id}/reactions` (add reaction)
  - `DELETE /messages/{id}/reactions/{emoji}` (remove reaction)
  - Note: No GET endpoint - reactions fetched via message list

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| No GET endpoint for reactions | High - Cannot fetch reactions independently | Use `MockReactionRepository` for now; document limitation; consider embedding reactions in Message entity |
| Static emoji list may feel limited | Low - 6 emojis covers common use cases | Document as MVP; plan expansion in future iteration |
| No real-time updates | Medium - Reactions won't appear instantly | Use pull-to-refresh; document as known limitation |
| Performance with many reactions | Low - Minimal expected at launch | Monitor; optimize aggregation if needed |
| UI/UX may need iteration | Low - Simple design reduces complexity | Get user feedback; plan refinements |

## Success Criteria

- [ ] Users can long-press message to see reaction picker
- [ ] Users can select emoji to add reaction
- [ ] Reactions appear below messages as pills
- [ ] User's own reactions are visually distinct
- [ ] Tapping reaction removes it (if user's own)
- [ ] Reaction counts are accurate
- [ ] App compiles and runs without crashes
- [ ] Basic error handling works (network failures)
- [ ] Code follows existing MVVM + Clean Architecture patterns

## Timeline Estimate

**Total: ~3.5 hours**

- UI Components: 1.5 hours
- ViewModel Integration: 1 hour
- DependencyContainer + Testing: 1 hour

This is significantly faster than the full 11-hour comprehensive proposal because:
- Domain/data layers already done
- No unit tests required initially
- Minimal UI (no animations, accessibility, etc.)
- No custom emoji picker complexity

## Alternatives Considered

1. **Full implementation (18 tasks, 11 hours)** - Rejected: Too complex for MVP
2. **Text-based reactions (e.g., ":thumbs_up:")** - Rejected: Less intuitive UX
3. **Single reaction type** - Rejected: Too limiting even for MVP
4. **Emoji keyboard integration** - Rejected: Too complex, unpredictable UX

## Notes

- This proposal assumes `implement-message-reactions` domain/data tasks 1-6 are complete
- Focus on "make it work" before "make it perfect"
- Future iterations can add animations, real-time updates, more emojis, etc.
- Consider user feedback before expanding scope
