import SwiftUI

/// Dedicated transaction row component for the History ledger matching the DELTA design tokens.
/// Explicitly displays Title, Person/Merchant, Category icon, Amount, Date, Time, and Transaction type.
public struct HistoryRowView: View {
    public let item: TransactionItem
    public let action: () -> Void

    public init(item: TransactionItem, action: @escaping () -> Void) {
        self.item = item
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Category Icon Squircle Container
                ZStack {
                    RoundedRectangle(cornerRadius: DeltaDimensions.radiusSquircleTile, style: .continuous)
                        .fill(Color.deltaBgOliveDark)
                        .frame(width: 44, height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: DeltaDimensions.radiusSquircleTile, style: .continuous)
                                .stroke(Color.deltaBorderOlive, lineWidth: 1)
                        )

                    Image(systemName: item.category.iconName)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(item.amountColor)
                }

                // Title, Person/Merchant & Transaction Type Badge
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(item.title)
                            .font(DeltaTypography.bodySemibold)
                            .foregroundColor(Color.deltaTextOnDark)
                            .lineLimit(1)

                        // Transaction Type pill badge
                        Text(typeBadgeText)
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(typeBadgeTextColor)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(typeBadgeBackgroundColor))
                    }

                    // Person / Merchant / Account context
                    Text(subtitleText)
                        .font(DeltaTypography.captionMeta)
                        .foregroundColor(Color.deltaTextMutedDark)
                        .lineLimit(1)
                }

                Spacer()

                // Amount, Date & Time
                VStack(alignment: .trailing, spacing: 3) {
                    Text(item.formattedAmount)
                        .font(DeltaTypography.bodySemibold)
                        .foregroundColor(item.amountColor)

                    HStack(spacing: 4) {
                        Text(item.timeString)
                    }
                    .font(DeltaTypography.captionMeta)
                    .foregroundColor(Color.deltaTextMutedDark)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.deltaBgSubtle.opacity(0.55))
            )
        }
        .buttonStyle(TransactionCardPressStyle())
    }

    private var subtitleText: String {
        if let note = item.note, !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "\(item.accountName) • \(note)"
        }
        return "\(item.accountName) • \(item.category.rawValue)"
    }

    private var typeBadgeText: String {
        if item.linkedSplitID != nil {
            return "SPLIT"
        }
        switch item.type {
        case .debit:
            return "DEBIT"
        case .credit:
            return "CREDIT"
        case .other:
            return "OTHER"
        }
    }

    private var typeBadgeTextColor: Color {
        switch item.type {
        case .debit:
            return Color.deltaExpenseRed
        case .credit:
            return Color(hex: "070A06")
        case .other:
            return Color(hex: "070A06")
        }
    }

    private var typeBadgeBackgroundColor: Color {
        switch item.type {
        case .debit:
            return Color.deltaExpenseRed.opacity(0.2)
        case .credit:
            return Color.deltaIncomeGreen
        case .other:
            return Color(hex: "E5C07B")
        }
    }
}

