import Foundation

// MARK: - Models

public struct ShortLink: Codable, Sendable {
    public let id: String
    public let shortCode: String
    public let shortUrl: String
    public let destinationUrl: String
    public let title: String?
    public let isActive: Bool
    public let clickCount: Int
    public let createdAt: String
    public let updatedAt: String
}

public struct CreateLinkParams: Encodable, Sendable {
    public let destinationUrl: String
    public let title: String?
    public let customCode: String?

    public init(destinationUrl: String, title: String? = nil, customCode: String? = nil) {
        self.destinationUrl = destinationUrl; self.title = title; self.customCode = customCode
    }
}

public struct UpdateLinkParams: Encodable, Sendable {
    public var destinationUrl: String?
    public var title: String?
    public var isActive: Bool?

    public init(destinationUrl: String? = nil, title: String? = nil, isActive: Bool? = nil) {
        self.destinationUrl = destinationUrl; self.title = title; self.isActive = isActive
    }
}

public struct LinkAnalytics: Codable, Sendable {
    public let linkId: String
    public let totalClicks: Int
    public let uniqueClicks: Int
    public let clicksByDay: [ClicksByDay]
    public let topReferrers: [TopReferrer]
    public let topCountries: [TopCountry]
}

public struct ClicksByDay: Codable, Sendable {
    public let date: String
    public let clicks: Int
}

public struct TopReferrer: Codable, Sendable {
    public let referrer: String
    public let clicks: Int
}

public struct TopCountry: Codable, Sendable {
    public let country: String
    public let clicks: Int
}

// MARK: - Client

public final class LinkClient: @unchecked Sendable {
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

    public func listLinks(limit: Int? = nil, offset: Int? = nil) async throws -> ListResponse<ShortLink> {
        var q: [String: String] = [:]
        if let l = limit { q["limit"] = String(l) }
        if let o = offset { q["offset"] = String(o) }
        return try await call(method: .GET, path: "/v1/link/links", query: q.isEmpty ? nil : q)
    }

    public func createLink(_ params: CreateLinkParams) async throws -> ShortLink {
        try await call(method: .POST, path: "/v1/link/links", body: params)
    }

    public func getLink(id: String) async throws -> ShortLink {
        try await call(method: .GET, path: "/v1/link/links/\(id)")
    }

    public func updateLink(id: String, params: UpdateLinkParams) async throws -> ShortLink {
        try await call(method: .PATCH, path: "/v1/link/links/\(id)", body: params)
    }

    public func deleteLink(id: String) async throws -> EmptyResponse {
        try await call(method: .DELETE, path: "/v1/link/links/\(id)")
    }

    public func getAnalytics(id: String, startDate: String? = nil, endDate: String? = nil) async throws -> LinkAnalytics {
        var q: [String: String] = [:]
        if let s = startDate { q["start_date"] = s }
        if let e = endDate { q["end_date"] = e }
        return try await call(method: .GET, path: "/v1/link/analytics/\(id)", query: q.isEmpty ? nil : q)
    }
}
