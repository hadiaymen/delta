import SwiftUI

/// Represents a logged personal transaction or budget record.
/// Uses Decimal precision for all financial arithmetic to avoid floating-point errors.
public struct TransactionItem: Identifiable, Hashable, Codable {
    public enum TransactionType: String, Codable, CaseIterable {
        case credit // Money received (Inflow / Green)
        case debit  // Money spent (Outflow / Red)
        case other  // Unknown or unclear classification (Unclassified / Amber)
    }

    public let id: String
    public var title: String          // Person, merchant, or source name (optional for Other)
    public var trxID: String
    public var amount: Decimal        // Accurate decimal currency representation
    public var type: TransactionType
    public var timestamp: Date        // Device local date & time
    public var category: ExpenseCategory
    public var accountID: String      // Associated personal account / envelope ID
    public var accountName: String    // Associated account name
    public var note: String?          // Purpose or short note
    public var descriptionText: String? // Optional detailed description
    public var linkedSplitID: String? // Linked SplitRecord ID if this was part of a split

    public init(
        id: String = UUID().uuidString,
        title: String,
        trxID: String = "TrxID: CJ" + String(Int.random(in: 10000000...99999999)),
        amount: Decimal,
        type: TransactionType,
        timestamp: Date = Date(),
        category: ExpenseCategory = .general,
        accountID: String = "default-checking",
        accountName: String = "Daily Living Envelope",
        note: String? = nil,
        descriptionText: String? = nil,
        linkedSplitID: String? = nil
    ) {
        self.id = id
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = trimmedTitle.isEmpty ? (type == .other ? "Unclassified Outlay" : "Transaction") : trimmedTitle
        self.trxID = trxID
        self.amount = amount < 0 ? -amount : amount
        self.type = type
        self.timestamp = timestamp
        self.category = category
        self.accountID = accountID
        self.accountName = accountName
        self.note = note
        self.descriptionText = descriptionText
        self.linkedSplitID = linkedSplitID
    }

    /// Formatted amount string with sign and currency symbol using Decimal formatter
    public var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        let formatted = formatter.string(from: amount as NSDecimalNumber) ?? "$\(amount)"
        switch type {
        case .debit:
            return "-\(formatted)"
        case .credit:
            return "+\(formatted)"
        case .other:
            return "~\(formatted)"
        }
    }

    /// Amount formatted without sign for input fields
    public var plainAmountString: String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
    }

    /// Display color according to DELTA design system tokens
    public var amountColor: Color {
        switch type {
        case .debit:
            return Color.deltaExpenseRed
        case .credit:
            return Color.deltaIncomeGreen
        case .other:
            return Color(hex: "E5C07B") // Muted unclassified amber
        }
    }

    /// Transaction card direction mapping
    public var cardDirection: TransactionCard.Direction {
        switch type {
        case .debit:
            return .outflow
        case .credit:
            return .inflow
        case .other:
            return .other
        }
    }

    /// SF Symbol for transaction status
    public var iconName: String {
        switch type {
        case .debit:
            return DeltaIcons.transactionOutflow
        case .credit:
            return DeltaIcons.transactionInflow
        case .other:
            return "questionmark.circle"
        }
    }

    /// Relative or formatted time string (e.g., "05:29 PM")
    public var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }

    /// Full local formatted date string
    public var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: timestamp)
    }

    /// Date grouping label (e.g. "Today", "Yesterday", "Nov 09, 2026")
    public var dateGroupLabel: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(timestamp) {
            return "Today"
        } else if calendar.isDateInYesterday(timestamp) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd, yyyy"
            return formatter.string(from: timestamp)
        }
    }
}
