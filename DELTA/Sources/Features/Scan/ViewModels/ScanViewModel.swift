import SwiftUI
import Combine

/// View model driving the receipt scanner screen for instant expense capture.
public final class ScanViewModel: ObservableObject {
    @Published public var isTorchOn: Bool = false
    @Published public var isScanning: Bool = true
    @Published public var detectedReceiptAmount: Double? = 42.80
    @Published public var detectedMerchant: String? = "Urban Cafe & Bakery"
    @Published public var showCaptureConfirmation: Bool = false
    @Published public var scanSuccessNotice: String = ""

    public let service: ExpenseTrackingService

    public init(service: ExpenseTrackingService) {
        self.service = service
    }

    public func toggleTorch() {
        isTorchOn.toggle()
    }

    public func captureReceipt() {
        guard let amount = detectedReceiptAmount, let merchant = detectedMerchant else { return }
        service.logOutlay(amount: amount, recipient: merchant, note: "Scanned paper receipt")
        scanSuccessNotice = "Scanned receipt logged: $\(String(format: "%.2f", amount)) from \(merchant)"
        showCaptureConfirmation = true
    }
}

