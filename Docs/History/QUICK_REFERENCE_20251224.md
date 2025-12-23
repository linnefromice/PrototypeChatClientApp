# Quick Reference: Improvement Priorities

## 🚨 CRITICAL - Fix First (Week 1)
Start with these 4 hours to unblock everything else.

### #1: Missing UseCase Protocols (2-3 hours)
**Files to create:**
- `Features/Chat/Domain/Repositories/ConversationUseCaseProtocol.swift`
- `Features/Chat/Domain/Repositories/MessageUseCaseProtocol.swift`
- `Features/Chat/Domain/Repositories/ReactionUseCaseProtocol.swift`
- `Features/Chat/Domain/Repositories/UserListUseCaseProtocol.swift`

**Files to update:**
- `Features/Chat/Presentation/ViewModels/ConversationListViewModel.swift`
- `Features/Chat/Presentation/ViewModels/ChatRoomViewModel.swift`
- `Features/Chat/Presentation/ViewModels/CreateConversationViewModel.swift`
- `App/DependencyContainer.swift`

**Why**: Makes ViewModels testable, enables mock injection in tests

---

### #2: ConversationRepositoryProtocol Location (1-2 hours)
**Move from:**
```
Core/Protocols/Repository/ConversationRepositoryProtocol.swift ❌
```

**Move to:**
```
Features/Chat/Domain/Repositories/ConversationRepositoryProtocol.swift ✅
```

**Update imports in:**
- `Features/Chat/Domain/UseCases/ConversationUseCase.swift`
- `App/DependencyContainer.swift`
- `Infrastructure/Network/Repositories/ConversationRepository.swift`
- `Features/Chat/Data/Repositories/MockConversationRepository.swift`
- Test files

**Why**: Follows documented architecture rules, prevents Core bloat

---

### #3: Add @MainActor Decorators (15 minutes)
**Add to these ViewModels:**
```swift
@MainActor
final class ConversationListViewModel: ObservableObject { ... }

@MainActor
final class CreateConversationViewModel: ObservableObject { ... }
```

**Files:**
- `Features/Chat/Presentation/ViewModels/ConversationListViewModel.swift`
- `Features/Chat/Presentation/ViewModels/CreateConversationViewModel.swift`

**Why**: Thread safety, consistency with other ViewModels

---

## 📈 HIGH VALUE - Do Next (Weeks 2-3)
12 hours of improvements that significantly enhance maintainability.

### #4: Add ViewModel Tests (4-6 hours)
Missing test coverage for:
- `ConversationListViewModel.loadConversations()`
- `ChatRoomViewModel.loadMessages()` and `sendMessage()`
- `CreateConversationViewModel` form validation

**Test gaps**: 15+ missing test methods

---

### #5: Extract Error Handling Pattern (2 hours)
**Create:** `Core/Extensions/ViewModelErrorHandling.swift`

Eliminates ~50 lines of duplicate error handling code found in:
- `ChatRoomViewModel`
- `ConversationListViewModel`
- `CreateConversationViewModel` (multiple methods)

---

### #6: Centralize Validation Logic (2 hours)
**Create:** `Infrastructure/Validation/Validators.swift`

Extract duplicate validation:
- UUID pattern used in `ConversationUseCase`
- IdAlias pattern used in `AuthenticationUseCase`
- Email/String validators

---

### #7: Unify Error Types (3-4 hours)
**Create:** `Core/Error/ViewModelError.swift`

Replace scattered error handling:
- `AuthenticationError` (auth-specific)
- `NetworkError` (infrastructure)
- `MessageError` (feature-specific)

---

## 🎯 NICE TO HAVE - Future (Weeks 4+)
UX improvements and advanced patterns (8+ hours).

### #8: Retry Functionality (3-4 hours)
Add retry methods to ViewModels:
```swift
func retry() async { ... }
```

Update error alerts to include "Retry" button.

---

### #9: Loading State Feedback (2-3 hours)
Add visual feedback for:
- Message sending
- Conversation creation
- User list loading

---

### #10: Success Toast Notifications (2-3 hours)
Add feedback for:
- Message sent
- Reaction added
- Conversation created

---

## 📊 ESTIMATED TIMELINE

| Phase | Hours | Timeline | Outcome |
|-------|-------|----------|---------|
| 1: Critical | 4 | Week 1 | Architecture fixed, unblocks testing |
| 2: Quality | 12 | Weeks 2-3 | 60% test coverage, code cleaner |
| 3: UX | 8 | Week 4 | Better user experience |
| 4: Advanced | 10+ | Week 5+ | Navigation coordination, integration tests |

**Total**: 40-50 hours over 4-6 weeks

---

## ⚠️ IMPLEMENTATION TIPS

### Order matters:
1. Always start with #1-3 (Critical)
2. Then do #4-7 (High-Value) in any order
3. Save #8-10 for polish

### Testing strategy:
- Unit test #4 additions thoroughly
- Run `make test` after each change
- Use `make build` to catch compilation errors

### Git workflow:
- Commit each category separately
- One commit per protocol/file moved
- Test before committing

### Risk mitigation:
- Create branch for Phase 1
- Test thoroughly after protocol changes
- Run full test suite before merging

---

## 🔍 QUICK VALIDATION CHECKLIST

After implementing Phase 1, verify:
- [ ] All ViewModels have `@MainActor`
- [ ] All UseCase classes have protocol definitions
- [ ] ConversationRepositoryProtocol in Features/Chat/Domain/Repositories/
- [ ] DependencyContainer imports updated
- [ ] Project builds without errors: `make build`
- [ ] All tests pass: `make test`

---

## 📚 REFERENCE DOCUMENTS

- **Full Analysis**: `COMPREHENSIVE_IMPROVEMENTS_20251223.md`
- **Architecture Details**: `ARCHITECTURE_ANALYSIS_20251222.md`
- **Detailed Roadmap**: `IMPROVEMENT_ROADMAP.md`
- **Project Guidelines**: `../../CLAUDE.md`

---

Generated: December 23, 2025
