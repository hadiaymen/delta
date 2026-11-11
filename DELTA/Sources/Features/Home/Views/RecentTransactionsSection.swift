import SwiftUI

/// Recent Transactions feed in strict descending chronological order.
/// Features date grouping, View All navigation, and empty state support.
public struct RecentTransactionsSection: View {
    public let transactions: [TransactionItem]
    public let onViewAll: () -> Void
    public let onSelectTransaction: (TransactionItem) -> Void

    public init(
        transactions: [TransactionItem],
        onViewAll: @escaping () -> Void,
        onSelectTransaction: @escaping (TransactionItem) -> Void
    ) {
        self.transactions = transactions
        self.onViewAll = onViewAll
        self.onSelectTransaction = onSelectTransaction
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header Row
            HStack {
                Text("Recent Transactions")
                    .font(DeltaTypography.sectionHeader)
                    .foregroundColor(Color.deltaTextOnDark)

                Spacer()

                Button(action: onViewAll) {
                    Text("View all >")
                        .font(DeltaTypography.actionLabel)
                        .foregroundColor(Color.deltaTextMutedDark)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 20)

            if transactions.isEmpty {
                // Empty State Container
                VStack(spacing: 8) {
                    Image(systemName: "tray")
                        .font(.system(size: 28, weight: .light))
                        .foregroundColor(Color.deltaTextMutedDark.opacity(0.6))
                        .padding(.top, 14)

                    Text("No transactions recorded yet")
                        .font(DeltaTypography.bodySemibold)
                        .foregroundColor(Color.deltaTextMutedDark)

                    Text("Log a Credit or Debit above to start tracking.")
                        .font(DeltaTypography.captionMeta)
                        .foregroundColor(Color.deltaTextMutedDark.opacity(0.8))
                        .padding(.bottom, 14)
                }
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.deltaBgSubtle.opacity(0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.deltaBorderOlive, lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)
            } else {
                // Descending Chronological Grouping
                let grouped = Dictionary(grouping: transactions, by: { $0.dateGroupLabel })
                let sortedKeys = grouped.keys.sorted { key1, key2 in
                    if key1 == "Today" { return true }
                    if key2 == "Today" { return false }
                    if key1 == "Yesterday" { return true }
                    if key2 == "Yesterday" { return false }
                    return key1 > key2
                }

                ForEach(sortedKeys, id: \.self) { dateLabel in
                    VStack(alignment: .leading, spacing: 10) {
                        // Date Label
                        Text(dateLabel)
                            .font(DeltaTypography.actionLabel)
                            .foregroundColor(Color.deltaTextMutedDark)
                            .padding(.horizontal, 20)

                        // Transaction Cards for Date Group
                        VStack(spacing: 12) {
                            ForEach(grouped[dateLabel] ?? []) { item in
                                TransactionCard(
                                    title: item.title,
                                    subtitle: item.trxID,
                                    amountString: item.formattedAmount,
                                    timeString: item.timeString,
                                    direction: item.cardDirection,
                                    action: {
                                        onSelectTransaction(item)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
    }
}
