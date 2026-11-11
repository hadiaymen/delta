import SwiftUI
import AVFoundation

/// Scan destination screen triggered by the prominent elevated center tab.
/// Integrates native AVFoundation camera feed, QR reticle, torch control,
/// and safe UPI QR payload inspection without automated payment calls.
public struct ScanView: View {
    @ObservedObject public var service: ExpenseTrackingService
    @StateObject private var viewModel: ScanViewModel

    public init(service: ExpenseTrackingService) {
        self.service = service
        self._viewModel = StateObject(wrappedValue: ScanViewModel(service: service))
    }

    public var body: some View {
        ZStack {
            // Background Canvas
            Color.deltaBgCanvas.ignoresSafeArea()

            // Camera Viewport & State Overlays
            Group {
                switch viewModel.authorizationStatus {
                case .authorized:
                    authorizedCameraView

                case .notDetermined:
                    permissionRequestView

                case .denied:
                    permissionDeniedView

                case .unavailable:
                    cameraUnavailableView
                }
            }

            // Top Header Bar Overlay
            VStack {
                topBarView
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                Spacer()

                // Floating Error Toast
                if let err = viewModel.scanErrorMessage {
                    errorToastView(message: err)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 110)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // Floating Success Toast
                if viewModel.showSuccessToast {
                    successToastView(message: viewModel.successToastMessage)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 110)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
        .sheet(isPresented: $viewModel.showConfirmationSheet, onDismiss: {
            viewModel.resumeScanning()
        }) {
            if let payload = viewModel.activePayload {
                QRScanConfirmationSheet(
                    service: service,
                    payload: payload,
                    onSaved: {
                        viewModel.handleSuccessfulSave()
                    }
                )
            }
        }
    }

    // MARK: - Top Header Bar
    private var topBarView: some View {
        HStack {
            Spacer()

            Text("Scan QR")
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
    }

    // MARK: - Authorized Active Camera View
    private var authorizedCameraView: some View {
        ZStack {
            // Native AVFoundation Camera Preview
            QRCameraPreviewView(session: viewModel.cameraService.captureSession)
                .ignoresSafeArea()

            // Translucent Mask with Neon Lime Reticle
            QRScanningReticleView()

            // Test payload launcher for convenience in testing
            VStack {
                Spacer()
                HStack(spacing: 8) {
                    testPayloadPill(title: "Sample UPI ($320.50)", action: {
                        viewModel.simulateScanSampleUPIWithAmount()
                    })
                    testPayloadPill(title: "Sample UPI (Manual $)", action: {
                        viewModel.simulateScanSampleUPIWithoutAmount()
                    })
                }
                .padding(.bottom, 100)
            }
        }
    }

    // MARK: - Permission Request View
    private var permissionRequestView: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.deltaBgOliveDark)
                    .frame(width: 80, height: 80)
                    .overlay(Circle().stroke(Color.deltaBorderOlive, lineWidth: 1))

                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundColor(Color.deltaSurfaceLime)
            }

            Text("Camera Access Required")
                .font(DeltaTypography.screenTitle)
                .foregroundColor(Color.deltaTextOnDark)

            Text("DELTA uses the camera to scan payment QR codes and receipts for instant expense logging.")
                .font(DeltaTypography.actionLabel)
                .foregroundColor(Color.deltaTextMutedDark)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button(action: {
                viewModel.requestCameraAccess()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "camera.fill")
                    Text("Enable Camera Access")
                }
                .font(DeltaTypography.bodySemibold)
                .foregroundColor(Color.deltaTextOnLime)
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(Capsule().fill(Color.deltaSurfaceLime))
            }
            .padding(.top, 10)

            Spacer()
            Spacer().frame(height: 80)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Permission Denied View
    private var permissionDeniedView: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.deltaBgOliveDark)
                    .frame(width: 80, height: 80)
                    .overlay(Circle().stroke(Color.deltaBorderOlive, lineWidth: 1))

                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundColor(Color.deltaExpenseRed)
            }

            Text("Camera Permission Disabled")
                .font(DeltaTypography.screenTitle)
                .foregroundColor(Color.deltaTextOnDark)

            Text("To scan QR codes and track outlays, please enable Camera permissions in iOS Settings.")
                .font(DeltaTypography.actionLabel)
                .foregroundColor(Color.deltaTextMutedDark)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button(action: {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "gearshape.fill")
                    Text("Open iOS Settings")
                }
                .font(DeltaTypography.bodySemibold)
                .foregroundColor(Color.deltaTextOnLime)
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(Capsule().fill(Color.deltaSurfaceLime))
            }
            .padding(.top, 10)

            Spacer()
            Spacer().frame(height: 80)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Camera Unavailable / Simulator View
    private var cameraUnavailableView: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.deltaBgOliveDark)
                    .frame(width: 80, height: 80)
                    .overlay(Circle().stroke(Color.deltaBorderOlive, lineWidth: 1))

                Image(systemName: "camera.metering.unknown")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundColor(Color(hex: "E5C07B"))
            }

            Text("Camera Unavailable")
                .font(DeltaTypography.screenTitle)
                .foregroundColor(Color.deltaTextOnDark)

            Text("AVCaptureDevice is unavailable in this environment (e.g. Simulator). You can test native QR workflows using sample payloads below:")
                .font(DeltaTypography.actionLabel)
                .foregroundColor(Color.deltaTextMutedDark)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)

            // Simulator Test Triggers
            VStack(spacing: 10) {
                Button(action: { viewModel.simulateScanSampleUPIWithAmount() }) {
                    simulatorActionRow(
                        title: "Scan Merchant UPI QR",
                        subtitle: "Starbucks Coffee • $320.50 (am pre-filled)"
                    )
                }

                Button(action: { viewModel.simulateScanSampleUPIWithoutAmount() }) {
                    simulatorActionRow(
                        title: "Scan Peer UPI (No Amount)",
                        subtitle: "Hadi Aymen • prompts for manual amount entry"
                    )
                }

                Button(action: { viewModel.simulateScanGenericQR() }) {
                    simulatorActionRow(
                        title: "Scan Generic Reference",
                        subtitle: "Merchant receipt tracking token"
                    )
                }

                Button(action: { viewModel.simulateScanMalformedQR() }) {
                    simulatorActionRow(
                        title: "Test Malformed QR Payload",
                        subtitle: "Validates graceful error handling"
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            Spacer()
            Spacer().frame(height: 80)
        }
    }

    private func simulatorActionRow(title: String, subtitle: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(DeltaTypography.bodySemibold)
                    .foregroundColor(Color.deltaTextOnDark)
                Text(subtitle)
                    .font(DeltaTypography.captionMeta)
                    .foregroundColor(Color.deltaTextMutedDark)
            }
            Spacer()
            Image(systemName: "arrow.up.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Color.deltaSurfaceLime)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.deltaBgOliveDark)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.deltaBorderOlive, lineWidth: 1)
        )
    }

    private func testPayloadPill(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color.deltaTextOnDark)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.deltaBgOliveDark.opacity(0.85))
                        .overlay(Capsule().stroke(Color.deltaBorderOlive, lineWidth: 1))
                )
        }
    }

    // MARK: - Toast Helpers
    private func errorToastView(message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(Color.deltaExpenseRed)
            Text(message)
                .font(DeltaTypography.captionMeta)
                .foregroundColor(Color.deltaTextOnDark)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color.deltaBgOliveDark)
                .overlay(Capsule().stroke(Color.deltaExpenseRed.opacity(0.5), lineWidth: 1))
        )
    }

    private func successToastView(message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Color.deltaSurfaceLime)
            Text(message)
                .font(DeltaTypography.captionMeta)
                .foregroundColor(Color.deltaTextOnDark)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color.deltaBgOliveDark)
                .overlay(Capsule().stroke(Color.deltaSurfaceLime.opacity(0.6), lineWidth: 1))
        )
    }
}
