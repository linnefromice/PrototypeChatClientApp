# Architecture Improvement Roadmap

## Phase 1: Critical Fixes (Week 1 - 4 hours)
Essential for architectural correctness before production.

### Issue #1: Missing UseCase Protocols
```
Objective: Make ViewModels testable
Files Affected: 4 UseCase classes + ViewModels
Effort: 2-3 hours

Tasks:
□ Create ConversationUseCaseProtocol.swift
□ Create MessageUseCaseProtocol.swift  
□ Create ReactionUseCaseProtocol.swift
□ Create UserListUseCaseProtocol.swift
□ Update ConversationListViewModel
□ Update ChatRoomViewModel
□ Update CreateConversationViewModel
□ Update DependencyContainer

Expected Outcome:
- All UseCases have protocols
- ViewModels depend on protocols
- Test mocks can be injected
- ViewModel tests become possible
```

### Issue #2: ConversationRepositoryProtocol Location
```
Objective: Follow documented architecture rules
Files Affected: 1 protocol + 5 imports
Effort: 1-2 hours

Tasks:
□ Move file to Features/Chat/Domain/Repositories/
□ Update import in ConversationUseCase.swift
□ Update import in DependencyContainer.swift
□ Update import in ConversationRepository.swift
□ Update import in MockConversationRepository.swift
□ Update imports in test files

Expected Outcome:
- Core layer only has cross-cutting concerns
- Chat feature owns its protocols
- Architecture rules followed
- No functional changes
```

### Issue #3: @MainActor Consistency
```
Objective: Ensure thread safety
Files Affected: 2 ViewModel classes
Effort: 30 minutes

Tasks:
□ Add @MainActor to ConversationListViewModel
□ Remove @MainActor from its methods
□ Add @MainActor to CreateConversationViewModel
□ Remove @MainActor from its methods
□ Verify tests use @MainActor

Expected Outcome:
- All ViewModels have @MainActor
- No method-level duplicates
- Thread safety guaranteed
- No behavior changes
```

---

## Phase 2: Testability & Maintainability (Weeks 2-3 - 8 hours)
Improve code coverage and reduce maintenance burden.

### Issue #4: Missing ViewModel Tests
```
Objective: Achieve 60%+ test coverage in Presentation layer
Effort: 4-6 hours

Tasks:
□ Create ConversationListViewModelTests.swift
  - loadConversations() behavior
  - Error handling
  - Title/subtitle formatting
□ Expand ChatRoomViewModelTests.swift
  - Message loading and sorting
  - Sending messages
  - Reaction operations
  - Error states
□ Expand CreateConversationViewModelTests.swift
  - User selection logic
  - Conversation creation
  - Validation

Expected Outcome:
- 40+ new test methods
- ViewModel behavior verified
- Regressions caught early
- Refactoring confidence
```

### Issue #5: Component Extraction
```
Objective: Improve build times and code reusability
Reference: REFACTORING_ANALYSIS_20251212.md (Phase 1)
Effort: 3-4 hours

Tasks:
□ Extract EmptyStateView.swift
  - Create Components/EmptyStateView.swift
  - Update ConversationListView
  - Update CreateConversationView
  - Add preview

□ Extract ConversationRowView.swift
  - Create Components/ConversationRowView.swift
  - Remove from ConversationListView
  - Add preview
  - Add unit tests

□ Extract UserSelectionRowView.swift
  - Create Components/UserSelectionRowView.swift
  - Remove from CreateConversationView
  - Add preview

Expected Outcome:
- ~50 lines duplicate code eliminated
- Preview compilation 30-50% faster
- Better component reusability
- Clear view hierarchy
```

### Issue #6: Validation Logic Standardization
```
Objective: DRY principle - eliminate duplicated validation
Effort: 2-3 hours

Tasks:
□ Create Infrastructure/Validation/Validators.swift
  - EmailValidator protocol
  - UUIDValidator (extract from ConversationUseCase)
  - StringLengthValidator
  - Regex constants

□ Update AuthenticationUseCase
  - Use validators instead of inline validation

□ Update ConversationUseCase
  - Use UUIDValidator

□ Add unit tests for validators

Expected Outcome:
- Single source of truth for validation
- Easier to modify rules (change in one place)
- Better testability
- Cleaner UseCase code
```

---

## Phase 3: Code Quality (Month 2 - 6 hours)
Improve error handling consistency and test coverage.

### Issue #7: Error Type Consistency
```
Objective: Feature-specific error types
Effort: 2 hours

Create:
□ Features/Chat/Domain/Entities/ConversationError.swift
  - invalidParticipantIds
  - duplicateConversation
  - maxParticipantsExceeded

□ Features/Chat/Domain/Entities/ReactionError.swift
  - cannotReactToOwnMessage
  - invalidEmoji
  - reactionAlreadyExists

Update:
□ ConversationUseCase to throw ConversationError
□ ReactionUseCase to throw ReactionError
□ ViewModel error handling

Expected Outcome:
- Clear error semantics
- Type-safe error handling
- Better error categorization
- Consistent pattern across features
```

### Issue #8: Additional Test Coverage
```
Objective: Increase domain layer coverage
Effort: 4-6 hours

Add Tests:
□ UserListUseCaseTests.swift
□ Repository error handling tests
□ NetworkConfiguration tests
□ APIClientFactory tests
□ DTO mapping tests
□ DateTranscoder edge cases

Expected Outcome:
- 80%+ domain layer coverage
- 60%+ overall coverage
- Critical paths tested
- Regression prevention
```

### Issue #9: Performance Optimization
```
Objective: Minor performance improvements
Effort: 1 hour

Tasks:
□ Cache URLSession in NetworkConfiguration
□ Evaluate redundant userId parameter removal
□ Optimize async mappings
□ Profile initialization time

Expected Outcome:
- Fewer object allocations
- Consistent URLSession reference
- Cleaner API signatures
- No behavioral changes
```

---

## Phase 4: Strategic (Month 3+ - Research & Planning)
Prepare for scaling and future modularization.

### Issue #10: Multimodule Preparation
```
Objective: Enable SPM modularization
Reference: MULTIMODULE_STRATEGY_20251211_JA.md
Effort: Research phase

Tasks:
□ Document feature boundaries
□ Verify no cross-feature dependencies
□ Create FeatureCoordinator patterns if needed
□ Plan Phase 1: CoreEntities, CoreProtocols
□ Plan Phase 2: Infrastructure modules
□ Plan Phase 3: Feature modules

Expected Outcome:
- Clear path to SPM modules
- No technical blockers identified
- Team documentation
- Ready for Phase 1 implementation
```

### Issue #11: State Management Enhancement (Optional)
```
Objective: Scalability for 50k+ LOC
Effort: Future research

Options:
□ Evaluate The Composable Architecture (TCA)
□ Custom Redux-like pattern
□ Current pattern enhancements
□ Async/await coordination patterns

Note: Not needed for current prototype
      Revisit at ~30k LOC

Expected Outcome:
- Decision documented
- Pilot implementation if chosen
- Team aligned on approach
```

### Issue #12: Integration Testing Setup (Future)
```
Objective: Test against real backend
Effort: After backend stabilizes

Tasks:
□ Create test backend configuration
□ Integration test suite
□ Mock server for CI
□ E2E scenario tests

Expected Outcome:
- Full system validation
- Regression detection
- Production confidence
```

---

## Timeline & Resource Allocation

### Week 1: Critical Fixes
```
Monday-Wednesday: Implement Phase 1 (4 hours)
- UseCase protocols
- Fix @MainActor
- Move ConversationRepositoryProtocol
- Run full test suite
- Verify no regressions

Estimated End State:
- All architecture rules followed
- 0 CRITICAL issues remaining
- Ready for production
```

### Weeks 2-3: Testability & Refactoring
```
Monday-Friday Week 2: Phase 2 Part A (4 hours)
- Component extraction
- ViewModel tests

Monday-Friday Week 3: Phase 2 Part B (4 hours)
- Validation standardization
- Test cleanup

Estimated End State:
- 60%+ test coverage
- Faster build times
- Better code reusability
```

### Month 2: Quality Improvements
```
Week 1: Error types & additional tests (4 hours)
Week 2: Performance optimization (1 hour)
Week 3: Code review & documentation (1 hour)

Estimated End State:
- 75%+ test coverage
- Consistent error handling
- Performance baseline established
```

### Month 3+: Strategic Planning
```
Ongoing research and planning
- SPM modularization strategy
- State management evaluation
- Integration test framework

No immediate implementation needed
```

---

## Success Metrics

### Architecture Quality
- [ ] All architecture rules followed (100%)
- [ ] All layers properly separated
- [ ] No circular dependencies
- [ ] Clear feature boundaries

### Code Quality
- [ ] 75%+ test coverage (domain + presentation)
- [ ] 0 CRITICAL issues
- [ ] 0 architecture violations
- [ ] Consistent error handling

### Performance
- [ ] Build time baseline established
- [ ] No major performance regressions
- [ ] Startup time < 1 second (with mock data)

### Team Readiness
- [ ] Architecture documentation clear
- [ ] Future developers can onboard in < 2 hours
- [ ] Rules enforcement documented
- [ ] Extension patterns clear

---

## Dependencies & Blockers

### No External Blockers
- All fixes are internal refactoring
- No backend changes required
- Can be done incrementally
- No feature development paused

### Internal Dependencies
```
Phase 1 → Phase 2 (critical path)
  Week 1 protocols must exist for Week 2 tests

Phase 2 → Phase 3 (loose coupling)
  Can be done in parallel after protocols exist

Phase 3 → Phase 4 (no dependency)
  Can start anytime
```

---

## Risk Assessment

| Phase | Risk | Mitigation |
|-------|------|-----------|
| 1 | Low | All refactoring, comprehensive tests exist |
| 2 | Low | Component extraction is additive |
| 3 | Low | Performance changes are backward compatible |
| 4 | None | Planning only, no implementation |

---

## Post-Completion Verification

### Phase 1 Checklist
- [ ] All tests pass
- [ ] No compiler warnings
- [ ] Code review complete
- [ ] Architecture rules documented in code

### Phase 2 Checklist
- [ ] New tests pass
- [ ] Coverage metrics improved
- [ ] Build time measured
- [ ] Preview rendering confirmed

### Phase 3 Checklist
- [ ] Additional tests pass
- [ ] Performance baseline established
- [ ] Error handling consistent
- [ ] Documentation updated

### Phase 4 Checklist
- [ ] Strategy documented
- [ ] Team alignment achieved
- [ ] No blockers identified
- [ ] Planning approved

---

**Version**: 1.0  
**Created**: 2025-12-22  
**Last Updated**: 2025-12-22  
**Owner**: Architecture Review  
**Status**: Ready for Implementation

