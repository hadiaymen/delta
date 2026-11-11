import SwiftUI
import Combine

/// Unified item in global search results representing either a transaction or a split record.
public enum SearchResultItem: Identifiable, Hashable {
    case transaction(TransactionItem)
    case split(SplitRecord)

    public var id: String {
        switch self {
        case .transaction(let item):
            return "tx_\(item.id)"
        case .split(let record):
            return "split_\(record.id)"
        }
    }

    public var timestamp: Date {
        switch self {
        case .transaction(let item):
            return item.timestamp
        case .split(let record):
            return record.timestamp
        }
    }
}

/// View model driving global DELTA search across transactions and splits,
/// featuring case-insensitive partial matching, debounced typing updates,
/// persistent recent searches, category filtering, and instant deletion updates.
public final class SearchViewModel: ObservableObject {
    @Published public var searchText: String = ""
    @Published public var debouncedSearchText: String = ""
    @Published public var selectedCategory: ExpenseCategory? = nil
    @Published public var selectedFilterType: FilterScope = .all
    @Published public var recentSearches: [String] = []

    public enum FilterScope: String, CaseIterable, Identifiable {
        case all = "All"
        case debits = "Debits"
        case credits = "Credits"
        case splits = "Splits"
        case other = "Other"

        public var id: String { rawValue }
    }

    public let service: ExpenseTrackingService
    private var cancellables = Set<AnyCancellable>()
    private let userDefaultsKey = "delta_recent_searches"

    public init(service: ExpenseTrackingService) {
        self.service = service
        loadRecentSearches()

        // 150ms debounce for smooth 60fps typing without CPU thrashing
        $searchText
            .debounce(for: .milliseconds(150), scheduler: RunLoop.main)
            .removeDuplicates()
            .assign(to: \.debouncedSearchText, on: self)
            .store(in: &cancellables)

        // Observe reactive updates from service so deletions remove items immediately
        service.$transactions
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        service.$splits
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    // MARK: - Filtered Global Search Results (Strict Descending Chronology)
    public var searchResults: [SearchResultItem] {
        let query = debouncedSearchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        var results: [SearchResultItem] = []

        // 1. Filter Transactions
        let matchingTxs = service.transactions.filter { tx in
            matchesTransaction(tx: tx, query: query)
        }
        for tx in matchingTxs {
            results.append(.transaction(tx))
        }

        // 2. Filter Splits (Unless specifically scoped to debits/credits/other only)
        if selectedCategory == nil && (selectedFilterType == .all || selectedFilterType == .splits) {
            let matchingSplits = service.splits.filter { split in
                matchesSplit(split: split, query: query)
            }
            for split in matchingSplits {
                results.append(.split(split))
            }
        }

        // 3. Sort strictly by newest date and time first
        return results.sorted { $0.timestamp > $1.timestamp }
    }

    // MARK: - Transaction Match Predicate
    private func matchesTransaction(tx: TransactionItem, query: String) -> Bool {
        // Scope Filter Check
        switch selectedFilterType {
        case .all:
            break
        case .debits:
            guard tx.type == .debit else { return false }
        case .credits:
            guard tx.type == .credit else { return false }
        case .splits:
            guard tx.linkedSplitID != nil else { return false }
        case .other:
            guard tx.type == .other else { return false }
        }

        // Category Filter Check
        if let cat = selectedCategory, tx.category != cat {
            return false
        }

        if query.isEmpty {
            return true
        }

        // Searchable Properties:
        // Title / Person / Merchant
        if tx.title.localizedCaseInsensitiveContains(query) { return true }

        // Category
        if tx.category.rawValue.localizedCaseInsensitiveContains(query) { return true }

        // Note / Purpose
        if let note = tx.note, note.localizedCaseInsensitiveContains(query) { return true }

        // Description
        if let desc = tx.descriptionText, desc.localizedCaseInsensitiveContains(query) { return true }

        // Account
        if tx.accountName.localizedCaseInsensitiveContains(query) { return true }

        // Transaction ID
        if tx.trxID.localizedCaseInsensitiveContains(query) { return true }

        // Transaction Type
        if tx.type.rawValue.localizedCaseInsensitiveContains(query) { return true }
        if tx.linkedSplitID != nil && "split".contains(query) { return true }

        // Amount (plain or formatted)
        if tx.plainAmountString.localizedCaseInsensitiveContains(query) { return true }
        if tx.formattedAmount.localizedCaseInsensitiveContains(query) { return true }
        if "\(tx.amount)".localizedCaseInsensitiveContains(query) { return true }

        // Date (Formatted String, Day, Month, Year)
        if tx.dateString.localizedCaseInsensitiveContains(query) { return true }
        if tx.timeString.localizedCaseInsensitiveContains(query) { return true }
        if tx.dateGroupLabel.localizedCaseInsensitiveContains(query) { return true }

        return false
    }

    // MARK: - Split Match Predicate
    private func matchesSplit(split: SplitRecord, query: String) -> Bool {
        if query.isEmpty {
            return true
        }

        // Split Title / Purpose
        if split.title.localizedCaseInsensitiveContains(query) { return true }

        // Payer Name (Person)
        if split.payerName.localizedCaseInsensitiveContains(query) { return true }

        // Account Name
        if split.accountName.localizedCaseInsensitiveContains(query) { return true }

        // Split Method
        if split.method.rawValue.localizedCaseInsensitiveContains(query) { return true }

        // Total Amount
        if split.formattedTotalAmount.localizedCaseInsensitiveContains(query) { return true }
        if "\(split.totalExpense)".localizedCaseInsensitiveContains(query) { return true }

        // Date & Time
        if split.dateString.localizedCaseInsensitiveContains(query) { return true }
        if split.timeString.localizedCaseInsensitiveContains(query) { return true }

        // Split Participants
        for participant in split.participants {
            if participant.name.localizedCaseInsensitiveContains(query) {
                return true
            }
        }

        // "split" keyword
        if "split".contains(query) { return true }

        return false
    }

    // MARK: - Recent Searches Management
    public func recordSearchQuery(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        var searches = recentSearches.filter { $0.caseInsensitiveCompare(trimmed) != .orderedSame }
        searches.insert(trimmed, at: 0)

        // Keep maximum 8 recent search items
        if searches.count > 8 {
            searches = Array(searches.prefix(8))
        }

        self.recentSearches = searches
        UserDefaults.standard.set(searches, forKey: userDefaultsKey)
    }

    public func removeRecentSearch(_ query: String) {
        recentSearches.removeAll { $0 == query }
        UserDefaults.standard.set(recentSearches, forKey: userDefaultsKey)
    }

    public func clearRecentSearches() {
        recentSearches.removeAll()
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }

    private func loadRecentSearches() {
        if let stored = UserDefaults.standard.stringArray(forKey: userDefaultsKey) {
            self.recentSearches = stored
        }
    }
}
