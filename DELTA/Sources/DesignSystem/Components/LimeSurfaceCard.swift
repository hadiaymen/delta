import SwiftUI

/// Rounded neon lime surface container with downward notch accent.
/// Directly mirrors the hero surface container in the reference design.
public struct LimeSurfaceCard<Content: View>: View {
    private let content: Content
    private let showNotch: Bool

    public init(showNotch: Bool = true, @ViewBuilder content: () -> Content) {
        self.showNotch = showNotch
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: 0) {
            content
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 18)

            if showNotch {
                // Downward curved pill notch accent matching the reference
                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color.deltaTextOnLime.opacity(0.6))
                    .padding(.bottom, 10)
            }
        }
        .background(
            Color.deltaSurfaceLime
        )
        .clipShape(
            RoundedCornerShape(
                radius: DeltaDimensions.radiusHeroSurface,
                corners: [.bottomLeft, .bottomRight]
            )
        )
    }
}

// MARK: - Custom Corner Radius Shape
public struct RoundedCornerShape: Shape {
    public var radius: CGFloat = .infinity
    public var corners: UIRectCorner = .allCorners

    public func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

