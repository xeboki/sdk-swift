# XebokiSDK for Swift

Official Swift SDK for the [Xeboki developer API](https://developers.xeboki.com). Supports iOS, macOS, tvOS, and watchOS with native `async/await` and zero third-party dependencies.

[![Swift 5.9+](https://img.shields.io/badge/Swift-5.9+-F05138.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/platforms-iOS%2015%20%7C%20macOS%2012%20%7C%20tvOS%2015%20%7C%20watchOS%208-lightgrey.svg)](Package.swift)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## Requirements

| Platform | Minimum version |
|----------|----------------|
| iOS      | 15.0           |
| macOS    | 12.0           |
| tvOS     | 15.0           |
| watchOS  | 8.0            |
| Swift    | 5.7            |

## Installation

### Swift Package Manager

In Xcode: **File → Add Package Dependencies** and enter:

```
https://github.com/xeboki/sdk-swift
```

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/xeboki/sdk-swift", from: "1.0.0"),
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [.product(name: "XebokiSDK", package: "sdk-swift")]
    ),
]
```

## Quick Start

```swift
import XebokiSDK

let xeboki = XebokiClient(apiKey: "xbk_live_...")

// List recent orders
let response = try await xeboki.pos.listOrders(
    params: .init(limit: 20, status: .completed)
)
print(response.data)

// Check rate limit after any call
if let rl = xeboki.lastRateLimit {
    print("\(rl.remaining)/\(rl.limit) requests remaining")
}
```

## Authentication

All requests are authenticated using an API key. Generate and manage your keys at [account.xeboki.com/developer](https://account.xeboki.com/developer).

| Key prefix     | Environment |
|----------------|-------------|
| `xbk_live_...` | Production  |
| `xbk_test_...` | Sandbox     |

**Never embed API keys in client-distributed app binaries.** For iOS apps, read the key from your server or a secured configuration source. Use `xbk_test_` keys during development.

## Client Configuration

```swift
// Simple — API key only
let xeboki = XebokiClient(apiKey: "xbk_live_...")

// Advanced — custom base URL (e.g. self-hosted gateway)
let options = XebokiClientOptions(
    apiKey: "xbk_live_...",
    baseURL: URL(string: "https://api.yourcompany.com")!
)
let xeboki = XebokiClient(options: options)
```

---

## Products

### `pos` — Point of Sale

Manage orders, products, inventory, customers, and sales reports.

#### Orders

```swift
// List orders
let result = try await xeboki.pos.listOrders(params: .init(
    limit: 50,
    status: .completed,
    locationId: "loc_abc",
    startDate: "2026-01-01",
    endDate: "2026-03-31"
))

// Get a single order
let order = try await xeboki.pos.getOrder(id: "ord_abc123")
print(order.total, order.paymentMethod)

// Create an order
let newOrder = try await xeboki.pos.createOrder(params: .init(
    items: [
        .init(productId: "prod_1", quantity: 2),
        .init(productId: "prod_2", quantity: 1, modifiers: [.init(modifierId: "mod_oat")])
    ],
    locationId: "loc_abc",
    paymentMethod: "card",
    customerId: "cust_xyz"
))
```

#### Products

```swift
// List products
let products = try await xeboki.pos.listProducts(params: .init(
    locationId: "loc_abc",
    isActive: true,
    search: "espresso"
))

// Create a product
let product = try await xeboki.pos.createProduct(params: .init(
    name: "Flat White",
    price: 4.50,
    locationId: "loc_abc",
    taxRate: 0.10,
    trackInventory: true
))

// Update a product
let updated = try await xeboki.pos.updateProduct(
    id: "prod_abc",
    params: .init(price: 4.75)
)
```

#### Inventory

```swift
// List inventory
let inventory = try await xeboki.pos.listInventory(
    params: .init(locationId: "loc_abc", lowStockOnly: true)
)

// Adjust stock level
let item = try await xeboki.pos.updateInventory(
    id: "inv_abc",
    params: .init(quantity: 50, reason: "restock", notes: "Weekly delivery")
)
```

#### Customers

```swift
// Search customers
let customers = try await xeboki.pos.listCustomers(
    params: .init(search: "jane", limit: 20)
)

// Create a customer
let customer = try await xeboki.pos.createCustomer(params: .init(
    name: "Jane Doe",
    email: "jane@example.com",
    phone: "+1-555-0100"
))
```

#### Sales Report

```swift
let report = try await xeboki.pos.getSalesReport(params: .init(
    startDate: "2026-03-01",
    endDate: "2026-03-31",
    locationId: "loc_abc"
))
print("Revenue: \(report.totalRevenue)")
print("Avg order: \(report.averageOrderValue)")
print("Top products: \(report.topProducts)")
```

---

### `chat` — Customer Support

Manage conversations, messages, agents, contacts, and inboxes.

```swift
// List open conversations
let conversations = try await xeboki.chat.listConversations(params: .init(
    status: .open,
    inboxId: "inbox_web"
))

// Send a message
let message = try await xeboki.chat.sendMessage(
    conversationId: "conv_abc",
    params: .init(content: "How can I help you today?")
)

// Resolve a conversation
let resolved = try await xeboki.chat.updateConversation(
    id: "conv_abc",
    params: .init(status: .resolved)
)

// Create a contact
let contact = try await xeboki.chat.createContact(params: .init(
    name: "Alex Smith",
    email: "alex@example.com",
    company: "Acme Corp"
))

// List available agents
let agents = try await xeboki.chat.listAgents(
    params: .init(isAvailable: true)
)
```

**Supported channels:** `web` · `email` · `sms` · `whatsapp` · `instagram` · `twitter`

---

### `link` — URL Shortener

```swift
// Create a short link
let link = try await xeboki.link.createLink(params: .init(
    destinationUrl: "https://yoursite.com/campaign",
    title: "Summer Sale",
    customCode: "summer26",
    tags: ["marketing"]
))
print(link.shortUrl)   // https://xbk.io/summer26

// Link analytics
let analytics = try await xeboki.link.getAnalytics(
    id: "lnk_abc",
    params: .init(startDate: "2026-03-01", endDate: "2026-03-31")
)
print("Clicks: \(analytics.totalClicks)")
print("Top countries: \(analytics.topCountries)")

// Update or delete
try await xeboki.link.updateLink(id: "lnk_abc", params: .init(isActive: false))
try await xeboki.link.deleteLink(id: "lnk_abc")
```

---

### `removebg` — Background Removal

```swift
// Submit a background removal job
let job = try await xeboki.removebg.removeBackground(params: .init(
    imageUrl: "https://example.com/photo.jpg",
    outputFormat: .png
))

// Poll for result
let result = try await xeboki.removebg.getJob(jobId: job.jobId)
if result.status == .completed, let url = result.resultUrl {
    print("Result: \(url)")
}
```

---

### `analytics` — Cross-Product Analytics

```swift
// List available reports
let reports = try await xeboki.analytics.listReports(
    params: .init(product: .pos)
)

// Run a report
let data = try await xeboki.analytics.getReport(
    id: "rep_revenue_daily",
    params: .init(
        startDate: "2026-01-01",
        endDate: "2026-03-31",
        groupBy: .month
    )
)
print(data.summary)

// Export to CSV
let export = try await xeboki.analytics.exportReport(params: .init(
    reportId: "rep_revenue_daily",
    format: .csv,
    startDate: "2026-01-01",
    endDate: "2026-03-31"
))
```

---

### `account` — Account Management

```swift
// Account info and usage
let account = try await xeboki.account.getAccount()
let usage   = try await xeboki.account.getUsage()
print("\(usage.pos.used) / \(usage.pos.limit)")

// Create a webhook
let webhook = try await xeboki.account.createWebhook(params: .init(
    url: "https://yourserver.com/webhooks",
    events: ["order.completed", "conversation.created"]
))

// API key management
let keys = try await xeboki.account.listApiKeys()
let newKey = try await xeboki.account.createApiKey(params: .init(
    name: "iOS Production",
    scopes: ["pos:read", "pos:write"]
))
print(newKey.key)   // shown only once — store it securely
```

---

### `launchpad` — App Distribution

```swift
// List your published apps
let apps = try await xeboki.launchpad.listApps()

// Create a new release
let release = try await xeboki.launchpad.createRelease(
    appId: "app_abc",
    params: .init(
        version: "2.4.0",
        releaseNotes: "Performance improvements.",
        downloadUrl: "https://cdn.example.com/app-2.4.0.ipa",
        platform: "ios"
    )
)
```

---

## Error Handling

All SDK methods throw `XebokiError` on non-2xx HTTP responses.

```swift
do {
    let order = try await xeboki.pos.createOrder(params: ...)
} catch let error as XebokiError {
    print("Status: \(error.status)")
    print("Message: \(error.message)")
    print("Request ID: \(error.requestId ?? "n/a")")  // include in support tickets

    if error.status == 429, let retry = error.retryAfter {
        print("Rate limited — retry after \(retry)s")
    }
} catch {
    print("Network error: \(error)")
}
```

**`XebokiError` properties**

| Property      | Type      | Description                                               |
|---------------|-----------|-----------------------------------------------------------|
| `status`      | `Int`     | HTTP status code                                          |
| `message`     | `String`  | Human-readable error description                          |
| `requestId`   | `String?` | Unique request ID — include in support tickets            |
| `retryAfter`  | `Int?`    | Seconds to wait before retrying (only present on 429)     |

**Common status codes**

| Status | Meaning                                           |
|--------|---------------------------------------------------|
| `400`  | Bad request — check your parameters               |
| `401`  | Invalid or missing API key                        |
| `403`  | Insufficient scope / permissions                  |
| `404`  | Resource not found                                |
| `422`  | Validation error                                  |
| `429`  | Rate limit exceeded — check `retryAfter`          |
| `500`  | Server error — retry with exponential back-off    |

---

## Rate Limiting

Every product has its own daily request quota. The SDK surfaces the live counters after each call via `lastRateLimit`.

```swift
let orders = try await xeboki.pos.listOrders()

if let rl = xeboki.lastRateLimit {
    print("\(rl.remaining) / \(rl.limit) requests remaining today")
    let resetDate = Date(timeIntervalSince1970: TimeInterval(rl.reset))
    print("Resets at \(resetDate)")
}
```

**`RateLimitInfo` properties**

| Property    | Type     | Description                                   |
|-------------|----------|-----------------------------------------------|
| `limit`     | `Int`    | Daily request quota for this product          |
| `remaining` | `Int`    | Requests remaining today                      |
| `reset`     | `Int`    | Unix timestamp when the counter resets (UTC)  |
| `requestId` | `String` | ID of the most recent request                 |

---

## Concurrency

The SDK is built entirely with `async/await` and is safe to use from any Swift concurrency context. `XebokiClient` is marked `@unchecked Sendable` and can be shared across tasks.

```swift
// Parallel requests using async let
async let orders   = xeboki.pos.listOrders()
async let products = xeboki.pos.listProducts()

let (o, p) = try await (orders, products)
```

---

## Support

- **Documentation:** [developers.xeboki.com](https://developers.xeboki.com)
- **Issues:** [github.com/xeboki/sdk-swift/issues](https://github.com/xeboki/sdk-swift/issues)
- **Email:** developers@xeboki.com

Include the `requestId` from `XebokiError` in all support requests.

## License

MIT
