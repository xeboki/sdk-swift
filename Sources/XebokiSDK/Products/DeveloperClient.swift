import Foundation

// MARK: - Models

public struct ApiKey: Codable, Sendable {
    public let id: String
    public let name: String
    public let keyPrefix: String
    public let scopes: [String]
    public let locationIds: [String]?
    public let isActive: Bool
    public let createdAt: String
    public let expiresAt: String?
    public let lastUsedAt: String?
}

public struct CreatedApiKey: Codable, Sendable {
    public let id: String
    public let name: String
    /// Full key — returned ONCE at creation. Store securely.
    public let key: String
    public let keyPrefix: String
    public let scopes: [String]
    public let locationIds: [String]?
    public let createdAt: String
    public let expiresAt: String?
    public let warning: String
}

public struct DeveloperWebhook: Codable, Sendable {
    public let id: String
    public let url: String
    public let events: [String]
    public let description: String?
    public let isActive: Bool
    public let secretPrefix: String
    public let createdAt: String
    public let lastTriggeredAt: String?
    public let failureCount: Int
}

public struct CreateApiKeyParams: Encodable, Sendable {
    public var name: String
    public var scopes: [String]
    public var locationIds: [String]?
    public var expiresAt: String?

    public init(name: String, scopes: [String],
                locationIds: [String]? = nil, expiresAt: String? = nil) {
        self.name = name
        self.scopes = scopes
        self.locationIds = locationIds
        self.expiresAt = expiresAt
    }
}

public struct RegisterWebhookParams: Encodable, Sendable {
    public var url: String
    public var events: [String]
    public var description: String?

    public init(url: String, events: [String], description: String? = nil) {
        self.url = url
        self.events = events
        self.description = description
    }
}

public struct TestWebhookParams: Encodable, Sendable {
    public var event: String

    public init(event: String = "order.created") {
        self.event = event
    }
}

public struct TestWebhookResponse: Codable, Sendable {
    public let status: String
    public let event: String
    public let url: String
}

public struct ScopesResponse: Codable, Sendable {
    public let scopes: [String]
}

public struct EventsResponse: Codable, Sendable {
    public let events: [String]
}

// MARK: - Client

/// Manage API keys and webhook endpoints for a subscriber.
///
/// Requires a POS JWT issued to an admin-role user.
/// All calls are scoped to the authenticated subscriber.
///
/// ```swift
/// let xeboki = XebokiClient(apiKey: "xbk_live_...")
///
/// // List API keys
/// let keys = try await xeboki.developer.listApiKeys()
///
/// // Create a key (key is shown ONCE — store it securely)
/// let created = try await xeboki.developer.createApiKey(
///     CreateApiKeyParams(name: "Mobile Storefront", scopes: ["pos:read", "orders:write"])
/// )
///
/// // Register a webhook
/// let hook = try await xeboki.developer.registerWebhook(
///     RegisterWebhookParams(url: "https://example.com/hook",
///                           events: ["order.created"])
/// )
/// ```
public actor DeveloperClient {
    private let http: HTTPClient
    private let onRateLimit: @Sendable (RateLimitInfo) -> Void

    init(http: HTTPClient, onRateLimit: @escaping @Sendable (RateLimitInfo) -> Void) {
        self.http = http
        self.onRateLimit = onRateLimit
    }

    private func call<T: Decodable>(
        method: HTTPMethod,
        path: String,
        query: [String: String]? = nil,
        body: (any Encodable)? = nil
    ) async throws -> T {
        let response: HTTPResponse<T> = try await http.request(
            method: method, path: path, query: query, body: body)
        onRateLimit(response.rateLimit)
        return response.data
    }

    // MARK: API Keys

    public func listApiKeys() async throws -> [ApiKey] {
        try await call(method: .GET, path: "/v1/developer/api-keys")
    }

    public func createApiKey(_ params: CreateApiKeyParams) async throws -> CreatedApiKey {
        try await call(method: .POST, path: "/v1/developer/api-keys", body: params)
    }

    public func revokeApiKey(id: String) async throws {
        let _: EmptyResponse = try await call(method: .DELETE, path: "/v1/developer/api-keys/\(id)")
    }

    // MARK: Webhooks

    public func listWebhooks() async throws -> [DeveloperWebhook] {
        try await call(method: .GET, path: "/v1/developer/webhooks")
    }

    public func registerWebhook(_ params: RegisterWebhookParams) async throws -> DeveloperWebhook {
        try await call(method: .POST, path: "/v1/developer/webhooks", body: params)
    }

    public func deleteWebhook(id: String) async throws {
        let _: EmptyResponse = try await call(method: .DELETE, path: "/v1/developer/webhooks/\(id)")
    }

    public func testWebhook(id: String, event: String = "order.created") async throws -> TestWebhookResponse {
        try await call(method: .POST, path: "/v1/developer/webhooks/\(id)/test",
                      body: TestWebhookParams(event: event))
    }

    // MARK: Discovery

    public func listScopes() async throws -> [String] {
        let r: ScopesResponse = try await call(method: .GET, path: "/v1/developer/scopes")
        return r.scopes
    }

    public func listEvents() async throws -> [String] {
        let r: EventsResponse = try await call(method: .GET, path: "/v1/developer/events")
        return r.events
    }
}
