import Foundation

/// Rate limit information extracted from response headers.
public struct RateLimitInfo: Sendable {
    public let limit: Int
    public let remaining: Int
    public let reset: Int
    public let requestId: String

    public init(limit: Int, remaining: Int, reset: Int, requestId: String) {
        self.limit = limit
        self.remaining = remaining
        self.reset = reset
        self.requestId = requestId
    }
}

/// An error returned by the Xeboki API.
public struct XebokiError: Error, CustomStringConvertible, Sendable {
    /// HTTP status code.
    public let status: Int
    /// Human-readable error message.
    public let message: String
    /// The X-Request-Id header value, if present.
    public let requestId: String?
    /// Number of seconds to wait before retrying (429 responses only).
    public let retryAfter: Int?

    public init(status: Int, message: String, requestId: String? = nil, retryAfter: Int? = nil) {
        self.status = status
        self.message = message
        self.requestId = requestId
        self.retryAfter = retryAfter
    }

    public var description: String {
        var parts = ["XebokiError(\(status)): \(message)"]
        if let rid = requestId { parts.append("requestId=\(rid)") }
        if let ra = retryAfter { parts.append("retryAfter=\(ra)s") }
        return parts.joined(separator: " ")
    }
}

/// Generic API error body.
struct APIErrorBody: Decodable {
    let message: String?
    let error: String?
}
