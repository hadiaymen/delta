import SwiftUI

/// History ledger view providing an audit trail of all personal expense records,
/// including a dedicated filter for Split outlays with interactive settlement details.
public struct HistoryView: View {
    @ObservedObject public var service: ExpenseTrackingService
    @StateObject private var viewModel: HistoryViewModel

    @State private var editingTransaction: TransactionItem? = nil
    @State private var selectedSplit: SplitRecord? = nil

    public init(service: ExpenseTrackingService) {
        self.service = service
        self._viewModel = StateObject(wrappedValue: HistoryViewModel(service: service))
    }

    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Top Bar
                HStack {
                    Spacer()

                    Text("History")
                        .font(DeltaTypography.screenTitle)
                        .foregroundColor(Color.deltaTextOnDark)

                    Spacer()

                    SquircleButton(
                        iconName: "square.and.arrow.up",
                        size: DeltaDimensions.sizeTopBarButton,
                        style: .dark,
                        action: {}
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                // Dedicated Filter Pill Selector (All, Outflows, Inflows, Splits)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(HistoryViewModel.FilterOption.allCases) { option in
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    viewModel.selectedFilter = option
                                }
                            }) {
                                HStack(spacing: 5) {
                                    if option == .splits {
                                        Image(systemName: "arrow.triangle.branch")
                                            .font(.system(size: 11))
                                    }
                                    Text(option.rawValue)
                                        .font(DeltaTypography.actionLabel)
                                }
                                .foregroundColor(viewModel.selectedFilter == option ? Color.deltaTextOnLime : Color.deltaTextMutedDark)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(viewModel.selectedFilter == option ? Color.deltaSurfaceLime : Color.deltaBgOliveDark)
                                        .overlay(
                                            Capsule().stroke(Color.deltaBorderOlive, lineWidth: viewModel.selectedFilter == option ? 0 : 1)
                                        )
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // Content according to selected filter
                if viewModel.selectedFilter == .splits {
                    // Dedicated Splits List
                    VStack(spacing: 12) {
                        if viewModel.filteredSplits.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "arrow.triangle.branch")
                                    .font(.system(size: 28, weight: .light))
                                    .foregroundColor(Color.deltaTextMutedDark.opacity(0.6))
                                    .padding(.top, 20)
                                Text("No Split Records")
                                    .font(DeltaTypography.bodySemibold)
                                    .foregroundColor(Color.deltaTextMutedDark)
                                Text("Split an outlay in Cards or Home to track shared expenses.")
                                    .font(DeltaTypography.captionMeta)
                                    .foregroundColor(Color.deltaTextMutedDark.opacity(0.8))
                                    .padding(.bottom, 20)
                            }
                            .frame(maxWidth: .infinity)
                            .background(RoundedRectangle(cornerRadius: 18).fill(Color.deltaBgSubtle.opacity(0.5)))
                            .padding(.horizontal, 20)
                        } else {
                            ForEach(viewModel.filteredSplits) { split in
                                SplitCardView(split: split) {
                                    selectedSplit = split
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                } else {
                    // Standard Transaction Cards Ledger
                    VStack(spacing: 12) {
                        if viewModel.filteredTransactions.isEmpty {
                            Text("No transactions found.")
                                .font(DeltaTypography.actionLabel)
                                .foregroundColor(Color.deltaTextMutedDark)
                                .padding(.top, 20)
                        } else {
                            ForEach(viewModel.filteredTransactions) { item in
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
                    }
                    .padding(.horizontal, 20)
                }

                // Bottom Padding for Nav Dock
                Spacer()
                    .frame(height: 110)
            }
        }
        .background(Color.deltaBgCanvas.ignoresSafeArea())
        .sheet(item: $editingTransaction) { item in
            TransactionFormSheet(
                service: service,
                mode: .edit(transaction: item)
            )
        }
        .sheet(item: $selectedSplit) { split in
            SplitDetailsSheet(service: service, split: split)
        }
    }
}
