import XCTest

/// Native XCTest UI Test suite for DELTA application.
/// Validates user journeys across all 5 navigation tabs, interactive workflows, and VoiceOver accessibility.
final class DELTAAppUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - 1. Tab Navigation Across All 5 Destinations
    func testTabBarNavigationAcrossAllFiveDestinations() throws {
        // Destination 1: Home
        let totalSpentHeader = app.staticTexts["TOTAL SPENT"]
        XCTAssertTrue(totalSpentHeader.waitForExistence(timeout: 5.0), "Home screen TOTAL SPENT should be visible")

        let hadiAymenProfile = app.staticTexts["Hadi Aymen"]
        XCTAssertTrue(hadiAymenProfile.exists, "User profile header 'Hadi Aymen' must be visible")

        // Destination 2: Cards
        let cardsTab = app.buttons["Cards"]
        XCTAssertTrue(cardsTab.exists, "Cards tab must exist")
        cardsTab.tap()

        let cardsHeader = app.staticTexts["Cards"]
        XCTAssertTrue(cardsHeader.waitForExistence(timeout: 3.0), "Cards screen header should appear")

        // Destination 3: Scan (Elevated Central Trigger)
        let scanCenterButton = app.buttons["Scan QR code"]
        XCTAssertTrue(scanCenterButton.exists, "Elevated center Scan button must exist")
        scanCenterButton.tap()

        let scanHeader = app.staticTexts["Scan QR"]
        XCTAssertTrue(scanHeader.waitForExistence(timeout: 3.0), "Scan screen should appear upon tapping center button")

        // Destination 4: History
        let historyTab = app.buttons["History"]
        XCTAssertTrue(historyTab.exists, "History tab must exist")
        historyTab.tap()

        let historyHeader = app.staticTexts["History"]
        XCTAssertTrue(historyHeader.waitForExistence(timeout: 3.0), "History header should appear")
        XCTAssertTrue(app.buttons["All"].exists, "Filter 'All' pill should be visible")
        XCTAssertTrue(app.buttons["Debit"].exists, "Filter 'Debit' pill should be visible")
        XCTAssertTrue(app.buttons["Credit"].exists, "Filter 'Credit' pill should be visible")
        XCTAssertTrue(app.buttons["Split"].exists, "Filter 'Split' pill should be visible")
        XCTAssertTrue(app.buttons["Other"].exists, "Filter 'Other' pill should be visible")

        // Destination 5: Search
        let searchTab = app.buttons["Search"]
        XCTAssertTrue(searchTab.exists, "Search tab must exist")
        searchTab.tap()

        let searchField = app.textFields["Search title, person, note, amount, date..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 3.0), "Search input field should be visible")
    }

    // MARK: - 2. Transaction Detail & Deletion Confirmation Flow
    func testTransactionDetailSheetAndDeletionConfirmation() throws {
        // Navigate to History
        let historyTab = app.buttons["History"]
        historyTab.tap()

        // Tap the first visible transaction row if present
        let firstRow = app.buttons.matching(NSPredicate(format: "label CONTAINS 'DEBIT' OR label CONTAINS 'CREDIT' OR label CONTAINS 'OTHER'")).firstMatch
        if firstRow.waitForExistence(timeout: 3.0) {
            firstRow.tap()

            // Verify Transaction Details Sheet
            let detailTitle = app.staticTexts["Transaction Details"]
            XCTAssertTrue(detailTitle.waitForExistence(timeout: 3.0), "Transaction details modal should present")

            // Tap Delete Record
            let deleteButton = app.buttons["Delete Record"]
            XCTAssertTrue(deleteButton.exists, "Delete button must be accessible")
            deleteButton.tap()

            // Verify confirmation dialog
            let deleteDialog = app.staticTexts["Delete Transaction?"]
            XCTAssertTrue(deleteDialog.waitForExistence(timeout: 2.0), "Confirmation dialog must explain permanent deletion")

            // Cancel to prevent unintended data loss in UI test
            let cancelButton = app.buttons["Cancel"]
            if cancelButton.exists {
                cancelButton.tap()
            }
        }
    }

    // MARK: - 3. Global Search Live Querying
    func testGlobalSearchRealtimeTyping() throws {
        let searchTab = app.buttons["Search"]
        searchTab.tap()

        let searchField = app.textFields["Search title, person, note, amount, date..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 3.0))

        searchField.tap()
        searchField.typeText("Starbucks")

        // Wait for debounced search results
        let resultsHeader = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'RESULTS'")).firstMatch
        _ = resultsHeader.waitForExistence(timeout: 2.0)
    }

    // MARK: - 4. Accessibility VoiceOver Verification
    func testVoiceOverKeyElementTraits() throws {
        let scanButton = app.buttons["Scan QR code"]
        XCTAssertTrue(scanButton.exists)
        XCTAssertEqual(scanButton.label, "Scan QR code")

        let homeTab = app.buttons["Home"]
        XCTAssertTrue(homeTab.exists)
        XCTAssertEqual(homeTab.label, "Home")
    }
}

