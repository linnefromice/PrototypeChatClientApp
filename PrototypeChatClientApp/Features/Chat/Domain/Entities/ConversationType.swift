import Foundation

/// 会話タイプ
///
/// スコープ: Features/Chat内で使用
enum ConversationType: String, Codable {
    case direct  // 1:1チャット
    case group   // グループチャット
}
