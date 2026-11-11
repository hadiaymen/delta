import SwiftUI

/// DELTA Design System Spring Animations & Motion Tokens
/// Features physics-based spring curves designed specifically for high-end fintech interactions.
public struct DeltaAnimations {
    /// Tactile button press spring: snappy, tight response with minimal oscillation
    public static let tactilePress = Animation.spring(
        response: 0.22,
        dampingFraction: 0.65,
        blendDuration: 0.0
    )

    /// Tab bar switch animation: fluid, confident motion
    public static let tabTransition = Animation.spring(
        response: 0.32,
        dampingFraction: 0.72,
        blendDuration: 0.0
    )

    /// Modal sheet presentation spring
    public static let sheetTransition = Animation.spring(
        response: 0.38,
        dampingFraction: 0.82,
        blendDuration: 0.0
    )

    /// Subtle toggle transition (e.g. balance eye reveal)
    public static let toggleReveal = Animation.easeInOut(duration: 0.22)

    /// Scanner laser cycle
    public static let scannerCycle = Animation.easeInOut(duration: 1.8).repeatForever(autoreverses: true)
}

