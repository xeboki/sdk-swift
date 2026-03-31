import Foundation

// MARK: - Models

public struct OrderItem: Codable, Sendable {
    public let productId: String
    public let name: String
    public let quantity: Int
    public let unitPrice: Double
    public let subtotal: Double
    public let modifiers: [OrderItemModifier]?
}

public struct OrderItemModifier: Codable, Sendable {
    public let name: String
    public let price: Double
}

public struct Order: Codable, Sendable {
    public let id: String
    public let orderNumber: String
    public let status: OrderStatus
    public let items: [OrderItem]
    public let subtotal: Double
    public let tax: Double
    public let discount: Double
    public let total: Double
    public let customerId: String?
    public let locationId: String
    public let employeeId: String
    public let paymentMethod: String
    public let notes: String?
    public let createdAt: String
    public let updatedAt: String
}

public enum OrderStatus: String, Codable, Sendable {
    case pending, processing, completed, cancelled, refunded
}

public struct ListOrdersParams: Encodable, Sendable {
    public var limit: Int?
    public var offset: Int?
    public var status: OrderStatus?
    public var locationId: String?
    public var customerId: String?
    public var startDate: String?
    public var endDate: String?

    public init(limit: Int? = nil, offset: Int? = nil, status: OrderStatus? = nil,
                locationId: String? = nil, customerId: String? = nil,
                startDate: String? = nil, endDate: String? = nil) {
        self.limit = limit; self.offset = offset; self.status = status
        self.locationId = locationId; self.customerId = customerId
        self.startDate = startDate; self.endDate = endDate
    }
}

public struct CreateOrderItemParams: Encodable, Sendable {
    public let productId: String
    public let quantity: Int
    public let modifiers: [CreateOrderModifierParams]?

    public init(productId: String, quantity: Int, modifiers: [CreateOrderModifierParams]? = nil) {
        self.productId = productId; self.quantity = quantity; self.modifiers = modifiers
    }
}

public struct CreateOrderModifierParams: Encodable, Sendable {
    public let modifierId: String
    public init(modifierId: String) { self.modifierId = modifierId }
}

public struct CreateOrderParams: Encodable, Sendable {
    public let items: [CreateOrderItemParams]
    public let customerId: String?
    public let locationId: String
    public let paymentMethod: String
    public let discount: Double?
    public let notes: String?

    public init(items: [CreateOrderItemParams], customerId: String? = nil, locationId: String,
                paymentMethod: String, discount: Double? = nil, notes: String? = nil) {
        self.items = items; self.customerId = customerId; self.locationId = locationId
        self.paymentMethod = paymentMethod; self.discount = discount; self.notes = notes
    }
}

public struct Product: Codable, Sendable {
    public let id: String
    public let name: String
    public let description: String?
    public let sku: String?
    public let barcode: String?
    public let categoryId: String?
    public let price: Double
    public let cost: Double?
    public let taxRate: Double
    public let imageUrl: String?
    public let isActive: Bool
    public let trackInventory: Bool
    public let locationId: String
    public let modifierGroupIds: [String]?
    public let createdAt: String
    public let updatedAt: String
}

public struct ListProductsParams: Encodable, Sendable {
    public var limit: Int?
    public var offset: Int?
    public var categoryId: String?
    public var locationId: String?
    public var isActive: Bool?
    public var search: String?

    public init(limit: Int? = nil, offset: Int? = nil, categoryId: String? = nil,
                locationId: String? = nil, isActive: Bool? = nil, search: String? = nil) {
        self.limit = limit; self.offset = offset; self.categoryId = categoryId
        self.locationId = locationId; self.isActive = isActive; self.search = search
    }
}

public struct CreateProductParams: Encodable, Sendable {
    public let name: String
    public let description: String?
    public let sku: String?
    public let barcode: String?
    public let categoryId: String?
    public let price: Double
    public let cost: Double?
    public let taxRate: Double?
    public let imageUrl: String?
    public let isActive: Bool?
    public let trackInventory: Bool?
    public let locationId: String
    public let modifierGroupIds: [String]?

    public init(name: String, description: String? = nil, sku: String? = nil, barcode: String? = nil,
                categoryId: String? = nil, price: Double, cost: Double? = nil, taxRate: Double? = nil,
                imageUrl: String? = nil, isActive: Bool? = nil, trackInventory: Bool? = nil,
                locationId: String, modifierGroupIds: [String]? = nil) {
        self.name = name; self.description = description; self.sku = sku; self.barcode = barcode
        self.categoryId = categoryId; self.price = price; self.cost = cost; self.taxRate = taxRate
        self.imageUrl = imageUrl; self.isActive = isActive; self.trackInventory = trackInventory
        self.locationId = locationId; self.modifierGroupIds = modifierGroupIds
    }
}

public struct UpdateProductParams: Encodable, Sendable {
    public var name: String?
    public var description: String?
    public var price: Double?
    public var cost: Double?
    public var taxRate: Double?
    public var isActive: Bool?
    public var categoryId: String?
    public var imageUrl: String?
    public var modifierGroupIds: [String]?

    public init(name: String? = nil, description: String? = nil, price: Double? = nil, cost: Double? = nil,
                taxRate: Double? = nil, isActive: Bool? = nil, categoryId: String? = nil,
                imageUrl: String? = nil, modifierGroupIds: [String]? = nil) {
        self.name = name; self.description = description; self.price = price; self.cost = cost
        self.taxRate = taxRate; self.isActive = isActive; self.categoryId = categoryId
        self.imageUrl = imageUrl; self.modifierGroupIds = modifierGroupIds
    }
}

public struct InventoryItem: Codable, Sendable {
    public let id: String
    public let productId: String
    public let productName: String
    public let locationId: String
    public let quantity: Int
    public let lowStockThreshold: Int?
    public let unit: String
    public let lastUpdated: String
}

public struct UpdateInventoryParams: Encodable, Sendable {
    public let quantity: Int
    public let reason: String?
    public let notes: String?

    public init(quantity: Int, reason: String? = nil, notes: String? = nil) {
        self.quantity = quantity; self.reason = reason; self.notes = notes
    }
}

public struct Customer: Codable, Sendable {
    public let id: String
    public let name: String
    public let email: String?
    public let phone: String?
    public let loyaltyPoints: Int?
    public let totalSpend: Double?
    public let visitCount: Int?
    public let notes: String?
    public let createdAt: String
    public let updatedAt: String
}

public struct CreateCustomerParams: Encodable, Sendable {
    public let name: String
    public let email: String?
    public let phone: String?
    public let notes: String?

    public init(name: String, email: String? = nil, phone: String? = nil, notes: String? = nil) {
        self.name = name; self.email = email; self.phone = phone; self.notes = notes
    }
}

public struct SalesReportTopProduct: Codable, Sendable {
    public let productId: String
    public let name: String
    public let quantitySold: Int
    public let revenue: Double
}

public struct SalesReportDailyRevenue: Codable, Sendable {
    public let date: String
    public let revenue: Double
    public let orders: Int
}

public struct SalesReportPaymentBreakdown: Codable, Sendable {
    public let method: String
    public let amount: Double
    public let count: Int
}

public struct SalesReport: Codable, Sendable {
    public let locationId: String
    public let startDate: String
    public let endDate: String
    public let totalOrders: Int
    public let totalRevenue: Double
    public let totalTax: Double
    public let totalDiscount: Double
    public let netRevenue: Double
    public let averageOrderValue: Double
    public let topProducts: [SalesReportTopProduct]
    public let revenueByDay: [SalesReportDailyRevenue]
    public let paymentBreakdown: [SalesReportPaymentBreakdown]
}

public struct PosSession: Codable, Sendable {
    public let id: String
    public let locationId: String
    public let employeeId: String
    public let employeeName: String
    public let openedAt: String
    public let closedAt: String?
    public let status: SessionStatus
    public let openingCash: Double
    public let closingCash: Double?
    public let totalSales: Double
    public let totalOrders: Int
}

public enum SessionStatus: String, Codable, Sendable {
    case open, closed
}

// MARK: - Client

public final class POSClient: @unchecked Sendable {
    private let http: HTTPClient
    private let onRateLimit: @Sendable (RateLimitInfo) -> Void

    init(http: HTTPClient, onRateLimit: @escaping @Sendable (RateLimitInfo) -> Void) {
        self.http = http
        self.onRateLimit = onRateLimit
    }

    private func call<T: Decodable>(method: HTTPMethod, path: String,
                                    query: [String: String]? = nil,
                                    body: (any Encodable)? = nil) async throws -> T {
        let response: HTTPResponse<T> = try await http.request(method: method, path: path, query: query, body: body)
        onRateLimit(response.rateLimit)
        return response.data
    }

    public func listOrders(params: ListOrdersParams? = nil) async throws -> ListResponse<Order> {
        try await call(method: .GET, path: "/v1/pos/orders", query: params?.asQuery())
    }

    public func createOrder(_ params: CreateOrderParams) async throws -> Order {
        try await call(method: .POST, path: "/v1/pos/orders", body: params)
    }

    public func getOrder(id: String) async throws -> Order {
        try await call(method: .GET, path: "/v1/pos/orders/\(id)")
    }

    public func listProducts(params: ListProductsParams? = nil) async throws -> ListResponse<Product> {
        try await call(method: .GET, path: "/v1/pos/products", query: params?.asQuery())
    }

    public func createProduct(_ params: CreateProductParams) async throws -> Product {
        try await call(method: .POST, path: "/v1/pos/products", body: params)
    }

    public func updateProduct(id: String, params: UpdateProductParams) async throws -> Product {
        try await call(method: .PUT, path: "/v1/pos/products/\(id)", body: params)
    }

    public func listInventory(locationId: String? = nil, lowStockOnly: Bool? = nil) async throws -> ListResponse<InventoryItem> {
        var query: [String: String] = [:]
        if let l = locationId { query["location_id"] = l }
        if let lso = lowStockOnly { query["low_stock_only"] = String(lso) }
        return try await call(method: .GET, path: "/v1/pos/inventory", query: query.isEmpty ? nil : query)
    }

    public func updateInventory(id: String, params: UpdateInventoryParams) async throws -> InventoryItem {
        try await call(method: .PUT, path: "/v1/pos/inventory/\(id)", body: params)
    }

    public func listCustomers(search: String? = nil, limit: Int? = nil, offset: Int? = nil) async throws -> ListResponse<Customer> {
        var query: [String: String] = [:]
        if let s = search { query["search"] = s }
        if let l = limit { query["limit"] = String(l) }
        if let o = offset { query["offset"] = String(o) }
        return try await call(method: .GET, path: "/v1/pos/customers", query: query.isEmpty ? nil : query)
    }

    public func createCustomer(_ params: CreateCustomerParams) async throws -> Customer {
        try await call(method: .POST, path: "/v1/pos/customers", body: params)
    }

    public func getSalesReport(startDate: String? = nil, endDate: String? = nil, locationId: String? = nil) async throws -> SalesReport {
        var query: [String: String] = [:]
        if let s = startDate { query["start_date"] = s }
        if let e = endDate { query["end_date"] = e }
        if let l = locationId { query["location_id"] = l }
        return try await call(method: .GET, path: "/v1/pos/reports/sales", query: query.isEmpty ? nil : query)
    }

    public func listSessions(locationId: String? = nil, status: SessionStatus? = nil, limit: Int? = nil, offset: Int? = nil) async throws -> ListResponse<PosSession> {
        var query: [String: String] = [:]
        if let l = locationId { query["location_id"] = l }
        if let s = status { query["status"] = s.rawValue }
        if let l = limit { query["limit"] = String(l) }
        if let o = offset { query["offset"] = String(o) }
        return try await call(method: .GET, path: "/v1/pos/sessions", query: query.isEmpty ? nil : query)
    }
}

// MARK: - Query Helpers

private extension ListOrdersParams {
    func asQuery() -> [String: String] {
        var q: [String: String] = [:]
        if let v = limit { q["limit"] = String(v) }
        if let v = offset { q["offset"] = String(v) }
        if let v = status { q["status"] = v.rawValue }
        if let v = locationId { q["location_id"] = v }
        if let v = customerId { q["customer_id"] = v }
        if let v = startDate { q["start_date"] = v }
        if let v = endDate { q["end_date"] = v }
        return q
    }
}

private extension ListProductsParams {
    func asQuery() -> [String: String] {
        var q: [String: String] = [:]
        if let v = limit { q["limit"] = String(v) }
        if let v = offset { q["offset"] = String(v) }
        if let v = categoryId { q["category_id"] = v }
        if let v = locationId { q["location_id"] = v }
        if let v = isActive { q["is_active"] = String(v) }
        if let v = search { q["search"] = v }
        return q
    }
}
