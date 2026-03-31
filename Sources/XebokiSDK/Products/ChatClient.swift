import Foundation

// MARK: - Models

public enum ConversationStatus: String, Codable, Sendable {
    case open, resolved, pending, snoozed
}

public enum ConversationChannel: String, Codable, Sendable {
    case web, email, sms, whatsapp, instagram, twitter
}

public struct Conversation: Codable, Sendable {
    public let id: String
    public let inboxId: String
    public let contactId: String
    public let assignedAgentId: String?
    public let status: ConversationStatus
    public let subject: String?
    public let channel: ConversationChannel
    public let unreadCount: Int
    public let firstReplyAt: String?
    public let resolvedAt: String?
    public let createdAt: String
    public let updatedAt: String
}

public struct CreateConversationParams: Encodable, Sendable {
    public let inboxId: String
    public let contactId: String
    public let assignedAgentId: String?
    public let subject: String?
    public let initialMessage: String?

    public init(inboxId: String, contactId: String, assignedAgentId: String? = nil,
                subject: String? = nil, initialMessage: String? = nil) {
        self.inboxId = inboxId; self.contactId = contactId
        self.assignedAgentId = assignedAgentId; self.subject = subject
        self.initialMessage = initialMessage
    }
}

public struct UpdateConversationParams: Encodable, Sendable {
    public var status: ConversationStatus?
    public var assignedAgentId: String??
    public var subject: String?

    public init(status: ConversationStatus? = nil, assignedAgentId: String?? = nil, subject: String? = nil) {
        self.status = status; self.assignedAgentId = assignedAgentId; self.subject = subject
    }
}

public enum MessageAuthorType: String, Codable, Sendable {
    case agent, contact, bot, system
}

public enum MessageContentType: String, Codable, Sendable {
    case text, image, file, template
}

public struct MessageAttachment: Codable, Sendable {
    public let type: String
    public let url: String
    public let name: String
    public let size: Int
}

public struct Message: Codable, Sendable {
    public let id: String
    public let conversationId: String
    public let authorType: MessageAuthorType
    public let authorId: String
    public let content: String
    public let contentType: MessageContentType
    public let attachments: [MessageAttachment]?
    public let isRead: Bool
    public let createdAt: String
    public let updatedAt: String
}

public struct SendMessageParams: Encodable, Sendable {
    public let content: String
    public let contentType: MessageContentType?
    public let attachments: [SendMessageAttachment]?

    public init(content: String, contentType: MessageContentType? = nil, attachments: [SendMessageAttachment]? = nil) {
        self.content = content; self.contentType = contentType; self.attachments = attachments
    }
}

public struct SendMessageAttachment: Encodable, Sendable {
    public let url: String
    public let name: String
    public let type: String
    public init(url: String, name: String, type: String) {
        self.url = url; self.name = name; self.type = type
    }
}

public enum AgentRole: String, Codable, Sendable {
    case agent, supervisor, admin
}

public struct Agent: Codable, Sendable {
    public let id: String
    public let name: String
    public let email: String
    public let role: AgentRole
    public let isAvailable: Bool
    public let inboxIds: [String]
    public let avatarUrl: String?
    public let createdAt: String
    public let updatedAt: String
}

public struct CreateAgentParams: Encodable, Sendable {
    public let name: String
    public let email: String
    public let role: AgentRole?
    public let inboxIds: [String]?

    public init(name: String, email: String, role: AgentRole? = nil, inboxIds: [String]? = nil) {
        self.name = name; self.email = email; self.role = role; self.inboxIds = inboxIds
    }
}

public struct Contact: Codable, Sendable {
    public let id: String
    public let name: String
    public let email: String?
    public let phone: String?
    public let company: String?
    public let avatarUrl: String?
    public let identifier: String?
    public let customAttributes: [String: String]?
    public let createdAt: String
    public let updatedAt: String
}

public struct CreateContactParams: Encodable, Sendable {
    public let name: String
    public let email: String?
    public let phone: String?
    public let company: String?
    public let identifier: String?
    public let customAttributes: [String: String]?

    public init(name: String, email: String? = nil, phone: String? = nil, company: String? = nil,
                identifier: String? = nil, customAttributes: [String: String]? = nil) {
        self.name = name; self.email = email; self.phone = phone; self.company = company
        self.identifier = identifier; self.customAttributes = customAttributes
    }
}

public struct Inbox: Codable, Sendable {
    public let id: String
    public let name: String
    public let channel: ConversationChannel
    public let isEnabled: Bool
    public let workingHoursEnabled: Bool
    public let outOfOfficeMessage: String?
    public let createdAt: String
    public let updatedAt: String
}

// MARK: - Client

public final class ChatClient: @unchecked Sendable {
    private let http: HTTPClient
    private let onRateLimit: @Sendable (RateLimitInfo) -> Void

    init(http: HTTPClient, onRateLimit: @escaping @Sendable (RateLimitInfo) -> Void) {
        self.http = http
        self.onRateLimit = onRateLimit
    }

    private func call<T: Decodable>(method: HTTPMethod, path: String,
                                    query: [String: String]? = nil,
                                    body: (any Encodable)? = nil) async throws -> T {
        let response: HTTPResponse<T> = try await http.request(method: method, path: path, query: query, body: body)
        onRateLimit(response.rateLimit)
        return response.data
    }

    public func listConversations(status: ConversationStatus? = nil, inboxId: String? = nil,
                                   assignedAgentId: String? = nil, limit: Int? = nil, offset: Int? = nil) async throws -> ListResponse<Conversation> {
        var q: [String: String] = [:]
        if let v = status { q["status"] = v.rawValue }
        if let v = inboxId { q["inbox_id"] = v }
        if let v = assignedAgentId { q["assigned_agent_id"] = v }
        if let v = limit { q["limit"] = String(v) }
        if let v = offset { q["offset"] = String(v) }
        return try await call(method: .GET, path: "/v1/chat/conversations", query: q.isEmpty ? nil : q)
    }

    public func createConversation(_ params: CreateConversationParams) async throws -> Conversation {
        try await call(method: .POST, path: "/v1/chat/conversations", body: params)
    }

    public func getConversation(id: String) async throws -> Conversation {
        try await call(method: .GET, path: "/v1/chat/conversations/\(id)")
    }

    public func updateConversation(id: String, params: UpdateConversationParams) async throws -> Conversation {
        try await call(method: .PATCH, path: "/v1/chat/conversations/\(id)", body: params)
    }

    public func listMessages(conversationId: String, limit: Int? = nil, before: String? = nil) async throws -> ListResponse<Message> {
        var q: [String: String] = [:]
        if let v = limit { q["limit"] = String(v) }
        if let v = before { q["before"] = v }
        return try await call(method: .GET, path: "/v1/chat/conversations/\(conversationId)/messages", query: q.isEmpty ? nil : q)
    }

    public func sendMessage(conversationId: String, params: SendMessageParams) async throws -> Message {
        try await call(method: .POST, path: "/v1/chat/conversations/\(conversationId)/messages", body: params)
    }

    public func listAgents(inboxId: String? = nil, isAvailable: Bool? = nil) async throws -> ListResponse<Agent> {
        var q: [String: String] = [:]
        if let v = inboxId { q["inbox_id"] = v }
        if let v = isAvailable { q["is_available"] = String(v) }
        return try await call(method: .GET, path: "/v1/chat/agents", query: q.isEmpty ? nil : q)
    }

    public func createAgent(_ params: CreateAgentParams) async throws -> Agent {
        try await call(method: .POST, path: "/v1/chat/agents", body: params)
    }

    public func listContacts(search: String? = nil, email: String? = nil, limit: Int? = nil, offset: Int? = nil) async throws -> ListResponse<Contact> {
        var q: [String: String] = [:]
        if let v = search { q["search"] = v }
        if let v = email { q["email"] = v }
        if let v = limit { q["limit"] = String(v) }
        if let v = offset { q["offset"] = String(v) }
        return try await call(method: .GET, path: "/v1/chat/contacts", query: q.isEmpty ? nil : q)
    }

    public func createContact(_ params: CreateContactParams) async throws -> Contact {
        try await call(method: .POST, path: "/v1/chat/contacts", body: params)
    }

    public func getContact(id: String) async throws -> Contact {
        try await call(method: .GET, path: "/v1/chat/contacts/\(id)")
    }

    public func listInboxes() async throws -> ListResponse<Inbox> {
        try await call(method: .GET, path: "/v1/chat/inboxes")
    }
}
