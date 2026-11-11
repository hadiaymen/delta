import XCTest
@testable import DELTA

final class SplitCalculationTests: XCTestCase {

    // MARK: - 1. Equal Split Remainder Distribution
    func testEqualSplitThreeWaysDistributesRemainderDeterministically() throws {
        let total = Decimal(string: "100.00")!
        let participants = [
            SplitParticipant(name: "Hadi Aymen", isCurrentUser: true),
            SplitParticipant(name: "Alina"),
            SplitParticipant(name: "Mark")
        ]

        let calculated = try SplitCalculationEngine.calculateEqualShares(
            total: total,
            participants: participants
        )

        XCTAssertEqual(calculated.count, 3)

        // 10000 cents / 3 = 3333 cents with remainder 1 cent
        // First participant gets 3334 cents ($33.34), others get 3333 cents ($33.33)
        XCTAssertEqual(calculated[0].shareAmount, Decimal(string: "33.34")!)
        XCTAssertEqual(calculated[1].shareAmount, Decimal(string: "33.33")!)
        XCTAssertEqual(calculated[2].shareAmount, Decimal(string: "33.33")!)

        // Invariant: sum of shares must equal total exactly
        let sum = calculated.reduce(Decimal.zero) { $0 + $1.shareAmount }
        XCTAssertEqual(sum, total)
    }

    func testEqualSplitSixWaysTenDollarsRemainderDistribution() throws {
        let total = Decimal(string: "10.00")!
        let participants = (1...6).map { SplitParticipant(name: "Person \($0)") }

        let calculated = try SplitCalculationEngine.calculateEqualShares(
            total: total,
            participants: participants
        )

        // 1000 cents / 6 = 166 cents with remainder 4 cents
        // First 4 get $1.67, last 2 get $1.66
        XCTAssertEqual(calculated[0].shareAmount, Decimal(string: "1.67")!)
        XCTAssertEqual(calculated[1].shareAmount, Decimal(string: "1.67")!)
        XCTAssertEqual(calculated[2].shareAmount, Decimal(string: "1.67")!)
        XCTAssertEqual(calculated[3].shareAmount, Decimal(string: "1.67")!)
        XCTAssertEqual(calculated[4].shareAmount, Decimal(string: "1.66")!)
        XCTAssertEqual(calculated[5].shareAmount, Decimal(string: "1.66")!)

        let sum = calculated.reduce(Decimal.zero) { $0 + $1.shareAmount }
        XCTAssertEqual(sum, total)
    }

    func testEqualSplitSevenWaysFiftyDollarsSumEquality() throws {
        let total = Decimal(string: "50.00")!
        let participants = (1...7).map { SplitParticipant(name: "Guest \($0)") }

        let calculated = try SplitCalculationEngine.calculateEqualShares(
            total: total,
            participants: participants
        )

        let sum = calculated.reduce(Decimal.zero) { $0 + $1.shareAmount }
        XCTAssertEqual(sum, total)
    }

    // MARK: - 2. Custom Split Validation
    func testCustomSplitValidSum() throws {
        let total = Decimal(string: "150.00")!
        let participants = [
            SplitParticipant(name: "Hadi Aymen", shareAmount: Decimal(string: "75.00")!),
            SplitParticipant(name: "Alina", shareAmount: Decimal(string: "45.00")!),
            SplitParticipant(name: "Mark", shareAmount: Decimal(string: "30.00")!)
        ]

        // 75 + 45 + 30 = 150 -> Valid
        XCTAssertNoThrow(try SplitCalculationEngine.validateCustomShares(total: total, participants: participants))
    }

    func testCustomSplitMismatchThrowsErrorWithDifference() {
        let total = Decimal(string: "150.00")!
        let participants = [
            SplitParticipant(name: "Hadi Aymen", shareAmount: Decimal(string: "70.00")!),
            SplitParticipant(name: "Alina", shareAmount: Decimal(string: "40.00")!),
            SplitParticipant(name: "Mark", shareAmount: Decimal(string: "30.00")!)
        ]

        // 70 + 40 + 30 = 140 (off by 10)
        XCTAssertThrowsError(try SplitCalculationEngine.validateCustomShares(total: total, participants: participants)) { error in
            guard case SplitValidationError.customSumMismatch(let exp, let act, let diff) = error else {
                XCTFail("Expected customSumMismatch but got \(error)")
                return
            }
            XCTAssertEqual(exp, Decimal(150))
            XCTAssertEqual(act, Decimal(140))
            XCTAssertEqual(diff, Decimal(10))
        }
    }

    // MARK: - 3. Percentage Split Validation & Remainder Handling
    func testPercentageSplitValidCalculation() throws {
        let total = Decimal(string: "200.00")!
        let participants = [
            SplitParticipant(name: "Hadi Aymen", percentage: Decimal(50)),
            SplitParticipant(name: "Alina", percentage: Decimal(30)),
            SplitParticipant(name: "Mark", percentage: Decimal(20))
        ]

        let calculated = try SplitCalculationEngine.calculatePercentageShares(
            total: total,
            participants: participants
        )

        XCTAssertEqual(calculated[0].shareAmount, Decimal(string: "100.00")!)
        XCTAssertEqual(calculated[1].shareAmount, Decimal(string: "60.00")!)
        XCTAssertEqual(calculated[2].shareAmount, Decimal(string: "40.00")!)

        let sum = calculated.reduce(Decimal.zero) { $0 + $1.shareAmount }
        XCTAssertEqual(sum, total)
    }

    func testPercentageSplitMismatchThrowsError() {
        let total = Decimal(string: "100.00")!
        let participants = [
            SplitParticipant(name: "Hadi Aymen", percentage: Decimal(50)),
            SplitParticipant(name: "Alina", percentage: Decimal(30)),
            SplitParticipant(name: "Mark", percentage: Decimal(15)) // Sums to 95%
        ]

        XCTAssertThrowsError(try SplitCalculationEngine.calculatePercentageShares(total: total, participants: participants)) { error in
            guard case SplitValidationError.percentageTotalMismatch(let exp, let act) = error else {
                XCTFail("Expected percentageTotalMismatch but got \(error)")
                return
            }
            XCTAssertEqual(exp, Decimal(100))
            XCTAssertEqual(act, Decimal(95))
        }
    }

    // MARK: - 4. Database Consistency & Relationship Invariants
    func testSplitCreationGeneratesSingleLinkedTransaction() async throws {
        let repo = LocalTransactionRepository()
        let service = ExpenseTrackingService(repository: repo)
        await service.loadData()

        let initialTxCount = service.transactions.count
        let initialSplitCount = service.splits.count

        let total = Decimal(string: "90.00")!
        let participants = [
            SplitParticipant(name: "Hadi Aymen", isCurrentUser: true, shareAmount: Decimal(30), isSettled: true),
            SplitParticipant(name: "Alina", shareAmount: Decimal(30), isSettled: false),
            SplitParticipant(name: "Mark", shareAmount: Decimal(30), isSettled: false)
        ]

        // Create split with single linked original transaction
        try await service.createSplit(
            title: "Team Lunch",
            totalAmount: total,
            method: .equal,
            payerName: "Hadi Aymen",
            isCurrentUserPayer: true,
            accountID: "delta-personal",
            accountName: "DELTA PERSONAL",
            timestamp: Date(),
            participants: participants,
            createLinkedTransaction: true
        )

        // Verifications
        XCTAssertEqual(service.splits.count, initialSplitCount + 1)
        XCTAssertEqual(service.transactions.count, initialTxCount + 1)

        let createdSplit = service.splits.first!
        XCTAssertEqual(createdSplit.title, "Team Lunch")
        XCTAssertNotNil(createdSplit.linkedTransactionID)

        let linkedTx = service.transactions.first(where: { $0.id == createdSplit.linkedTransactionID })
        XCTAssertNotNil(linkedTx)
        XCTAssertEqual(linkedTx?.amount, total)
        XCTAssertEqual(linkedTx?.type, .debit)
        XCTAssertEqual(linkedTx?.linkedSplitID, createdSplit.id)

        // Never duplicate: exactly 1 linked transaction exists for this split
        let matchingTxs = service.transactions.filter { $0.linkedSplitID == createdSplit.id }
        XCTAssertEqual(matchingTxs.count, 1)

        // Outstanding owed calculation
        XCTAssertEqual(createdSplit.totalOwedToPayer, Decimal(60)) // Alina 30 + Mark 30
        XCTAssertFalse(createdSplit.isFullySettled)
    }

    func testSettlingParticipantCreatesReimbursementWithoutDuplicateOutlay() async throws {
        let repo = LocalTransactionRepository()
        let service = ExpenseTrackingService(repository: repo)
        await service.loadData()

        let participants = [
            SplitParticipant(id: "p-1", name: "Hadi Aymen", isCurrentUser: true, shareAmount: Decimal(25), isSettled: true),
            SplitParticipant(id: "p-2", name: "Alina", shareAmount: Decimal(25), isSettled: false)
        ]

        try await service.createSplit(
            title: "Movie Tickets",
            totalAmount: Decimal(50),
            method: .equal,
            payerName: "Hadi Aymen",
            isCurrentUserPayer: true,
            accountID: "delta-personal",
            accountName: "DELTA PERSONAL",
            timestamp: Date(),
            participants: participants,
            createLinkedTransaction: true
        )

        let split = service.splits.first!
        let txCountBeforeSettle = service.transactions.count

        // Settle Alina's share
        try await service.toggleParticipantSettlement(splitID: split.id, participantID: "p-2")

        let updatedSplit = service.splits.first(where: { $0.id == split.id })!
        XCTAssertTrue(updatedSplit.isFullySettled)
        XCTAssertEqual(updatedSplit.totalOwedToPayer, Decimal.zero)

        // A single reimbursement Credit was added, preserving net outlay calculation
        XCTAssertEqual(service.transactions.count, txCountBeforeSettle + 1)
        let reimbursement = service.transactions.first!
        XCTAssertEqual(reimbursement.type, .credit)
        XCTAssertEqual(reimbursement.amount, Decimal(25))
    }

    func testDeletingSplitRemovesLinkedTransactionConsistently() async throws {
        let repo = LocalTransactionRepository()
        let service = ExpenseTrackingService(repository: repo)
        await service.loadData()

        let participants = [
            SplitParticipant(name: "Hadi Aymen", isCurrentUser: true, shareAmount: Decimal(30), isSettled: true),
            SplitParticipant(name: "Alina", shareAmount: Decimal(30), isSettled: false)
        ]

        try await service.createSplit(
            title: "Temporary Dinner",
            totalAmount: Decimal(60),
            method: .equal,
            payerName: "Hadi Aymen",
            isCurrentUserPayer: true,
            accountID: "delta-personal",
            accountName: "DELTA PERSONAL",
            timestamp: Date(),
            participants: participants,
            createLinkedTransaction: true
        )

        let split = service.splits.first(where: { $0.title == "Temporary Dinner" })!
        let linkedID = split.linkedTransactionID!

        XCTAssertTrue(service.transactions.contains(where: { $0.id == linkedID }))

        // Delete split
        try await service.deleteSplit(id: split.id)

        // Invariant: split and its linked transaction are both removed
        XCTAssertFalse(service.splits.contains(where: { $0.id == split.id }))
        XCTAssertFalse(service.transactions.contains(where: { $0.id == linkedID }))
    }
}

