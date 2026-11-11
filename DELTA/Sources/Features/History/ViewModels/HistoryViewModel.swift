import SwiftUI
import Combine

/// View model driving the History ledger screen with dedicated Splits filter support.
public final class HistoryViewModel: ObservableObject {
    @Published public var selectedFilter: FilterOption = .all
    @Published public var searchQuery: String = ""

    public enum FilterOption: String, CaseIterable, Identifiable {
        case all = "All"
        case expenses = "Outflows"
        case income = "Inflows"
        case splits = "Splits"

        public var id: String { rawValue }
    }

    public let service: ExpenseTrackingService

    public init(service: ExpenseTrackingService) {
        self.service = service
    }

    public var filteredTransactions: [TransactionItem] {
        service.transactions.filter { item in
            let matchesFilter: Bool
            switch selectedFilter {
            case .all:
                matchesFilter = true
            case .expenses:
                matchesFilter = item.type == .debit
            case .income:
                matchesFilter = item.type == .credit
            case .splits:
                matchesFilter = item.linkedSplitID != nil
            }

            if searchQuery.isEmpty {
                return matchesFilter
            } else {
                return matchesFilter && (
                    item.title.localizedCaseInsensitiveContains(searchQuery) ||
                    item.trxID.localizedCaseInsensitiveContains(searchQuery)
                )
            }
        }
    }

    public var filteredSplits: [SplitRecord] {
        service.splits.filter { split in
            if searchQuery.isEmpty {
                return true
            } else {
                return split.title.localizedCaseInsensitiveContains(searchQuery) ||
                       split.payerName.localizedCaseInsensitiveContains(searchQuery) ||
                       split.participants.contains(where: { $0.name.localizedCaseInsensitiveContains(searchQuery) })
            }
        }
    }
}
