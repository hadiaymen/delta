import XCTest
@testable import DELTA

final class GlobalSearchTests: XCTestCase {
    private var service: ExpenseTrackingService!
    private var viewModel: SearchViewModel!

    override func setUp() async throws {
        try await super.setUp()
        let repo = LocalTransactionRepository()
        self.service = ExpenseTrackingService(repository: repo)
        await service.loadData()
        self.viewModel = SearchViewModel(service: service)
    }

    // MARK: - 1. Search by Title & Merchant (Case-Insensitive Partial Matching)
    func testSearchByTitleAndMerchantPartialMatch() async throws {
        try await service.recordTransaction(
            type: .debit,
            amount: 45.00,
            title: "Whole Foods Market",
            timestamp: Date(),
            category: .groceries,
            accountID: "card-1",
            accountName: "DELTA PERSONAL"
        )

        viewModel.debouncedSearchText = "whole"
        let results = viewModel.searchResults
        XCTAssertFalse(results.isEmpty)
        if case .transaction(let tx) = results.first {
            XCTAssertEqual(tx.title, "Whole Foods Market")
        } else {
            XCTFail("Expected matching transaction")
        }
    }

    // MARK: - 2. Search by Note & Purpose
    func testSearchByNoteAndPurpose() async throws {
        try await service.recordTransaction(
            type: .debit,
            amount: 18.50,
            title: "Cafe Nero",
            timestamp: Date(),
            category: .dining,
            accountID: "card-1",
            accountName: "DELTA PERSONAL",
            note: "Client quarterly strategy session"
        )

        viewModel.debouncedSearchText = "quarterly strategy"
        let results = viewModel.searchResults
        XCTAssertEqual(results.count, 1)
        if case .transaction(let tx) = results.first {
            XCTAssertEqual(tx.note, "Client quarterly strategy session")
        } else {
            XCTFail("Expected matching note")
        }
    }

    // MARK: - 3. Search by Split Participant Name
    func testSearchBySplitParticipantName() async throws {
        let shares = try SplitCalculationEngine.calculateEqualSplit(
            totalExpense: 120,
            participants: ["Marcus Aurelius", "Elena Rostova"],
            includeCurrentUser: true,
            currentUserName: "Hadi Aymen"
        )

        try await service.recordSplit(
            title: "Team Offsite Dinner",
            totalExpense: 120,
            payerName: "Hadi Aymen",
            accountID: "card-1",
            accountName: "DELTA PERSONAL",
            method: .equal,
            shares: shares
        )

        viewModel.debouncedSearchText = "elena"
        let results = viewModel.searchResults
        XCTAssertFalse(results.isEmpty)

        let containsElenaSplit = results.contains { item in
            if case .split(let split) = item {
                return split.participants.contains(where: { $0.name.localizedCaseInsensitiveContains("elena") })
            }
            return false
        }
        XCTAssertTrue(containsElenaSplit, "Split with Elena as participant should be found")
    }

    // MARK: - 4. Search by Amount & Account
    func testSearchByAmountAndAccount() async throws {
        try await service.recordTransaction(
            type: .credit,
            amount: 987.65,
            title: "Consulting Inflow",
            timestamp: Date(),
            category: .income,
            accountID: "card-3",
            accountName: "DELTA SAVINGS"
        )

        // Search by numeric amount substring
        viewModel.debouncedSearchText = "987.65"
        var results = viewModel.searchResults
        XCTAssertFalse(results.isEmpty)

        // Search by account name
        viewModel.debouncedSearchText = "savings"
        results = viewModel.searchResults
        XCTAssertTrue(results.contains { item in
            if case .transaction(let tx) = item {
                return tx.accountName == "DELTA SAVINGS"
            }
            return false
        })
    }

    // MARK: - 5. Search by Category & Transaction Type
    func testSearchByCategoryAndType() async throws {
        try await service.recordTransaction(
            type: .other,
            amount: 55.00,
            title: "Unknown Kiosk Charge",
            timestamp: Date(),
            category: .other,
            accountID: "card-2",
            accountName: "DELTA CASH"
        )

        // Search by type keyword "other"
        viewModel.debouncedSearchText = "other"
        let results = viewModel.searchResults
        XCTAssertTrue(results.contains { item in
            if case .transaction(let tx) = item {
                return tx.title == "Unknown Kiosk Charge"
            }
            return false
        })
    }

    // MARK: - 6. Chronological Sorting Invariant (Newest First)
    func testResultsSortedNewestFirst() async throws {
        let now = Date()
        let older = Calendar.current.date(byAdding: .day, value: -3, to: now)!

        let txOld = TransactionItem(title: "Echo Old", amount: 10, type: .debit, timestamp: older)
        let txNew = TransactionItem(title: "Echo New", amount: 20, type: .debit, timestamp: now)
        service.transactions = [txOld, txNew]

        viewModel.debouncedSearchText = "echo"
        let results = viewModel.searchResults
        XCTAssertEqual(results.count, 2)
        if case .transaction(let first) = results[0],
           case .transaction(let second) = results[1] {
            XCTAssertEqual(first.title, "Echo New")
            XCTAssertEqual(second.title, "Echo Old")
            XCTAssertTrue(first.timestamp > second.timestamp)
        } else {
            XCTFail("Ordering failed")
        }
    }

    // MARK: - 7. Instant Deletion Sync (Item immediately removed from Search)
    func testDeletingTransactionImmediatelyRemovesFromSearch() async throws {
        try await service.recordTransaction(
            type: .debit,
            amount: 99.00,
            title: "Subscription To Cancel",
            timestamp: Date(),
            category: .utilities,
            accountID: "card-1",
            accountName: "DELTA PERSONAL"
        )

        viewModel.debouncedSearchText = "Subscription To Cancel"
        XCTAssertEqual(viewModel.searchResults.count, 1)

        let targetTx = service.transactions.first(where: { $0.title == "Subscription To Cancel" })!

        // Delete transaction
        try await service.deleteTransaction(id: targetTx.id)

        // Verify immediately removed from search
        let resultsAfterDelete = viewModel.searchResults
        XCTAssertTrue(resultsAfterDelete.isEmpty, "Deleted transaction must vanish from search immediately")
    }

    // MARK: - 8. Recent Searches Management
    func testRecentSearchesManagement() {
        viewModel.clearRecentSearches()
        XCTAssertTrue(viewModel.recentSearches.isEmpty)

        viewModel.recordSearchQuery("Coffee")
        viewModel.recordSearchQuery("Salary")
        viewModel.recordSearchQuery("Coffee") // Duplicate check

        XCTAssertEqual(viewModel.recentSearches, ["Coffee", "Salary"])

        viewModel.removeRecentSearch("Salary")
        XCTAssertEqual(viewModel.recentSearches, ["Coffee"])

        viewModel.clearRecentSearches()
        XCTAssertTrue(viewModel.recentSearches.isEmpty)
    }
}

