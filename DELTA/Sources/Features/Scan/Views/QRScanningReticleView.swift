import SwiftUI

/// Clear scanning frame with neon lime corner brackets, dark masking, and animated scanline.
public struct QRScanningReticleView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var scanLineOffset: CGFloat = -110

    public init() {}

    public var body: some View {
        VStack(spacing: 24) {
            ZStack {
                // Outer Mask Frame
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(Color.deltaSurfaceLime.opacity(0.3), lineWidth: 1.5)
                    .frame(width: 270, height: 270)
                    .background(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(Color.black.opacity(0.2))
                    )

                // Neon Lime Corner Accents
                ReticleCornerBrackets()
                    .stroke(Color.deltaSurfaceLime, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                    .frame(width: 270, height: 270)

                // Animated Laser Sweep Beam (Suppressed when Reduce Motion is enabled)
                if !reduceMotion {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.deltaSurfaceLime.opacity(0.9),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 250, height: 2)
                        .shadow(color: Color.deltaSurfaceLime, radius: 8, x: 0, y: 0)
                        .offset(y: scanLineOffset)
                        .onAppear {
                            withAnimation(
                                .easeInOut(duration: 1.8).repeatForever(autoreverses: true)
                            ) {
                                scanLineOffset = 110
                            }
                        }
                }
            }

            // Scanning Guidance Text
            VStack(spacing: 4) {
                Text("Align QR code within the frame")
                    .font(DeltaTypography.bodySemibold)
                    .foregroundColor(Color.deltaTextOnDark)

                Text("Supports UPI merchant codes and expense references")
                    .font(DeltaTypography.captionMeta)
                    .foregroundColor(Color.deltaTextMutedDark)
            }
        }
    }
}

// MARK: - Reticle Corner Brackets Shape
private struct ReticleCornerBrackets: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let armLength: CGFloat = 30
        let radius: CGFloat = 20

        // Top-Left Corner
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + armLength))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
        path.addQuadCurve(to: CGPoint(x: rect.minX + radius, y: rect.minY), control: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + armLength, y: rect.minY))

        // Top-Right Corner
        path.move(to: CGPoint(x: rect.maxX - armLength, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + radius), control: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + armLength))

        // Bottom-Right Corner
        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY - armLength))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
        path.addQuadCurve(to: CGPoint(x: rect.maxX - radius, y: rect.maxY), control: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX - armLength, y: rect.maxY))

        // Bottom-Left Corner
        path.move(to: CGPoint(x: rect.minX + armLength, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY - radius), control: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - armLength))

        return path
    }
}

