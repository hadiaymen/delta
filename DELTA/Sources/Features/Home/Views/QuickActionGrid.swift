import SwiftUI

/// Two quick action triggers (Credit and Debit) on the neon lime financial summary card.
/// Symmetrically balanced with dark squircle buttons and spring physics.
public struct QuickActionGrid: View {
    public let onCredit: () -> Void
    public let onDebit: () -> Void

    public init(
        onCredit: @escaping () -> Void,
        onDebit: @escaping () -> Void
    ) {
        self.onCredit = onCredit
        self.onDebit = onDebit
    }

    public var body: some View {
        HStack(spacing: 36) {
            Spacer()

            // Credit Action Trigger (Inflow / Deposit / Refund)
            actionButton(
                title: "Credit",
                icon: DeltaIcons.transactionInflow,
                action: onCredit
            )

            // Debit Action Trigger (Outflow / Expense / Spend)
            actionButton(
                title: "Debit",
                icon: DeltaIcons.transactionOutflow,
                action: onDebit
            )

            Spacer()
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func actionButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        VStack(spacing: 8) {
            Button(action: action) {
                ZStack {
                    RoundedRectangle(cornerRadius: DeltaDimensions.radiusSquircleButton, style: .continuous)
                        .fill(Color.deltaTextOnLime)
                        .frame(width: DeltaDimensions.sizeActionButton, height: DeltaDimensions.sizeActionButton)
                        .overlay(
                            RoundedRectangle(cornerRadius: DeltaDimensions.radiusSquircleButton, style: .continuous)
                                .stroke(Color.black.opacity(0.12), lineWidth: 1)
                        )
                        .deltaShadow(DeltaShadows.squircleOnLime)

                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color.deltaSurfaceLime)
                }
            }
            .buttonStyle(QuickActionButtonPressStyle())

            Text(title)
                .font(DeltaTypography.actionLabel)
                .foregroundColor(Color.deltaTextOnLime)
        }
    }
}

private struct QuickActionButtonPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(DeltaAnimations.tactilePress, value: configuration.isPressed)
    }
}
