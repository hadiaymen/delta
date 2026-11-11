import SwiftUI

/// Personal expense tracking category definitions.
/// Represents user budget envelopes (Food, Utilities, Travel, Shopping, Health, etc.).
public enum ExpenseCategory: String, CaseIterable, Identifiable, Codable {
    case general = "General"
    case dining = "Dining & Food"
    case groceries = "Groceries"
    case utilities = "Bills & Utilities"
    case transfer = "Personal Outlay"
    case entertainment = "Entertainment"
    case shopping = "Shopping"
    case income = "Inflow & Deposit"

    public var id: String { rawValue }

    public var iconName: String {
        switch self {
        case .general:
            return "bag"
        case .dining:
            return "fork.knife"
        case .groceries:
            return "cart"
        case .utilities:
            return "bolt.fill"
        case .transfer:
            return "arrow.up.right"
        case .entertainment:
            return "film"
        case .shopping:
            return "tag.fill"
        case .income:
            return "arrow.down.left"
        }
    }
}

