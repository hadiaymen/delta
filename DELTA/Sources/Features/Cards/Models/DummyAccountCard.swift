import SwiftUI

/// Represents a visual dummy account card for personal expense budgeting.
/// STRICT COMPLIANCE:
/// - These are dummy visual accounts representing user budget categories only (NOT bank cards).
/// - NEVER generates or displays usable payment card numbers, CVVs, or expiry dates.
public struct DummyAccountCard: Identifiable, Hashable, Codable {
    public enum CardTheme: String, Codable, CaseIterable {
        case chartreuseLime // Primary DELTA signature gradient
        case forestOlive    // Deep dark olive secondary gradient
        case obsidianDark   // Deep obsidian gradient
        case electricLime   // Bright solid lime accent
    }

    public let id: String
    public var accountName: String        // e.g. "DELTA PERSONAL", "DELTA CASH", "DELTA SAVINGS"
    public var cardholderName: String      // e.g. "Hadi Aymen"
    public var accountIdentifier: String   // e.g. "DELTA •••• 5890" (non-usable dummy identifier)
    public var accountCategory: String     // e.g. "Personal Account", "Cash Envelope", "Savings Vault"
    public var initialBalance: Decimal
    public var currentBalance: Decimal
    public var theme: CardTheme
    public var isPrimary: Bool
    public var isLocked: Bool

    public init(
        id: String = UUID().uuidString,
        accountName: String,
        cardholderName: String = "Hadi Aymen",
        accountIdentifier: String = "DELTA •••• " + String(Int.random(in: 1000...9999)),
        accountCategory: String = "Personal Account",
        initialBalance: Decimal,
        currentBalance: Decimal? = nil,
        theme: CardTheme = .chartreuseLime,
        isPrimary: Bool = false,
        isLocked: Bool = false
    ) {
        self.id = id
        self.accountName = accountName
        self.cardholderName = cardholderName
        self.accountIdentifier = accountIdentifier
        self.accountCategory = accountCategory
        self.initialBalance = initialBalance
        self.currentBalance = currentBalance ?? initialBalance
        self.theme = theme
        self.isPrimary = isPrimary
        self.isLocked = isLocked
    }

    public var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: currentBalance as NSDecimalNumber) ?? "$\(currentBalance)"
    }
}
