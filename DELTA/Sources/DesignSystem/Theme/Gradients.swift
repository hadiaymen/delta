import SwiftUI

/// DELTA Design System Gradients
public struct DeltaGradients {
    /// The primary signature card gradient: chartreuse lime fading down into deep forest olive
    public static let cardSurface = LinearGradient(
        colors: [
            Color.deltaCardGradStart,
            Color(hex: "56760D"),
            Color.deltaCardGradEnd
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Subtle background card gradient peeking behind
    public static let cardPeekSurface = LinearGradient(
        colors: [
            Color(hex: "293A0A"),
            Color.deltaCardPeek
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Subtle glow effect for active center scan trigger
    public static let scanGlow = RadialGradient(
        colors: [
            Color.deltaSurfaceLime.opacity(0.4),
            Color.clear
        ],
        center: .center,
        startRadius: 4,
        endRadius: 42
    )

    /// Bottom fade gradient for scroll containers
    public static let bottomFade = LinearGradient(
        colors: [
            Color.clear,
            Color.deltaBgCanvas.opacity(0.85),
            Color.deltaBgCanvas
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

