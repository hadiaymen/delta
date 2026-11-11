import XCTest
@testable import DELTA

final class QRScannerTests: XCTestCase {

    // MARK: - 1. UPI QR Payload Parsing with Full Fields
    func testParseValidUPIWithAllFields() {
        let rawUPI = "upi://pay?pa=starbucks@hdfcbank&pn=Starbucks%20Coffee&am=320.50&tn=Dark%20Roast%20%26%20Croissant&tr=TRX87654321&cu=INR"
        let result = QRPayloadParser.parse(payload: rawUPI)

        switch result {
        case .success(let payload):
            XCTAssertEqual(payload.type, .upi)
            XCTAssertEqual(payload.payeeAddress, "starbucks@hdfcbank")
            XCTAssertEqual(payload.payeeName, "Starbucks Coffee")
            XCTAssertEqual(payload.amount, Decimal(string: "320.50"))
            XCTAssertEqual(payload.transactionNote, "Dark Roast & Croissant")
            XCTAssertEqual(payload.referenceID, "TRX87654321")
            XCTAssertEqual(payload.currency, "INR")
            XCTAssertEqual(payload.displayTitle, "Starbucks Coffee")
        case .failure(let error):
            XCTFail("Expected successful parse, got: \(error.localizedDescription)")
        }
    }

    // MARK: - 2. UPI QR Payload Without Amount (Manual Entry Case)
    func testParseValidUPIWithoutAmount() {
        let rawUPI = "upi://pay?pa=sarah.j@okhdfcbank&pn=Sarah%20Jenkins&tn=Dinner%20Split&tr=REF123456"
        let result = QRPayloadParser.parse(payload: rawUPI)

        switch result {
        case .success(let payload):
            XCTAssertEqual(payload.type, .upi)
            XCTAssertEqual(payload.payeeAddress, "sarah.j@okhdfcbank")
            XCTAssertEqual(payload.payeeName, "Sarah Jenkins")
            XCTAssertNil(payload.amount, "Amount must be nil so user can input manually")
            XCTAssertEqual(payload.transactionNote, "Dinner Split")
            XCTAssertEqual(payload.referenceID, "REF123456")
        case .failure(let error):
            XCTFail("Expected successful parse, got: \(error.localizedDescription)")
        }
    }

    // MARK: - 3. UPI QR with Space Plus-Encoding
    func testParseUPIWithPlusEncoding() {
        let rawUPI = "upi://pay?pa=cornerbistro@icici&pn=The+Corner+Bistro&am=45.25&tn=Table+4"
        let result = QRPayloadParser.parse(payload: rawUPI)

        switch result {
        case .success(let payload):
            XCTAssertEqual(payload.payeeName, "The Corner Bistro")
            XCTAssertEqual(payload.transactionNote, "Table 4")
            XCTAssertEqual(payload.amount, Decimal(string: "45.25"))
        case .failure(let error):
            XCTFail("Expected successful parse, got: \(error.localizedDescription)")
        }
    }

    // MARK: - 4. Malformed and Empty Payloads Rejection
    func testRejectEmptyPayload() {
        let result = QRPayloadParser.parse(payload: "   ")
        switch result {
        case .success:
            XCTFail("Should reject empty payload")
        case .failure(let error):
            XCTAssertEqual(error, .emptyPayload)
        }
    }

    func testRejectMalformedUPIQueryDelimiter() {
        let result = QRPayloadParser.parse(payload: "upi://pay")
        switch result {
        case .success:
            XCTFail("Should reject UPI missing '?' query delimiter")
        case .failure:
            break // Expected
        }
    }

    func testRejectEmptyUPIQueryParameters() {
        let result = QRPayloadParser.parse(payload: "upi://pay?")
        switch result {
        case .success:
            XCTFail("Should reject empty query parameters")
        case .failure:
            break // Expected
        }
    }

    func testRejectUnsafeJavascriptScheme() {
        let result = QRPayloadParser.parse(payload: "javascript:alert('attack')")
        switch result {
        case .success:
            XCTFail("Should reject javascript: URI")
        case .failure(let error):
            XCTAssertEqual(error, .unsupportedFormat("Potentially unsafe payload URI scheme rejected"))
        }
    }

    // MARK: - 5. Safe Generic QR Payload Parsing
    func testParseGenericSafeTextPayload() {
        let rawText = "INVOICE-REF-2026-X992"
        let result = QRPayloadParser.parse(payload: rawText)

        switch result {
        case .success(let payload):
            XCTAssertEqual(payload.type, .generic)
            XCTAssertNil(payload.amount)
            XCTAssertEqual(payload.transactionNote, "INVOICE-REF-2026-X992")
            XCTAssertTrue(payload.referenceID?.starts(with: "SCAN-") ?? false)
        case .failure(let error):
            XCTFail("Expected successful generic parse, got: \(error.localizedDescription)")
        }
    }

    // MARK: - 6. End-to-End Scanned Record Storage & Conversion Invariants
    func testSaveScannedQROutlayAsOtherAndConvertLater() async throws {
        let repo = LocalTransactionRepository()
        let service = ExpenseTrackingService(repository: repo)
        await service.loadData()

        let initialCount = service.transactions.count
        let initialSpent = service.monthlySpentDecimal

        // 1. Parse UPI QR
        let rawUPI = "upi://pay?pa=starbucks@hdfcbank&pn=Starbucks%20Coffee&am=12.50&tn=Espresso&tr=TRX998877"
        let parseResult = QRPayloadParser.parse(payload: rawUPI)
        guard case .success(let payload) = parseResult else {
            XCTFail("Parse failed")
            return
        }

        // 2. Save under Other after confirmation
        let targetAccount = service.accounts.first!
        try await service.recordTransaction(
            type: .other,
            amount: payload.amount!,
            title: payload.displayTitle,
            timestamp: Date(),
            category: .other,
            accountID: targetAccount.id,
            accountName: targetAccount.accountName,
            note: payload.transactionNote,
            descriptionText: "Scan Ref: \(payload.referenceID ?? "")"
        )

        // Verifications
        XCTAssertEqual(service.transactions.count, initialCount + 1)
        let savedTx = service.transactions.first(where: { $0.title == "Starbucks Coffee" })!
        XCTAssertEqual(savedTx.type, .other)
        XCTAssertEqual(savedTx.amount, Decimal(string: "12.50"))
        XCTAssertEqual(savedTx.category, .other)
        XCTAssertEqual(savedTx.note, "Espresso")
        XCTAssertTrue(savedTx.descriptionText?.contains("Scan Ref: TRX998877") ?? false)

        // As an 'Other' transaction, monthly debit spent remains untouched
        XCTAssertEqual(service.monthlySpentDecimal, initialSpent)

        // 3. User later converts this scanned record into a Debit
        try await service.convertOtherTransaction(
            id: savedTx.id,
            toType: .debit,
            category: .dining
        )

        // Verify conversion in-place with zero duplicate records
        XCTAssertEqual(service.transactions.count, initialCount + 1)
        let convertedTx = service.transactions.first(where: { $0.id == savedTx.id })!
        XCTAssertEqual(convertedTx.type, .debit)
        XCTAssertEqual(convertedTx.category, .dining)

        // Monthly spent now reflects the debit outlay
        XCTAssertEqual(service.monthlySpentDecimal, initialSpent + Decimal(string: "12.50")!)
    }
}

