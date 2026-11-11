import SwiftUI
import Combine

/// View model driving global expense search and category filtering.
public final class SearchViewModel: ObservableObject {
    @Published public var searchText: String = ""
    @Published public var selectedCategory: ExpenseCategory? = nil

    public let service: ExpenseTrackingService

    public init(service: ExpenseTrackingService) {
        self.service = service
    }

    public var searchResults: [TransactionItem] {
        service.transactions.filter { item in
            let matchesCategory: Bool
            if let cat = selectedCategory {
                matchesCategory = item.category == cat
            } else {
                matchesCategory = true
            }

            if searchText.isEmpty {
                return matchesCategory
            } else {
                return matchesCategory && (
                    item.title.localizedCaseInsensitiveContains(searchText) ||
                    item.trxID.localizedCaseInsensitiveContains(searchText)
                )
            }
        }
    }
}

