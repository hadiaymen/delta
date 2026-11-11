import SwiftUI

/// Options sheet triggered by the "Other" quick action for the selected account card.
public struct AccountOptionsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject public var service: ExpenseTrackingService

    public let card: DummyAccountCard
    public let onEditTapped: () -> Void
    public let onLogOtherTapped: () -> Void

    public init(
        service: ExpenseTrackingService,
        card: DummyAccountCard,
        onEditTapped: @escaping () -> Void,
        onLogOtherTapped: @escaping () -> Void = {}
    ) {
        self.service = service
        self.card = card
        self.onEditTapped = onEditTapped
        self.onLogOtherTapped = onLogOtherTapped
    }

    public var body: some View {
        DeltaModalSheet(title: "\(card.accountName) Options", onClose: { dismiss() }) {
            VStack(spacing: 16) {
                // Info Summary
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(card.accountName)
                            .font(DeltaTypography.bodySemibold)
                            .foregroundColor(Color.deltaTextOnDark)

                        Text(card.accountIdentifier)
                            .font(DeltaTypography.captionMeta)
                            .foregroundColor(Color.deltaTextMutedDark)
                    }

                    Spacer()

                    Text(card.formattedBalance)
                        .font(DeltaTypography.sectionHeader)
                        .foregroundColor(Color.deltaSurfaceLime)
                }
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.deltaBgOliveDark))
                .padding(.horizontal, 20)
                .padding(.top, 10)

                // Actions List
                VStack(spacing: 10) {
                    // 1. Log Other Transaction
                    Button(action: {
                        dismiss()
                        onLogOtherTapped()
                    }) {
                        optionRow(
                            icon: "questionmark.circle",
                            title: "Record Other (Unclassified)",
                            subtitle: "Log financial record whose classification is unclear"
                        )
                    }

                    // 2. Edit Details
                    Button(action: {
                        dismiss()
                        onEditTapped()
                    }) {
                        optionRow(icon: "pencil", title: "Edit Account & Budget", subtitle: "Update name, category, or card color")
                    }

                    // 3. Lock / Freeze Envelope Toggle
                    Button(action: {
                        var updated = card
                        updated.isLocked.toggle()
                        service.updateAccount(updated)
                        dismiss()
                    }) {
                        optionRow(
                            icon: card.isLocked ? "lock.open" : "lock",
                            title: card.isLocked ? "Unlock Account" : "Freeze Account",
                            subtitle: card.isLocked ? "Allow new debits against this budget" : "Temporarily pause new outlays on this card"
                        )
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }
            .padding(.bottom, 24)
        }
    }

    @ViewBuilder
    private func optionRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.deltaBgOliveDark)
                    .frame(width: 44, height: 44)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.deltaBorderOlive, lineWidth: 1))

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color.deltaSurfaceLime)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DeltaTypography.bodySemibold)
                    .foregroundColor(Color.deltaTextOnDark)

                Text(subtitle)
                    .font(DeltaTypography.captionMeta)
                    .foregroundColor(Color.deltaTextMutedDark)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(Color.deltaTextMutedDark)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.deltaBgSubtle.opacity(0.6))
        )
    }
}

