import SwiftUI

/// Reusable Contact Avatar Chip component for quick payee carousels.
public struct ContactAvatarChip: View {
    private let name: String
    private let maskedIdentifier: String
    private let initials: String
    private let isSelected: Bool
    private let action: () -> Void

    public init(
        name: String,
        maskedIdentifier: String,
        initials: String,
        isSelected: Bool = false,
        action: @escaping () -> Void = {}
    ) {
        self.name = name
        self.maskedIdentifier = maskedIdentifier
        self.initials = initials
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                // Avatar Circle
                ZStack {
                    Circle()
                        .fill(Color(hex: "233215"))
                        .frame(width: 38, height: 38)

                    Text(initials)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color.deltaSurfaceLime)
                }

                // Name & Masked Identifier
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(DeltaTypography.bodySemibold)
                        .foregroundColor(Color.deltaTextOnDark)

                    Text(maskedIdentifier)
                        .font(DeltaTypography.captionMeta)
                        .foregroundColor(Color.deltaTextMutedDark)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(isSelected ? Color.deltaBgOliveHover : Color.deltaBgOliveDark)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(isSelected ? Color.deltaSurfaceLime.opacity(0.5) : Color.deltaBorderOlive, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(ChipPressStyle())
    }
}

private struct ChipPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(DeltaAnimations.tactilePress, value: configuration.isPressed)
    }
}

