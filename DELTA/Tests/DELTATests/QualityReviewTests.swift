import XCTest
@testable import DELTA

final class QualityReviewTests: XCTestCase {

    // MARK: - 1. Financial Calculations & Decimal Precision
    func testDecimalPrecisionMultiplicationAndSum() {
        let dec1 = Decimal(string: "19.99")!
        let dec2 = Decimal(string: "0.01")!
        let sum = dec1 + dec2
        XCTAssertEqual(sum, Decimal(string: "20.00")!)

        // 3-way split of 100.00 minor unit distribution
        let shares = try? SplitCalculationEngine.calculateEqualSplit(
            totalExpense: 100,
            participants: ["Alice", "Bob", "Charlie"],
            includeCurrentUser: false
        )
        XCTAssertNotNil(shares)
        let totalSum = shares!.reduce(Decimal.zero) { $0 + $1.shareAmount }
        XCTAssertEqual(totalSum, Decimal(100))
        // Deterministic cents: 33.34, 33.33, 33.33
        XCTAssertEqual(shares![0].shareAmount, Decimal(string: "33.34")!)
        XCTAssertEqual(shares![1].shareAmount, Decimal(string: "33.33")!)
        XCTAssertEqual(shares![2].shareAmount, Decimal(string: "33.33")!)
    }

    // MARK: - 2. Credit vs Debit Behavior & Account Balance Invariants
    func testCreditIncreasesAndDebitDecreasesBalance() async throws {
        let repo = LocalTransactionRepository()
        let service = ExpenseTrackingService(repository: repo)
        await service.loadData()

        let account = service.accounts.first!
        let initialBal = account.currentBalance

        // 1. Inflow (Credit)
        try await service.recordTransaction(
            type: .credit,
            amount: 500,
            title: "Bonus Deposit",
            timestamp: Date(),
            category: .income,
            accountID: account.id,
            accountName: account.accountName
        )

        let afterCredit = service.accounts.first(where: { $0.id == account.id })!.currentBalance
        XCTAssertEqual(afterCredit, initialBal + 500)

        // 2. Outflow (Debit)
        try await service.recordTransaction(
            type: .debit,
            amount: 200,
            title: "Hardware Tool",
            timestamp: Date(),
            category: .shopping,
            accountID: account.id,
            accountName: account.accountName
        )

        let afterDebit = service.accounts.first(where: { $0.id == account.id })!.currentBalance
        XCTAssertEqual(afterDebit, initialBal + 300)
    }

    // MARK: - 3. Data Backup & Atomic Restore
    func testDataBackupAndRestoreCycle() async throws {
        let repo = LocalTransactionRepository()
        let service = ExpenseTrackingService(repository: repo)
        await service.loadData()

        // Log a unique marker transaction
        let markerTitle = "BackupMarker_\(UUID().uuidString.prefix(6))"
        try await service.recordTransaction(
            type: .debit,
            amount: 77.77,
            title: markerTitle,
            timestamp: Date(),
            category: .entertainment,
            accountID: service.accounts.first!.id,
            accountName: service.accounts.first!.accountName
        )

        // 1. Export Backup
        let backupData = try await service.exportBackup()
        XCTAssertFalse(backupData.isEmpty)

        // 2. Clear / mutate ledger
        let markerTx = service.transactions.first(where: { $0.title == markerTitle })!
        try await service.deleteTransaction(id: markerTx.id)
        XCTAssertFalse(service.transactions.contains(where: { $0.title == markerTitle }))

        // 3. Restore from Backup
        try await service.restoreFromBackup(data: backupData)

        // 4. Verify restored state
        XCTAssertTrue(service.transactions.contains(where: { $0.title == markerTitle }))
        let restoredTx = service.transactions.first(where: { $0.title == markerTitle })!
        XCTAssertEqual(restoredTx.amount, Decimal(string: "77.77"))
    }

    // MARK: - 4. Deletion Cascade & Safe 5s Undo
    func testDeletionCascadeAndUndo() async throws {
        let repo = LocalTransactionRepository()
        let service = ExpenseTrackingService(repository: repo)
        await service.loadData()

        // Create a split
        let shares = try SplitCalculationEngine.calculateEqualSplit(
            totalExpense: 60,
            participants: ["Alex", "Jordan"],
            includeCurrentUser: true,
            currentUserName: "Hadi Aymen"
        )
        try await service.recordSplit(
            title: "Dinner Outlay",
            totalExpense: 60,
            payerName: "Hadi Aymen",
            accountID: service.accounts.first!.id,
            accountName: service.accounts.first!.accountName,
            method: .equal,
            shares: shares
        )

        let split = service.splits.first(where: { $0.title == "Dinner Outlay" })!
        guard let linkedID = split.linkedTransactionID else {
            XCTFail("Missing linked transaction")
            return
        }

        // Delete linked transaction
        try await service.deleteTransaction(id: linkedID)
        XCTAssertFalse(service.splits.contains(where: { $0.id == split.id }))

        // Undo deletion
        await service.undoLastDeletion()
        XCTAssertTrue(service.splits.contains(where: { $0.id == split.id }))
        XCTAssertTrue(service.transactions.contains(where: { $0.id == linkedID }))
    }

    // MARK: - 5. QR Code Safety & UPI Parsing
    func testQRPayloadSafetyValidation() {
        let safeUPI = "upi://pay?pa=store@upi&pn=Grocery+Store&am=88.40&tn=Supplies&tr=ORD100"
        let result = QRPayloadParser.parse(payload: safeUPI)
        guard case .success(let payload) = result else {
            XCTFail("Failed parsing safe UPI")
            return
        }
        XCTAssertEqual(payload.payeeName, "Grocery Store")
        XCTAssertEqual(payload.amount, Decimal(string: "88.40")!)

        // Reject dangerous link
        let dangerous = "javascript:document.cookie"
        let badResult = QRPayloadParser.parse(payload: dangerous)
        guard case .failure = badResult else {
            XCTFail("Failed to reject dangerous script URI")
            return
        }
    }

    // MARK: - 6. Global Search Multi-Field & Reactive Deletion
    func testSearchIndexingAndReactiveDeletion() async throws {
        let repo = LocalTransactionRepository()
        let service = ExpenseTrackingService(repository: repo)
        await service.loadData()
        let searchVM = SearchViewModel(service: service)

        let uniqueParty = "UniqueParty_\(UUID().uuidString.prefix(4))"
        try await service.recordTransaction(
            type: .debit,
            amount: 15.00,
            title: uniqueParty,
            timestamp: Date(),
            category: .dining,
            accountID: service.accounts.first!.id,
            accountName: service.accounts.first!.accountName
        )

        searchVM.debouncedSearchText = uniqueParty.lowercased()
        XCTAssertEqual(searchVM.searchResults.count, 1)

        let item = service.transactions.first(where: { $0.title == uniqueParty })!
        try await service.deleteTransaction(id: item.id)

        XCTAssertTrue(searchVM.searchResults.isEmpty, "Item must vanish from search immediately upon deletion")
    }
}

