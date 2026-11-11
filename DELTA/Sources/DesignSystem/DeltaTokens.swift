import SwiftUI

/// DELTA Centralized Design Tokens Umbrella
/// Direct access point to all design system token subsystems.
public struct DeltaTokens {
    public typealias Colors = Color
    public typealias Typography = DeltaTypography
    public typealias Dimensions = DeltaDimensions
    public typealias Spacing = DeltaDimensions.Spacing
    public typealias Radius = DeltaDimensions.Radius
    public typealias Gradients = DeltaGradients
    public typealias Shadows = DeltaShadows
    public typealias Icons = DeltaIcons
    public typealias Animations = DeltaAnimations
}

