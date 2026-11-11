import Foundation

public enum SplitValidationError: LocalizedError, Equatable {
    case zeroTotal
    case emptyParticipants
    case customSumMismatch(expected: Decimal, actual: Decimal, difference: Decimal)
    case percentageTotalMismatch(expected: Decimal, actual: Decimal)
    case negativeShare(participantName: String)

    public var errorDescription: String? {
        switch self {
        case .zeroTotal:
            return "Total expense must be greater than zero."
        case .emptyParticipants:
            return "At least two participants are required to split an expense."
        case .customSumMismatch(let exp, let act, let diff):
            let formattedDiff = diff > 0 ? "$\(diff) under" : "$\(-diff) over"
            return "Custom shares sum to $\(act), which does not equal the total of $\(exp) (\(formattedDiff))."
        case .percentageTotalMismatch(let exp, let act):
            return "Percentages total \(act)%, but must equal exactly \(exp)%."
        case .negativeShare(let name):
            return "Share for \(name) cannot be negative."
        }
    }
}

/// Pure computation engine for calculating shares, remainder distribution, and validating splits.
public struct SplitCalculationEngine {
    /// Equal Split: Distributes minor currency unit (cents) remainders deterministically.
    /// Guarantees that the sum of all individual shares equals the total expense down to the exact cent.
    public static func calculateEqualShares(
        total: Decimal,
        participants: [SplitParticipant]
    ) throws -> [SplitParticipant] {
        guard total > Decimal.zero else { throw SplitValidationError.zeroTotal }
        guard !participants.isEmpty else { throw SplitValidationError.emptyParticipants }

        let count = Int64(participants.count)

        // Convert total Decimal to minor currency units (cents)
        let totalCents = Int64(NSDecimalNumber(decimal: total * 100).intValue)
        let baseCents = totalCents / count
        let remainderCents = Int(totalCents % count)

        var updated = participants
        for i in 0..<updated.count {
            // First 'remainderCents' participants receive base + 1 cent
            let centsForParticipant = i < remainderCents ? (baseCents + 1) : baseCents
            updated[i].shareAmount = Decimal(centsForParticipant) / Decimal(100)
            updated[i].percentage = (Decimal(centsForParticipant) / Decimal(totalCents)) * Decimal(100)
        }

        return updated
    }

    /// Custom Split: Validates that the sum of custom assigned shares strictly equals the total.
    public static func validateCustomShares(
        total: Decimal,
        participants: [SplitParticipant]
    ) throws {
        guard total > Decimal.zero else { throw SplitValidationError.zeroTotal }
        guard !participants.isEmpty else { throw SplitValidationError.emptyParticipants }

        for p in participants {
            if p.shareAmount < Decimal.zero {
                throw SplitValidationError.negativeShare(participantName: p.name)
            }
        }

        let actualSum = participants.reduce(Decimal.zero) { $0 + $1.shareAmount }
        if actualSum != total {
            let diff = total - actualSum
            throw SplitValidationError.customSumMismatch(expected: total, actual: actualSum, difference: diff)
        }
    }

    /// Percentage Split: Validates that percentages sum to 100% and calculates individual shares
    /// distributing any minor unit rounding remainders deterministically.
    public static func calculatePercentageShares(
        total: Decimal,
        participants: [SplitParticipant]
    ) throws -> [SplitParticipant] {
        guard total > Decimal.zero else { throw SplitValidationError.zeroTotal }
        guard !participants.isEmpty else { throw SplitValidationError.emptyParticipants }

        let actualPercentageSum = participants.reduce(Decimal.zero) { $0 + ($1.percentage ?? Decimal.zero) }
        if actualPercentageSum != Decimal(100) {
            throw SplitValidationError.percentageTotalMismatch(expected: Decimal(100), actual: actualPercentageSum)
        }

        let totalCents = Int64(NSDecimalNumber(decimal: total * 100).intValue)
        var allocatedCents: Int64 = 0
        var updated = participants

        for i in 0..<updated.count {
            let pct = updated[i].percentage ?? Decimal.zero
            let exactCents = (Decimal(totalCents) * pct) / Decimal(100)
            let cents = Int64(NSDecimalNumber(decimal: exactCents).intValue)
            updated[i].shareAmount = Decimal(cents) / Decimal(100)
            allocatedCents += cents
        }

        // Distribute remainder cents deterministically to the largest share participants
        var remainingCents = totalCents - allocatedCents
        var idx = 0
        while remainingCents > 0 && idx < updated.count {
            let currentCents = Int64(NSDecimalNumber(decimal: updated[idx].shareAmount * 100).intValue)
            updated[idx].shareAmount = Decimal(currentCents + 1) / Decimal(100)
            remainingCents -= 1
            idx += 1
        }

        return updated
    }
}

