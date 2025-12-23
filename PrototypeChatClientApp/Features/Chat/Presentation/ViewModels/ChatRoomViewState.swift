import Foundation

/// State machine for ChatRoomViewModel
enum ChatRoomViewState: Equatable {
    case idle
    case loading
    case loaded([Message])
    case sendingMessage([Message]) // Current messages while sending
    case error(String, [Message]) // Error with current messages to maintain state

    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }

    var isSending: Bool {
        if case .sendingMessage = self {
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

    var messages: [Message] {
        switch self {
        case .idle, .loading:
            return []
        case .loaded(let messages):
            return messages
        case .sendingMessage(let messages):
            return messages
        case .error(_, let messages):
            return messages
        }
    }
}
