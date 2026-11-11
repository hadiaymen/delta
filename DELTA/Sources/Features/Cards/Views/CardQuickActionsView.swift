import SwiftUI

/// Exactly four Quick Actions (Split, Credit, Debit, Other) under the card stack.
/// Preserves the original squircle grid proportions, icon styling, and labels.
public struct CardQuickActionsView: View {
    public enum ActionType: String, CaseIterable, Identifiable {
        case split = "Split"
        case credit = "Credit"
        case debit = "Debit"
        case other = "Other"

        public var id: String { rawValue }

        public var iconName: String {
            switch self {
            case .split:
                return "arrow.triangle.branch"
            case .credit:
                return DeltaIcons.transactionInflow
            case .debit:
                return DeltaIcons.transactionOutflow
            case .other:
                return "slider.horizontal.3"
            }
        }
    }

    public let onActionSelected: (ActionType) -> Void

    public init(onActionSelected: @escaping (ActionType) -> Void) {
        self.onActionSelected = onActionSelected
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Quick Actions")
                .font(DeltaTypography.sectionHeader)
                .foregroundColor(Color.deltaTextOnDark)
                .padding(.horizontal, 20)

            HStack(spacing: 16) {
                ForEach(ActionType.allCases) { action in
                    Button(action: {
                        onActionSelected(action)
                    }) {
                        VStack(spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: DeltaDimensions.radiusSquircleButton, style: .continuous)
                                    .fill(Color.deltaBgOliveDark)
                                    .frame(width: 58, height: 58)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DeltaDimensions.radiusSquircleButton, style: .continuous)
                                            .stroke(Color.deltaBorderOlive, lineWidth: 1)
                                    )

                                Image(systemName: action.iconName)
                                    .font(.system(size: 21, weight: .semibold))
                                    .foregroundColor(Color.deltaSurfaceLime)
                            }

                            Text(action.rawValue)
                                .font(DeltaTypography.actionLabel)
                                .foregroundColor(Color.deltaTextMutedDark)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SquirclePressStyle())
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

private struct SquirclePressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(DeltaAnimations.tactilePress, value: configuration.isPressed)
    }
}
