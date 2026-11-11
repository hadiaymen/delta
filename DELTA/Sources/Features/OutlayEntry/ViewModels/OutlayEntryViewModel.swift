import SwiftUI
import Combine

/// View model driving the Log Outlay / Numeric Keypad screen.
public final class OutlayEntryViewModel: ObservableObject {
    @Published public var rawAmountString: String = "1500.00"
    @Published public var selectedRecipient: String = "Alina"
    @Published public var transferLimitMax: Double = 10000.00
    @Published public var currentSliderValue: Double = 1500.00
    @Published public var isHoldingToSend: Bool = false
    @Published public var holdProgress: Double = 0.0
    @Published public var showSuccessToast: Bool = false
    @Published public var showLimitAlert: Bool = false

    public let service: ExpenseTrackingService

    public init(service: ExpenseTrackingService) {
        self.service = service
    }

    public var parsedAmount: Double {
        Double(rawAmountString) ?? 0.0
    }

    public var formattedDisplayAmount: String {
        "$\(rawAmountString)"
    }

    public func handleKeypadInput(_ key: String) {
        switch key {
        case "⌫", "x":
            if !rawAmountString.isEmpty {
                rawAmountString.removeLast()
            }
            if rawAmountString.isEmpty {
                rawAmountString = "0"
            }
        case "↩":
            // Submit
            executeSend()
        case ".":
            if !rawAmountString.contains(".") {
                rawAmountString.append(".")
            }
        default:
            if rawAmountString == "0" || rawAmountString == "1500.00" {
                rawAmountString = key
            } else {
                // Limit to 2 decimal places
                if let dotIndex = rawAmountString.firstIndex(of: ".") {
                    let decimals = rawAmountString[dotIndex...].count - 1
                    if decimals >= 2 { return }
                }
                rawAmountString.append(key)
            }
        }
    }

    public func executeSend() {
        guard parsedAmount > 0 else { return }
        if parsedAmount > transferLimitMax {
            showLimitAlert = true
            return
        }
        service.logOutlay(amount: parsedAmount, recipient: selectedRecipient, note: "Personal outlay entry")
        showSuccessToast = true
    }
}

