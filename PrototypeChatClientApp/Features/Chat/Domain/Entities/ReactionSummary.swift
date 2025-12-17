import Foundation

struct ReactionSummary: Equatable {
    let emoji: String
    let count: Int
    let userIds: [String]

    func hasUser(_ userId: String) -> Bool {
        userIds.contains(userId)
    }
}
