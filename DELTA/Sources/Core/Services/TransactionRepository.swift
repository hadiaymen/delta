import Foundation

public enum RepositoryError: LocalizedError, Equatable {
    case duplicateTransaction
    case transactionNotFound(String)
    case storageFailure(String)

    public var errorDescription: String? {
        switch self {
        case .duplicateTransaction:
            return "A duplicate transaction with the same details and timestamp already exists."
        case .transactionNotFound(let id):
            return "Transaction with ID \(id) not found."
        case .storageFailure(let msg):
            return "Failed to save data: \(msg)"
        }
    }
}

/// Protocol defining operations for transactions and favourite people.
public protocol TransactionRepositoryProtocol {
    func fetchTransactions() async throws -> [TransactionItem]
    func addTransaction(_ item: TransactionItem) async throws
    func updateTransaction(_ item: TransactionItem) async throws
    func deleteTransaction(id: String) async throws
    func fetchFavouritePeople() async throws -> [ContactItem]
    func addFavouritePerson(_ person: ContactItem) async throws
    func fetchSplits() async throws -> [SplitRecord]
    func addSplit(_ split: SplitRecord) async throws
    func updateSplit(_ split: SplitRecord) async throws
    func deleteSplit(id: String) async throws
    func exportBackupData() async throws -> Data
    func restoreBackupData(_ data: Data) async throws
}

/// Local file-backed transaction repository with persistence, duplicate prevention, and editing support.
public final class LocalTransactionRepository: TransactionRepositoryProtocol {
    private let fileManager = FileManager.default
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder
    private var inMemoryTransactions: [TransactionItem] = []
    private var inMemoryContacts: [ContactItem] = []
    private var inMemorySplits: [SplitRecord] = []

    private var storageFileURL: URL? {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("delta_transactions.json")
    }

    private var contactsFileURL: URL? {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("delta_contacts.json")
    }

    private var splitsFileURL: URL? {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("delta_splits.json")
    }

    public init() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.jsonEncoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.jsonDecoder = decoder

        loadInitialData()
    }

    private func loadInitialData() {
        // Load saved transactions or populate seed data
        if let fileURL = storageFileURL,
           let data = try? Data(contentsOf: fileURL),
           let saved = try? jsonDecoder.decode([TransactionItem].self, from: data),
           !saved.isEmpty {
            self.inMemoryTransactions = saved
        } else {
            self.inMemoryTransactions = generateSeedTransactions()
            saveTransactionsToDisk()
        }

        // Load saved contacts or populate seed data
        if let fileURL = contactsFileURL,
           let data = try? Data(contentsOf: fileURL),
           let saved = try? jsonDecoder.decode([ContactItem].self, from: data),
           !saved.isEmpty {
            self.inMemoryContacts = saved
        } else {
            self.inMemoryContacts = generateSeedContacts()
            saveContactsToDisk()
        }

        // Load saved splits or populate seed data
        if let fileURL = splitsFileURL,
           let data = try? Data(contentsOf: fileURL),
           let saved = try? jsonDecoder.decode([SplitRecord].self, from: data),
           !saved.isEmpty {
            self.inMemorySplits = saved
        } else {
            self.inMemorySplits = generateSeedSplits()
            saveSplitsToDisk()
        }
    }

    public func fetchTransactions() async throws -> [TransactionItem] {
        return inMemoryTransactions.sorted { $0.timestamp > $1.timestamp }
    }

    public func addTransaction(_ item: TransactionItem) async throws {
        // Duplicate detection
        if FinancialCalculator.isDuplicate(candidate: item, existing: inMemoryTransactions) {
            throw RepositoryError.duplicateTransaction
        }
        inMemoryTransactions.insert(item, at: 0)
        saveTransactionsToDisk()
    }

    public func updateTransaction(_ item: TransactionItem) async throws {
        guard let index = inMemoryTransactions.firstIndex(where: { $0.id == item.id }) else {
            throw RepositoryError.transactionNotFound(item.id)
        }
        // Verify update doesn't collide with another distinct transaction
        if FinancialCalculator.isDuplicate(candidate: item, existing: inMemoryTransactions) {
            throw RepositoryError.duplicateTransaction
        }
        inMemoryTransactions[index] = item
        saveTransactionsToDisk()
    }

    public func deleteTransaction(id: String) async throws {
        guard let index = inMemoryTransactions.firstIndex(where: { $0.id == id }) else {
            throw RepositoryError.transactionNotFound(id)
        }
        inMemoryTransactions.remove(at: index)
        saveTransactionsToDisk()
    }

    public func fetchFavouritePeople() async throws -> [ContactItem] {
        return inMemoryContacts
    }

    public func addFavouritePerson(_ person: ContactItem) async throws {
        inMemoryContacts.append(person)
        saveContactsToDisk()
    }

    // MARK: - Split CRUD Operations
    public func fetchSplits() async throws -> [SplitRecord] {
        return inMemorySplits.sorted { $0.timestamp > $1.timestamp }
    }

    public func addSplit(_ split: SplitRecord) async throws {
        inMemorySplits.insert(split, at: 0)
        saveSplitsToDisk()
    }

    public func updateSplit(_ split: SplitRecord) async throws {
        guard let index = inMemorySplits.firstIndex(where: { $0.id == split.id }) else {
            throw RepositoryError.transactionNotFound(split.id)
        }
        inMemorySplits[index] = split
        saveSplitsToDisk()
    }

    public func deleteSplit(id: String) async throws {
        guard let index = inMemorySplits.firstIndex(where: { $0.id == id }) else {
            throw RepositoryError.transactionNotFound(id)
        }
        inMemorySplits.remove(at: index)
        saveSplitsToDisk()
    }

    // MARK: - Data Backup & Restore
    public struct DELTABackupPayload: Codable {
        public let version: String
        public let timestamp: Date
        public let transactions: [TransactionItem]
        public let contacts: [ContactItem]
        public let splits: [SplitRecord]
    }

    public func exportBackupData() async throws -> Data {
        let payload = DELTABackupPayload(
            version: "1.0.0",
            timestamp: Date(),
            transactions: inMemoryTransactions,
            contacts: inMemoryContacts,
            splits: inMemorySplits
        )
        return try jsonEncoder.encode(payload)
    }

    public func restoreBackupData(_ data: Data) async throws {
        guard let payload = try? jsonDecoder.decode(DELTABackupPayload.self, from: data) else {
            throw RepositoryError.storageFailure("Invalid or corrupted backup archive payload.")
        }

        self.inMemoryTransactions = payload.transactions
        self.inMemoryContacts = payload.contacts
        self.inMemorySplits = payload.splits

        saveTransactionsToDisk()
        saveContactsToDisk()
        saveSplitsToDisk()
    }

    private func saveTransactionsToDisk() {
        guard let url = storageFileURL,
              let data = try? jsonEncoder.encode(inMemoryTransactions) else { return }
        try? data.write(to: url)
    }

    private func saveContactsToDisk() {
        guard let url = contactsFileURL,
              let data = try? jsonEncoder.encode(inMemoryContacts) else { return }
        try? data.write(to: url)
    }

    private func saveSplitsToDisk() {
        guard let url = splitsFileURL,
              let data = try? jsonEncoder.encode(inMemorySplits) else { return }
        try? data.write(to: url)
    }

    private func generateSeedSplits() -> [SplitRecord] {
        let calendar = Calendar.current
        let now = Date()
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: now) ?? now

        let splitId = UUID().uuidString
        let linkedTxId = "split-seed-tx-1"

        let participant1 = SplitParticipant(
            name: "Hadi Aymen",
            identifier: "hadi@delta.dev",
            isCurrentUser: true,
            shareAmount: Decimal(string: "40.00")!,
            percentage: Decimal(string: "33.33"),
            isSettled: true,
            settledDate: twoDaysAgo
        )

        let participant2 = SplitParticipant(
            name: "Alina",
            identifier: "*****46",
            isCurrentUser: false,
            shareAmount: Decimal(string: "40.00")!,
            percentage: Decimal(string: "33.33"),
            isSettled: true,
            settledDate: calendar.date(byAdding: .day, value: -1, to: now)
        )

        let participant3 = SplitParticipant(
            name: "Mark",
            identifier: "*****37",
            isCurrentUser: false,
            shareAmount: Decimal(string: "40.00")!,
            percentage: Decimal(string: "33.34"),
            isSettled: false,
            settledDate: nil
        )

        let seedSplit = SplitRecord(
            id: splitId,
            title: "Team Italian Dinner",
            totalAmount: Decimal(string: "120.00")!,
            method: .equal,
            payerName: "Hadi Aymen",
            isCurrentUserPayer: true,
            accountID: "delta-personal",
            accountName: "DELTA PERSONAL",
            timestamp: twoDaysAgo,
            participants: [participant1, participant2, participant3],
            linkedTransactionID: linkedTxId
        )

        return [seedSplit]
    }

    // MARK: - Seed Data Generation with Decimal Currency Units
    private func generateSeedTransactions() -> [TransactionItem] {
        let calendar = Calendar.current
        let now = Date()

        let today529PM = calendar.date(bySettingHour: 17, minute: 29, second: 0, of: now) ?? now
        let today1237PM = calendar.date(bySettingHour: 12, minute: 37, second: 0, of: now) ?? now.addingTimeInterval(-3600 * 4)

        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: now) else { return [] }
        let yesterday345PM = calendar.date(bySettingHour: 15, minute: 45, second: 0, of: yesterday) ?? yesterday
        let yesterday1115AM = calendar.date(bySettingHour: 11, minute: 15, second: 0, of: yesterday) ?? yesterday

        guard let fiveDaysAgo = calendar.date(byAdding: .day, value: -5, to: now),
              let eightDaysAgo = calendar.date(byAdding: .day, value: -8, to: now) else { return [] }

        guard let lastMonthDate = calendar.date(byAdding: .month, value: -1, to: now),
              let lastMonthTx1 = calendar.date(bySettingHour: 14, minute: 20, second: 0, of: lastMonthDate),
              let lastMonthTx2 = calendar.date(byAdding: .day, value: 5, to: lastMonthDate) else { return [] }

        return [
            TransactionItem(
                title: "Send Money to Kuraishi H.",
                trxID: "TrxID: CJ4901TUZO",
                amount: Decimal(string: "450.00") ?? 450,
                type: .debit,
                timestamp: today529PM,
                category: .transfer,
                accountID: "default-checking",
                accountName: "Daily Living Envelope",
                note: "Freelance design review payment"
            ),
            TransactionItem(
                title: "Receive from Alina",
                trxID: "TrxID: CJ79OZ8UX4",
                amount: Decimal(string: "1250.00") ?? 1250,
                type: .credit,
                timestamp: today1237PM,
                category: .income,
                accountID: "default-checking",
                accountName: "Daily Living Envelope",
                note: "Shared apartment rent reimbursement"
            ),
            TransactionItem(
                title: "Whole Foods Market",
                trxID: "TrxID: CJ33100X9L",
                amount: Decimal(string: "86.40") ?? 86.4,
                type: .debit,
                timestamp: yesterday345PM,
                category: .groceries,
                accountID: "default-checking",
                accountName: "Daily Living Envelope",
                note: "Weekly organic groceries"
            ),
            TransactionItem(
                title: "Electric & Power Utility",
                trxID: "TrxID: CJ102878YA",
                amount: Decimal(string: "114.20") ?? 114.2,
                type: .debit,
                timestamp: yesterday1115AM,
                category: .utilities,
                accountID: "default-checking",
                accountName: "Daily Living Envelope",
                note: "Monthly residential utility bill"
            ),
            TransactionItem(
                title: "Equinox Gym Membership",
                trxID: "TrxID: CJ6619280P",
                amount: Decimal(string: "280.00") ?? 280,
                type: .debit,
                timestamp: fiveDaysAgo,
                category: .general,
                accountID: "default-checking",
                accountName: "Daily Living Envelope",
                note: "Monthly health club fee"
            ),
            TransactionItem(
                title: "Urban Cafe & Roastery",
                trxID: "TrxID: CJ8830114K",
                amount: Decimal(string: "42.80") ?? 42.8,
                type: .debit,
                timestamp: eightDaysAgo,
                category: .dining,
                accountID: "default-checking",
                accountName: "Daily Living Envelope",
                note: "Coffee & breakfast meeting"
            ),
            // Prior month transactions for accurate comparative metrics
            TransactionItem(
                title: "Metro Transit Monthly Pass",
                trxID: "TrxID: CJ9912048M",
                amount: Decimal(string: "128.00") ?? 128,
                type: .debit,
                timestamp: lastMonthTx1,
                category: .general,
                accountID: "default-checking",
                accountName: "Daily Living Envelope",
                note: "Previous month transport"
            ),
            TransactionItem(
                title: "Cloud Services Hosting",
                trxID: "TrxID: CJ7723019Q",
                amount: Decimal(string: "320.00") ?? 320,
                type: .debit,
                timestamp: lastMonthTx2,
                category: .utilities,
                accountID: "default-checking",
                accountName: "Daily Living Envelope",
                note: "Previous month server cluster"
            )
        ]
    }

    private func generateSeedContacts() -> [ContactItem] {
        return [
            ContactItem(name: "Alina", maskedIdentifier: "*****46", initials: "AL"),
            ContactItem(name: "Mark", maskedIdentifier: "*****37", initials: "MK"),
            ContactItem(name: "Rabia", maskedIdentifier: "*****88", initials: "RB"),
            ContactItem(name: "Kuraishi", maskedIdentifier: "*****12", initials: "KH"),
            ContactItem(name: "Zayn", maskedIdentifier: "*****90", initials: "ZN"),
            ContactItem(name: "Elena", maskedIdentifier: "*****53", initials: "EL")
        ]
    }
}
