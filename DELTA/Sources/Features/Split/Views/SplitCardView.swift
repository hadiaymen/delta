import SwiftUI

/// Reusable Split Record presentation card for lists and the History screen filter.
public struct SplitCardView: View {
    public let split: SplitRecord
    public let onTap: () -> Void

    public init(split: SplitRecord, onTap: @escaping () -> Void = {}) {
        self.split = split
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                // Top Row: Title, Method & Total
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(split.title)
                            .font(DeltaTypography.bodySemibold)
                            .foregroundColor(Color.deltaTextOnDark)

                        Text(split.method.rawValue)
                            .font(DeltaTypography.captionMeta)
                            .foregroundColor(Color.deltaTextMutedDark)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 3) {
                        Text(split.formattedTotalAmount)
                            .font(DeltaTypography.bodySemibold)
                            .foregroundColor(Color.deltaSurfaceLime)

                        Text("\(split.participantCount) participants")
                            .font(DeltaTypography.captionMeta)
                            .foregroundColor(Color.deltaTextMutedDark)
                    }
                }

                Divider()
                    .background(Color.deltaBorderOlive)

                // Bottom Row: Settlement Status & Date
                HStack {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(split.isFullySettled ? Color.deltaSurfaceLime : Color.deltaExpenseRed)
                            .frame(width: 7, height: 7)

                        Text(split.isFullySettled ? "Fully Settled" : "\(split.settledCount)/\(split.participantCount) Settled")
                            .font(DeltaTypography.captionMeta)
                            .foregroundColor(split.isFullySettled ? Color.deltaSurfaceLime : Color.deltaTextMutedDark)
                    }

                    Spacer()

                    Text(split.formattedDate)
                        .font(DeltaTypography.captionMeta)
                        .foregroundColor(Color.deltaTextMutedDark)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.deltaBgOliveDark)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.deltaBorderOlive, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(SplitCardPressStyle())
    }
}

private struct SplitCardPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(DeltaAnimations.tactilePress, value: configuration.isPressed)
    }
}

