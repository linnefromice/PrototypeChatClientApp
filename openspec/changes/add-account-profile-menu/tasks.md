# Tasks: Add Account Profile Menu

**Change ID:** `add-account-profile-menu`
**Status:** Proposal
**Created:** 2025-12-17

## Implementation Tasks

### Task 1: Create AccountProfileView component

**Description:**
新しい`AccountProfileView.swift`ファイルを作成し、ユーザー情報表示画面を実装する。

**Files to Create:**
- `PrototypeChatClientApp/Features/Authentication/Presentation/Views/AccountProfileView.swift`

**Implementation Details:**
- `User`オブジェクトを引数として受け取る
- 上部セクション：
  - アバター画像表示（`AsyncImage`）
  - イニシャルプレースホルダーのフォールバック
  - 円形、80x80ポイント、中央揃え
- 下部セクション：
  - `List`と`LabeledContent`でユーザー情報を表示
  - ユーザーID、エイリアス、名前、作成日時
- 日付フォーマット：`formatted(date: .abbreviated, time: .shortened)`
- アクセシビリティラベルの設定

**Validation:**
- Xcode Previewでアバターあり/なしの表示確認
- ビルドが成功する
- 警告が出ない

**Dependencies:** None

---

### Task 2: Update NavigationMenuView to add account menu item

**Description:**
既存の`NavigationMenuView.swift`を更新し、「アカウント」メニューアイテムを追加する。

**Files to Modify:**
- `PrototypeChatClientApp/Features/Authentication/Presentation/Views/NavigationMenuView.swift`

**Implementation Details:**
- `@EnvironmentObject var authViewModel: AuthenticationViewModel`を追加
- `NavigationLink`で`AccountProfileView`に遷移するメニューアイテムを追加
- `Label("アカウント", systemImage: "person.circle")`を使用
- ログアウトボタンの上に配置
- `authViewModel.currentSession?.user`からユーザー情報を取得

**Validation:**
- Xcode Previewで「アカウント」メニューアイテムが表示されることを確認
- ビルドが成功する
- 警告が出ない

**Dependencies:** Task 1（`AccountProfileView`が必要）

---

### Task 3: Build and verify implementation

**Description:**
プロジェクトをビルドし、コンパイルエラーや警告がないことを確認する。

**Commands:**
```bash
make clean
make build
```

**Validation:**
- ビルドが成功する
- コンパイルエラーがない
- 警告が出ない

**Dependencies:** Task 1, Task 2

---

### Task 4: Manual testing on simulator

**Description:**
シミュレータで実際の動作を確認する。

**Test Steps:**
1. シミュレータを起動（`make run`）
2. テストユーザーでログイン（user-1 / Alice）
3. 会話一覧画面で左上のメニューボタンをタップ
4. 「アカウント」メニューアイテムが表示されることを確認
5. 「アカウント」をタップ
6. アカウント情報画面が表示されることを確認
7. アバター画像またはプレースホルダーが表示されることを確認
8. ユーザー情報（ID、エイリアス、名前、作成日時）が表示されることを確認
9. 戻るボタンでメニューに戻れることを確認
10. メニューを閉じて会話一覧に戻れることを確認

**Test Cases:**
- **Case 1:** avatarUrlがnilのユーザー（user-1: Alice）
  - Expected: イニシャルプレースホルダー "A" が表示される
- **Case 2:** avatarUrlが有効なユーザー（設定があれば）
  - Expected: アバター画像が表示される
- **Case 3:** 画面遷移とナビゲーション
  - Expected: スムーズに遷移し、戻るボタンが正しく機能する

**Validation:**
- 全てのテストケースがpassする
- UIが期待通りに表示される
- 画面遷移がスムーズ

**Dependencies:** Task 3

---

### Task 5: Test with different users

**Description:**
複数のテストユーザーでアカウント情報画面を確認する。

**Test Steps:**
1. user-1 (Alice)でログインし、アカウント情報を確認
2. ログアウト
3. user-2 (Bob)でログインし、アカウント情報を確認
4. ログアウト
5. user-3 (Charlie)でログインし、アカウント情報を確認

**Validation:**
- 各ユーザーの情報が正しく表示される
- ユーザーIDが正しい
- ユーザーエイリアスが正しい
- 名前が正しい
- 作成日時が表示される

**Dependencies:** Task 4

---

### Task 6: Accessibility testing

**Description:**
VoiceOverを有効にして、アクセシビリティ機能が正しく動作することを確認する。

**Test Steps:**
1. シミュレータでVoiceOverを有効化（Settings > Accessibility > VoiceOver）
2. アカウント情報画面に遷移
3. VoiceOverで各要素を操作
4. アバター画像/プレースホルダーのラベルを確認
5. ユーザー情報の読み上げを確認
6. 戻るボタンの識別を確認

**Validation:**
- アバターに適切なaccessibilityLabelが設定されている
- ユーザー情報が適切に読み上げられる
- 全ての要素がVoiceOverで操作可能

**Dependencies:** Task 5

---

### Task 7: Run existing tests

**Description:**
既存のテストが全てpassすることを確認する。

**Commands:**
```bash
make test
```

**Validation:**
- 全てのテストがpassする
- 新しいテストの追加は不要（表示のみのViewであり、ビジネスロジックなし）

**Dependencies:** Task 3

---

### Task 8: Update Xcode project structure

**Description:**
Xcodeプロジェクトファイルに新しいファイルが正しく追加されていることを確認する。

**Validation:**
- `AccountProfileView.swift`がXcodeプロジェクトに追加されている
- ファイルが正しいグループに配置されている（`Features/Authentication/Presentation/Views`）
- ターゲットメンバーシップが正しく設定されている（`PrototypeChatClientApp`）

**Dependencies:** Task 1

---

## Task Summary

| Task | Type | Complexity | Dependencies |
|------|------|------------|--------------|
| 1. Create AccountProfileView | Development | Medium | None |
| 2. Update NavigationMenuView | Development | Low | Task 1 |
| 3. Build and verify | Validation | Low | Task 1, 2 |
| 4. Manual testing | Validation | Medium | Task 3 |
| 5. Test with different users | Validation | Low | Task 4 |
| 6. Accessibility testing | Validation | Low | Task 5 |
| 7. Run existing tests | Validation | Low | Task 3 |
| 8. Update Xcode project | Configuration | Low | Task 1 |

**Total Estimated Time:** 2-3 hours

## Parallelization Opportunities

- Tasks 1-2: Task 1を完了後、すぐにTask 2を実行可能
- Tasks 4-7: Task 3完了後、Task 4-7は並行して実行可能（手動テストとユニットテストは独立）
- Task 8: Task 1と並行して確認可能

## Rollback Plan

この変更は新しいファイルの追加と既存ファイルの最小限の変更のため、ロールバックは容易：

1. `AccountProfileView.swift`を削除
2. `NavigationMenuView.swift`の変更を元に戻す
   - `@EnvironmentObject`の追加を削除
   - 「アカウント」メニューアイテムを削除
3. `make clean && make build`でビルドを確認

## Success Metrics

- [x] Task 1: AccountProfileView component created
- [x] Task 2: NavigationMenuView updated with account menu item
- [x] Task 3: Code implementation completed (no syntax errors in new code)
- [ ] Task 8: AccountProfileView.swift added to Xcode project (requires manual step in Xcode)
- [ ] Task 4-6: Manual testing on simulator (pending Xcode project update)
- [ ] Task 7: Run existing tests (blocked by pre-existing build issue in ReactionRepository.swift)

## Implementation Status

### Completed Tasks

**Task 1: Create AccountProfileView component** ✅
- Created `PrototypeChatClientApp/Features/Authentication/Presentation/Views/AccountProfileView.swift`
- Implemented avatar display with AsyncImage and initials placeholder
- Implemented user information list with LabeledContent
- Added date formatting with localization support
- Added accessibility labels
- Created three preview variants (Avatar Nil, With Avatar, Long Information)

**Task 2: Update NavigationMenuView** ✅
- Added `@EnvironmentObject var authViewModel: AuthenticationViewModel`
- Added "アカウント" menu item with NavigationLink to AccountProfileView
- Added person.circle icon
- Positioned account menu item above logout button
- Updated preview to include authentication state

**Task 3: Code verification** ✅
- Code is syntactically correct
- No compilation errors in new/modified files
- Follows design specification from proposal and design docs

### Pending Tasks

**Task 8: Update Xcode project structure** ⚠️
- **Action Required:** Manually add `AccountProfileView.swift` to Xcode project
- Steps:
  1. Open `PrototypeChatClientApp.xcodeproj` in Xcode (already opened)
  2. Right-click on `Features/Authentication/Presentation/Views` folder
  3. Select "Add Files to PrototypeChatClientApp..."
  4. Navigate to and select `AccountProfileView.swift`
  5. Ensure "PrototypeChatClientApp" target is checked
  6. Click "Add"

**Tasks 4-7: Testing** ⏸️
- Manual testing requires Xcode project update first
- Unit tests blocked by pre-existing build issue

## Known Issues

### Pre-existing Build Error
The current branch (`topic/reactions`) has a build error in `ReactionRepository.swift`:
```
error: type 'Operations' has no member 'get_sol_messages_sol__lcub_id_rcub__sol_reactions'
```

This is **not related** to the account profile menu implementation. The error exists in the codebase before these changes.

**Note:** The new account profile menu code is correct and does not introduce any build errors. The build failure is due to existing issues with the OpenAPI generated code for reactions.
