# Proposal: Implement Group Chat UI

## Overview

Add group chat creation functionality to the iOS client UI. The domain layer (`ConversationUseCase.createGroupConversation`) and data layer already support group chat creation, but the presentation layer currently only supports direct (1:1) chat creation.

## Problem

Users cannot create group chats through the UI because:
1. `CreateConversationView` only allows selecting a single user
2. `CreateConversationViewModel` only has `createDirectConversation()` method
3. No UI for entering group name
4. No UI for selecting multiple participants

## Proposed Solution

Extend the existing `CreateConversationView` and `CreateConversationViewModel` to support both direct and group chat creation modes:

1. Add a segmented control to toggle between "Direct" and "Group" modes
2. In Group mode:
   - Allow multi-selection of users
   - Show a text field for group name input
   - Display selected user count
3. Update ViewModel to handle group chat creation
4. Add validation for group chat requirements (minimum 2 participants, group name required)

## Scope

**In Scope:**
- Update `CreateConversationViewModel` to support group chat creation
- Update `CreateConversationView` UI for multi-user selection and group name input
- Add validation logic for group chat requirements
- Add unit tests for new ViewModel logic

**Out of Scope:**
- Backend API changes (already implemented)
- ConversationRepository changes (already implemented)
- Group chat display in conversation list (already works via existing code)
- Group chat settings/management after creation

## Impact

**User Impact:**
- Users can create group chats with multiple participants
- Users can name their group chats

**Technical Impact:**
- Minimal - extends existing patterns without breaking changes
- No database schema changes required
- No API changes required

## Alternatives Considered

1. **Create separate GroupChatCreationView**: Rejected because it duplicates logic and navigation complexity
2. **Bottom sheet for group name**: Rejected to keep UX simple and all inputs visible

## Dependencies

None - all required backend and domain logic already exists.

## Risks

- Low risk: Leverages existing tested domain layer
- UI complexity slightly increased with mode toggle

## Success Criteria

- [ ] Users can toggle between Direct and Group chat modes
- [ ] Users can select multiple participants for group chats
- [ ] Users can enter a group name
- [ ] Group chat creation succeeds and navigates to chat room
- [ ] Validation prevents invalid group chat creation (e.g., no participants, no name)
- [ ] All unit tests pass
