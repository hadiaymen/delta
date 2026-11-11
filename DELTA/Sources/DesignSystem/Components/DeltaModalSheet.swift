import SwiftUI

/// Reusable Modal Sheet container adhering to DELTA design system standards.
public struct DeltaModalSheet<Content: View>: View {
    private let title: String
    private let onClose: () -> Void
    private let content: Content

    public init(
        title: String,
        onClose: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.onClose = onClose
        self.content = content()
    }

    public var body: some View {
        ZStack {
            Color.deltaBgCanvas.ignoresSafeArea()

            VStack(spacing: 0) {
                // Drag Indicator Handle
                Capsule()
                    .fill(Color.deltaBorderOlive.opacity(0.8))
                    .frame(width: 36, height: 4)
                    .padding(.top, 10)
                    .padding(.bottom, 6)

                // Top Navigation Bar
                HStack {
                    SquircleButton(
                        iconName: DeltaIcons.chevronBack,
                        size: DeltaDimensions.sizeTopBarButton,
                        style: .dark,
                        action: onClose
                    )

                    Spacer()

                    Text(title)
                        .font(DeltaTypography.screenTitle)
                        .foregroundColor(Color.deltaTextOnDark)

                    Spacer()

                    SquircleButton(
                        iconName: DeltaIcons.notificationBell,
                        size: DeltaDimensions.sizeTopBarButton,
                        style: .dark,
                        action: {}
                    )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)

                // Modal Content
                content
            }
        }
        .clipShape(
            RoundedCornerShape(
                radius: DeltaDimensions.radiusHeroSurface,
                corners: [.topLeft, .topRight]
            )
        )
        .preferredColorScheme(.dark)
    }
}

