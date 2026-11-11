import SwiftUI

/// Reusable Transaction Card component matching the reference feed item.
/// Supports outflows (Debit / Red), inflows (Credit / Lime), and unclassified (Other / Amber).
public struct TransactionCard: View {
    public enum Direction {
        case outflow // Expense / Debit (red)
        case inflow  // Income / Credit (lime)
        case other   // Unknown / Unclassified (amber)
    }

    private let title: String
    private let subtitle: String
    private let amountString: String
    private let timeString: String
    private let direction: Direction
    private let action: () -> Void

    public init(
        title: String,
        subtitle: String,
        amountString: String,
        timeString: String,
        direction: Direction,
        action: @escaping () -> Void = {}
    ) {
        self.title = title
        self.subtitle = subtitle
        self.amountString = amountString
        self.timeString = timeString
        self.direction = direction
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Dark Squircle Icon Container
                ZStack {
                    RoundedRectangle(cornerRadius: DeltaDimensions.radiusSquircleTile, style: .continuous)
                        .fill(Color.deltaBgOliveDark)
                        .frame(width: 46, height: 46)
                        .overlay(
                            RoundedRectangle(cornerRadius: DeltaDimensions.radiusSquircleTile, style: .continuous)
                                .stroke(Color.deltaBorderOlive, lineWidth: 1)
                        )

                    Image(systemName: iconName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(accentColor)
                }

                // Title & Subtitle (TrxID / Category)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(DeltaTypography.bodySemibold)
                        .foregroundColor(Color.deltaTextOnDark)
                        .lineLimit(1)

                    Text(subtitle)
                        .font(DeltaTypography.captionMeta)
                        .foregroundColor(Color.deltaTextMutedDark)
                }

                Spacer()

                // Amount & Timestamp
                VStack(alignment: .trailing, spacing: 3) {
                    Text(amountString)
                        .font(DeltaTypography.bodySemibold)
                        .foregroundColor(accentColor)

                    Text(timeString)
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

    private var accentColor: Color {
        switch direction {
        case .outflow:
            return Color.deltaExpenseRed
        case .inflow:
            return Color.deltaIncomeGreen
        case .other:
            return Color(hex: "E5C07B") // Muted unclassified amber
        }
    }

    private var iconName: String {
        switch direction {
        case .outflow:
            return DeltaIcons.transactionOutflow
        case .inflow:
            return DeltaIcons.transactionInflow
        case .other:
            return "questionmark.circle"
        }
    }
}

private struct TransactionCardPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(DeltaAnimations.tactilePress, value: configuration.isPressed)
    }
}
