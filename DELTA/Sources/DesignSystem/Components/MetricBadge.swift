import SwiftUI

/// Compact metric pill badge matching the reference (e.g. "↑ 24%  Last week").
public struct MetricBadge: View {
    private let text: String
    private let isPositive: Bool

    public init(text: String = "↑ 24%  Last week", isPositive: Bool = true) {
        self.text = text
        self.isPositive = isPositive
    }

    public var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(DeltaTypography.pillBadge)
                .foregroundColor(Color(hex: "173A05"))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Color(hex: "B7EA16")
        )
        .clipShape(Capsule())
        .accessibilityLabel("Monthly comparison: \(text)")
    }
}

