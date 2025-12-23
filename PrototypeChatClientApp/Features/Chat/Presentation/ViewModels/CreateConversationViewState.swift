import Foundation

/// State machine for CreateConversationViewModel
enum CreateConversationViewState: Equatable {
    case idle
    case loadingUsers
    case usersLoaded([User])
    case creatingConversation
    case conversationCreated(ConversationDetail)
    case error(String)

    var isLoading: Bool {
        switch self {
        case .loadingUsers, .creatingConversation:
            return true
        default:
            return false
        }
    }

    var errorMessage: String? {
        if case .error(let message) = self {
            return message
        }
        return nil
    }

    var showError: Bool {
        if case .error = self {
            return true
        }
        return false
    }

    var availableUsers: [User] {
        if case .usersLoaded(let users) = self {
            return users
        }
        return []
    }

    var createdConversation: ConversationDetail? {
        if case .conversationCreated(let conversation) = self {
            return conversation
        }
        return nil
    }
}
