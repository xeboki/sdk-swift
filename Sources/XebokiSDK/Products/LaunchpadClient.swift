import Foundation

// MARK: - Models

public struct LaunchpadCustomer: Codable, Sendable {
    public let id: String
    public let name: String
    public let email: String
    public let phone: String?
    public let metadata: [String: String]?
    public let createdAt: String
    public let updatedAt: String
}

public struct CreateLaunchpadCustomerParams: Encodable, Sendable {
    public let name: String
    public let email: String
    public let phone: String?
    public let metadata: [String: String]?

    public init(name: String, email: String, phone: String? = nil, metadata: [String: String]? = nil) {
        self.name = name; self.email = email; self.phone = phone; self.metadata = metadata
    }
}

public struct Plan: Codable, Sendable {
    public let id: String
    public let name: String
    public let description: String?
    public let price: Double
    public let currency: String
    public let interval: String
    public let intervalCount: Int
    public let trialDays: Int
    public let features: [String]
    public let isActive: Bool
}

public struct LaunchpadSubscription: Codable, Sendable {
    public let id: String
    public let customerId: String
    public let planId: String
    public let planName: String
    public let status: String
    public let currentPeriodStart: String
    public let currentPeriodEnd: String
    public let trialEnd: String?
    public let cancelAtPeriodEnd: Bool
    public let createdAt: String
}

public struct CreateSubscriptionParams: Encodable, Sendable {
    public let customerId: String
    public let planId: String
    public let trialDays: Int?
    public let couponCode: String?

    public init(customerId: String, planId: String, trialDays: Int? = nil, couponCode: String? = nil) {
        self.customerId = customerId; self.planId = planId
        self.trialDays = trialDays; self.couponCode = couponCode
    }
}

public struct LaunchpadInvoice: Codable, Sendable {
    public let id: String
    public let customerId: String
    public let subscriptionId: String?
    public let amount: Double
    public let currency: String
    public let status: String
    public let pdfUrl: String?
    public let createdAt: String
    public let paidAt: String?
}

public struct Coupon: Codable, Sendable {
    public let id: String
    public let code: String
    public let discountType: String
    public let discountValue: Double
    public let maxRedemptions: Int?
    public let timesRedeemed: Int
    public let expiresAt: String?
    public let isActive: Bool
    public let createdAt: String
}

public struct CreateCouponParams: Encodable, Sendable {
    public let code: String
    public let discountType: DiscountType
    public let discountValue: Double
    public let maxRedemptions: Int?
    public let expiresAt: String?

    public init(code: String, discountType: DiscountType, discountValue: Double,
                maxRedemptions: Int? = nil, expiresAt: String? = nil) {
        self.code = code; self.discountType = discountType; self.discountValue = discountValue
        self.maxRedemptions = maxRedemptions; self.expiresAt = expiresAt
    }
}

public enum DiscountType: String, Encodable, Sendable {
    case percentage, fixed
}

public struct LaunchpadOverview: Codable, Sendable {
    public let mrr: Double
    public let arr: Double
    public let activeSubscriptions: Int
    public let churnRate: Double
    public let newSubscriptionsThisMonth: Int
    public let cancelledThisMonth: Int
    public let mrrGrowthPercent: Double
}

// MARK: - Client

public final class LaunchpadClient: @unchecked Sendable {
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

    public func listCustomers(limit: Int? = nil, offset: Int? = nil, search: String? = nil) async throws -> ListResponse<LaunchpadCustomer> {
        var q: [String: String] = [:]
        if let l = limit { q["limit"] = String(l) }
        if let o = offset { q["offset"] = String(o) }
        if let s = search { q["search"] = s }
        return try await call(method: .GET, path: "/v1/launchpad/customers", query: q.isEmpty ? nil : q)
    }

    public func createCustomer(_ params: CreateLaunchpadCustomerParams) async throws -> LaunchpadCustomer {
        try await call(method: .POST, path: "/v1/launchpad/customers", body: params)
    }

    public func getCustomer(id: String) async throws -> LaunchpadCustomer {
        try await call(method: .GET, path: "/v1/launchpad/customers/\(id)")
    }

    public func listSubscriptions(customerId: String? = nil, status: String? = nil) async throws -> ListResponse<LaunchpadSubscription> {
        var q: [String: String] = [:]
        if let c = customerId { q["customer_id"] = c }
        if let s = status { q["status"] = s }
        return try await call(method: .GET, path: "/v1/launchpad/subscriptions", query: q.isEmpty ? nil : q)
    }

    public func createSubscription(_ params: CreateSubscriptionParams) async throws -> LaunchpadSubscription {
        try await call(method: .POST, path: "/v1/launchpad/subscriptions", body: params)
    }

    public func cancelSubscription(id: String) async throws -> EmptyResponse {
        try await call(method: .DELETE, path: "/v1/launchpad/subscriptions/\(id)")
    }

    public func listPlans() async throws -> ListResponse<Plan> {
        try await call(method: .GET, path: "/v1/launchpad/plans")
    }

    public func listInvoices(customerId: String? = nil, limit: Int? = nil) async throws -> ListResponse<LaunchpadInvoice> {
        var q: [String: String] = [:]
        if let c = customerId { q["customer_id"] = c }
        if let l = limit { q["limit"] = String(l) }
        return try await call(method: .GET, path: "/v1/launchpad/invoices", query: q.isEmpty ? nil : q)
    }

    public func listCoupons() async throws -> ListResponse<Coupon> {
        try await call(method: .GET, path: "/v1/launchpad/coupons")
    }

    public func createCoupon(_ params: CreateCouponParams) async throws -> Coupon {
        try await call(method: .POST, path: "/v1/launchpad/coupons", body: params)
    }

    public func getOverview() async throws -> LaunchpadOverview {
        try await call(method: .GET, path: "/v1/launchpad/analytics/overview")
    }
}
