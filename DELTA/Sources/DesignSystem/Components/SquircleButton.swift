import SwiftUI

/// A reusable squircle button styled with DELTA design system tokens.
/// Features tactile scale animation and haptic-ready interactions.
public struct SquircleButton: View {
    public enum Style {
        /// Dark obsidian-olive background for placement on lime surfaces or dark canvas
        case dark
        /// Subtle outline style for secondary actions
        case outlined
        /// Neon lime accent style
        case limeAccent
    }

    private let iconName: String
    private let title: String?
    private let size: CGFloat
    private let style: Style
    private let isSystemIcon: Bool
    private let action: () -> Void

    @State private var isPressed: Bool = false

    public init(
        iconName: String,
        title: String? = nil,
        size: CGFloat = DeltaDimensions.sizeActionButton,
        style: Style = .dark,
        isSystemIcon: Bool = true,
        action: @escaping () -> Void
    ) {
        self.iconName = iconName
        self.title = title
        self.size = size
        self.style = style
        self.isSystemIcon = isSystemIcon
        self.action = action
    }

    public var body: some View {
        Button(action: {
            action()
        }) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: DeltaDimensions.radiusSquircleButton, style: .continuous)
                        .fill(backgroundColor)
                        .frame(width: size, height: size)
                        .overlay(
                            RoundedRectangle(cornerRadius: DeltaDimensions.radiusSquircleButton, style: .continuous)
                                .stroke(strokeColor, lineWidth: 1)
                        )

                    if isSystemIcon {
                        Image(systemName: iconName)
                            .font(.system(size: size * 0.4, weight: .semibold))
                            .foregroundColor(iconColor)
                    } else {
                        Image(iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: size * 0.45, height: size * 0.45)
                            .foregroundColor(iconColor)
                    }
                }

                if let title = title {
                    Text(title)
                        .font(DeltaTypography.actionLabel)
                        .foregroundColor(titleColor)
                        .lineLimit(1)
                }
            }
        }
        .accessibilityLabel(accessibilityTitle)
        .accessibilityAddTraits(.isButton)
        .buttonStyle(SquirclePressStyle())
    }

    private var accessibilityTitle: String {
        if let title = title, !title.isEmpty {
            return title
        }
        return iconName.replacingOccurrences(of: ".", with: " ").capitalized
    }

    private var backgroundColor: Color {
        switch style {
        case .dark:
            return Color.deltaBgOliveDark
        case .outlined:
            return Color.clear
        case .limeAccent:
            return Color.deltaSurfaceLime
        }
    }

    private var strokeColor: Color {
        switch style {
        case .dark:
            return Color.deltaBorderOlive
        case .outlined:
            return Color.deltaBorderOlive.opacity(0.8)
        case .limeAccent:
            return Color.clear
        }
    }

    private var iconColor: Color {
        switch style {
        case .dark:
            return Color.deltaTextOnDark
        case .outlined:
            return Color.deltaTextMutedDark
        case .limeAccent:
            return Color.deltaTextOnLime
        }
    }

    private var titleColor: Color {
        return Color.deltaTextOnDark
    }
}

// MARK: - Tactile Press Style
private struct SquirclePressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .opacity(configuration.isPressed ? 0.88 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.65), value: configuration.isPressed)
    }
}

