import SwiftUI

/// Scan destination screen triggered by the prominent elevated center tab.
public struct ScanView: View {
    @ObservedObject public var service: ExpenseTrackingService
    @StateObject private var viewModel: ScanViewModel

    public init(service: ExpenseTrackingService) {
        self.service = service
        self._viewModel = StateObject(wrappedValue: ScanViewModel(service: service))
    }

    public var body: some View {
        ZStack {
            Color.deltaBgCanvas.ignoresSafeArea()

            VStack(spacing: 24) {
                // Top Header Bar
                HStack {
                    Spacer()

                    Text("Scan Receipt")
                        .font(DeltaTypography.screenTitle)
                        .foregroundColor(Color.deltaTextOnDark)

                    Spacer()

                    // Flashlight Toggle Squircle
                    SquircleButton(
                        iconName: viewModel.isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill",
                        size: DeltaDimensions.sizeTopBarButton,
                        style: viewModel.isTorchOn ? .limeAccent : .dark,
                        action: { viewModel.toggleTorch() }
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                Spacer()

                // Viewfinder Reticle
                ReceiptScannerOverlayView(viewModel: viewModel)

                Spacer()

                // Instruction & Manual Outlay Prompt
                VStack(spacing: 8) {
                    Text("Align receipt total or expense QR code")
                        .font(DeltaTypography.bodySemibold)
                        .foregroundColor(Color.deltaTextOnDark)

                    Text("Automatically logs expense to your primary budget envelope.")
                        .font(DeltaTypography.actionLabel)
                        .foregroundColor(Color.deltaTextMutedDark)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 32)

                // Capture Button
                Button(action: {
                    viewModel.captureReceipt()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 16, weight: .bold))

                        Text("Capture & Log Outlay")
                            .font(DeltaTypography.bodySemibold)
                    }
                    .foregroundColor(Color.deltaTextOnLime)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.deltaSurfaceLime)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .padding(.horizontal, 24)
                .buttonStyle(PlainButtonStyle())

                // Bottom Padding for Nav Dock
                Spacer()
                    .frame(height: 90)
            }
        }
        .alert(isPresented: $viewModel.showCaptureConfirmation) {
            Alert(
                title: Text("Receipt Scanned"),
                message: Text(viewModel.scanSuccessNotice),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

