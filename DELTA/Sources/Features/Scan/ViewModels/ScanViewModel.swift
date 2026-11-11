import SwiftUI
import Combine

/// View model driving the native QR scanner, orchestrating AVFoundation camera access,
/// flashlight control, payload inspection, and safety verification.
public final class ScanViewModel: ObservableObject {
    @Published public var cameraService: QRCameraService
    @Published public var activePayload: ParsedQRPayload? = nil
    @Published public var showConfirmationSheet: Bool = false
    @Published public var scanErrorMessage: String? = nil
    @Published public var showSuccessToast: Bool = false
    @Published public var successToastMessage: String = ""

    public let service: ExpenseTrackingService
    private var cancellables = Set<AnyCancellable>()

    public init(service: ExpenseTrackingService, cameraService: QRCameraService = QRCameraService()) {
        self.service = service
        self.cameraService = cameraService

        // Observe QR code detection from the camera service
        cameraService.$lastDetectedQR
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] rawQR in
                self?.handleDetectedQR(rawQR)
            }
            .store(in: &cancellables)
    }

    public var isTorchOn: Bool {
        cameraService.isTorchOn
    }

    public var authorizationStatus: CameraAuthorizationStatus {
        cameraService.authorizationStatus
    }

    public func onAppear() {
        cameraService.checkAuthorization()
        if cameraService.authorizationStatus == .authorized {
            cameraService.startScanning()
        }
    }

    public func onDisappear() {
        cameraService.stopScanning()
    }

    public func toggleTorch() {
        cameraService.toggleTorch()
    }

    public func requestCameraAccess() {
        cameraService.requestCameraPermission()
    }

    /// Processes a detected QR string safely through QRPayloadParser without executing any code.
    public func handleDetectedQR(_ rawString: String) {
        let result = QRPayloadParser.parse(payload: rawString)
        switch result {
        case .success(let payload):
            self.activePayload = payload
            self.scanErrorMessage = nil
            self.showConfirmationSheet = true
            // Temporarily pause camera scanning while confirmation sheet is presented
            cameraService.stopScanning()

        case .failure(let error):
            self.scanErrorMessage = error.localizedDescription
            // Dismiss error after 3.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in
                if self?.scanErrorMessage == error.localizedDescription {
                    self?.scanErrorMessage = nil
                }
            }
        }
    }

    /// Resumes scanning after confirmation sheet dismissal or save
    public func resumeScanning() {
        cameraService.resetLastDetection()
        activePayload = nil
        showConfirmationSheet = false
        if cameraService.authorizationStatus == .authorized {
            cameraService.startScanning()
        }
    }

    public func handleSuccessfulSave() {
        let title = activePayload?.displayTitle ?? "Outlay"
        successToastMessage = "Logged '\(title)' under Other in History"
        showSuccessToast = true
        resumeScanning()

        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { [weak self] in
            self?.showSuccessToast = false
        }
    }

    // MARK: - Simulator / Testing Injections
    public func simulateScanSampleUPIWithAmount() {
        handleDetectedQR("upi://pay?pa=starbucks@hdfcbank&pn=Starbucks%20Coffee&am=320.50&tn=Dark%20Roast%20%26%20Croissant&tr=TRX87654321&cu=INR")
    }

    public func simulateScanSampleUPIWithoutAmount() {
        handleDetectedQR("upi://pay?pa=hadi.aymen@okhdfcbank&pn=Hadi%20Aymen&tn=Weekend%20Split%20Reimbursement&tr=TRX11223344")
    }

    public func simulateScanGenericQR() {
        handleDetectedQR("DELTA-MERCHANT-RECEIPT-REF-2026-9921A")
    }

    public func simulateScanMalformedQR() {
        handleDetectedQR("upi://pay?")
    }
}
