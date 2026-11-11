import SwiftUI
import Combine

/// View model driving global expense search and category filtering, including unclassified/other records.
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
                let matchesTitle = item.title.localizedCaseInsensitiveContains(searchText)
                let matchesTrxID = item.trxID.localizedCaseInsensitiveContains(searchText)
                let matchesDesc = item.descriptionText?.localizedCaseInsensitiveContains(searchText) ?? false
                let matchesNote = item.note?.localizedCaseInsensitiveContains(searchText) ?? false
                let matchesAccount = item.accountName.localizedCaseInsensitiveContains(searchText)
                return matchesCategory && (matchesTitle || matchesTrxID || matchesDesc || matchesNote || matchesAccount)
            }
        }
    }
}
