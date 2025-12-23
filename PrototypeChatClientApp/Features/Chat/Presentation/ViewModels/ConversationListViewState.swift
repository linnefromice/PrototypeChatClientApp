import Foundation

/// State machine for ConversationListViewModel
enum ConversationListViewState: Equatable {
    case idle
    case loading
    case loaded([ConversationDetail])
    case error(String, [ConversationDetail]) // Error with cached conversations

    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }

    var errorMessage: String? {
        if case .error(let message, _) = self {
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

    var conversations: [ConversationDetail] {
        switch self {
        case .idle, .loading:
            return []
        case .loaded(let conversations):
            return conversations
        case .error(_, let conversations):
            return conversations
        }
    }
}
