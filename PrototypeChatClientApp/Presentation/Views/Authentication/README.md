# 認証機能実装ガイド

## 概要

このディレクトリには、仮認証機能の実装が含まれています。
バックエンドに認証機能がない開発環境において、User IDのみで認証状態を管理します。

## 実装済みファイル

### Domain層 (ビジネスロジック)

```
Domain/
├── Entities/
│   ├── User.swift                    # ユーザーエンティティ
│   ├── AuthSession.swift             # 認証セッション
│   └── AuthenticationError.swift     # 認証エラー定義
├── UseCases/
│   └── Authentication/
│       └── AuthenticationUseCase.swift  # 認証ビジネスロジック
└── Repositories/
    └── UserRepositoryProtocol.swift  # ユーザーリポジトリプロトコル
```

### Data層 (データ管理)

```
Data/
├── Local/
│   ├── StorageKey.swift              # ローカルストレージキー定義
│   └── AuthSessionManager.swift      # セッション永続化管理
└── Repositories/
    └── MockUserRepository.swift      # モックユーザーリポジトリ
```

### Presentation層 (UI)

```
Presentation/
├── ViewModels/
│   └── AuthenticationViewModel.swift # 認証状態管理ViewModel
└── Views/
    ├── Authentication/
    │   └── AuthenticationView.swift  # 認証画面UI
    ├── RootView.swift                # ルート画面（認証状態で分岐）
    └── MainView.swift                # 認証後のメイン画面
```

## 使用方法

### 1. Previewでの確認

各Viewファイルには複数のPreviewが用意されています：

**AuthenticationView.swift**
- `#Preview("初期状態")` - 初期表示
- `#Preview("User ID入力済み")` - 入力済み状態
- `#Preview("エラー表示")` - エラー状態
- `#Preview("認証中")` - ローディング状態

**RootView.swift**
- `#Preview("未認証")` - 認証画面表示
- `#Preview("認証済み")` - メイン画面表示

**MainView.swift**
- `#Preview` - 認証後の画面

### 2. シミュレーターでの実行

1. Xcodeでプロジェクトを開く
2. ビルドターゲットを選択
3. Run (⌘R) で実行

### 3. テスト用User ID

MockUserRepositoryには以下のUser IDが登録されています：

- `user-1` → Alice
- `user-2` → Bob
- `user-3` → Charlie

これらのIDでログインテストが可能です。

## 認証フロー

```
[アプリ起動]
    ↓
[ローカルセッションチェック]
    ↓
┌─────────────────┐
│ セッション存在？ │
└─────┬───────────┘
      │
  ┌───┴───┐
  YES    NO
  │      │
  ↓      ↓
[自動  [認証画面]
ログイン]  ↓
  │    [User ID入力]
  │      ↓
  │    [Submit]
  │      ↓
  │    [GET /users/{userId}]
  │      ↓
  │    ┌────┴────┐
  │    成功     失敗
  │    │        │
  │    ↓        ↓
  │  [セッション [エラー表示]
  │   保存]
  │    │
  └────┴────┐
           ↓
      [メイン画面]
```

## コード例

### ViewModel使用例

```swift
// ViewModelの初期化
let viewModel = AuthenticationViewModel(
    authenticationUseCase: AuthenticationUseCase(
        userRepository: MockUserRepository(),
        sessionManager: AuthSessionManager()
    )
)

// 認証実行
Task {
    await viewModel.authenticate()
}

// ログアウト
viewModel.logout()

// 現在のセッション取得
if let session = viewModel.currentSession {
    print("User: \(session.user.name)")
}
```

### 他のViewでの認証情報利用

```swift
struct SomeView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel

    var body: some View {
        VStack {
            if let userId = authViewModel.currentSession?.userId {
                Text("User ID: \(userId)")
            }
        }
    }
}
```

## デバッグ機能

### 開発環境限定機能

`#if DEBUG`ブロック内に以下の機能が実装されています：

1. **前回使用したUser IDの表示**
   - 認証画面下部に表示
   - タップで自動入力

2. **環境情報の表示**
   - "開発環境"ラベル

### セッション情報の確認

```swift
// UserDefaultsから直接確認
let sessionData = UserDefaults.standard.data(forKey: "com.prototype.chat.authSession")
let lastUserId = UserDefaults.standard.string(forKey: "com.prototype.chat.lastUserId")
```

## トラブルシューティング

### ビルドエラーが発生する

**症状**: `Cannot find 'AuthSessionManager' in scope`

**解決策**:
1. Xcodeを再起動
2. `Clean Build Folder` (⇧⌘K)
3. ビルドを再実行

### Previewが表示されない

**症状**: Preview not available

**解決策**:
1. Previewを閉じて再度開く (⌥⌘↩)
2. Xcodeを再起動
3. `~/Library/Developer/Xcode/DerivedData`を削除

### 認証が成功しない

**症状**: User IDを入力しても「見つかりません」エラー

**原因**: MockUserRepositoryに登録されていないUser ID

**解決策**: `user-1`, `user-2`, `user-3`のいずれかを使用

### セッションが保存されない

**症状**: アプリ再起動後に認証状態が消える

**解決策**:
1. AuthSessionManagerの`saveSession`が呼ばれているか確認
2. UserDefaultsの書き込み権限を確認

## 次のステップ

### 本番APIへの接続

1. **OpenAPI Generatorの導入**
   - API_LAYER_DESIGN_20251211_JA.mdを参照
   - swift-openapi-generatorをセットアップ

2. **UserRepositoryの実装**
   ```swift
   class UserRepository: UserRepositoryProtocol {
       private let client: Client

       func fetchUser(id: String) async throws -> User {
           // Generated APIクライアントを使用
       }
   }
   ```

3. **依存性注入の更新**
   ```swift
   // MockUserRepository → UserRepository
   let userRepository = UserRepository(client: apiClient)
   ```

### 認証機能の拡張

1. **JWT認証への移行**
   - `AuthenticationUseCaseProtocol`の実装を差し替え
   - トークン管理機能を追加

2. **Keychain導入**
   - セキュアな認証情報保存
   - `AuthSessionManager`をKeychain対応に更新

## 参考ドキュメント

- [認証管理設計書](../../../../Specs/Plans/AUTH_DESIGN_20251211_JA.md)
- [アーキテクチャ概要](../../../../Specs/Plans/IOS_APP_ARCHITECTURE_20251211_JA.md)
- [API接続レイヤー設計](../../../../Specs/Plans/API_LAYER_DESIGN_20251211_JA.md)

## 実装者向けメモ

### アーキテクチャのポイント

1. **Protocol指向設計**
   - テスタビリティの向上
   - 実装の差し替えが容易

2. **依存性注入**
   - ViewModelへのUseCase注入
   - UseCaseへのRepository注入

3. **レイヤー分離**
   - Domain: ビジネスロジック（フレームワーク非依存）
   - Data: データ管理（永続化実装）
   - Presentation: UI（SwiftUI依存）

### テストの追加

```swift
// AuthenticationViewModelTests.swift
@MainActor
class AuthenticationViewModelTests: XCTestCase {
    func testAuthenticate_Success() async throws {
        let mockRepo = MockUserRepository()
        let sessionManager = AuthSessionManager(
            userDefaults: UserDefaults(suiteName: "test")!
        )
        let useCase = AuthenticationUseCase(
            userRepository: mockRepo,
            sessionManager: sessionManager
        )
        let sut = AuthenticationViewModel(
            authenticationUseCase: useCase,
            sessionManager: sessionManager
        )

        sut.userId = "user-1"
        await sut.authenticate()

        XCTAssertTrue(sut.isAuthenticated)
    }
}
```
