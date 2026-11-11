import SwiftUI

/// Reusable Transaction Card component matching the reference feed item.
public struct TransactionCard: View {
    public enum Direction {
        case outflow // Expense (red)
        case inflow  // Income / Refund (lime)
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

                    Image(systemName: direction == .outflow ? DeltaIcons.transactionOutflow : DeltaIcons.transactionInflow)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(accentColor)
                }

                // Title & Subtitle (TrxID)
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
        direction == .outflow ? Color.deltaExpenseRed : Color.deltaIncomeGreen
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

