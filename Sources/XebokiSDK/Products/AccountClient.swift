import Foundation

// MARK: - Models

public struct UserProfile: Codable, Sendable {
    public let id: Int
    public let email: String
    public let fullName: String
    public let products: [String]
    public let createdAt: String
    public let updatedAt: String
}

public struct UpdateProfileParams: Encodable, Sendable {
    public var fullName: String?
    public var email: String?

    public init(fullName: String? = nil, email: String? = nil) {
        self.fullName = fullName; self.email = email
    }
}

public struct AccountSubscription: Codable, Sendable {
    public let id: String
    public let product: String
    public let plan: String
    public let status: String
    public let currentPeriodStart: String
    public let currentPeriodEnd: String
    public let cancelAtPeriodEnd: Bool
}

public struct Invoice: Codable, Sendable {
    public let id: String
    public let amount: Double
    public let currency: String
    public let status: String
    public let description: String?
    public let pdfUrl: String?
    public let createdAt: String
    public let paidAt: String?
}

public struct PaymentMethod: Codable, Sendable {
    public let id: String
    public let type: String
    public let brand: String?
    public let last4: String?
    public let expMonth: Int?
    public let expYear: Int?
    public let isDefault: Bool
}

// MARK: - Client

public final class AccountClient: @unchecked Sendable {
    private let http: HTTPClient
    private let onRateLimit: @Sendable (RateLimitInfo) -> Void

    init(http: HTTPClient, onRateLimit: @escaping @Sendable (RateLimitInfo) -> Void) {
        self.http = http; self.onRateLimit = onRateLimit
    }

    private func call<T: Decodable>(method: HTTPMethod, path: String,
                                    query: [String: String]? = nil,
                                    body: (any Encodable)? = nil) async throws -> T {
        let response: HTTPResponse<T> = try await http.request(method: method, path: path, query: query, body: body)
        onRateLimit(response.rateLimit)
        return response.data
    }

    public func getProfile() async throws -> UserProfile {
        try await call(method: .GET, path: "/v1/account/me")
    }

    public func updateProfile(_ params: UpdateProfileParams) async throws -> UserProfile {
        try await call(method: .PATCH, path: "/v1/account/me", body: params)
    }

    public func listSubscriptions() async throws -> ListResponse<AccountSubscription> {
        try await call(method: .GET, path: "/v1/account/subscriptions")
    }

    public func listInvoices(limit: Int? = nil, offset: Int? = nil) async throws -> ListResponse<Invoice> {
        var q: [String: String] = [:]
        if let l = limit { q["limit"] = String(l) }
        if let o = offset { q["offset"] = String(o) }
        return try await call(method: .GET, path: "/v1/account/invoices", query: q.isEmpty ? nil : q)
    }

    public func listPaymentMethods() async throws -> ListResponse<PaymentMethod> {
        try await call(method: .GET, path: "/v1/account/payment-methods")
    }
}
