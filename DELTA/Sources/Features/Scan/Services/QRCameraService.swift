import AVFoundation
import SwiftUI
import Combine

/// Hardware camera authorization states for DELTA scanner.
public enum CameraAuthorizationStatus: Equatable {
    case authorized
    case notDetermined
    case denied
    case unavailable
}

/// Service wrapping AVFoundation camera APIs for native QR code scanning and torch control.
public final class QRCameraService: NSObject, ObservableObject {
    @Published public var authorizationStatus: CameraAuthorizationStatus = .notDetermined
    @Published public var isTorchOn: Bool = false
    @Published public var isSessionRunning: Bool = false
    @Published public var lastDetectedQR: String? = nil

    public let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "com.delta.camera.sessionQueue")
    private var videoDeviceInput: AVCaptureDeviceInput?
    private let metadataOutput = AVCaptureMetadataOutput()
    private var isConfigured = false

    public override init() {
        super.init()
        checkAuthorization()
    }

    // MARK: - Camera Authorization
    public func checkAuthorization() {
        guard let _ = AVCaptureDevice.default(for: .video) else {
            DispatchQueue.main.async {
                self.authorizationStatus = .unavailable
            }
            return
        }

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            DispatchQueue.main.async {
                self.authorizationStatus = .authorized
            }
            configureSessionIfNeeded()
        case .notDetermined:
            DispatchQueue.main.async {
                self.authorizationStatus = .notDetermined
            }
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.authorizationStatus = .denied
            }
        @unknown default:
            DispatchQueue.main.async {
                self.authorizationStatus = .denied
            }
        }
    }

    public func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if granted {
                    self.authorizationStatus = .authorized
                    self.configureSessionIfNeeded()
                    self.startScanning()
                } else {
                    self.authorizationStatus = .denied
                }
            }
        }
    }

    // MARK: - Session Configuration
    private func configureSessionIfNeeded() {
        sessionQueue.async { [weak self] in
            guard let self = self, !self.isConfigured else { return }

            guard let videoDevice = AVCaptureDevice.default(for: .video) else {
                DispatchQueue.main.async {
                    self.authorizationStatus = .unavailable
                }
                return
            }

            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = .high

            do {
                let videoInput = try AVCaptureDeviceInput(device: videoDevice)
                if self.captureSession.canAddInput(videoInput) {
                    self.captureSession.addInput(videoInput)
                    self.videoDeviceInput = videoInput
                } else {
                    self.captureSession.commitConfiguration()
                    return
                }

                if self.captureSession.canAddOutput(self.metadataOutput) {
                    self.captureSession.addOutput(self.metadataOutput)
                    self.metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                    // Request QR code metadata inspection
                    if self.metadataOutput.availableMetadataObjectTypes.contains(.qr) {
                        self.metadataOutput.metadataObjectTypes = [.qr]
                    }
                }

                self.captureSession.commitConfiguration()
                self.isConfigured = true
            } catch {
                self.captureSession.commitConfiguration()
            }
        }
    }

    // MARK: - Session Control
    public func startScanning() {
        guard authorizationStatus == .authorized else { return }
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
                DispatchQueue.main.async {
                    self.isSessionRunning = true
                }
            }
        }
    }

    public func stopScanning() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
                DispatchQueue.main.async {
                    self.isSessionRunning = false
                    if self.isTorchOn {
                        self.setTorch(enabled: false)
                    }
                }
            }
        }
    }

    // MARK: - Flashlight / Torch Control
    public func toggleTorch() {
        setTorch(enabled: !isTorchOn)
    }

    public func setTorch(enabled: Bool) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            if enabled && device.isTorchModeSupported(.on) {
                device.torchMode = .on
                DispatchQueue.main.async { self.isTorchOn = true }
            } else if !enabled && device.isTorchModeSupported(.off) {
                device.torchMode = .off
                DispatchQueue.main.async { self.isTorchOn = false }
            }
            device.unlockForConfiguration()
        } catch {
            // Torch configuration failed silently
        }
    }

    public func resetLastDetection() {
        self.lastDetectedQR = nil
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension QRCameraService: AVCaptureMetadataOutputObjectsDelegate {
    public func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              metadataObject.type == .qr,
              let stringValue = metadataObject.stringValue,
              !stringValue.isEmpty else {
            return
        }

        // Avoid repeated duplicate hits within a single scan
        if lastDetectedQR != stringValue {
            lastDetectedQR = stringValue
        }
    }
}

