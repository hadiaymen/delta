import SwiftUI

/// DELTA Design System Shadow Tokens
/// Accurately configured for dark obsidian canvas and vibrant neon lime glow.
public struct DeltaShadows {
    /// Deep elevation shadow for primary stacked account cards
    public static let cardElevation = Shadow(
        color: Color.black.opacity(0.55),
        radius: 20,
        x: 0,
        y: 10
    )

    /// Subtle card border highlight
    public static let cardBorderGlow = Shadow(
        color: Color.white.opacity(0.12),
        radius: 1,
        x: 0,
        y: 0
    )

    /// Floating bottom navigation dock shadow
    public static let navDockElevation = Shadow(
        color: Color.black.opacity(0.48),
        radius: 18,
        x: 0,
        y: -6
    )

    /// Radial halo around the elevated central Scan button
    public static let scanButtonGlow = Shadow(
        color: Color.deltaSurfaceLime.opacity(0.45),
        radius: 12,
        x: 0,
        y: 2
    )

    /// Soft shadow for dark squircle buttons on neon lime surface
    public static let squircleOnLime = Shadow(
        color: Color.black.opacity(0.18),
        radius: 6,
        x: 0,
        y: 3
    )

    /// Subtle tile elevation on dark canvas
    public static let tileElevation = Shadow(
        color: Color.black.opacity(0.28),
        radius: 8,
        x: 0,
        y: 4
    )
}

public struct Shadow {
    public let color: Color
    public let radius: CGFloat
    public let x: CGFloat
    public let y: CGFloat

    public init(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
}

public extension View {
    func deltaShadow(_ shadow: Shadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}

