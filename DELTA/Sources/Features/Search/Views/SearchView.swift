import SwiftUI

/// Global search view querying across transactions and splits,
/// supporting multi-field matching, recent searches, category filters, and descending chronological sorting.
public struct SearchView: View {
    @ObservedObject public var service: ExpenseTrackingService
    @StateObject private var viewModel: SearchViewModel

    @State private var selectedTransaction: TransactionItem? = nil
    @State private var selectedSplit: SplitRecord? = nil

    public init(service: ExpenseTrackingService) {
        self.service = service
        self._viewModel = StateObject(wrappedValue: SearchViewModel(service: service))
    }

    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // Top Header Bar
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Search")
                            .font(DeltaTypography.screenTitle)
                            .foregroundColor(Color.deltaTextOnDark)

                        Text("Query all records, participants & notes")
                            .font(DeltaTypography.captionMeta)
                            .foregroundColor(Color.deltaTextMutedDark)
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                // Search Bar Input
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.deltaTextMutedDark)

                    TextField("Search title, person, note, amount, date...", text: $viewModel.searchText)
                        .font(DeltaTypography.bodySemibold)
                        .foregroundColor(Color.deltaTextOnDark)
                        .accentColor(Color.deltaSurfaceLime)
                        .autocorrectionDisabled()
                        .onSubmit {
                            viewModel.recordSearchQuery(viewModel.searchText)
                        }

                    if !viewModel.searchText.isEmpty {
                        Button(action: {
                            viewModel.searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color.deltaTextMutedDark)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.deltaBgOliveDark)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.deltaBorderOlive, lineWidth: 1)
                )
                .padding(.horizontal, 20)

                // Scope Filters (All, Debits, Credits, Splits, Other)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(SearchViewModel.FilterScope.allCases) { scope in
                            let isSelected = viewModel.selectedFilterType == scope
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    viewModel.selectedFilterType = scope
                                }
                            }) {
                                Text(scope.rawValue)
                                    .font(DeltaTypography.actionLabel)
                                    .foregroundColor(isSelected ? Color.deltaTextOnLime : Color.deltaTextMutedDark)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(
                                        Capsule()
                                            .fill(isSelected ? Color.deltaSurfaceLime : Color.deltaBgOliveDark)
                                            .overlay(Capsule().stroke(Color.deltaBorderOlive, lineWidth: isSelected ? 0 : 1))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // Category Filter Chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(ExpenseCategory.allCases) { category in
                            let isSelected = viewModel.selectedCategory == category
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    if isSelected {
                                        viewModel.selectedCategory = nil
                                    } else {
                                        viewModel.selectedCategory = category
                                    }
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: category.iconName)
                                        .font(.system(size: 11))

                                    Text(category.rawValue)
                                        .font(DeltaTypography.actionLabel)
                                }
                                .foregroundColor(isSelected ? Color.deltaTextOnLime : Color.deltaTextMutedDark)
                                .padding(.horizontal, 13)
                                .padding(.vertical, 7)
                                .background(
                                    Capsule()
                                        .fill(isSelected ? Color.deltaSurfaceLime : Color.deltaBgOliveDark)
                                        .overlay(Capsule().stroke(Color.deltaBorderOlive, lineWidth: isSelected ? 0 : 1))
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // Content: Recent Searches (When search text is empty) OR Search Results
                if viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && viewModel.selectedCategory == nil && viewModel.selectedFilterType == .all {
                    recentSearchesSection
                } else {
                    searchResultsSection
                }

                // Bottom Padding for Nav Dock
                Spacer()
                    .frame(height: 110)
            }
        }
        .background(Color.deltaBgCanvas.ignoresSafeArea())
        .sheet(item: $selectedTransaction) { item in
            TransactionDetailSheet(
                service: service,
                transaction: item
            )
        }
        .sheet(item: $selectedSplit) { split in
            SplitDetailsSheet(
                service: service,
                split: split
            )
        }
    }

    // MARK: - Recent Searches Section
    private var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            if !viewModel.recentSearches.isEmpty {
                HStack {
                    Text("RECENT SEARCHES")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(Color.deltaTextMutedDark)

                    Spacer()

                    Button(action: {
                        viewModel.clearRecentSearches()
                    }) {
                        Text("Clear All")
                            .font(DeltaTypography.captionMeta)
                            .foregroundColor(Color.deltaTextMutedDark)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 6)

                // Recent Searches Flow Pills
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(viewModel.recentSearches, id: \.self) { query in
                        HStack {
                            Button(action: {
                                viewModel.searchText = query
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "clock.arrow.circlepath")
                                        .font(.system(size: 13))
                                        .foregroundColor(Color.deltaSurfaceLime)

                                    Text(query)
                                        .font(DeltaTypography.bodySemibold)
                                        .foregroundColor(Color.deltaTextOnDark)

                                    Spacer()
                                }
                            }

                            Button(action: {
                                viewModel.removeRecentSearch(query)
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(Color.deltaTextMutedDark)
                                    .padding(6)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.deltaBgOliveDark)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.deltaBorderOlive, lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 20)
            } else {
                // Empty Initial State Card
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(Color.deltaTextMutedDark.opacity(0.6))
                        .padding(.top, 24)

                    Text("Global Finance Search")
                        .font(DeltaTypography.cardTitle)
                        .foregroundColor(Color.deltaTextOnDark)

                    Text("Type a merchant, person name, note, account envelope, amount, or split participant.")
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
                .padding(.top, 10)
            }
        }
    }

    // MARK: - Search Results Section
    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            let results = viewModel.searchResults

            if results.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(Color.deltaExpenseRed.opacity(0.8))
                        .padding(.top, 24)

                    Text("No Results for '\(viewModel.searchText)'")
                        .font(DeltaTypography.cardTitle)
                        .foregroundColor(Color.deltaTextOnDark)

                    Text("No matching transactions, notes, or split expenses found. Try adjusting spelling or filter criteria.")
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
                .padding(.top, 10)
            } else {
                HStack {
                    Text("\(results.count) RESULTS • NEWEST FIRST")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(Color.deltaTextMutedDark)

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)

                VStack(spacing: 10) {
                    ForEach(results) { item in
                        switch item {
                        case .transaction(let tx):
                            HistoryRowView(item: tx) {
                                viewModel.recordSearchQuery(viewModel.searchText)
                                selectedTransaction = tx
                            }

                        case .split(let split):
                            SplitCardView(split: split) {
                                viewModel.recordSearchQuery(viewModel.searchText)
                                selectedSplit = split
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}
