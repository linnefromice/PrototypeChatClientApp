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

**Mock authentication flow:**
- User ID input only (no password)
- Calls `GET /users/{userId}` to validate user
- Stores session in UserDefaults
- Test users: `user-1` (Alice), `user-2` (Bob), `user-3` (Charlie)

**Architecture:**
```
Presentation/
  - AuthenticationViewModel (@MainActor)
  - AuthenticationView, RootView, MainView
Domain/
  - AuthenticationUseCase
  - Entities: AuthSession, AuthenticationError
Data/
  - MockUserRepository (for offline development)
  - AuthSessionManager (UserDefaults persistence)
```

### API Connection (⏳ Planned)

Currently using mock repositories. Future implementation will use:
- Apple's swift-openapi-generator
- Generated client from OpenAPI spec
- Code generation in `Infrastructure/Network/Generated/`

See `Specs/Plans/API_LAYER_DESIGN_20251211_JA.md` for detailed design.

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

- **Main branch:** `main`
- Build artifacts (`DerivedData/`, `build/`) are gitignored
- OpenAPI generated code (planned) will be in `.gitignore`
- Screenshots are gitignored
