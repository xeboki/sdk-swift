import Foundation

public enum HTTPMethod: String {
    case GET, POST, PUT, PATCH, DELETE
}

struct HTTPResponse<T: Decodable> {
    let data: T
    let rateLimit: RateLimitInfo
}

final class HTTPClient: @unchecked Sendable {
    private let baseURL: URL
    private let apiKey: String
    private let session: URLSession

    init(baseURL: URL, apiKey: String) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 120
        self.session = URLSession(configuration: config)
    }

    func request<T: Decodable>(
        method: HTTPMethod,
        path: String,
        query: [String: String]? = nil,
        body: (any Encodable)? = nil
    ) async throws -> HTTPResponse<T> {
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!

        if let query = query, !query.isEmpty {
            urlComponents.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = urlComponents.url else {
            throw XebokiError(status: 0, message: "Invalid URL for path: \(path)")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let body = body {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw XebokiError(status: 0, message: "Invalid response type")
        }

        let requestId = httpResponse.value(forHTTPHeaderField: "X-Request-Id")
        let rateLimit = RateLimitInfo(
            limit: Int(httpResponse.value(forHTTPHeaderField: "X-RateLimit-Limit") ?? "0") ?? 0,
            remaining: Int(httpResponse.value(forHTTPHeaderField: "X-RateLimit-Remaining") ?? "0") ?? 0,
            reset: Int(httpResponse.value(forHTTPHeaderField: "X-RateLimit-Reset") ?? "0") ?? 0,
            requestId: requestId ?? ""
        )

        guard (200...299).contains(httpResponse.statusCode) else {
            var errorMessage = "HTTP \(httpResponse.statusCode)"
            var retryAfter: Int? = nil

            if let errorBody = try? JSONDecoder().decode(APIErrorBody.self, from: data) {
                errorMessage = errorBody.message ?? errorBody.error ?? errorMessage
            }

            if httpResponse.statusCode == 429,
               let retryHeader = httpResponse.value(forHTTPHeaderField: "Retry-After") {
                retryAfter = Int(retryHeader)
            }

            throw XebokiError(
                status: httpResponse.statusCode,
                message: errorMessage,
                requestId: requestId,
                retryAfter: retryAfter
            )
        }

        // Handle empty body (204 No Content)
        if httpResponse.statusCode == 204 || data.isEmpty {
            if let empty = EmptyResponse() as? T {
                return HTTPResponse(data: empty, rateLimit: rateLimit)
            }
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        let decoded = try decoder.decode(T.self, from: data)
        return HTTPResponse(data: decoded, rateLimit: rateLimit)
    }
}

/// Used as a placeholder return type for DELETE/204 endpoints.
public struct EmptyResponse: Decodable, @unchecked Sendable {
    public init() {}
}

/// Generic paginated list response.
public struct ListResponse<T: Decodable & Sendable>: Decodable, Sendable {
    public let data: [T]
    public let total: Int
    public let limit: Int
    public let offset: Int
}
