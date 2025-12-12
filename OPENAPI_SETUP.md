# OpenAPI Generator セットアップガイド

このドキュメントは、Swift OpenAPI Generatorを使ったAPIクライアントコード自動生成のセットアップ手順を説明します。

## 前提条件

- Xcode 15.0+
- macOS 13.0+
- OpenAPI仕様書: `Resources/openapi.yaml`

## セットアップ手順

### Step 1: OpenAPI仕様書を取得

```bash
make fetch-openapi
```

これにより、`Resources/openapi.yaml` にバックエンドのAPI仕様書がダウンロードされます。

### Step 2: Xcodeでプロジェクトを開く

```bash
make open
```

または直接：
```bash
open PrototypeChatClientApp.xcodeproj
```

### Step 3: Swift Package依存関係を追加

#### 3-1. Package Dependencies画面を開く

Xcode メニュー → **File** → **Add Package Dependencies...**

#### 3-2. 以下の3つのパッケージを順番に追加

**パッケージ 1: Swift OpenAPI Generator**
```
https://github.com/apple/swift-openapi-generator
```
- Version: **1.0.0** 以上
- Add to Project: **PrototypeChatClientApp**
- プロダクト選択: **なし**（プラグインのみ使用）

---

**パッケージ 2: Swift OpenAPI Runtime**
```
https://github.com/apple/swift-openapi-runtime
```
- Version: **1.0.0** 以上
- Add to Project: **PrototypeChatClientApp**
- プロダクト選択: **OpenAPIRuntime** にチェック

---

**パッケージ 3: Swift OpenAPI URLSession**
```
https://github.com/apple/swift-openapi-urlsession
```
- Version: **1.0.0** 以上
- Add to Project: **PrototypeChatClientApp**
- プロダクト選択: **OpenAPIURLSession** にチェック

### Step 4: Build Pluginを設定

#### 4-1. プロジェクト設定を開く

左ペインでプロジェクト **PrototypeChatClientApp** を選択 → ターゲット **PrototypeChatClientApp** を選択

#### 4-2. Build Phasesタブに移動

**Build Phases** タブをクリック

#### 4-3. Run Build Tool Plug-insを追加

1. 左上の **+** ボタンをクリック
2. **New Run Build Tool Plug-in Phase** を選択
3. 追加されたセクションを展開
4. **+** ボタンをクリックして **OpenAPIGenerator** を選択

### Step 5: OpenAPI Generator設定ファイルを確認

プロジェクトルートに以下のファイルが存在することを確認：

**openapi-generator-config.yaml**
```yaml
generate:
  - types    # Generate schema types
  - client   # Generate client

accessModifier: internal

additionalImports:
  - Foundation
```

**Resources/openapi.yaml**
```bash
# 存在確認
ls -lh Resources/openapi.yaml
```

### Step 6: ビルド実行

```bash
make build
```

または Xcode で **⌘ + B** (Command + B)

ビルドが成功すると、以下のファイルが自動生成されます：

```
PrototypeChatClientApp/Infrastructure/Network/Generated/
├── Client.swift       # APIクライアント
├── Types.swift        # スキーマ型定義
└── Operations.swift   # エンドポイント定義
```

**注意:** `Generated/` ディレクトリは `.gitignore` に含まれており、gitには追跡されません。

### Step 7: 動作確認

ビルドログで以下のメッセージを確認：

```
SwiftDriver PrototypeChatClientApp normal arm64 com.apple.xcode.tools.swift.compiler
```

エラーなくビルドが完了すれば、セットアップ成功です！

## トラブルシューティング

### 問題1: パッケージが見つからない

**症状:**
```
error: no such module 'OpenAPIRuntime'
```

**解決策:**
1. Xcode → File → Packages → Resolve Package Versions
2. または `make resolve` を実行

---

### 問題2: Build Pluginが実行されない

**症状:**
- `Generated/` ディレクトリが空
- コード生成されない

**解決策:**
1. Build Phases → Run Build Tool Plug-ins に **OpenAPIGenerator** があるか確認
2. プラグインの実行順序を確認（Compile Sourcesより前に実行される必要がある）
3. Clean Build: `make clean && make build`

---

### 問題3: openapi.yaml が見つからない

**症状:**
```
error: OpenAPI document not found
```

**解決策:**
```bash
# OpenAPI仕様書を再取得
make fetch-openapi

# ファイルが存在するか確認
ls Resources/openapi.yaml
```

---

### 問題4: ビルドが遅い

**原因:**
- OpenAPI Generatorはビルドごとにコード生成を実行

**対策:**
- 生成コードをキャッシュ（DerivedDataに保存される）
- openapi.yamlが変更されない限り、再生成はスキップされる

---

## 使用方法

### APIクライアントの初期化例

```swift
import OpenAPIRuntime
import OpenAPIURLSession

// 環境に応じたbaseURLを取得
let environment = AppEnvironment.current
let transport = URLSessionTransport()

let client = Client(
    serverURL: environment.baseURL,
    transport: transport
)
```

### Repositoryでの利用例

```swift
class UserRepository: UserRepositoryProtocol {
    private let client: Client

    init(client: Client) {
        self.client = client
    }

    func fetchUser(id: String) async throws -> User {
        let response = try await client.getUser(
            path: .init(userId: id)
        )

        switch response {
        case .ok(let okResponse):
            let userDTO = try okResponse.body.json
            return userDTO.toDomain()
        case .notFound:
            throw NetworkError.notFound
        case .undocumented(statusCode: let code, _):
            throw NetworkError.from(statusCode: code)
        }
    }
}
```

## OpenAPI仕様書の更新

バックエンドAPIが更新された場合：

```bash
# 最新の仕様書を取得
make fetch-openapi

# ビルドして自動生成コードを更新
make build
```

生成されたコードに型エラーがある場合は、Repositoryの実装を更新してください。

## 参考ドキュメント

- [API接続レイヤー設計書](Specs/Plans/API_LAYER_DESIGN_20251211_JA.md)
- [Swift OpenAPI Generator - GitHub](https://github.com/apple/swift-openapi-generator)
- [Swift OpenAPI Generator - Documentation](https://swiftpackageindex.com/apple/swift-openapi-generator/documentation)

---

**最終更新:** 2025年12月12日
