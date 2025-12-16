# Tasks: Implement Chat Messaging Screen

**Change ID:** `implement-chat-messaging-screen`

## Implementation Tasks

These tasks deliver the chat messaging feature with message display and sending capabilities.

---

### 1. Create Message domain entity

**File:** `PrototypeChatClientApp/Features/Chat/Domain/Entities/Message.swift` (new file)

**Description:**
Create the Message entity that represents a chat message with all necessary properties.

**Steps:**
1. Create new Swift file `Message.swift` in Domain/Entities
2. Define Message struct with properties: id, conversationId, senderUserId, type, text, createdAt
3. Implement `Identifiable` protocol (id property)
4. Implement `Equatable` protocol for testing
5. Implement `Codable` protocol for API communication
6. Add `MessageType` enum (text, system)

**Code Template:**
```swift
import Foundation

enum MessageType: String, Codable {
    case text
    case system
}

struct Message: Identifiable, Equatable, Codable {
    let id: String
    let conversationId: String
    let senderUserId: String?
    let type: MessageType
    let text: String?
    let createdAt: Date

    // Optional fields for future use
    let replyToMessageId: String?
    let systemEvent: String?
}
```

**Expected Outcome:**
- Message entity created with all required properties
- Conforms to Identifiable, Equatable, Codable
- MessageType enum defined

**Validation:**
- Build succeeds: `make build`
- No compilation errors

**Estimated Effort:** 10 minutes

---

### 2. Create MessageUseCase with fetch and send methods

**File:** `PrototypeChatClientApp/Features/Chat/Domain/UseCases/MessageUseCase.swift` (new file)

**Description:**
Create the use case that handles business logic for fetching and sending messages.

**Steps:**
1. Create `MessageUseCase.swift` file
2. Define `MessageRepositoryProtocol` with `fetchMessages` and `sendMessage` methods
3. Implement `MessageUseCase` class with repository dependency
4. Implement `fetchMessages(conversationId:userId:limit:)` method
5. Implement `sendMessage(conversationId:senderUserId:text:)` method
6. Add error handling

**Code Template:**
```swift
import Foundation

protocol MessageRepositoryProtocol {
    func fetchMessages(conversationId: String, userId: String, limit: Int) async throws -> [Message]
    func sendMessage(conversationId: String, senderUserId: String, text: String) async throws -> Message
}

class MessageUseCase {
    private let messageRepository: MessageRepositoryProtocol

    init(messageRepository: MessageRepositoryProtocol) {
        self.messageRepository = messageRepository
    }

    func fetchMessages(conversationId: String, userId: String, limit: Int = 50) async throws -> [Message] {
        return try await messageRepository.fetchMessages(
            conversationId: conversationId,
            userId: userId,
            limit: limit
        )
    }

    func sendMessage(conversationId: String, senderUserId: String, text: String) async throws -> Message {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw MessageError.emptyMessage
        }

        return try await messageRepository.sendMessage(
            conversationId: conversationId,
            senderUserId: senderUserId,
            text: text
        )
    }
}

enum MessageError: Error {
    case emptyMessage
}
```

**Expected Outcome:**
- MessageUseCase created with fetch and send methods
- MessageRepositoryProtocol defined
- Input validation for empty messages

**Validation:**
- Build succeeds: `make build`

**Estimated Effort:** 15 minutes

---

### 3. Create MockMessageRepository for testing

**File:** `PrototypeChatClientApp/Features/Chat/Data/Repositories/MockMessageRepository.swift` (new file)

**Description:**
Create a mock repository for testing and offline development.

**Steps:**
1. Create `MockMessageRepository.swift`
2. Implement `MessageRepositoryProtocol`
3. Use in-memory array to store messages
4. Generate mock messages with timestamps
5. Simulate async delays

**Code Template:**
```swift
import Foundation

class MockMessageRepository: MessageRepositoryProtocol {
    var messages: [Message] = []

    init() {
        // Pre-populate with sample messages
        let now = Date()
        messages = [
            Message(
                id: "msg-1",
                conversationId: "conv-1",
                senderUserId: "user-1",
                type: .text,
                text: "Hello!",
                createdAt: now.addingTimeInterval(-3600),
                replyToMessageId: nil,
                systemEvent: nil
            ),
            Message(
                id: "msg-2",
                conversationId: "conv-1",
                senderUserId: "user-2",
                type: .text,
                text: "Hi there!",
                createdAt: now.addingTimeInterval(-1800),
                replyToMessageId: nil,
                systemEvent: nil
            )
        ]
    }

    func fetchMessages(conversationId: String, userId: String, limit: Int) async throws -> [Message] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        return messages
            .filter { $0.conversationId == conversationId }
            .sorted { $0.createdAt < $1.createdAt }
            .prefix(limit)
            .map { $0 }
    }

    func sendMessage(conversationId: String, senderUserId: String, text: String) async throws -> Message {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds

        let newMessage = Message(
            id: UUID().uuidString,
            conversationId: conversationId,
            senderUserId: senderUserId,
            type: .text,
            text: text,
            createdAt: Date(),
            replyToMessageId: nil,
            systemEvent: nil
        )

        messages.append(newMessage)
        return newMessage
    }
}
```

**Expected Outcome:**
- MockMessageRepository created
- Pre-populated with sample messages
- Simulates async behavior

**Validation:**
- Build succeeds: `make build`

**Estimated Effort:** 15 minutes

---

### 4. Create MessageDTO and mapping

**File:** `PrototypeChatClientApp/Infrastructure/Network/DTOs/MessageDTO+Mapping.swift` (new file)

**Description:**
Create DTO for API communication and mapping to domain entity.

**Steps:**
1. Create `MessageDTO+Mapping.swift`
2. Define `MessageDTO` struct matching OpenAPI schema
3. Implement mapping from DTO to Message entity
4. Implement mapping from Message to DTO (for request body)

**Code Template:**
```swift
import Foundation

// This will be generated by OpenAPI Generator, but we define extension for mapping
extension Components.Schemas.Message {
    func toDomain() -> Message {
        Message(
            id: id,
            conversationId: conversationId,
            senderUserId: senderUserId,
            type: type == "text" ? .text : .system,
            text: text,
            createdAt: createdAt,
            replyToMessageId: replyToMessageId,
            systemEvent: systemEvent
        )
    }
}

extension Components.Schemas.SendMessageRequest {
    static func from(senderUserId: String, text: String) -> Self {
        Self(
            senderUserId: senderUserId,
            type: "text",
            text: text,
            replyToMessageId: nil,
            systemEvent: nil
        )
    }
}
```

**Expected Outcome:**
- DTO mapping extensions created
- toDomain() method converts API response to Message
- from() method creates request body from parameters

**Validation:**
- Build succeeds: `make build`

**Estimated Effort:** 10 minutes

---

### 5. Create MessageRepository using OpenAPI client

**File:** `PrototypeChatClientApp/Infrastructure/Network/Repositories/MessageRepository.swift` (new file)

**Description:**
Create the repository that communicates with the backend API using OpenAPI generated client.

**Steps:**
1. Create `MessageRepository.swift`
2. Implement `MessageRepositoryProtocol`
3. Use OpenAPI `Client` for API calls
4. Map DTOs to domain entities
5. Add error logging

**Code Template:**
```swift
import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

class MessageRepository: MessageRepositoryProtocol {
    private let client: Client

    init(client: Client) {
        self.client = client
    }

    func fetchMessages(conversationId: String, userId: String, limit: Int) async throws -> [Message] {
        do {
            let response = try await client.get_sol_conversations_sol__id__sol_messages(
                path: .init(id: conversationId),
                query: .init(
                    userId: userId,
                    limit: limit,
                    before: nil
                )
            )

            switch response {
            case .ok(let okResponse):
                let messageDTOs = try okResponse.body.json
                return messageDTOs.map { $0.toDomain() }
            case .undocumented(statusCode: let statusCode, _):
                print("❌ [MessageRepository] fetchMessages failed - status \(statusCode)")
                throw NetworkError.unexpectedStatusCode(statusCode)
            }
        } catch let error as NetworkError {
            print("❌ [MessageRepository] fetchMessages failed - NetworkError: \(error)")
            throw error
        } catch {
            print("❌ [MessageRepository] fetchMessages failed - Unexpected error: \(error)")
            throw error
        }
    }

    func sendMessage(conversationId: String, senderUserId: String, text: String) async throws -> Message {
        do {
            let request = Components.Schemas.SendMessageRequest.from(
                senderUserId: senderUserId,
                text: text
            )

            let response = try await client.post_sol_conversations_sol__id__sol_messages(
                path: .init(id: conversationId),
                body: .json(request)
            )

            switch response {
            case .created(let createdResponse):
                let messageDTO = try createdResponse.body.json
                return messageDTO.toDomain()
            case .undocumented(statusCode: let statusCode, _):
                print("❌ [MessageRepository] sendMessage failed - status \(statusCode)")
                throw NetworkError.unexpectedStatusCode(statusCode)
            }
        } catch let error as NetworkError {
            print("❌ [MessageRepository] sendMessage failed - NetworkError: \(error)")
            throw error
        } catch {
            print("❌ [MessageRepository] sendMessage failed - Unexpected error: \(error)")
            throw error
        }
    }
}
```

**Expected Outcome:**
- MessageRepository created with OpenAPI client
- Proper error handling and logging
- DTO to domain mapping

**Validation:**
- Build succeeds: `make build`

**Estimated Effort:** 20 minutes

---

### 6. Create ChatRoomViewModel

**File:** `PrototypeChatClientApp/Features/Chat/Presentation/ViewModels/ChatRoomViewModel.swift` (new file)

**Description:**
Create the ViewModel that manages chat room state and handles user interactions.

**Steps:**
1. Create `ChatRoomViewModel.swift` with `@MainActor`
2. Add `@Published` properties for state management
3. Implement `loadMessages()` method
4. Implement `sendMessage()` method
5. Handle loading and error states
6. Handle URLError.cancelled for cancellation

**Code Template:**
```swift
import Foundation
import Combine

@MainActor
class ChatRoomViewModel: ObservableObject {
    // MARK: - Properties
    private let messageUseCase: MessageUseCase
    private let conversationId: String
    let currentUserId: String

    @Published var messages: [Message] = []
    @Published var messageText: String = ""
    @Published var isLoading: Bool = false
    @Published var isSending: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false

    // MARK: - Initialization
    init(
        messageUseCase: MessageUseCase,
        conversationId: String,
        currentUserId: String
    ) {
        self.messageUseCase = messageUseCase
        self.conversationId = conversationId
        self.currentUserId = currentUserId
    }

    // MARK: - Methods
    func loadMessages() async {
        isLoading = true
        errorMessage = nil
        showError = false

        do {
            messages = try await messageUseCase.fetchMessages(
                conversationId: conversationId,
                userId: currentUserId,
                limit: 50
            )
        } catch {
            if let urlError = error as? URLError, urlError.code == .cancelled {
                print("ℹ️ [ChatRoomViewModel] loadMessages cancelled")
            } else if (error as NSError).code == NSURLErrorCancelled {
                print("ℹ️ [ChatRoomViewModel] loadMessages cancelled")
            } else {
                let message = "メッセージの取得に失敗しました: \(error.localizedDescription)"
                print("❌ [ChatRoomViewModel] loadMessages failed - \(error)")
                errorMessage = message
                showError = true
            }
        }

        isLoading = false
    }

    func sendMessage() async {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        let textToSend = messageText
        messageText = "" // Clear immediately for better UX

        isSending = true
        errorMessage = nil
        showError = false

        do {
            let newMessage = try await messageUseCase.sendMessage(
                conversationId: conversationId,
                senderUserId: currentUserId,
                text: textToSend
            )

            // Add to local messages array
            messages.append(newMessage)
        } catch {
            let message = "メッセージの送信に失敗しました: \(error.localizedDescription)"
            print("❌ [ChatRoomViewModel] sendMessage failed - \(error)")
            errorMessage = message
            showError = true

            // Restore text on error
            messageText = textToSend
        }

        isSending = false
    }

    var canSendMessage: Bool {
        !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSending
    }

    func isOwnMessage(_ message: Message) -> Bool {
        message.senderUserId == currentUserId
    }
}
```

**Expected Outcome:**
- ChatRoomViewModel created with state management
- loadMessages and sendMessage methods implemented
- Proper error handling
- Helper methods for UI

**Validation:**
- Build succeeds: `make build`

**Estimated Effort:** 25 minutes

---

### 7. Create MessageBubbleView component

**File:** `PrototypeChatClientApp/Features/Chat/Presentation/Views/MessageBubbleView.swift` (new file)

**Description:**
Create reusable message bubble component with different styles for sent/received messages.

**Steps:**
1. Create `MessageBubbleView.swift`
2. Accept `message` and `isOwnMessage` parameters
3. Implement bubble with conditional styling
4. Add sender name for received messages
5. Add timestamp formatting

**Code Template:**
```swift
import SwiftUI

struct MessageBubbleView: View {
    let message: Message
    let isOwnMessage: Bool
    let senderName: String?

    var body: some View {
        HStack {
            if isOwnMessage {
                Spacer()
            }

            VStack(alignment: isOwnMessage ? .trailing : .leading, spacing: 4) {
                if !isOwnMessage, let senderName = senderName {
                    Text(senderName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text(message.text ?? "")
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(isOwnMessage ? Color.blue : Color(.systemGray5))
                    .foregroundColor(isOwnMessage ? .white : .primary)
                    .cornerRadius(16)

                Text(formattedTime)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: isOwnMessage ? .trailing : .leading)

            if !isOwnMessage {
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: message.createdAt)
    }
}

#Preview {
    VStack {
        MessageBubbleView(
            message: Message(
                id: "1",
                conversationId: "c1",
                senderUserId: "user-1",
                type: .text,
                text: "Hello from me!",
                createdAt: Date(),
                replyToMessageId: nil,
                systemEvent: nil
            ),
            isOwnMessage: true,
            senderName: nil
        )

        MessageBubbleView(
            message: Message(
                id: "2",
                conversationId: "c1",
                senderUserId: "user-2",
                type: .text,
                text: "Hello from Bob!",
                createdAt: Date(),
                replyToMessageId: nil,
                systemEvent: nil
            ),
            isOwnMessage: false,
            senderName: "Bob"
        )
    }
}
```

**Expected Outcome:**
- MessageBubbleView created with conditional styling
- Sender name shown for received messages
- Timestamp formatted correctly
- Preview working

**Validation:**
- Build succeeds: `make build`
- Preview renders correctly in Xcode

**Estimated Effort:** 20 minutes

---

### 8. Create MessageInputView component

**File:** `PrototypeChatClientApp/Features/Chat/Presentation/Views/MessageInputView.swift` (new file)

**Description:**
Create the text input component fixed at the bottom of the screen.

**Steps:**
1. Create `MessageInputView.swift`
2. Add TextField with binding to message text
3. Add Send button with conditional styling
4. Implement send action callback
5. Add keyboard handling

**Code Template:**
```swift
import SwiftUI

struct MessageInputView: View {
    @Binding var messageText: String
    let canSend: Bool
    let isSending: Bool
    let onSend: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            TextField("メッセージを入力", text: $messageText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...5)
                .accessibilityLabel("メッセージを入力")

            Button(action: onSend) {
                if isSending {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Image(systemName: "paperplane.fill")
                }
            }
            .disabled(!canSend)
            .foregroundColor(canSend ? .blue : .gray)
            .accessibilityLabel("送信")
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
}

#Preview {
    VStack {
        Spacer()
        MessageInputView(
            messageText: .constant(""),
            canSend: false,
            isSending: false,
            onSend: {}
        )
        MessageInputView(
            messageText: .constant("Hello"),
            canSend: true,
            isSending: false,
            onSend: {}
        )
        MessageInputView(
            messageText: .constant("Sending..."),
            canSend: false,
            isSending: true,
            onSend: {}
        )
    }
}
```

**Expected Outcome:**
- MessageInputView created
- Send button with conditional styling
- Loading indicator during send
- Preview working

**Validation:**
- Build succeeds: `make build`
- Preview renders correctly

**Estimated Effort:** 15 minutes

---

### 9. Create ChatRoomView

**File:** `PrototypeChatClientApp/Features/Chat/Presentation/Views/ChatRoomView.swift` (new file)

**Description:**
Create the main chat room screen that combines all components.

**Steps:**
1. Create `ChatRoomView.swift`
2. Add ScrollViewReader for auto-scroll
3. Implement message list with LazyVStack
4. Add MessageInputView at bottom
5. Add loading and error states
6. Add pull-to-refresh
7. Implement auto-scroll to bottom

**Code Template:**
```swift
import SwiftUI

struct ChatRoomView: View {
    @StateObject private var viewModel: ChatRoomViewModel
    let conversationDetail: ConversationDetail

    init(
        viewModel: ChatRoomViewModel,
        conversationDetail: ConversationDetail
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.conversationDetail = conversationDetail
    }

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading && viewModel.messages.isEmpty {
                loadingView
            } else if viewModel.messages.isEmpty {
                emptyStateView
            } else {
                messageListView
            }

            Divider()

            MessageInputView(
                messageText: $viewModel.messageText,
                canSend: viewModel.canSendMessage,
                isSending: viewModel.isSending,
                onSend: {
                    Task {
                        await viewModel.sendMessage()
                    }
                }
            )
        }
        .navigationTitle(conversationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $viewModel.showError) {
            Alert(
                title: Text("エラー"),
                message: Text(viewModel.errorMessage ?? "不明なエラー"),
                dismissButton: .default(Text("OK"))
            )
        }
        .task {
            await viewModel.loadMessages()
        }
    }

    private var messageListView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.messages) { message in
                        MessageBubbleView(
                            message: message,
                            isOwnMessage: viewModel.isOwnMessage(message),
                            senderName: senderName(for: message)
                        )
                        .id(message.id)
                    }
                }
                .padding(.vertical, 8)
            }
            .refreshable {
                await viewModel.loadMessages()
            }
            .onChange(of: viewModel.messages.count) { _ in
                // Auto-scroll to bottom when new message is added
                if let lastMessage = viewModel.messages.last {
                    withAnimation {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            .onAppear {
                // Scroll to bottom on initial load
                if let lastMessage = viewModel.messages.last {
                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            Text("まだメッセージがありません")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("読み込み中...")
                .foregroundColor(.secondary)
        }
    }

    private var conversationTitle: String {
        switch conversationDetail.type {
        case .group:
            return conversationDetail.conversation.name ?? "グループチャット"
        case .direct:
            let otherParticipant = conversationDetail.activeParticipants.first {
                $0.userId != viewModel.currentUserId
            }
            return otherParticipant?.user.name ?? "チャット"
        }
    }

    private func senderName(for message: Message) -> String? {
        guard !viewModel.isOwnMessage(message) else { return nil }

        let participant = conversationDetail.activeParticipants.first {
            $0.userId == message.senderUserId
        }
        return participant?.user.name
    }
}
```

**Expected Outcome:**
- ChatRoomView created with all components
- Auto-scroll to bottom on load and new messages
- Pull-to-refresh working
- Empty state and loading state

**Validation:**
- Build succeeds: `make build`

**Estimated Effort:** 30 minutes

---

### 10. Update ConversationListView navigation

**File:** `PrototypeChatClientApp/Features/Chat/Presentation/Views/ConversationListView.swift`

**Description:**
Replace the placeholder NavigationLink with actual navigation to ChatRoomView.

**Steps:**
1. Update the NavigationLink destination from placeholder Text to ChatRoomView
2. Create ChatRoomViewModel instance
3. Pass conversationDetail to ChatRoomView

**Code Changes:**

Replace:
```swift
NavigationLink {
    // チャット詳細画面は後で実装
    Text("チャット詳細画面（未実装）")
} label: {
    conversationRow(for: detail)
}
```

With:
```swift
NavigationLink {
    ChatRoomView(
        viewModel: makeChatRoomViewModel(for: detail),
        conversationDetail: detail
    )
} label: {
    conversationRow(for: detail)
}
```

Add method:
```swift
private func makeChatRoomViewModel(for detail: ConversationDetail) -> ChatRoomViewModel {
    let container = DependencyContainer.shared
    return ChatRoomViewModel(
        messageUseCase: container.messageUseCase,
        conversationId: detail.id,
        currentUserId: viewModel.currentUserId
    )
}
```

**Expected Outcome:**
- Tapping conversation navigates to ChatRoomView
- ViewModel properly initialized
- No compilation errors

**Validation:**
- Build succeeds: `make build`

**Estimated Effort:** 10 minutes

---

### 11. Update DependencyContainer

**File:** `PrototypeChatClientApp/App/DependencyContainer.swift`

**Description:**
Add MessageUseCase and MessageRepository to the dependency container.

**Steps:**
1. Add `messageRepository` lazy property
2. Add `messageUseCase` lazy property
3. Use MockMessageRepository for preview container

**Code Changes:**

Add to DependencyContainer:
```swift
@MainActor
lazy var messageRepository: MessageRepositoryProtocol = {
    MessageRepository(client: apiClient)
}()

@MainActor
lazy var messageUseCase: MessageUseCase = {
    MessageUseCase(messageRepository: messageRepository)
}()
```

Update `makePreviewContainer()`:
```swift
static func makePreviewContainer() -> DependencyContainer {
    let container = DependencyContainer()

    // Use mock repositories for preview
    container.conversationRepository = MockConversationRepository()
    container.messageRepository = MockMessageRepository()  // Add this line

    return container
}
```

**Expected Outcome:**
- MessageUseCase available through DependencyContainer
- Preview container uses mock repository
- No compilation errors

**Validation:**
- Build succeeds: `make build`

**Estimated Effort:** 10 minutes

---

### 12. Add Message test data to MockData

**File:** `PrototypeChatClientApp/Features/Chat/Testing/MockData.swift`

**Description:**
Add sample Message objects for testing and previews.

**Steps:**
1. Add static `sampleMessages` array
2. Create messages for different users
3. Create messages with different timestamps

**Code Changes:**

Add to `MockData`:
```swift
static let sampleMessages: [Message] = [
    Message(
        id: "msg-1",
        conversationId: "conv-1",
        senderUserId: "user-1",
        type: .text,
        text: "こんにちは！",
        createdAt: Date().addingTimeInterval(-3600),
        replyToMessageId: nil,
        systemEvent: nil
    ),
    Message(
        id: "msg-2",
        conversationId: "conv-1",
        senderUserId: "user-2",
        type: .text,
        text: "お元気ですか？",
        createdAt: Date().addingTimeInterval(-1800),
        replyToMessageId: nil,
        systemEvent: nil
    ),
    Message(
        id: "msg-3",
        conversationId: "conv-1",
        senderUserId: "user-1",
        type: .text,
        text: "はい、元気です！ありがとうございます。",
        createdAt: Date().addingTimeInterval(-900),
        replyToMessageId: nil,
        systemEvent: nil
    )
]
```

**Expected Outcome:**
- Sample messages available for testing
- Messages have different senders and timestamps

**Validation:**
- Build succeeds: `make build`

**Estimated Effort:** 5 minutes

---

### 13. Write MessageUseCase unit tests

**File:** `PrototypeChatClientAppTests/Features/Chat/Domain/UseCases/MessageUseCaseTests.swift` (new file)

**Description:**
Write comprehensive unit tests for MessageUseCase.

**Steps:**
1. Create test file
2. Test fetchMessages success case
3. Test fetchMessages with limit
4. Test sendMessage success case
5. Test sendMessage with empty text (should fail)
6. Test error propagation

**Code Template:**
```swift
import XCTest
@testable import PrototypeChatClientApp

@MainActor
final class MessageUseCaseTests: XCTestCase {
    var sut: MessageUseCase!
    var mockRepository: MockMessageRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockMessageRepository()
        sut = MessageUseCase(messageRepository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    func test_fetchMessages_returnsMessages() async throws {
        // Given
        let conversationId = "conv-1"
        let userId = "user-1"

        // When
        let messages = try await sut.fetchMessages(
            conversationId: conversationId,
            userId: userId,
            limit: 50
        )

        // Then
        XCTAssertFalse(messages.isEmpty)
        XCTAssertTrue(messages.allSatisfy { $0.conversationId == conversationId })
    }

    func test_sendMessage_createsNewMessage() async throws {
        // Given
        let conversationId = "conv-1"
        let senderUserId = "user-1"
        let text = "Test message"

        // When
        let message = try await sut.sendMessage(
            conversationId: conversationId,
            senderUserId: senderUserId,
            text: text
        )

        // Then
        XCTAssertEqual(message.conversationId, conversationId)
        XCTAssertEqual(message.senderUserId, senderUserId)
        XCTAssertEqual(message.text, text)
        XCTAssertEqual(message.type, .text)
    }

    func test_sendMessage_emptyText_throwsError() async {
        // Given
        let conversationId = "conv-1"
        let senderUserId = "user-1"
        let text = "   " // whitespace only

        // When/Then
        do {
            _ = try await sut.sendMessage(
                conversationId: conversationId,
                senderUserId: senderUserId,
                text: text
            )
            XCTFail("Should throw error for empty message")
        } catch {
            // Success
        }
    }
}
```

**Expected Outcome:**
- MessageUseCaseTests created with 3+ test cases
- All tests pass

**Validation:**
- Tests pass: `make test`

**Estimated Effort:** 20 minutes

---

### 14. Build and run manual tests

**Description:**
Test the complete messaging flow in the iOS simulator.

**Test Steps:**
1. Run app: `make run`
2. Login as `user-1` (Alice)
3. Tap on a conversation to open chat room
4. Verify message list displays correctly
5. Verify own messages are right-aligned with blue bubbles
6. Verify other messages are left-aligned with gray bubbles
7. Type a message in the input field
8. Tap send button
9. Verify message appears in the list
10. Verify scroll position is at bottom
11. Pull to refresh the message list
12. Verify refresh indicator appears
13. Navigate back to conversation list
14. Navigate to chat room again
15. Verify messages persist

**Error Scenarios:**
1. Try to send empty message → send button should be disabled
2. Simulate network error → error alert should appear

**Expected Outcome:**
- Full messaging flow works correctly
- UI matches design specifications
- No crashes or unexpected behavior

**Validation:**
- Take screenshots of key screens
- Verify all scenarios from spec

**Estimated Effort:** 30 minutes

---

### 15. Verify all tests pass

**Description:**
Run the full test suite to ensure no regressions.

**Steps:**
1. Run all tests: `make test`
2. Verify all existing tests pass
3. Verify new MessageUseCase tests pass
4. Check for any warnings

**Expected Outcome:**
- All tests pass without errors
- No new warnings introduced

**Validation:**
- `make test` exits with success code

**Estimated Effort:** 5 minutes

---

## Task Summary

| # | Task | Type | Effort | Dependencies |
|---|------|------|--------|--------------|
| 1 | Create Message entity | Code | 10 min | None |
| 2 | Create MessageUseCase | Code | 15 min | Task 1 |
| 3 | Create MockMessageRepository | Code | 15 min | Task 1, 2 |
| 4 | Create MessageDTO mapping | Code | 10 min | Task 1 |
| 5 | Create MessageRepository | Code | 20 min | Task 1, 2, 4 |
| 6 | Create ChatRoomViewModel | Code | 25 min | Task 2 |
| 7 | Create MessageBubbleView | Code | 20 min | Task 1 |
| 8 | Create MessageInputView | Code | 15 min | None |
| 9 | Create ChatRoomView | Code | 30 min | Task 6, 7, 8 |
| 10 | Update ConversationListView | Code | 10 min | Task 9 |
| 11 | Update DependencyContainer | Code | 10 min | Task 2, 5 |
| 12 | Add mock Message data | Code | 5 min | Task 1 |
| 13 | Write MessageUseCase tests | Test | 20 min | Task 2 |
| 14 | Manual testing | Test | 30 min | All code tasks |
| 15 | Verify all tests pass | Test | 5 min | All tasks |

**Total Estimated Time:** 240 minutes (4 hours)

---

## Parallel Execution

- Tasks 1, 7, 8 can be done in parallel (entity, UI components)
- Tasks 2 and 3 can start after Task 1
- Tasks 4 and 5 can be done in parallel after Task 1
- Tasks 13, 14, 15 can be done in parallel after all code tasks complete

---

## Success Checklist

- [ ] Message entity created with all properties
- [ ] MessageUseCase created with fetch and send methods
- [ ] MessageRepository implements API calls with OpenAPI client
- [ ] MockMessageRepository works for testing
- [ ] ChatRoomViewModel manages state correctly
- [ ] ChatRoomView displays messages in bubble format
- [ ] MessageBubbleView shows sent/received styling correctly
- [ ] MessageInputView handles text input and send button
- [ ] Navigation from conversation list to chat room works
- [ ] Messages display in chronological order (oldest to newest)
- [ ] Own messages are right-aligned with blue bubbles
- [ ] Other messages are left-aligned with gray bubbles
- [ ] Auto-scroll to bottom on load and new message
- [ ] Pull-to-refresh fetches new messages
- [ ] Empty state displays when no messages
- [ ] Loading state displays during fetch
- [ ] Error alerts display on API errors
- [ ] Send button disabled when text is empty
- [ ] Message sending shows loading indicator
- [ ] All existing tests pass (`make test`)
- [ ] New MessageUseCase tests pass
- [ ] Manual testing confirms all flows work
- [ ] No memory leaks or crashes

---

## Rollback Plan

If issues are discovered:
1. Revert ConversationListView navigation (restore placeholder)
2. Remove ChatRoomView and related view files
3. Remove ChatRoomViewModel
4. Remove MessageUseCase and repositories from DependencyContainer
5. Remove Message-related domain code
6. No database or backend changes, so no migration needed
