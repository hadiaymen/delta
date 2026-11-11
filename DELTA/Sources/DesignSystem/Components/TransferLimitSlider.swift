import SwiftUI

/// Reusable Transfer & Outlay Limit Progress Slider component.
public struct TransferLimitSlider: View {
    private let title: String
    private let currentAmount: Double
    private let maxLimit: Double

    public init(
        title: String = "Transfer Limits",
        currentAmount: Double,
        maxLimit: Double = 10000.00
    ) {
        self.title = title
        self.currentAmount = currentAmount
        self.maxLimit = maxLimit
    }

    public var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(title)
                    .font(DeltaTypography.captionMeta)
                    .foregroundColor(Color.deltaTextMutedDark)

                Spacer()

                Text(String(format: "$%.2f", maxLimit))
                    .font(DeltaTypography.captionMeta)
                    .foregroundColor(Color.deltaTextMutedDark)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Inactive Track
                    Capsule()
                        .fill(Color.deltaBgOliveDark)
                        .frame(height: 5)

                    // Active Lime Fill
                    Capsule()
                        .fill(Color.deltaSurfaceLime)
                        .frame(
                            width: min(max(geo.size.width * CGFloat(currentAmount / maxLimit), 6), geo.size.width),
                            height: 5
                        )
                        .animation(DeltaAnimations.tactilePress, value: currentAmount)
                }
            }
            .frame(height: 5)
        }
    }
}

