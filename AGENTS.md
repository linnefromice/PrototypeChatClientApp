<!-- OPENSPEC:START -->
# OpenSpec Instructions

These instructions are for AI assistants working in this project.

Always open `@/openspec/AGENTS.md` when the request:
- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/openspec/AGENTS.md` to learn:
- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

Keep this managed block so 'openspec update' can refresh the instructions.

<!-- OPENSPEC:END -->

# Documentation Structure

This project maintains a clear separation between design specifications and supporting documentation.

## Directory Structure

```
Specs/                  # Design Master - Single Source of Truth
├── README.md           # Documentation index and navigation
└── *.md                # Latest design specifications (no dates)

Docs/
├── Plans/              # Future plans and proposals
├── History/            # Analysis reports (with dates: *_YYYYMMDD.md)
└── Manuals/            # Setup guides and procedures

CLAUDE.md               # AI assistant instructions (tool-specific)
AGENTS.md               # This file (tool-specific)
openspec/               # OpenSpec workflow files (tool-specific)
```

## Documentation Categories

### Specs/ - Design Master
**Purpose:** Single source of truth for current design
**Rules:**
- Always contains the latest design specifications
- No date suffixes in filenames
- Update when architecture or features change
- Examples: `IOS_APP_ARCHITECTURE.md`, `AUTH_DESIGN.md`

### Docs/Plans/ - Future Plans
**Purpose:** Proposals and future roadmaps
**Rules:**
- Future improvement plans
- Proposals not yet implemented
- Examples: `CI_CD_ENVIRONMENT_PROPOSAL.md`, `COMPREHENSIVE_IMPROVEMENTS.md`

### Docs/History/ - Analysis & Reports
**Purpose:** Time-stamped analysis and investigation reports
**Rules:**
- All files include date suffix: `*_YYYYMMDD.md`
- Archive of past investigations
- Examples: `ARCHITECTURE_ANALYSIS_20251222.md`, `REFACTORING_COST_ESTIMATION_20251223.md`

### Docs/Manuals/ - Setup Guides
**Purpose:** Step-by-step procedures and guides
**Rules:**
- Setup instructions
- Configuration guides
- Troubleshooting procedures
- Examples: `BUILD_CONFIGURATIONS.md`, `ENVIRONMENT_SETUP.md`

## AI Assistant Responsibilities

### After Modifying Swift Files

When you modify `*.swift` files, **always check** if documentation needs updates:

1. **Check Specs/** if changes affect:
   - Architecture or layer structure
   - Feature design or API contracts
   - Module dependencies
   - Build system or environment configuration

2. **Check Docs/Manuals/** if changes affect:
   - Setup procedures
   - Build configurations
   - Environment settings
   - Development workflows

3. **Verification Steps:**
   ```bash
   # After Swift file modifications
   make build  # Always verify compilation

   # Then check documentation
   # - Does Specs/ reflect the new design?
   # - Do Manuals/ need procedure updates?
   ```

### Documentation Update Workflow

1. **Design Changes** → Update `Specs/*.md`
   - Remove outdated information
   - Add new design details
   - Keep files current and date-free

2. **Analysis/Investigation** → Create `Docs/History/*_YYYYMMDD.md`
   - New analysis reports
   - Investigation results
   - Always include date suffix

3. **Future Plans** → Create/Update `Docs/Plans/*.md`
   - Proposals
   - Roadmaps
   - Not-yet-implemented features

4. **Procedure Changes** → Update `Docs/Manuals/*.md`
   - Setup changes
   - New configuration steps
   - Workflow modifications

## Quick Reference

| Change Type | Update Location | Filename Format |
|-------------|----------------|-----------------|
| Architecture design | `Specs/` | No date |
| Feature design | `Specs/` | No date |
| Setup procedure | `Docs/Manuals/` | No date |
| Analysis report | `Docs/History/` | `*_YYYYMMDD.md` |
| Future proposal | `Docs/Plans/` | Optional date |

For complete documentation index, see `Specs/README.md`.