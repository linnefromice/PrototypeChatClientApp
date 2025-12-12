import Foundation

/// 会話リポジトリプロトコル
///
/// スコープ: Core層で定義、Features/Chat内で使用
protocol ConversationRepositoryProtocol {
    /// ユーザーの会話一覧を取得
    /// - Parameter userId: ユーザーID
    /// - Returns: 会話詳細リスト
    func fetchConversations(userId: String) async throws -> [ConversationDetail]

    /// 会話を作成
    /// - Parameters:
    ///   - type: 会話タイプ (direct/group)
    ///   - participantIds: 参加者のユーザーIDリスト
    ///   - name: 会話名（グループチャットの場合のみ）
    /// - Returns: 作成された会話詳細
    func createConversation(
        type: ConversationType,
        participantIds: [String],
        name: String?
    ) async throws -> ConversationDetail
}
