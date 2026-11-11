import SwiftUI

/// Method used to divide an expense outlay across participants.
public enum SplitMethod: String, Codable, CaseIterable, Identifiable {
    case equal = "Equal Split"
    case custom = "Custom Amount"
    case percentage = "Percentage"

    public var id: String { rawValue }

    public var iconName: String {
        switch self {
        case .equal:
            return "equal.circle"
        case .custom:
            return "dollarsign.circle"
        case .percentage:
            return "percent"
        }
    }
}

/// Represents an individual participant in a split expense.
public struct SplitParticipant: Identifiable, Hashable, Codable {
    public let id: String
    public var name: String
    public var identifier: String       // e.g. "*****46" or phone/email
    public var isCurrentUser: Bool     // True if participant is Hadi Aymen
    public var shareAmount: Decimal     // Computed or assigned portion
    public var percentage: Decimal?    // Used during percentage splits (0-100)
    public var isSettled: Bool         // Settlement status: paid vs owed
    public var settledDate: Date?

    public init(
        id: String = UUID().uuidString,
        name: String,
        identifier: String = "",
        isCurrentUser: Bool = false,
        shareAmount: Decimal = Decimal.zero,
        percentage: Decimal? = nil,
        isSettled: Bool = false,
        settledDate: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.identifier = identifier
        self.isCurrentUser = isCurrentUser
        self.shareAmount = shareAmount
        self.percentage = percentage
        self.isSettled = isSettled
        self.settledDate = settledDate
    }

    public var formattedShare: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: shareAmount as NSDecimalNumber) ?? "$\(shareAmount)"
    }
}

/// Complete split record maintaining participants, calculation method, settlement tracking, and transaction link.
public struct SplitRecord: Identifiable, Hashable, Codable {
    public let id: String
    public var title: String
    public var totalAmount: Decimal
    public var method: SplitMethod
    public var payerName: String
    public var isCurrentUserPayer: Bool
    public var accountID: String
    public var accountName: String
    public var timestamp: Date
    public var participants: [SplitParticipant]
    public var linkedTransactionID: String?

    public init(
        id: String = UUID().uuidString,
        title: String,
        totalAmount: Decimal,
        method: SplitMethod = .equal,
        payerName: String = "Hadi Aymen",
        isCurrentUserPayer: Bool = true,
        accountID: String = "delta-personal",
        accountName: String = "DELTA PERSONAL",
        timestamp: Date = Date(),
        participants: [SplitParticipant] = [],
        linkedTransactionID: String? = nil
    ) {
        self.id = id
        self.title = title
        self.totalAmount = totalAmount
        self.method = method
        self.payerName = payerName
        self.isCurrentUserPayer = isCurrentUserPayer
        self.accountID = accountID
        self.accountName = accountName
        self.timestamp = timestamp
        self.participants = participants
        self.linkedTransactionID = linkedTransactionID
    }

    public var participantCount: Int {
        participants.count
    }

    public var settledCount: Int {
        participants.filter { $0.isSettled || ($0.isCurrentUser && isCurrentUserPayer) }.count
    }

    public var isFullySettled: Bool {
        participants.allSatisfy { $0.isSettled || ($0.isCurrentUser && isCurrentUserPayer) }
    }

    /// Current user's individual share of the split
    public var currentUserShare: Decimal {
        participants.first(where: { $0.isCurrentUser })?.shareAmount ?? Decimal.zero
    }

    /// Total amount owed to payer by unsettled other participants
    public var totalOwedToPayer: Decimal {
        participants
            .filter { !$0.isCurrentUser && !$0.isSettled }
            .reduce(Decimal.zero) { $0 + $1.shareAmount }
    }

    public var formattedTotalAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: totalAmount as NSDecimalNumber) ?? "$\(totalAmount)"
    }

    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}

