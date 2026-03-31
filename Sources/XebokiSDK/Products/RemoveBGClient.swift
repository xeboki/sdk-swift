import Foundation

// MARK: - Models

public struct ProcessedImage: Codable, Sendable {
    public let id: String
    public let resultUrl: String
    public let format: String
    public let width: Int
    public let height: Int
    public let creditsUsed: Int
    public let createdAt: String
}

public struct ProcessImageParams: Encodable, Sendable {
    public let imageUrl: String?
    public let imageBase64: String?
    public let outputFormat: String?
    public let bgColor: String?

    public init(imageUrl: String? = nil, imageBase64: String? = nil,
                outputFormat: String? = nil, bgColor: String? = nil) {
        self.imageUrl = imageUrl; self.imageBase64 = imageBase64
        self.outputFormat = outputFormat; self.bgColor = bgColor
    }
}

public struct QuotaInfo: Codable, Sendable {
    public let plan: String
    public let creditsTotal: Int
    public let creditsUsed: Int
    public let creditsRemaining: Int
    public let resetsAt: String
}

public struct BatchJob: Codable, Sendable {
    public let id: String
    public let status: BatchStatus
    public let totalImages: Int
    public let processedImages: Int
    public let failedImages: Int
    public let results: [BatchResult]?
    public let createdAt: String
    public let completedAt: String?
}

public enum BatchStatus: String, Codable, Sendable {
    case queued, processing, completed, failed
}

public struct BatchResult: Codable, Sendable {
    public let index: Int
    public let status: String
    public let resultUrl: String?
    public let error: String?
}

public struct SubmitBatchParams: Encodable, Sendable {
    public let images: [BatchImageInput]
    public let outputFormat: String?

    public init(images: [BatchImageInput], outputFormat: String? = nil) {
        self.images = images; self.outputFormat = outputFormat
    }
}

public struct BatchImageInput: Encodable, Sendable {
    public let imageUrl: String?
    public let imageBase64: String?

    public init(imageUrl: String? = nil, imageBase64: String? = nil) {
        self.imageUrl = imageUrl; self.imageBase64 = imageBase64
    }
}

// MARK: - Client

public final class RemoveBGClient: @unchecked Sendable {
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

    public func process(_ params: ProcessImageParams) async throws -> ProcessedImage {
        try await call(method: .POST, path: "/v1/removebg/process", body: params)
    }

    public func getQuota() async throws -> QuotaInfo {
        try await call(method: .GET, path: "/v1/removebg/quota")
    }

    public func submitBatch(_ params: SubmitBatchParams) async throws -> BatchJob {
        try await call(method: .POST, path: "/v1/removebg/batch", body: params)
    }

    public func getBatch(id: String) async throws -> BatchJob {
        try await call(method: .GET, path: "/v1/removebg/batch/\(id)")
    }
}
