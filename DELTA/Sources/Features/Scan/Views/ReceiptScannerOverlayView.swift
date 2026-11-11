import SwiftUI

/// Reticle view wrapper preserved for compatibility with previous scanner overlay implementations.
public struct ReceiptScannerOverlayView: View {
    public init(viewModel: ScanViewModel? = nil) {}

    public var body: some View {
        QRScanningReticleView()
    }
}
