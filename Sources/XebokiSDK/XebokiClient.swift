import Foundation

/// Configuration options for XebokiClient.
public struct XebokiClientOptions: Sendable {
    public let apiKey: String
    public let baseURL: URL

    public init(apiKey: String, baseURL: URL = URL(string: "https://api.xeboki.com")!) {
        self.apiKey = apiKey
        self.baseURL = baseURL
    }
}

/// The main entry point for the Xeboki SDK.
///
/// ```swift
/// let xeboki = XebokiClient(options: XebokiClientOptions(apiKey: "xbk_live_..."))
/// let orders = try await xeboki.pos.listOrders()
/// ```
public final class XebokiClient: @unchecked Sendable {
    public let pos: POSClient
    public let chat: ChatClient
    public let link: LinkClient
    public let removebg: RemoveBGClient
    public let analytics: AnalyticsClient
    public let account: AccountClient
    public let launchpad: LaunchpadClient

    private var _lastRateLimit: RateLimitInfo?
    public var lastRateLimit: RateLimitInfo? { _lastRateLimit }

    public init(options: XebokiClientOptions) {
        precondition(options.apiKey.hasPrefix("xbk_"), "apiKey must start with xbk_live_ or xbk_test_")

        let http = HTTPClient(baseURL: options.baseURL, apiKey: options.apiKey)
        let onRateLimit: @Sendable (RateLimitInfo) -> Void = { [weak self] info in
            self?._lastRateLimit = info
        }

        self.pos = POSClient(http: http, onRateLimit: onRateLimit)
        self.chat = ChatClient(http: http, onRateLimit: onRateLimit)
        self.link = LinkClient(http: http, onRateLimit: onRateLimit)
        self.removebg = RemoveBGClient(http: http, onRateLimit: onRateLimit)
        self.analytics = AnalyticsClient(http: http, onRateLimit: onRateLimit)
        self.account = AccountClient(http: http, onRateLimit: onRateLimit)
        self.launchpad = LaunchpadClient(http: http, onRateLimit: onRateLimit)
    }

    /// Convenience initialiser accepting just the API key.
    public convenience init(apiKey: String) {
        self.init(options: XebokiClientOptions(apiKey: apiKey))
    }
}
