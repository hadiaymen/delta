import SwiftUI

/// DELTA Design System Icon Registry
/// Centralizes all SF Symbols and icon identifiers across the application.
public struct DeltaIcons {
    // MARK: - Navigation Destinations
    public static let tabHome = "house"
    public static let tabHomeActive = "house.fill"
    public static let tabCards = "creditcard"
    public static let tabCardsActive = "creditcard.fill"
    public static let tabScan = "qrcode.viewfinder"
    public static let tabHistory = "clock.arrow.circlepath"
    public static let tabSearch = "magnifyingglass"

    // MARK: - Top Bar Actions
    public static let chevronBack = "chevron.left"
    public static let notificationBell = "bell"
    public static let achievementTrophy = "trophy"
    public static let optionsMenu = "ellipsis"
    public static let balanceVisible = "eye.fill"
    public static let balanceHidden = "eye.slash.fill"

    // MARK: - Dashboard Quick Actions (Lime Card)
    public static let actionSend = "arrow.up.right"
    public static let actionRequest = "arrow.down.left"
    public static let actionPayment = "creditcard"
    public static let actionWithdraw = "tray.and.arrow.down"

    // MARK: - Cards Deck Actions (2x4 Grid)
    public static let cardSendMoney = "arrow.up.right"
    public static let cardTopup = "plus"
    public static let cardStatements = "doc.text"
    public static let cardBillsPay = "banknote"
    public static let cardLoans = "chart.line.uptrend.xyaxis"
    public static let cardFreeze = "snowflake"
    public static let cardLimitRequest = "slider.horizontal.3"
    public static let cardDeposits = "arrow.down.circle"

    // MARK: - Transaction Types
    public static let transactionOutflow = "arrow.up.right"
    public static let transactionInflow = "arrow.down.left"

    // MARK: - Account Card Emblems
    public static let contactlessWave = "wave.3.forward"
    public static let swapAccount = "arrow.2.squarepath"
    public static let addCard = "plus"

    // MARK: - Keypad & Outlay Input
    public static let keypadBackspace = "delete.left"
    public static let keypadReturn = "arrow.uturn.backward"
    public static let flashlightOn = "flashlight.on.fill"
    public static let flashlightOff = "flashlight.off.fill"
}

