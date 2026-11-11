import SwiftUI
import Combine

/// Core business service for DELTA personal expense tracking.
/// Uses Decimal currency calculations, updates account balances automatically,
/// prevents duplicate transactions, and supports full create, read, update, and delete (CRUD) workflows.
public final class ExpenseTrackingService: ObservableObject {
    public enum ServiceState: Equatable {
        case idle
        case loading
        case loaded
        case empty
        case error(String)
    }

    @Published public var state: ServiceState = .idle
    @Published public var userDisplayName: String = "Hadi Aymen"
    @Published public var userHandle: String = "@hadiaymen"
    @Published public var unreadNotificationCount: Int = 2

    @Published public var isAmountVisible: Bool = true
    @Published public var selectedMonthDate: Date = Date()
    @Published public var transactions: [TransactionItem] = []
    @Published public var splits: [SplitRecord] = []
    @Published public var favouritePeople: [ContactItem] = []
    public var contacts: [ContactItem] { favouritePeople }

    // Dynamic Visual Dummy Account Cards (Not real bank cards)
    @Published public var cards: [DummyAccountCard] = [
        DummyAccountCard(
            id: "delta-personal",
            accountName: "DELTA PERSONAL",
            cardholderName: "Hadi Aymen",
            accountIdentifier: "DELTA •••• 5890",
            accountCategory: "Primary Account",
            initialBalance: Decimal(string: "23590.73") ?? 23590.73,
            theme: .chartreuseLime,
            isPrimary: true
        ),
        DummyAccountCard(
            id: "delta-cash",
            accountName: "DELTA CASH",
            cardholderName: "Hadi Aymen",
            accountIdentifier: "DELTA •••• 3412",
            accountCategory: "Cash Envelope",
            initialBalance: Decimal(string: "1450.00") ?? 1450.00,
            theme: .electricLime,
            isPrimary: false
        ),
        DummyAccountCard(
            id: "delta-savings",
            accountName: "DELTA SAVINGS",
            cardholderName: "Hadi Aymen",
            accountIdentifier: "DELTA •••• 9081",
            accountCategory: "Savings Vault",
            initialBalance: Decimal(string: "14200.00") ?? 14200.00,
            theme: .forestOlive,
            isPrimary: false
        )
    ]

    // Dynamic Financial Calculations from Real Repository Transactions (Decimal precision)
    @Published public var monthlySpentDecimal: Decimal = Decimal.zero
    @Published public var monthlyReceivedDecimal: Decimal = Decimal.zero
    @Published public var spendingComparisonText: String = "0% vs last month"
    @Published public var spendingComparisonIsIncrease: Bool = true

    private let repository: TransactionRepositoryProtocol

    public init(repository: TransactionRepositoryProtocol = LocalTransactionRepository()) {
        self.repository = repository
        Task {
            await loadData()
        }
    }

    // MARK: - Data Loading & Calculation
    @MainActor
    public func loadData() async {
        state = .loading
        do {
            let fetchedTransactions = try await repository.fetchTransactions()
            let fetchedContacts = try await repository.fetchFavouritePeople()
            let fetchedSplits = try await repository.fetchSplits()

            self.transactions = fetchedTransactions.sorted { $0.timestamp > $1.timestamp }
            self.favouritePeople = fetchedContacts
            self.splits = fetchedSplits.sorted { $0.timestamp > $1.timestamp }

            recalculateFinancials()

            if self.transactions.isEmpty {
                self.state = .empty
            } else {
                self.state = .loaded
            }
        } catch {
            self.state = .error("Failed to load financial data: \(error.localizedDescription)")
        }
    }

    // MARK: - Data Backup & Restore
    @MainActor
    public func exportBackup() async throws -> Data {
        return try await repository.exportBackupData()
    }

    @MainActor
    public func restoreFromBackup(data: Data) async throws {
        try await repository.restoreBackupData(data)
        await loadData()
    }

    /// Automatically recalculates monthly spent, monthly received, spending comparison, and card balances.
    public func recalculateFinancials() {
        // 1. Calculate Monthly Spent (Sum of Debits in current calendar month)
        self.monthlySpentDecimal = FinancialCalculator.calculateMonthlySpent(
            transactions: transactions,
            monthDate: selectedMonthDate
        )

        // 2. Calculate Monthly Received (Sum of Credits in current calendar month)
        self.monthlyReceivedDecimal = FinancialCalculator.calculateMonthlyReceived(
            transactions: transactions,
            monthDate: selectedMonthDate
        )

        // 3. Calculate Monthly Spending Comparison
        let comparison = FinancialCalculator.calculateMonthlySpendingComparison(
            transactions: transactions,
            monthDate: selectedMonthDate
        )
        self.spendingComparisonText = comparison.formattedText
        self.spendingComparisonIsIncrease = comparison.isIncrease

        // 4. Update Account Balances automatically
        self.cards = FinancialCalculator.calculateAccountBalances(
            accounts: cards,
            transactions: transactions
        )
    }

    // MARK: - Account Management (CRUD)
    @MainActor
    public func addAccount(
        name: String,
        initialBalance: Decimal,
        category: String,
        theme: DummyAccountCard.CardTheme
    ) {
        let newCard = DummyAccountCard(
            accountName: name,
            cardholderName: userDisplayName,
            accountIdentifier: "DELTA •••• " + String(Int.random(in: 1000...9999)),
            accountCategory: category,
            initialBalance: initialBalance,
            currentBalance: initialBalance,
            theme: theme,
            isPrimary: false
        )
        cards.append(newCard)
        recalculateFinancials()
    }

    @MainActor
    public func updateAccount(_ updatedCard: DummyAccountCard) {
        if let idx = cards.firstIndex(where: { $0.id == updatedCard.id }) {
            cards[idx] = updatedCard
            recalculateFinancials()
        }
    }

    @MainActor
    public func deleteAccount(id: String) {
        cards.removeAll { $0.id == id && !$0.isPrimary }
        recalculateFinancials()
    }

    // MARK: - Amount Visibility Toggle
    public func toggleAmountVisibility() {
        withAnimation(DeltaAnimations.toggleReveal) {
            isAmountVisible.toggle()
        }
    }

    /// Formatted display string for TOTAL SPENT
    public var formattedTotalSpent: String {
        if isAmountVisible {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencySymbol = "$"
            formatter.maximumFractionDigits = 2
            formatter.minimumFractionDigits = 2
            return formatter.string(from: monthlySpentDecimal as NSDecimalNumber) ?? "$\(monthlySpentDecimal)"
        } else {
            return "$••••••"
        }
    }

    // MARK: - Transaction Operations (CRUD)

    /// Add a new transaction (Credit or Debit) with full validation and duplicate protection.
    @MainActor
    public func recordTransaction(
        type: TransactionItem.TransactionType,
        amount: Decimal,
        title: String,
        timestamp: Date,
        category: ExpenseCategory,
        accountID: String,
        accountName: String,
        note: String?
    ) async throws {
        // 1. Validation
        let validationResult = FinancialCalculator.validate(amount: amount, title: title, allowEmptyTitle: type == .other)
        if case .failure(let error) = validationResult {
            throw error
        }

        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedTitle = cleanTitle.isEmpty ? (type == .other ? "Unclassified Outlay" : "Transaction") : cleanTitle

        let newTransaction = TransactionItem(
            title: resolvedTitle,
            amount: amount,
            type: type,
            timestamp: timestamp,
            category: category,
            accountID: accountID,
            accountName: accountName,
            note: note?.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        // 2. Save persistently through repository (handles duplicate checks)
        try await repository.addTransaction(newTransaction)

        // 3. Update local state
        transactions.insert(newTransaction, at: 0)
        transactions.sort { $0.timestamp > $1.timestamp }
        recalculateFinancials()
        state = .loaded
    }

    /// Update an existing transaction record.
    @MainActor
    public func updateTransaction(_ item: TransactionItem) async throws {
        let validationResult = FinancialCalculator.validate(amount: item.amount, title: item.title, allowEmptyTitle: item.type == .other)
        if case .failure(let error) = validationResult {
            throw error
        }

        try await repository.updateTransaction(item)

        if let index = transactions.firstIndex(where: { $0.id == item.id }) {
            transactions[index] = item
            transactions.sort { $0.timestamp > $1.timestamp }
            recalculateFinancials()
            state = .loaded
        }
    }

    // Cache for short safe Undo operation
    @Published public var pendingDeletedTransaction: TransactionItem? = nil
    private var pendingDeletedSplit: SplitRecord? = nil

    /// Delete a transaction record persistently with split-cascade consistency and optional undo support.
    @MainActor
    public func deleteTransaction(id: String) async throws {
        guard let itemIndex = transactions.firstIndex(where: { $0.id == id }) else {
            throw RepositoryError.transactionNotFound(id)
        }
        let itemToDelete = transactions[itemIndex]

        // Find linked split if any to maintain relationship consistency
        var linkedSplit: SplitRecord? = nil
        if let splitID = itemToDelete.linkedSplitID {
            linkedSplit = splits.first(where: { $0.id == splitID })
        }

        // Cache for Undo
        self.pendingDeletedTransaction = itemToDelete
        self.pendingDeletedSplit = linkedSplit

        // 1. Delete from persistent storage
        try await repository.deleteTransaction(id: id)
        if let split = linkedSplit {
            try? await repository.deleteSplit(id: split.id)
            splits.removeAll { $0.id == split.id }
        }

        // 2. Remove from local transactions array (automatically updates Search)
        transactions.remove(at: itemIndex)

        // 3. Recalculate account balances, TOTAL SPENT, and analytics
        recalculateFinancials()

        if transactions.isEmpty {
            state = .empty
        } else {
            state = .loaded
        }
    }

    /// Restore the last deleted transaction and its linked split record.
    @MainActor
    public func undoLastDeletion() async {
        guard let item = pendingDeletedTransaction else { return }

        // Restore transaction to persistent repository
        try? await repository.addTransaction(item)
        transactions.insert(item, at: 0)
        transactions.sort { $0.timestamp > $1.timestamp }

        // Restore linked split if it existed
        if let split = pendingDeletedSplit {
            try? await repository.addSplit(split)
            splits.insert(split, at: 0)
            splits.sort { $0.timestamp > $1.timestamp }
        }

        // Recalculate financial balances and analytics
        recalculateFinancials()
        state = .loaded

        // Clear undo cache
        pendingDeletedTransaction = nil
        pendingDeletedSplit = nil
    }

    /// Finalize deletion once the undo timer expires
    public func finalizeDeletion() {
        pendingDeletedTransaction = nil
        pendingDeletedSplit = nil
    }

    // MARK: - 'Other' Transaction Conversion (Zero Duplicate Invariant)
    @MainActor
    public func convertOtherTransaction(
        id: String,
        toType: TransactionItem.TransactionType,
        category: ExpenseCategory,
        accountID: String? = nil,
        accountName: String? = nil
    ) async throws {
        guard let index = transactions.firstIndex(where: { $0.id == id }) else {
            throw RepositoryError.transactionNotFound(id)
        }
        var item = transactions[index]
        item.type = toType
        item.category = category
        if let accID = accountID { item.accountID = accID }
        if let accName = accountName { item.accountName = accName }

        try await updateTransaction(item)
    }

    @MainActor
    public func convertOtherToSplit(
        transactionID: String,
        title: String,
        method: SplitMethod,
        participants: [SplitParticipant]
    ) async throws {
        guard let index = transactions.firstIndex(where: { $0.id == transactionID }) else {
            throw RepositoryError.transactionNotFound(transactionID)
        }

        var item = transactions[index]
        let splitID = UUID().uuidString

        item.type = .debit
        item.title = "\(title) (Split)"
        item.category = .dining
        item.linkedSplitID = splitID
        try await repository.updateTransaction(item)
        transactions[index] = item

        let newSplit = SplitRecord(
            id: splitID,
            title: title,
            totalAmount: item.amount,
            method: method,
            payerName: "Hadi Aymen",
            isCurrentUserPayer: true,
            accountID: item.accountID,
            accountName: item.accountName,
            timestamp: item.timestamp,
            participants: participants,
            linkedTransactionID: item.id
        )

        try await repository.addSplit(newSplit)
        splits.insert(newSplit, at: 0)
        splits.sort { $0.timestamp > $1.timestamp }
        recalculateFinancials()
    }

    // MARK: - Split Expense Operations
    @MainActor
    public func createSplit(
        title: String,
        totalAmount: Decimal,
        method: SplitMethod,
        payerName: String,
        isCurrentUserPayer: Bool,
        accountID: String,
        accountName: String,
        timestamp: Date,
        participants: [SplitParticipant],
        createLinkedTransaction: Bool
    ) async throws {
        let splitID = UUID().uuidString
        var linkedTxID: String? = nil

        // Create a single linked original expense transaction when appropriate
        if isCurrentUserPayer && createLinkedTransaction {
            let linkedTx = TransactionItem(
                title: "\(title) (Split)",
                amount: totalAmount,
                type: .debit,
                timestamp: timestamp,
                category: .dining,
                accountID: accountID,
                accountName: accountName,
                note: "Split between \(participants.count) participants via \(method.rawValue)",
                linkedSplitID: splitID
            )
            try await repository.addTransaction(linkedTx)
            transactions.insert(linkedTx, at: 0)
            transactions.sort { $0.timestamp > $1.timestamp }
            linkedTxID = linkedTx.id
        }

        let newSplit = SplitRecord(
            id: splitID,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            totalAmount: totalAmount,
            method: method,
            payerName: payerName,
            isCurrentUserPayer: isCurrentUserPayer,
            accountID: accountID,
            accountName: accountName,
            timestamp: timestamp,
            participants: participants,
            linkedTransactionID: linkedTxID
        )

        try await repository.addSplit(newSplit)
        splits.insert(newSplit, at: 0)
        splits.sort { $0.timestamp > $1.timestamp }
        recalculateFinancials()
    }

    @MainActor
    public func updateSplit(_ updatedSplit: SplitRecord) async throws {
        try await repository.updateSplit(updatedSplit)

        if let index = splits.firstIndex(where: { $0.id == updatedSplit.id }) {
            splits[index] = updatedSplit
            splits.sort { $0.timestamp > $1.timestamp }
        }

        // Update linked transaction amount if present
        if let linkedID = updatedSplit.linkedTransactionID,
           let txIndex = transactions.firstIndex(where: { $0.id == linkedID }) {
            var linkedTx = transactions[txIndex]
            linkedTx.title = "\(updatedSplit.title) (Split)"
            linkedTx.amount = updatedSplit.totalAmount
            linkedTx.accountID = updatedSplit.accountID
            linkedTx.accountName = updatedSplit.accountName
            linkedTx.timestamp = updatedSplit.timestamp
            try await repository.updateTransaction(linkedTx)
            transactions[txIndex] = linkedTx
        }

        recalculateFinancials()
    }

    @MainActor
    public func deleteSplit(id: String) async throws {
        // Find split to check for linked transaction
        let splitToDelete = splits.first(where: { $0.id == id })

        try await repository.deleteSplit(id: id)
        splits.removeAll { $0.id == id }

        // Remove single linked transaction consistently
        if let linkedID = splitToDelete?.linkedTransactionID {
            try? await repository.deleteTransaction(id: linkedID)
            transactions.removeAll { $0.id == linkedID }
        }

        recalculateFinancials()
    }

    @MainActor
    public func toggleParticipantSettlement(splitID: String, participantID: String) async throws {
        guard let splitIndex = splits.firstIndex(where: { $0.id == splitID }),
              let pIndex = splits[splitIndex].participants.firstIndex(where: { $0.id == participantID }) else {
            return
        }

        var split = splits[splitIndex]
        let currentStatus = split.participants[pIndex].isSettled
        let newStatus = !currentStatus
        split.participants[pIndex].isSettled = newStatus
        split.participants[pIndex].settledDate = newStatus ? Date() : nil

        let participant = split.participants[pIndex]

        // When settling, if current user was payer, record incoming credit reimbursement
        if newStatus && split.isCurrentUserPayer && !participant.isCurrentUser {
            let reimbursementTx = TransactionItem(
                title: "Reimbursement from \(participant.name)",
                amount: participant.shareAmount,
                type: .credit,
                timestamp: Date(),
                category: .income,
                accountID: split.accountID,
                accountName: split.accountName,
                note: "Settled share for '\(split.title)'",
                linkedSplitID: split.id
            )
            try? await repository.addTransaction(reimbursementTx)
            transactions.insert(reimbursementTx, at: 0)
            transactions.sort { $0.timestamp > $1.timestamp }
        }

        try await updateSplit(split)
    }

    // Convenience loggers
    @MainActor
    public func logDebit(
        amount: Decimal,
        title: String,
        timestamp: Date = Date(),
        category: ExpenseCategory = .general,
        accountID: String = "default-checking",
        accountName: String = "Daily Living Envelope",
        note: String? = nil
    ) async {
        do {
            try await recordTransaction(
                type: .debit,
                amount: amount,
                title: title,
                timestamp: timestamp,
                category: category,
                accountID: accountID,
                accountName: accountName,
                note: note
            )
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    @MainActor
    public func logCredit(
        amount: Decimal,
        title: String,
        timestamp: Date = Date(),
        category: ExpenseCategory = .income,
        accountID: String = "default-checking",
        accountName: String = "Daily Living Envelope",
        note: String? = nil
    ) async {
        do {
            try await recordTransaction(
                type: .credit,
                amount: amount,
                title: title,
                timestamp: timestamp,
                category: category,
                accountID: accountID,
                accountName: accountName,
                note: note
            )
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    public func logOutlay(amount: Double, recipient: String, note: String) {
        Task { @MainActor in
            await logDebit(
                amount: Decimal(amount),
                title: "Send Money to \(recipient)",
                category: .transfer,
                note: note
            )
        }
    }

    @MainActor
    public func addFavouritePerson(name: String, identifier: String) async {
        let initials = name.split(separator: " ").compactMap { $0.first }.prefix(2).map(String.init).joined().uppercased()
        let newPerson = ContactItem(
            name: name,
            maskedIdentifier: identifier,
            initials: initials.isEmpty ? "HA" : initials
        )
        do {
            try await repository.addFavouritePerson(newPerson)
            favouritePeople.append(newPerson)
        } catch {
            state = .error("Failed to add favourite person: \(error.localizedDescription)")
        }
    }
}
