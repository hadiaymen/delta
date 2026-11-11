import SwiftUI

/// Futuristic viewfinder reticle overlay for scanning expense receipts.
public struct ReceiptScannerOverlayView: View {
    @ObservedObject public var viewModel: ScanViewModel
    @State private var scanLineOffset: CGFloat = -110

    public init(viewModel: ScanViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            // Viewfinder Target Frame
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.deltaSurfaceLime.opacity(0.35), lineWidth: 1.5)
                .frame(width: 280, height: 280)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.deltaBgOliveDark.opacity(0.45))
                )

            // Neon Lime Corner Accents
            CornerBracketsShape()
                .stroke(Color.deltaSurfaceLime, lineWidth: 3.5)
                .frame(width: 280, height: 280)

            // Animated Laser Scanning Beam
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.deltaSurfaceLime.opacity(0.8),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 260, height: 2)
                .shadow(color: Color.deltaSurfaceLime, radius: 6, x: 0, y: 0)
                .offset(y: scanLineOffset)
                .onAppear {
                    withAnimation(
                        .easeInOut(duration: 2.0).repeatForever(autoreverses: true)
                    ) {
                        scanLineOffset = 110
                    }
                }

            // Realtime Detected Receipt Pill
            if let amount = viewModel.detectedReceiptAmount, let merchant = viewModel.detectedMerchant {
                VStack(spacing: 4) {
                    Text(merchant)
                        .font(DeltaTypography.captionMeta)
                        .foregroundColor(Color.deltaTextOnLime)

                    Text(String(format: "$%.2f", amount))
                        .font(DeltaTypography.bodySemibold)
                        .foregroundColor(Color.deltaTextOnLime)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.deltaSurfaceLime)
                        .shadow(color: Color.black.opacity(0.4), radius: 8, x: 0, y: 4)
                )
                .offset(y: 100)
            }
        }
    }
}

// MARK: - Corner Brackets Shape
private struct CornerBracketsShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let length: CGFloat = 28
        let r: CGFloat = 16

        // Top-Left
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + length))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + r))
        path.addQuadCurve(to: CGPoint(x: rect.minX + r, y: rect.minY), control: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + length, y: rect.minY))

        // Top-Right
        path.move(to: CGPoint(x: rect.maxX - length, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - r, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + r), control: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + length))

        // Bottom-Right
        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY - length))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - r))
        path.addQuadCurve(to: CGPoint(x: rect.maxX - r, y: rect.maxY), control: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX - length, y: rect.maxY))

        // Bottom-Left
        path.move(to: CGPoint(x: rect.minX + length, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + r, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY - r), control: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - length))

        return path
    }
}

