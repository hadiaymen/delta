import Foundation

public enum TransactionValidationError: LocalizedError, Equatable {
    case emptyTitle
    case nonPositiveAmount
    case excessiveDecimals

    public var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return "Person, merchant or source name is required."
        case .nonPositiveAmount:
            return "Transaction amount must be greater than zero."
        case .excessiveDecimals:
            return "Amount cannot have more than 2 decimal places."
        }
    }
}

/// Pure, decoupled financial calculations engine using Decimal precision.
public struct FinancialCalculator {
    /// Calculate the sum of all Debit transactions in the specified calendar month.
    public static func calculateMonthlySpent(
        transactions: [TransactionItem],
        monthDate: Date,
        calendar: Calendar = .current
    ) -> Decimal {
        transactions
            .filter { tx in
                tx.type == .debit &&
                calendar.isDate(tx.timestamp, equalTo: monthDate, toGranularity: .month) &&
                calendar.isDate(tx.timestamp, equalTo: monthDate, toGranularity: .year)
            }
            .reduce(Decimal.zero) { $0 + $1.amount }
    }

    /// Calculate the sum of all Credit transactions in the specified calendar month.
    public static func calculateMonthlyReceived(
        transactions: [TransactionItem],
        monthDate: Date,
        calendar: Calendar = .current
    ) -> Decimal {
        transactions
            .filter { tx in
                tx.type == .credit &&
                calendar.isDate(tx.timestamp, equalTo: monthDate, toGranularity: .month) &&
                calendar.isDate(tx.timestamp, equalTo: monthDate, toGranularity: .year)
            }
            .reduce(Decimal.zero) { $0 + $1.amount }
    }

    /// Calculate monthly spending comparison between current month and previous month debits.
    public static func calculateMonthlySpendingComparison(
        transactions: [TransactionItem],
        monthDate: Date,
        calendar: Calendar = .current
    ) -> (percentage: Double, isIncrease: Bool, formattedText: String) {
        let currentTotal = calculateMonthlySpent(transactions: transactions, monthDate: monthDate, calendar: calendar)

        guard let prevMonthDate = calendar.date(byAdding: .month, value: -1, to: monthDate) else {
            return (0.0, false, "0% vs last month")
        }

        let previousTotal = calculateMonthlySpent(transactions: transactions, monthDate: prevMonthDate, calendar: calendar)

        if previousTotal > Decimal.zero {
            let currentDouble = NSDecimalNumber(decimal: currentTotal).doubleValue
            let prevDouble = NSDecimalNumber(decimal: previousTotal).doubleValue
            let percentage = ((currentDouble - prevDouble) / prevDouble) * 100.0

            if percentage >= 0 {
                return (percentage, true, String(format: "↑ %.0f%% vs last month", abs(percentage)))
            } else {
                return (percentage, false, String(format: "↓ %.0f%% vs last month", abs(percentage)))
            }
        } else if currentTotal > Decimal.zero {
            return (100.0, true, "↑ 100% vs last month")
        } else {
            return (0.0, false, "0% vs last month")
        }
    }

    /// Recalculates current balances for personal accounts: initialBalance + credits - debits.
    public static func calculateAccountBalances(
        accounts: [DummyAccountCard],
        transactions: [TransactionItem]
    ) -> [DummyAccountCard] {
        return accounts.map { account in
            var updated = account
            let accountTransactions = transactions.filter { $0.accountID == account.id || $0.accountName == account.accountName }

            var netChange = Decimal.zero
            for tx in accountTransactions {
                switch tx.type {
                case .credit:
                    netChange += tx.amount
                case .debit:
                    netChange -= tx.amount
                }
            }

            updated.currentBalance = account.initialBalance + netChange
            return updated
        }
    }

    /// Duplicate transaction detection:
    /// Rejects if an existing transaction has identical title, amount, type, accountID, and occurs within 60 seconds of timestamp (ignoring the transaction itself when editing).
    public static func isDuplicate(
        candidate: TransactionItem,
        existing: [TransactionItem]
    ) -> Bool {
        return existing.contains { item in
            guard item.id != candidate.id else { return false }
            let sameTitle = item.title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ==
                            candidate.title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let sameAmount = item.amount == candidate.amount
            let sameType = item.type == candidate.type
            let sameAccount = item.accountID == candidate.accountID
            let timeDifference = abs(item.timestamp.timeIntervalSince(candidate.timestamp))
            return sameTitle && sameAmount && sameType && sameAccount && timeDifference < 60
        }
    }

    /// Validates required fields and amount decimal precision.
    public static func validate(amount: Decimal, title: String) -> Result<Void, TransactionValidationError> {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedTitle.isEmpty {
            return .failure(.emptyTitle)
        }
        if amount <= Decimal.zero {
            return .failure(.nonPositiveAmount)
        }
        // Verify maximum 2 decimal places
        var dec = amount
        var rounded = Decimal()
        NSDecimalRound(&rounded, &dec, 2, .plain)
        if dec != rounded {
            return .failure(.excessiveDecimals)
        }
        return .success(())
    }
}

