import XCTest
@testable import DELTA

final class FinancialCalculationsTests: XCTestCase {
    private var calendar: Calendar!
    private var testDate: Date!

    override func setUp() {
        super.setUp()
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        self.calendar = cal

        // Fixed date: November 15, 2026, 12:00:00 GMT
        var components = DateComponents()
        components.year = 2026
        components.month = 11
        components.day = 15
        components.hour = 12
        components.minute = 0
        components.second = 0
        self.testDate = cal.date(from: components)!
    }

    // MARK: - 1. Monthly Debit Spent Calculations
    func testCalculateMonthlySpentSumsOnlyDebitsInTargetMonth() {
        let sameMonthDebit1 = TransactionItem(
            title: "Groceries",
            amount: Decimal(string: "124.50")!,
            type: .debit,
            timestamp: testDate,
            category: .groceries
        )

        let sameMonthDebit2 = TransactionItem(
            title: "Coffee",
            amount: Decimal(string: "5.75")!,
            type: .debit,
            timestamp: calendar.date(byAdding: .day, value: -2, to: testDate)!,
            category: .dining
        )

        let sameMonthCredit = TransactionItem(
            title: "Salary",
            amount: Decimal(string: "3500.00")!,
            type: .credit,
            timestamp: testDate,
            category: .income
        )

        let otherMonthDebit = TransactionItem(
            title: "Last Month Bill",
            amount: Decimal(string: "200.00")!,
            type: .debit,
            timestamp: calendar.date(byAdding: .month, value: -1, to: testDate)!,
            category: .utilities
        )

        let txs = [sameMonthDebit1, sameMonthDebit2, sameMonthCredit, otherMonthDebit]
        let totalSpent = FinancialCalculator.calculateMonthlySpent(
            transactions: txs,
            monthDate: testDate,
            calendar: calendar
        )

        // Expected: 124.50 + 5.75 = 130.25 (Credit and other month ignored)
        XCTAssertEqual(totalSpent, Decimal(string: "130.25")!)
    }

    // MARK: - 2. Decimal Precision (No Floating Point Error)
    func testDecimalPrecisionCalculation() {
        let tx1 = TransactionItem(
            title: "Item 1",
            amount: Decimal(string: "0.10")!,
            type: .debit,
            timestamp: testDate
        )
        let tx2 = TransactionItem(
            title: "Item 2",
            amount: Decimal(string: "0.20")!,
            type: .debit,
            timestamp: testDate
        )

        let total = FinancialCalculator.calculateMonthlySpent(
            transactions: [tx1, tx2],
            monthDate: testDate,
            calendar: calendar
        )

        // In binary IEEE-754 double, 0.1 + 0.2 == 0.30000000000000004.
        // In Decimal arithmetic, 0.10 + 0.20 must equal exactly 0.30.
        XCTAssertEqual(total, Decimal(string: "0.30")!)
    }

    // MARK: - 3. Monthly Received (Credits) Calculation
    func testCalculateMonthlyReceivedSumsOnlyCredits() {
        let credit1 = TransactionItem(
            title: "Freelance",
            amount: Decimal(string: "1250.00")!,
            type: .credit,
            timestamp: testDate
        )
        let credit2 = TransactionItem(
            title: "Refund",
            amount: Decimal(string: "45.50")!,
            type: .credit,
            timestamp: testDate
        )
        let debit = TransactionItem(
            title: "Dinner",
            amount: Decimal(string: "60.00")!,
            type: .debit,
            timestamp: testDate
        )

        let totalReceived = FinancialCalculator.calculateMonthlyReceived(
            transactions: [credit1, credit2, debit],
            monthDate: testDate,
            calendar: calendar
        )

        XCTAssertEqual(totalReceived, Decimal(string: "1295.50")!)
    }

    // MARK: - 4. Monthly Spending Comparison
    func testMonthlyComparisonIncrease() {
        let currentMonthDebit = TransactionItem(
            title: "Rent",
            amount: Decimal(string: "1500.00")!,
            type: .debit,
            timestamp: testDate
        )

        let prevMonthDate = calendar.date(byAdding: .month, value: -1, to: testDate)!
        let prevMonthDebit = TransactionItem(
            title: "Rent",
            amount: Decimal(string: "1000.00")!,
            type: .debit,
            timestamp: prevMonthDate
        )

        let result = FinancialCalculator.calculateMonthlySpendingComparison(
            transactions: [currentMonthDebit, prevMonthDebit],
            monthDate: testDate,
            calendar: calendar
        )

        // (1500 - 1000) / 1000 = 50% increase
        XCTAssertEqual(result.percentage, 50.0, accuracy: 0.01)
        XCTAssertTrue(result.isIncrease)
        XCTAssertEqual(result.formattedText, "↑ 50% vs last month")
    }

    func testMonthlyComparisonDecrease() {
        let currentMonthDebit = TransactionItem(
            title: "Groceries",
            amount: Decimal(string: "600.00")!,
            type: .debit,
            timestamp: testDate
        )

        let prevMonthDate = calendar.date(byAdding: .month, value: -1, to: testDate)!
        let prevMonthDebit = TransactionItem(
            title: "Groceries",
            amount: Decimal(string: "800.00")!,
            type: .debit,
            timestamp: prevMonthDate
        )

        let result = FinancialCalculator.calculateMonthlySpendingComparison(
            transactions: [currentMonthDebit, prevMonthDebit],
            monthDate: testDate,
            calendar: calendar
        )

        // (600 - 800) / 800 = -25%
        XCTAssertEqual(result.percentage, -25.0, accuracy: 0.01)
        XCTAssertFalse(result.isIncrease)
        XCTAssertEqual(result.formattedText, "↓ 25% vs last month")
    }

    // MARK: - 5. Automatic Account Balances Recalculation
    func testAccountBalancesCalculation() {
        let checking = DummyAccountCard(
            id: "acc-1",
            accountName: "DELTA PERSONAL",
            cardholderName: "Hadi Aymen",
            accountIdentifier: "DELTA •••• 1234",
            initialBalance: Decimal(string: "1000.00")!
        )

        let savings = DummyAccountCard(
            id: "acc-2",
            accountName: "DELTA SAVINGS",
            cardholderName: "Hadi Aymen",
            accountIdentifier: "DELTA •••• 5678",
            initialBalance: Decimal(string: "5000.00")!
        )

        let tx1 = TransactionItem(
            title: "Dinner",
            amount: Decimal(string: "150.00")!,
            type: .debit,
            accountID: "acc-1",
            accountName: "DELTA PERSONAL"
        )

        let tx2 = TransactionItem(
            title: "Refund",
            amount: Decimal(string: "50.00")!,
            type: .credit,
            accountID: "acc-1",
            accountName: "DELTA PERSONAL"
        )

        let tx3 = TransactionItem(
            title: "Interest Deposit",
            amount: Decimal(string: "25.00")!,
            type: .credit,
            accountID: "acc-2",
            accountName: "DELTA SAVINGS"
        )

        let updated = FinancialCalculator.calculateAccountBalances(
            accounts: [checking, savings],
            transactions: [tx1, tx2, tx3]
        )

        // acc-1: 1000 - 150 + 50 = 900.00
        XCTAssertEqual(updated[0].currentBalance, Decimal(string: "900.00")!)

        // acc-2: 5000 + 25 = 5025.00
        XCTAssertEqual(updated[1].currentBalance, Decimal(string: "5025.00")!)
    }

    // MARK: - 6. Duplicate Detection
    func testDuplicateTransactionDetection() {
        let existing = TransactionItem(
            id: "orig-1",
            title: "Uber Ride",
            amount: Decimal(string: "28.50")!,
            type: .debit,
            timestamp: testDate,
            accountID: "acc-1"
        )

        // Duplicate with same title, amount, type, account, and timestamp within 60s
        let duplicate = TransactionItem(
            id: "new-1",
            title: "Uber Ride",
            amount: Decimal(string: "28.50")!,
            type: .debit,
            timestamp: testDate.addingTimeInterval(15),
            accountID: "acc-1"
        )

        // Non-duplicate (different title)
        let nonDuplicateTitle = TransactionItem(
            id: "new-2",
            title: "Lyft Ride",
            amount: Decimal(string: "28.50")!,
            type: .debit,
            timestamp: testDate,
            accountID: "acc-1"
        )

        // Non-duplicate (different amount)
        let nonDuplicateAmount = TransactionItem(
            id: "new-3",
            title: "Uber Ride",
            amount: Decimal(string: "32.00")!,
            type: .debit,
            timestamp: testDate,
            accountID: "acc-1"
        )

        XCTAssertTrue(FinancialCalculator.isDuplicate(candidate: duplicate, existing: [existing]))
        XCTAssertFalse(FinancialCalculator.isDuplicate(candidate: nonDuplicateTitle, existing: [existing]))
        XCTAssertFalse(FinancialCalculator.isDuplicate(candidate: nonDuplicateAmount, existing: [existing]))

        // Self-editing should not be reported as a duplicate
        XCTAssertFalse(FinancialCalculator.isDuplicate(candidate: existing, existing: [existing]))
    }

    // MARK: - 7. Validation Rules
    func testValidationRules() {
        // Valid
        XCTAssertEqual(FinancialCalculator.validate(amount: Decimal(string: "15.99")!, title: "Lunch"), .success(()))

        // Empty title
        XCTAssertEqual(FinancialCalculator.validate(amount: Decimal(10), title: "   "), .failure(.emptyTitle))

        // Non-positive amount
        XCTAssertEqual(FinancialCalculator.validate(amount: Decimal(0), title: "Store"), .failure(.nonPositiveAmount))
        XCTAssertEqual(FinancialCalculator.validate(amount: Decimal(-5), title: "Store"), .failure(.nonPositiveAmount))

        // Excessive decimals (> 2 decimal places)
        XCTAssertEqual(FinancialCalculator.validate(amount: Decimal(string: "12.345")!, title: "Store"), .failure(.excessiveDecimals))
    }

    // MARK: - 8. Account CRUD & Balance Invariants
    func testAccountAdditionAndRemovalInvariants() {
        let personal = DummyAccountCard(
            id: "card-1",
            accountName: "DELTA PERSONAL",
            initialBalance: Decimal(1000)
        )
        let cash = DummyAccountCard(
            id: "card-2",
            accountName: "DELTA CASH",
            initialBalance: Decimal(500)
        )
        let savings = DummyAccountCard(
            id: "card-3",
            accountName: "DELTA SAVINGS",
            initialBalance: Decimal(2000)
        )

        var accounts = [personal, cash, savings]

        // Add user-created account
        let travel = DummyAccountCard(
            id: "card-4",
            accountName: "DELTA TRAVEL",
            initialBalance: Decimal(750)
        )
        accounts.append(travel)
        XCTAssertEqual(accounts.count, 4)

        // Delete user-created account
        accounts.removeAll { $0.id == "card-4" }
        XCTAssertEqual(accounts.count, 3)
        XCTAssertEqual(accounts.map(\.accountName), ["DELTA PERSONAL", "DELTA CASH", "DELTA SAVINGS"])
    }

    // MARK: - 9. 'Other' Unclassified Workflow & Conversion Invariants
    func testOtherTransactionCreationAndInPlaceConversion() async throws {
        let repo = LocalTransactionRepository()
        let service = ExpenseTrackingService(repository: repo)
        await service.loadData()

        let initialTxCount = service.transactions.count

        // 1. Record an 'Other' transaction with optional merchant/title left blank
        try await service.recordTransaction(
            type: .other,
            amount: Decimal(string: "78.50")!,
            title: "", // Optional, defaults to "Unclassified Outlay"
            timestamp: Date(),
            category: .other,
            accountID: "delta-personal",
            accountName: "DELTA PERSONAL",
            note: "Mystery charge on card"
        )

        XCTAssertEqual(service.transactions.count, initialTxCount + 1)
        let otherTx = service.transactions.first!
        XCTAssertEqual(otherTx.type, .other)
        XCTAssertEqual(otherTx.amount, Decimal(string: "78.50")!)
        XCTAssertEqual(otherTx.title, "Unclassified Outlay")
        XCTAssertEqual(otherTx.category, .other)

        // Other does not mutate monthly spent until classified
        let spentBefore = service.monthlySpentDecimal

        // 2. In-place conversion from Other into Debit
        try await service.convertOtherTransaction(
            id: otherTx.id,
            toType: .debit,
            category: .groceries
        )

        // Zero duplicate invariant: count remains exactly initialTxCount + 1
        XCTAssertEqual(service.transactions.count, initialTxCount + 1)
        let convertedDebit = service.transactions.first(where: { $0.id == otherTx.id })!
        XCTAssertEqual(convertedDebit.type, .debit)
        XCTAssertEqual(convertedDebit.category, .groceries)

        // Now correctly reflects in monthly spent calculation
        XCTAssertEqual(service.monthlySpentDecimal, spentBefore + Decimal(string: "78.50")!)

        // 3. In-place conversion from Debit into Credit
        try await service.convertOtherTransaction(
            id: otherTx.id,
            toType: .credit,
            category: .income
        )

        XCTAssertEqual(service.transactions.count, initialTxCount + 1)
        let convertedCredit = service.transactions.first(where: { $0.id == otherTx.id })!
        XCTAssertEqual(convertedCredit.type, .credit)
        XCTAssertEqual(convertedCredit.category, .income)
    }

    // MARK: - 10. History Deletion, Cascade & Safe Undo Invariants
    func testDeleteTransactionRemovesFromLedgerAndRecalculatesBalances() async throws {
        let repo = LocalTransactionRepository()
        let service = ExpenseTrackingService(repository: repo)
        await service.loadData()

        // Record a debit transaction
        let targetAccount = service.accounts.first!
        let initialBalance = targetAccount.currentBalance
        let debitAmount = Decimal(string: "150.00")!

        try await service.recordTransaction(
            type: .debit,
            amount: debitAmount,
            title: "Office Chair",
            timestamp: Date(),
            category: .shopping,
            accountID: targetAccount.id,
            accountName: targetAccount.accountName,
            note: "Desk upgrade"
        )

        let tx = service.transactions.first(where: { $0.title == "Office Chair" })!
        let spentWithTx = service.monthlySpentDecimal

        // Deleting transaction
        try await service.deleteTransaction(id: tx.id)

        // 1. Removed from persistent repository and in-memory ledger
        let fetchedTxs = try await repo.fetchTransactions()
        XCTAssertFalse(fetchedTxs.contains(where: { $0.id == tx.id }))
        XCTAssertFalse(service.transactions.contains(where: { $0.id == tx.id }))

        // 2. Account balance restored (debit of 150 removed means balance is back to initial)
        let updatedAccount = service.accounts.first(where: { $0.id == targetAccount.id })!
        XCTAssertEqual(updatedAccount.currentBalance, initialBalance)

        // 3. Monthly spent updated
        XCTAssertEqual(service.monthlySpentDecimal, spentWithTx - debitAmount)
    }

    func testDeleteTransactionCascadesToLinkedSplitWithoutOrphanRecords() async throws {
        let repo = LocalTransactionRepository()
        let service = ExpenseTrackingService(repository: repo)
        await service.loadData()

        // Create a split expense
        let targetAccount = service.accounts.first!
        let totalExpense = Decimal(string: "90.00")!

        let splitResult = try SplitCalculationEngine.calculateEqualSplit(
            totalExpense: totalExpense,
            participants: ["Sarah Jenkins", "Alex Rivera"],
            includeCurrentUser: true,
            currentUserName: "Hadi Aymen"
        )

        try await service.recordSplit(
            title: "Team Lunch",
            totalExpense: totalExpense,
            payerName: "Hadi Aymen",
            accountID: targetAccount.id,
            accountName: targetAccount.accountName,
            method: .equal,
            shares: splitResult
        )

        let splitRecord = service.splits.first(where: { $0.title == "Team Lunch" })!
        let linkedTxID = splitRecord.linkedTransactionID
        XCTAssertNotNil(linkedTxID)

        let linkedTx = service.transactions.first(where: { $0.id == linkedTxID })
        XCTAssertNotNil(linkedTx)

        // Deleting the transaction must cascade and remove the linked split without leaving orphan records
        try await service.deleteTransaction(id: linkedTx!.id)

        // Verify split is also removed from memory and storage
        XCTAssertFalse(service.splits.contains(where: { $0.id == splitRecord.id }))
        let fetchedSplits = try await repo.fetchSplits()
        XCTAssertFalse(fetchedSplits.contains(where: { $0.id == splitRecord.id }))
    }

    func testUndoLastDeletionRestoresTransactionAndAccountBalances() async throws {
        let repo = LocalTransactionRepository()
        let service = ExpenseTrackingService(repository: repo)
        await service.loadData()

        let targetAccount = service.accounts.first!
        let debitAmount = Decimal(string: "85.25")!

        try await service.recordTransaction(
            type: .debit,
            amount: debitAmount,
            title: "Groceries Market",
            timestamp: Date(),
            category: .groceries,
            accountID: targetAccount.id,
            accountName: targetAccount.accountName
        )

        let tx = service.transactions.first(where: { $0.title == "Groceries Market" })!
        let balanceAfterDebit = service.accounts.first(where: { $0.id == targetAccount.id })!.currentBalance

        // 1. Delete
        try await service.deleteTransaction(id: tx.id)
        XCTAssertFalse(service.transactions.contains(where: { $0.id == tx.id }))

        // 2. Perform Undo within window
        await service.undoLastDeletion()

        // 3. Verified restored
        XCTAssertTrue(service.transactions.contains(where: { $0.id == tx.id }))
        let restoredAccount = service.accounts.first(where: { $0.id == targetAccount.id })!
        XCTAssertEqual(restoredAccount.currentBalance, balanceAfterDebit)
    }

    func testHistoryDateGroupingChronologicalOrder() {
        let service = ExpenseTrackingService()
        let vm = HistoryViewModel(service: service)

        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: now)!

        let txRecent = TransactionItem(title: "Recent", amount: 10, type: .debit, timestamp: now)
        let txYesterday = TransactionItem(title: "Yesterday", amount: 20, type: .debit, timestamp: yesterday)
        let txTwoDaysAgo = TransactionItem(title: "Two Days Ago", amount: 30, type: .debit, timestamp: twoDaysAgo)

        service.transactions = [txYesterday, txTwoDaysAgo, txRecent]

        let groups = vm.groupedTransactions
        XCTAssertEqual(groups.count, 3)
        XCTAssertEqual(groups[0].dateLabel, "Today")
        XCTAssertEqual(groups[1].dateLabel, "Yesterday")
        XCTAssertEqual(groups[0].items.first?.title, "Recent")
    }
}


