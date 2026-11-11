import SwiftUI

/// History ledger view providing an audit trail of all personal expense records,
/// structured with 4 primary category filters (Debit, Credit, Split, Other) plus All,
/// date-grouped descending chronology, detail inspector, deletion with confirmation, and safe 5s Undo.
public struct HistoryView: View {
    @ObservedObject public var service: ExpenseTrackingService
    @StateObject private var viewModel: HistoryViewModel

    @State private var selectedTransaction: TransactionItem? = nil
    @State private var selectedSplit: SplitRecord? = nil
    @State private var showSearchField: Bool = false

    public init(service: ExpenseTrackingService) {
        self.service = service
        self._viewModel = StateObject(wrappedValue: HistoryViewModel(service: service))
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Top Bar
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("History")
                                .font(DeltaTypography.screenTitle)
                                .foregroundColor(Color.deltaTextOnDark)

                            Text("\(service.transactions.count) records logged")
                                .font(DeltaTypography.captionMeta)
                                .foregroundColor(Color.deltaTextMutedDark)
                        }

                        Spacer()

                        // Search Toggle Button
                        SquircleButton(
                            iconName: showSearchField ? "xmark" : "magnifyingglass",
                            size: DeltaDimensions.sizeTopBarButton,
                            style: .dark,
                            action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showSearchField.toggle()
                                    if !showSearchField {
                                        viewModel.searchQuery = ""
                                    }
                                }
                            }
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    // Expandable In-line Search Bar
                    if showSearchField {
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color.deltaTextMutedDark)

                            TextField("Search title, party, note, or ID...", text: $viewModel.searchQuery)
                                .font(DeltaTypography.bodySemibold)
                                .foregroundColor(Color.deltaTextOnDark)
                                .accentColor(Color.deltaSurfaceLime)

                            if !viewModel.searchQuery.isEmpty {
                                Button(action: { viewModel.searchQuery = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Color.deltaTextMutedDark)
                                }
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.deltaBgOliveDark)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.deltaBorderOlive, lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    // 5-Filter Pill Selector (All, Debit, Credit, Split, Other)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(HistoryViewModel.FilterOption.allCases) { option in
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        viewModel.selectedFilter = option
                                    }
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: option.iconName)
                                            .font(.system(size: 11, weight: .bold))

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
                    .padding(.top, 4)

                    // Content Ledger
                    if viewModel.selectedFilter == .split {
                        // Split specific view: Shows Split Cards and Split Transactions
                        VStack(spacing: 16) {
                            if viewModel.filteredSplits.isEmpty && viewModel.filteredTransactions.isEmpty {
                                emptyStateView(
                                    icon: "arrow.triangle.branch",
                                    title: "No Split Records",
                                    message: "Split outlays created in Cards or Home will appear here."
                                )
                            } else {
                                // Dedicated Split Records Cards
                                if !viewModel.filteredSplits.isEmpty {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("ACTIVE SPLITS")
                                            .font(.system(size: 11, weight: .bold, design: .rounded))
                                            .foregroundColor(Color.deltaTextMutedDark)
                                            .padding(.horizontal, 20)

                                        ForEach(viewModel.filteredSplits) { split in
                                            SplitCardView(split: split) {
                                                selectedSplit = split
                                            }
                                            .padding(.horizontal, 20)
                                        }
                                    }
                                }

                                // Linked Split Transactions grouped by Date
                                if !viewModel.groupedTransactions.isEmpty {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("SPLIT EXPENSE TRANSACTIONS")
                                            .font(.system(size: 11, weight: .bold, design: .rounded))
                                            .foregroundColor(Color.deltaTextMutedDark)
                                            .padding(.horizontal, 20)

                                        dateGroupedTransactionsList
                                    }
                                }
                            }
                        }
                    } else {
                        // Standard Ledger Grouped by Date (Newest Date and Time First)
                        if viewModel.groupedTransactions.isEmpty {
                            emptyStateView(
                                icon: viewModel.selectedFilter.iconName,
                                title: "No \(viewModel.selectedFilter.rawValue) Transactions",
                                message: "Logged records matching this filter will be audited here."
                            )
                        } else {
                            dateGroupedTransactionsList
                        }
                    }

                    // Bottom Padding for Nav Dock and Floating Undo
                    Spacer()
                        .frame(height: 120)
                }
            }

            // Floating Undo Banner
            if viewModel.showUndoBanner {
                undoBannerView
            }
        }
        .background(Color.deltaBgCanvas.ignoresSafeArea())
        .sheet(item: $selectedTransaction) { item in
            TransactionDetailSheet(
                service: service,
                transaction: item,
                onDeleted: {
                    viewModel.triggerUndoToast()
                }
            )
        }
        .sheet(item: $selectedSplit) { split in
            SplitDetailsSheet(service: service, split: split)
        }
    }

    // MARK: - Date Grouped Transactions List
    private var dateGroupedTransactionsList: some View {
        VStack(spacing: 18) {
            ForEach(viewModel.groupedTransactions, id: \.date) { group in
                VStack(alignment: .leading, spacing: 10) {
                    // Date Header
                    HStack {
                        Text(group.dateLabel.uppercased())
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(Color.deltaTextMutedDark)

                        Spacer()

                        Text("\(group.items.count) \(group.items.count == 1 ? "entry" : "entries")")
                            .font(DeltaTypography.captionMeta)
                            .foregroundColor(Color.deltaTextMutedDark.opacity(0.8))
                    }
                    .padding(.horizontal, 20)

                    // Transactions for this day
                    VStack(spacing: 10) {
                        ForEach(group.items) { item in
                            HistoryRowView(item: item) {
                                selectedTransaction = item
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }

    // MARK: - Floating Undo Banner
    private var undoBannerView: some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.uturn.backward.circle.fill")
                .foregroundColor(Color.deltaSurfaceLime)
                .font(.system(size: 22))

            VStack(alignment: .leading, spacing: 2) {
                Text("Transaction deleted")
                    .font(DeltaTypography.bodySemibold)
                    .foregroundColor(Color.deltaTextOnDark)

                Text("Available for \(viewModel.undoCountdownSeconds)s")
                    .font(DeltaTypography.captionMeta)
                    .foregroundColor(Color.deltaTextMutedDark)
            }

            Spacer()

            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.performUndo()
                }
            }) {
                Text("UNDO")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color.deltaTextOnLime)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.deltaSurfaceLime))
            }

            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.dismissUndoToast()
                }
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color.deltaTextMutedDark)
                    .padding(4)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.deltaBgOliveDark)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.deltaBorderOlive, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.55), radius: 12, y: 6)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 94)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Empty State Helper
    private func emptyStateView(icon: String, title: String, message: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 32, weight: .light))
                .foregroundColor(Color.deltaTextMutedDark.opacity(0.7))
                .padding(.top, 24)

            Text(title)
                .font(DeltaTypography.cardTitle)
                .foregroundColor(Color.deltaTextOnDark)

            Text(message)
                .font(DeltaTypography.captionMeta)
                .foregroundColor(Color.deltaTextMutedDark)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.deltaBgSubtle.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.deltaBorderOlive.opacity(0.5), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
}
