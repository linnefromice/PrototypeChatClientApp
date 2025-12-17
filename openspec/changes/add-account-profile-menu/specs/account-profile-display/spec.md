# Spec: Account Profile Display

**Capability:** `account-profile-display`
**Status:** Proposed
**Created:** 2025-12-17

## Overview

ナビゲーションメニューにアカウント情報を表示する機能を追加します。ユーザーは自分のプロフィール情報（アバター、ユーザーID、名前、作成日時など）を確認できるようになります。

## ADDED Requirements

### Requirement: REQ-ACCOUNT-001 - Navigation Menu Account Option

ナビゲーションメニューに「アカウント」メニューアイテムを表示し、ユーザー情報画面に遷移できるようにする。システムは、ログイン済みユーザーがナビゲーションメニューからアカウント情報画面にアクセスできるようにしなければならない(MUST)。

#### Scenario: User opens navigation menu and sees account option

**Given:**
- ユーザーがログイン済み
- 会話一覧画面が表示されている

**When:**
- ユーザーが左上のメニューボタン（三本線アイコン）をタップ
- ナビゲーションメニューが表示される

**Then:**
- 「アカウント」メニューアイテムが表示される
- 「アカウント」の左側に人物アイコン（person.circle）が表示される
- 「ログアウト」メニューアイテムの上に配置される

#### Scenario: User navigates to account profile screen

**Given:**
- ナビゲーションメニューが表示されている
- ユーザーがログイン済み

**When:**
- ユーザーが「アカウント」メニューアイテムをタップ

**Then:**
- アカウント情報画面（AccountProfileView）に遷移する
- ナビゲーションバーに「アカウント」というタイトルが表示される
- 戻るボタンでメニューに戻れる

### Requirement: REQ-ACCOUNT-002 - Avatar Display

ユーザーのアバター画像を画面上部に表示する。アバター画像がない場合は、イニシャルプレースホルダーを表示する。システムは、ユーザーのアバター画像またはイニシャルプレースホルダーを画面上部に表示しなければならない(MUST)。

#### Scenario: User with avatar URL views profile

**Given:**
- ユーザーがログイン済み
- ユーザーの`avatarUrl`が有効なURL文字列

**When:**
- アカウント情報画面が表示される

**Then:**
- 画面上部にアバター画像が表示される
- アバター画像は円形で表示される
- アバター画像のサイズは80x80ポイント
- 画像の読み込み中はプレースホルダーが表示される
- 画像の読み込みに失敗した場合はイニシャルプレースホルダーが表示される

#### Scenario: User without avatar URL views profile

**Given:**
- ユーザーがログイン済み
- ユーザーの`avatarUrl`がnil

**When:**
- アカウント情報画面が表示される

**Then:**
- 画面上部にイニシャルプレースホルダーが表示される
- プレースホルダーは円形で表示される
- プレースホルダーのサイズは80x80ポイント
- プレースホルダーの背景色はセカンダリ背景色
- プレースホルダーの中央にユーザー名の最初の文字が表示される
- 文字は大文字で表示される

### Requirement: REQ-ACCOUNT-003 - User Information Display

ユーザーの詳細情報をリスト形式で表示する。システムは、ユーザーID、エイリアス、名前、作成日時をリスト形式で表示しなければならない(MUST)。

#### Scenario: User views detailed account information

**Given:**
- ユーザーがログイン済み
- アカウント情報画面が表示されている

**When:**
- ユーザーが画面をスクロールする

**Then:**
- 以下の情報がリスト形式で表示される：
  - ユーザーID（`user.id`）
  - ユーザーエイリアス（`user.idAlias`）
  - 名前（`user.name`）
  - 作成日時（`user.createdAt`）
- 各情報はラベルと値のペアで表示される
- ラベルは左側、値は右側に表示される
- 各情報は1行で表示される（長い場合は省略記号）

#### Scenario: User views formatted creation date

**Given:**
- ユーザーがログイン済み
- アカウント情報画面が表示されている
- ユーザーの`createdAt`が`Date`オブジェクト

**When:**
- 作成日時が表示される

**Then:**
- 日付は "2025/12/17" のような短縮形式で表示される
- 時刻は "10:30" のような短縮形式で表示される
- 日付と時刻はユーザーのロケールに合わせて表示される
- タイムゾーンはユーザーのデバイス設定に従う

### Requirement: REQ-ACCOUNT-004 - Screen Layout

アカウント情報画面のレイアウトは、iOS標準の設定画面パターンに従う。システムは、iOS標準のList UIを使用してアカウント情報を表示しなければならない(MUST)。

#### Scenario: User views account profile layout

**Given:**
- ユーザーがログイン済み
- アカウント情報画面が表示されている

**When:**
- 画面が表示される

**Then:**
- ナビゲーションバーのタイトルは「アカウント」
- ナビゲーションバーのタイトル表示モードは`.inline`
- 画面は`List`を使用して構成される
- アバターセクションと情報セクションは別々の`Section`に配置される
- アバターセクションは情報セクションの上に表示される
- アバターは水平方向に中央揃えされる

### Requirement: REQ-ACCOUNT-005 - Accessibility Support

アカウント情報画面はアクセシビリティ機能に対応する。システムは、VoiceOverユーザーが全ての要素にアクセスできるようにしなければならない(MUST)。

#### Scenario: VoiceOver user navigates account profile

**Given:**
- VoiceOverが有効
- ユーザーがログイン済み
- アカウント情報画面が表示されている

**When:**
- ユーザーがVoiceOverで画面を操作する

**Then:**
- アバター画像には「プロフィール画像」というaccessibilityLabelが設定される
- イニシャルプレースホルダーには「{ユーザー名}のプロフィール画像」というaccessibilityLabelが設定される
- 各情報項目のラベルと値が適切に読み上げられる
- VoiceOverで戻るボタンが識別できる

## Cross-References

### Related Requirements

- **Navigation Menu:** この機能は既存の`NavigationMenuView`を拡張します（`add-logout-navigation-menu`で実装済み）
- **Authentication:** `AuthenticationViewModel`と`AuthSession`に依存します

### Future Enhancements

以下の機能は今回のスコープ外ですが、将来的に追加可能：
- プロフィール編集機能（REQ-ACCOUNT-EDIT）
- アバター画像アップロード機能（REQ-AVATAR-UPLOAD）
- ステータスメッセージ表示・編集機能（REQ-STATUS-MESSAGE）

## Validation Criteria

- [ ] 「アカウント」メニューアイテムが表示される
- [ ] 「アカウント」タップで画面遷移する
- [ ] アバター画像またはプレースホルダーが表示される
- [ ] ユーザー情報が正しく表示される
- [ ] 日付が適切にフォーマットされる
- [ ] 戻るボタンでメニューに戻れる
- [ ] VoiceOverで全ての要素にアクセスできる
