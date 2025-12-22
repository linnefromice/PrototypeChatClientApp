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

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

This project uses a Makefile for all common development tasks. Run `make help` to see all available commands.

### Essential Commands

```bash
# Build and run app on simulator
make run

# Build only
make build

# Run unit tests
make test

# Clean build artifacts
make clean

# Open project in Xcode
make open
```

### Simulator Management

```bash
# List available simulators
make devices

# Boot simulator and install app
make boot
make install

# Launch app on running simulator
make launch

# View app logs in real-time
make logs

# Take screenshot
make screenshot
```

### Device Configuration

```bash
# Use specific device (default: iPhone 16)
DEVICE="iPhone 15 Pro" make run

# Use Debug or Release configuration (default: Debug)
CONFIGURATION=Release make build
```

### Package Management

```bash
# Resolve Swift Package dependencies
make resolve

# Update dependencies
make update

# Reset package cache
make reset-packages
```

## Project Architecture

### Layer Structure

The project follows **MVVM + Clean Architecture** with a multimodule-ready structure:

```
App/                    # Application layer - dependency injection, app entry point
Core/                   # Cross-cutting shared layer - entities/protocols used across features
Features/               # Feature modules - each feature follows Domain/Data/Presentation
Infrastructure/         # Infrastructure layer - network, storage (planned)
```

### Dependency Rules

**Allowed:**
- `Features/* → Core/*` (features can use shared entities)
- `App → Features/*` (app layer integrates features)
- `App → Core/*` (app can access shared code)

**Prohibited:**
- `Features/A → Features/B` (no direct feature-to-feature dependencies)
- `Core → Features/*` (shared layer cannot depend on features)
- `Infrastructure → Features/*` (infrastructure cannot depend on features)

### Entity Classification

**Cross-cutting Entities** (in `Core/Entities/`):
- `User.swift` - used across authentication, conversations, messages, profile
- Future: `Participant.swift` when adding conversation features

**Feature-specific Entities** (in `Features/*/Domain/Entities/`):
- `AuthSession.swift` - authentication feature only
- `AuthenticationError.swift` - authentication feature only
- Future: `Conversation.swift`, `Message.swift` in their respective features

### Dependency Injection

All dependencies are managed centrally in `App/DependencyContainer.swift`:

- Uses `@MainActor` for thread safety with ViewModels
- Implements lazy initialization pattern
- Singleton instance: `DependencyContainer.shared`
- Protocol-based design allows easy mocking for tests

**Important:** ViewModels must be initialized as lazy properties due to `@MainActor` requirements.

## Current Implementation Status

### Authentication Feature (✅ Implemented)

**BetterAuth Integration (Primary):**
- Username/password authentication
- Cookie-based session management (automatic via HTTPCookieStorage)
- User registration with email validation
- Session validation via backend API
- Automatic legacy session migration

**Legacy Support (Backward Compatibility):**
- ID Alias authentication still supported
- Automatic migration from UserDefaults to cookie-based sessions
- Test users: `user-1` (Alice), `user-2` (Bob), `user-3` (Charlie)

**Architecture:**
```
Presentation/
  - AuthenticationViewModel (@MainActor)
    - login(), register(), checkAuthentication()
  - AuthenticationView (username/password login)
  - RegistrationView (full registration form)
  - RootView (session validation on app start)
Domain/
  - AuthenticationUseCase
    - BetterAuth methods: register(), login(), validateSession()
    - Legacy: authenticate(idAlias:)
  - Entities: AuthSession, AuthenticationError
  - Repositories: AuthenticationRepositoryProtocol
Data/
  - DefaultAuthRepository (BetterAuth API integration)
  - MockAuthRepository (testing)
  - AuthSessionManager (cookie + UserDefaults management)
Infrastructure/
  - NetworkConfiguration (cookie-based URLSession)
```

**Session Management:**
- **Cookie-based**: Sessions managed via HTTPCookieStorage (automatic)
- **Legacy migration**: Old UserDefaults sessions automatically detected and migrated
- **Logout**: Clears both cookies and UserDefaults

**Test Users (MockAuthRepository):**
- alice / password123 → Alice
- bob / password123 → Bob
- charlie / password123 → Charlie

### API Connection (✅ Implemented)

**Authentication API:**
- **DefaultAuthRepository**: Real API implementation using BetterAuth
  - `POST /api/auth/sign-up/email` - User registration
  - `POST /api/auth/sign-in/username` - Login
  - `GET /api/auth/get-session` - Session validation
  - `POST /api/auth/sign-out` - Logout
- **Cookie Management**: Automatic via `NetworkConfiguration.session`
- **Error Handling**: 400/401/500 status codes with user-friendly messages

**Mock Repositories:**
- Still available for offline development and testing
- `MockAuthRepository`, `MockUserRepository`, etc.

**OpenAPI-Generated Client:**
- Apple's swift-openapi-generator for other APIs
- Generated client from OpenAPI spec
- Code generation in `Infrastructure/Network/Generated/`

See `Specs/Plans/API_LAYER_DESIGN_20251211_JA.md` for detailed design.

## Environment Configuration

### Backend URL Management

The app uses **Info.plist + Build Settings** to manage environment-specific backend URLs.

**Configuration Flow:**
```
Build Settings (BACKEND_URL) → Info.plist (BackendUrl) → Environment.backendUrl
```

**Current Setup:**
- **Development**: `http://localhost:8787` (requires local backend running)
- **Production**: `https://prototype-hono-drizzle-backend.linnefromice.workers.dev`

**Setup Instructions:**

1. **Add User-Defined Setting in Xcode:**
   - Project → Build Settings → `+` → Add User-Defined Setting
   - Name: `BACKEND_URL`
   - Debug: `http://localhost:8787`
   - Release: `https://prototype-hono-drizzle-backend.linnefromice.workers.dev`

2. **Verify Info.plist:**
   ```xml
   <key>BackendUrl</key>
   <string>$(BACKEND_URL)</string>
   ```

3. **Use in Code:**
   ```swift
   // Recommended
   let url = AppConfig.backendUrl

   // Legacy (still supported)
   let env = AppEnvironment.current
   let url = env.baseURL
   ```

**Debugging:**
```swift
#if DEBUG
AppConfig.printConfiguration()
// Output:
// 🔧 [Environment] Configuration:
//    Backend URL: http://localhost:8787
//    Environment: Development
//    Secure Context: false
#endif
```

**Command Line Usage:**

```bash
# Localhost backend (Debug)
make run-debug
# or
make run CONFIGURATION=Debug

# Production backend (Development)
make run-dev
# or
make run CONFIGURATION=Development

# Check current configuration
make info
```

**See Also:**
- Build configurations guide: `Docs/BUILD_CONFIGURATIONS.md`
- Environment setup: `Docs/ENVIRONMENT_SETUP.md`
- AppConfig struct: `Infrastructure/Environment/AppConfig.swift`

## Implementation Rules

### Critical: Always Build After Code Changes

**IMPORTANT:** After modifying any `*.swift` files, you MUST run `make build` to verify the changes compile successfully.

```bash
# After editing Swift files
make build

# If build fails, fix errors before proceeding
make clean
make build
```

This ensures:
- Code compiles without errors
- Dependencies are correctly resolved
- No syntax or type errors are introduced
- Changes integrate properly with existing code

## Adding New Features

When implementing a new feature:

1. Create feature directory: `Features/{FeatureName}/`
2. Follow the three-layer structure:
   ```
   Domain/
     Entities/       # Feature-specific models
     UseCases/       # Business logic
     Repositories/   # Repository protocols
   Data/
     Repositories/   # Repository implementations
     Local/          # Local data sources
   Presentation/
     ViewModels/     # @MainActor ViewModels
     Views/          # SwiftUI views
   ```
3. Determine if entities are cross-cutting or feature-specific:
   - Cross-cutting (used by 2+ features) → `Core/Entities/`
   - Feature-specific (used by 1 feature only) → `Features/{Name}/Domain/Entities/`
4. Add dependencies to `App/DependencyContainer.swift`
5. Register ViewModels as lazy properties in DependencyContainer
6. **Run `make build` to verify implementation**

## Testing

### Running Tests

```bash
# Run all tests
make test

# Run specific test in Xcode
xcodebuild test \
  -project PrototypeChatClientApp.xcodeproj \
  -scheme PrototypeChatClientApp \
  -destination "platform=iOS Simulator,name=iPhone 15" \
  -only-testing:PrototypeChatClientAppTests/AuthenticationUseCaseTests
```

### Test Structure

- Domain layer (UseCases, Entities): Priority for unit tests
- Data layer (Repositories, Managers): Mock external dependencies
- Presentation layer (ViewModels): Use `@MainActor` in test setup
- Mock implementations go in `Features/*/Data/Repositories/Mock*Repository.swift`

## iOS Configuration

- **Deployment Target:** iOS 16.0+
- **Swift Version:** 5.9+
- **Xcode:** 15.0+
- **Bundle ID:** `com.linnefromice.PrototypeChatClientApp`

## Backend Connection

- **Development:** `http://localhost:3000` (planned)
- **Production:** `https://prototype-hono-drizzle-backend.linnefromice.workers.dev`

## Future Multimodule Migration

The folder structure is prepared for Swift Package Manager modularization:

**Phase 1:** Extract Core modules (`CoreEntities`, `CoreProtocols`, `CoreExtensions`)
**Phase 2:** Extract Infrastructure modules (`InfrastructureNetwork`, `InfrastructureStorage`)
**Phase 3:** Extract Feature modules (`FeatureAuthentication`, `FeatureConversationList`, etc.)

See `Specs/Plans/MULTIMODULE_STRATEGY_20251211_JA.md` for detailed migration strategy.

## Design Documentation

Comprehensive design docs in `Specs/Plans/`:
- `MULTIMODULE_STRATEGY_20251211_JA.md` - Folder structure and module strategy
- `IOS_APP_ARCHITECTURE_20251211_JA.md` - Overall architecture and tech stack
- `API_LAYER_DESIGN_20251211_JA.md` - OpenAPI Generator integration plan
- `AUTH_DESIGN_20251211_JA.md` - Authentication flow and implementation
- `CLI_TOOLS_DESIGN_20251211_JA.md` - Makefile commands documentation

## Common Issues

### Build Errors
```bash
make clean
make build
```

### Simulator Issues
```bash
# Reset simulator
make reset

# Try different device
make devices
DEVICE="iPhone 15 Pro" make run
```

### Package Issues
```bash
make reset-packages
make resolve
```

### DerivedData Issues
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/PrototypeChatClientApp-*
make clean
make build
```

## Git Workflow

### Git Operations Policy

**CRITICAL:** Do NOT create commits or pull requests unless explicitly requested by the user.

- Only run `git add`, `git commit`, or `git push` when the user specifically asks
- Only create pull requests when the user explicitly requests it (e.g., `/ai-pr` command)
- If unclear whether to commit, ask the user first
- Focus on implementing features and fixes; let the user control when to commit

### Repository Information

- **Main branch:** `main`
- Build artifacts (`DerivedData/`, `build/`) are gitignored
- OpenAPI generated code (planned) will be in `.gitignore`
- Screenshots are gitignored
