import SwiftUI

/// Reusable SwiftUI ButtonStyles adhering to DELTA spring motion standards.

// MARK: - Squircle Button Style
public struct SquircleButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.93 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(DeltaAnimations.tactilePress, value: configuration.isPressed)
    }
}

// MARK: - Lime Primary Action Button Style
public struct LimeActionButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .brightness(configuration.isPressed ? -0.05 : 0.0)
            .animation(DeltaAnimations.tactilePress, value: configuration.isPressed)
    }
}

// MARK: - Numeric Keypad Button Style
public struct KeypadButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .opacity(configuration.isPressed ? 0.75 : 1.0)
            .animation(DeltaAnimations.tactilePress, value: configuration.isPressed)
    }
}

// MARK: - Tab Item Button Style
public struct TabItemButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(DeltaAnimations.tactilePress, value: configuration.isPressed)
    }
}

// MARK: - Hold To Send Button Style
public struct HoldToSendButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .brightness(configuration.isPressed ? -0.08 : 0.0)
            .animation(DeltaAnimations.tactilePress, value: configuration.isPressed)
    }
}

