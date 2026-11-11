import SwiftUI

/// Full ledger modal sheet displayed when tapping "View all >" on Recent Transactions.
/// Supports tapping any transaction to view, edit, or delete it.
public struct AllTransactionsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject public var service: ExpenseTrackingService

    @State private var editingTransaction: TransactionItem? = nil

    public init(service: ExpenseTrackingService) {
        self.service = service
    }

    public var body: some View {
        DeltaModalSheet(title: "All Transactions", onClose: { dismiss() }) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    HStack {
                        Text("\(service.transactions.count) Chronological Records")
                            .font(DeltaTypography.actionLabel)
                            .foregroundColor(Color.deltaTextMutedDark)

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    VStack(spacing: 12) {
                        ForEach(service.transactions) { item in
                            TransactionCard(
                                title: item.title,
                                subtitle: item.trxID,
                                amountString: item.formattedAmount,
                                timeString: item.timeString,
                                direction: item.type == .debit ? .outflow : .inflow,
                                action: {
                                    editingTransaction = item
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
        }
        .sheet(item: $editingTransaction) { item in
            TransactionFormSheet(
                service: service,
                mode: .edit(transaction: item)
            )
        }
    }
}
