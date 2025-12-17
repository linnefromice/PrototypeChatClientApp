# Tasks: Update Login to Use ID Alias

## Phase 1: OpenAPI Specification and Code Generation

### Task 1: Update OpenAPI specification with idAlias field
**Description**: Add `idAlias` field to User schema in `openapi.yaml`

**Steps**:
1. Open `PrototypeChatClientApp/openapi.yaml`
2. Locate the `User` schema under `components.schemas`
3. Add `idAlias` property with pattern validation:
   ```yaml
   idAlias:
     type: string
     pattern: '^[a-z0-9][a-z0-9._-]*[a-z0-9]$'
     minLength: 3
     maxLength: 30
     description: 'Unique human-readable identifier for login'
   ```
4. Add `idAlias` to the `required` array
5. Save the file

**Validation**: Run `grep -A 5 "idAlias:" PrototypeChatClientApp/openapi.yaml` to verify the field is added

**Dependencies**: None

---

### Task 2: Add login endpoint to OpenAPI specification
**Description**: Define `POST /users/login` endpoint in `openapi.yaml`

**Steps**:
1. Add `LoginRequest` schema under `components.schemas`:
   ```yaml
   LoginRequest:
     type: object
     properties:
       idAlias:
         type: string
         pattern: '^[a-z0-9][a-z0-9._-]*[a-z0-9]$'
         minLength: 3
         maxLength: 30
     required:
       - idAlias
   ```
2. Add `/users/login` endpoint under `paths`:
   ```yaml
   /users/login:
     post:
       summary: Login user by ID alias
       requestBody:
         required: true
         content:
           application/json:
             schema:
               $ref: '#/components/schemas/LoginRequest'
       responses:
         '200':
           description: User found
           content:
             application/json:
               schema:
                 $ref: '#/components/schemas/User'
         '400':
           description: Bad request - invalid idAlias format
         '404':
           description: User not found
   ```
3. Save the file

**Validation**: Run `grep -A 10 "/users/login:" PrototypeChatClientApp/openapi.yaml` to verify

**Dependencies**: Task 1

---

### Task 3: Regenerate OpenAPI client code
**Description**: Run OpenAPI generator to create new Swift types and client methods

**Steps**:
1. Run `make build` to trigger OpenAPI code generation (integrated into build process)
2. Verify no compilation errors occur
3. Check that generated code includes:
   - `Components.Schemas.User` with `idAlias` property
   - `Components.Schemas.LoginRequest`
   - `Operations.post_sol_users_sol_login` method

**Validation**: Build succeeds and generated types are available

**Dependencies**: Task 2

---

## Phase 2: Domain Layer Updates

### Task 4: Update User entity with idAlias field
**Description**: Add `idAlias` property to the `User` struct in `Core/Entities/User.swift`

**Steps**:
1. Open `PrototypeChatClientApp/Core/Entities/User.swift`
2. Add `let idAlias: String` property after `id`
3. Update initializer if needed (struct will auto-generate memberwise init)
4. Update any existing User creation code to include `idAlias`

**Example**:
```swift
struct User: Codable, Identifiable, Equatable {
    let id: String
    let idAlias: String  // NEW
    let name: String
    let avatarUrl: String?
    let createdAt: Date
}
```

**Validation**: Build succeeds; `User` conforms to `Codable`, `Identifiable`, `Equatable`

**Dependencies**: Task 3

---

### Task 5: Update UserDTO mapping to include idAlias
**Description**: Update `toDomain()` method in `UserDTO+Mapping.swift` to map `idAlias` field

**Steps**:
1. Open `Infrastructure/Network/DTOs/UserDTO+Mapping.swift`
2. Update the `toDomain()` extension method:
   ```swift
   extension Components.Schemas.User {
       func toDomain() -> User {
           User(
               id: id,
               idAlias: idAlias,  // NEW
               name: name,
               avatarUrl: avatarUrl,
               createdAt: createdAt
           )
       }
   }
   ```
3. Save the file

**Validation**: Build succeeds; no type mismatches

**Dependencies**: Task 4

---

## Phase 3: Repository Layer Updates

### Task 6: Add loginByIdAlias method to UserRepositoryProtocol
**Description**: Extend `UserRepositoryProtocol` with new login method

**Steps**:
1. Open `Core/Protocols/Repository/UserRepositoryProtocol.swift`
2. Add new method signature:
   ```swift
   func loginByIdAlias(_ idAlias: String) async throws -> User
   ```
3. Save the file

**Validation**: Build fails until all implementations are updated (expected)

**Dependencies**: Task 5

---

### Task 7: Implement loginByIdAlias in UserRepository
**Description**: Add real API implementation for login in `UserRepository.swift`

**Steps**:
1. Open `Infrastructure/Network/Repositories/UserRepository.swift`
2. Implement the new method:
   ```swift
   func loginByIdAlias(_ idAlias: String) async throws -> User {
       let input = Operations.post_sol_users_sol_login.Input(
           body: .json(
               Components.Schemas.LoginRequest(idAlias: idAlias)
           )
       )

       do {
           let response = try await client.post_sol_users_sol_login(input)

           switch response {
           case .ok(let okResponse):
               let userDTO = try okResponse.body.json
               return userDTO.toDomain()
           case .notFound:
               print("❌ [UserRepository] loginByIdAlias failed - User not found: \(idAlias)")
               throw NetworkError.notFound
           case .undocumented(statusCode: let code, _):
               let error = NetworkError.from(statusCode: code)
               print("❌ [UserRepository] loginByIdAlias failed - Status: \(code)")
               throw error
           }
       } catch let error as NetworkError {
           throw error
       } catch {
           print("❌ [UserRepository] loginByIdAlias failed - Unexpected: \(error)")
           throw error
       }
   }
   ```
3. Save the file

**Validation**: Build succeeds for `UserRepository`

**Dependencies**: Task 6

---

### Task 8: Implement loginByIdAlias in MockUserRepository
**Description**: Add mock implementation for testing

**Steps**:
1. Open `Features/Authentication/Data/Repositories/MockUserRepository.swift`
2. Add new method:
   ```swift
   func loginByIdAlias(_ idAlias: String) async throws -> User {
       guard let user = users.first(where: { $0.idAlias == idAlias }) else {
           throw NetworkError.notFound
       }
       return user
   }
   ```
3. Update mock users to include `idAlias` field:
   ```swift
   private var users: [User] = [
       User(id: "user-1", idAlias: "alice", name: "Alice", ...),
       User(id: "user-2", idAlias: "bob", name: "Bob", ...),
       User(id: "user-3", idAlias: "charlie", name: "Charlie", ...)
   ]
   ```
4. Save the file

**Validation**: Build succeeds for `MockUserRepository`

**Dependencies**: Task 6

---

## Phase 4: Use Case Layer Updates

### Task 9: Update AuthenticationUseCase to use loginByIdAlias
**Description**: Replace `fetchUser(id:)` call with `loginByIdAlias(_:)` in authenticate method

**Steps**:
1. Open `Features/Authentication/Domain/UseCases/AuthenticationUseCase.swift`
2. Update the `authenticate(userId:)` method parameter name to `authenticate(idAlias:)`
3. Replace the repository call:
   ```swift
   func authenticate(idAlias: String) async throws -> AuthSession {
       // 1. Validate idAlias
       guard !idAlias.trimmingCharacters(in: .whitespaces).isEmpty else {
           throw AuthenticationError.emptyUserId  // Consider renaming to emptyIdAlias
       }

       // 2. Call POST /users/login
       let user: User
       do {
           user = try await userRepository.loginByIdAlias(idAlias)
       } catch {
           throw AuthenticationError.userNotFound
       }

       // 3. Create session using user.id (UUID)
       let session = AuthSession(
           userId: user.id,  // Still use UUID for session
           user: user,
           authenticatedAt: Date()
       )

       // 4. Save session
       try sessionManager.saveSession(session)

       return session
   }
   ```
4. Update the protocol if needed

**Validation**: Build succeeds; logic flows correctly

**Dependencies**: Task 7, Task 8

---

### Task 10: Add idAlias validation to AuthenticationUseCase
**Description**: Implement client-side validation for `idAlias` format

**Steps**:
1. In `AuthenticationUseCase.swift`, add validation helper:
   ```swift
   private func validateIdAliasFormat(_ idAlias: String) throws {
       let pattern = "^[a-z0-9][a-z0-9._-]*[a-z0-9]$"
       let regex = try NSRegularExpression(pattern: pattern)
       let range = NSRange(location: 0, length: idAlias.utf16.count)

       guard idAlias.count >= 3, idAlias.count <= 30 else {
           throw AuthenticationError.invalidIdAliasFormat
       }

       guard regex.firstMatch(in: idAlias, range: range) != nil else {
           throw AuthenticationError.invalidIdAliasFormat
       }
   }
   ```
2. Call validation before API request:
   ```swift
   try validateIdAliasFormat(idAlias)
   ```
3. Add new error case to `AuthenticationError`:
   ```swift
   case invalidIdAliasFormat
   ```

**Validation**: Invalid formats are rejected before API call

**Dependencies**: Task 9

---

## Phase 5: Presentation Layer Updates

### Task 11: Update AuthenticationViewModel to use idAlias
**Description**: Rename property and update method calls in ViewModel

**Steps**:
1. Open `Features/Authentication/Presentation/ViewModels/AuthenticationViewModel.swift`
2. Rename `@Published var userId` to `@Published var idAlias`
3. Update `authenticate()` method to call `authenticationUseCase.authenticate(idAlias: idAlias)`
4. Update validation logic and error handling
5. Update `loadLastUserId()` method name if it references userId (consider keeping for backward compatibility)

**Validation**: Build succeeds; ViewModel compiles without errors

**Dependencies**: Task 10

---

### Task 12: Update AuthenticationView UI labels and placeholders
**Description**: Change UI text to reflect `idAlias` instead of `userId`

**Steps**:
1. Open `Features/Authentication/Presentation/Views/AuthenticationView.swift`
2. Update labels:
   - "User ID" → "ID Alias" or "ユーザーID"
   - "User IDを入力" → "ID Aliasを入力" or "ユーザー名を入力"
   - "バックエンドに登録済みのUser IDを入力してください" → "ユーザー名を入力してください（例: alice, bob_2024）"
3. Update TextField binding: `$viewModel.userId` → `$viewModel.idAlias`
4. Update validation display if needed

**Validation**: UI displays correctly in Xcode preview

**Dependencies**: Task 11

---

## Phase 6: Testing

### Task 13: Update existing AuthenticationUseCase tests
**Description**: Fix existing unit tests to use new `idAlias`-based authentication

**Steps**:
1. Open `PrototypeChatClientAppTests/Features/Authentication/AuthenticationUseCaseTests.swift`
2. Update test method calls from `authenticate(userId:)` to `authenticate(idAlias:)`
3. Update test user data to include `idAlias` field
4. Update mock repository expectations

**Validation**: Run `make test`; all existing tests pass

**Dependencies**: Task 9

---

### Task 14: Add idAlias validation tests
**Description**: Create new test cases for `idAlias` format validation

**Steps**:
1. In `AuthenticationUseCaseTests.swift`, add test cases:
   - `test_authenticate_validIdAlias_succeeds()`
   - `test_authenticate_tooShortIdAlias_fails()`
   - `test_authenticate_tooLongIdAlias_fails()`
   - `test_authenticate_uppercaseIdAlias_fails()`
   - `test_authenticate_spacesInIdAlias_fails()`
   - `test_authenticate_invalidSymbolsInIdAlias_fails()`
   - `test_authenticate_startsWithSymbol_fails()`
2. Implement each test with appropriate assertions

**Validation**: Run `make test`; new tests pass

**Dependencies**: Task 13

---

### Task 15: Update MockData to include idAlias
**Description**: Add `idAlias` field to all test data users

**Steps**:
1. Open `PrototypeChatClientApp/Features/Chat/Testing/MockData.swift`
2. Update all `User` instances to include `idAlias`:
   ```swift
   static let user1 = User(
       id: "user1",
       idAlias: "alice",
       name: "Alice",
       avatarUrl: nil,
       createdAt: Date(timeIntervalSince1970: 1000)
   )
   ```
3. Save the file

**Validation**: Build succeeds; no test failures

**Dependencies**: Task 4

---

## Phase 7: Integration and Verification

### Task 16: Test end-to-end login flow in simulator
**Description**: Manual testing of the complete authentication flow

**Steps**:
1. Build and run the app: `make run`
2. Enter a valid `idAlias` (e.g., "alice", "bob", "charlie")
3. Verify successful login
4. Test with invalid formats (uppercase, too short, etc.)
5. Verify appropriate error messages are displayed
6. Test logout and re-login

**Validation**: Login works with `idAlias`; errors are user-friendly

**Dependencies**: All previous tasks

---

### Task 17: Verify all tests pass
**Description**: Run full test suite to ensure no regressions

**Steps**:
1. Run `make clean`
2. Run `make test`
3. Verify all unit tests pass
4. Check for any warnings or deprecated usage

**Validation**: `make test` exits with code 0; no test failures

**Dependencies**: Task 16

---

## Summary

**Total Tasks**: 17
**Estimated Complexity**: Medium
**Parallelizable Work**:
- Tasks 1-3 can be done first (OpenAPI updates)
- Tasks 4-5 depend on Task 3
- Tasks 6-8 can be done in parallel after Task 5
- Tasks 9-12 are sequential
- Tasks 13-15 can be done in parallel
- Tasks 16-17 are final validation steps

**Critical Path**: Task 1 → Task 2 → Task 3 → Task 4 → Task 5 → Task 6 → Task 9 → Task 11 → Task 12 → Task 16 → Task 17
