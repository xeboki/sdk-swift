import Foundation

// MARK: - Models

public struct AnalyticsReport: Codable, Sendable {
    public let id: String
    public let name: String
    public let description: String?
    public let product: String
    public let metrics: [String]
    public let availableGranularities: [String]
    public let createdAt: String
}

public struct ReportData: Codable, Sendable {
    public let reportId: String
    public let name: String
    public let product: String
    public let startDate: String
    public let endDate: String
    public let granularity: String
    public let rows: [[String: AnyCodable]]
    public let summary: [String: AnyCodable]?
}

public struct AnyCodable: Codable, Sendable {
    public let value: Any

    public init(_ value: Any) { self.value = value }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let v = try? container.decode(String.self) { value = v }
        else if let v = try? container.decode(Double.self) { value = v }
        else if let v = try? container.decode(Int.self) { value = v }
        else if let v = try? container.decode(Bool.self) { value = v }
        else { value = NSNull() }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let v = value as? String { try container.encode(v) }
        else if let v = value as? Double { try container.encode(v) }
        else if let v = value as? Int { try container.encode(v) }
        else if let v = value as? Bool { try container.encode(v) }
        else { try container.encodeNil() }
    }
}

public struct ExportReportParams: Encodable, Sendable {
    public let reportId: String
    public let format: ExportFormat
    public let startDate: String?
    public let endDate: String?

    public init(reportId: String, format: ExportFormat, startDate: String? = nil, endDate: String? = nil) {
        self.reportId = reportId; self.format = format
        self.startDate = startDate; self.endDate = endDate
    }
}

public enum ExportFormat: String, Encodable, Sendable {
    case csv, pdf
}

public struct ExportResult: Codable, Sendable {
    public let exportId: String
    public let downloadUrl: String
    public let format: String
    public let expiresAt: String
}

// MARK: - Client

public final class AnalyticsClient: @unchecked Sendable {
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

    public func listReports(product: String? = nil) async throws -> ListResponse<AnalyticsReport> {
        var q: [String: String] = [:]
        if let p = product { q["product"] = p }
        return try await call(method: .GET, path: "/v1/analytics/reports", query: q.isEmpty ? nil : q)
    }

    public func getReport(id: String, startDate: String? = nil, endDate: String? = nil, granularity: String? = nil) async throws -> ReportData {
        var q: [String: String] = [:]
        if let s = startDate { q["start_date"] = s }
        if let e = endDate { q["end_date"] = e }
        if let g = granularity { q["granularity"] = g }
        return try await call(method: .GET, path: "/v1/analytics/reports/\(id)", query: q.isEmpty ? nil : q)
    }

    public func exportReport(_ params: ExportReportParams) async throws -> ExportResult {
        try await call(method: .POST, path: "/v1/analytics/reports/export", body: params)
    }
}
