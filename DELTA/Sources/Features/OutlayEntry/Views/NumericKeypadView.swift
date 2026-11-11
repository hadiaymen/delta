import SwiftUI

/// 3x4 Squircle Numeric Keypad matching the reference outlay screen.
public struct NumericKeypadView: View {
    public let onKeyPress: (String) -> Void

    private let keys: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["↩", "0", "x"]
    ]

    public init(onKeyPress: @escaping (String) -> Void) {
        self.onKeyPress = onKeyPress
    }

    public var body: some View {
        VStack(spacing: 10) {
            ForEach(keys, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { key in
                        Button(action: {
                            onKeyPress(key)
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: DeltaDimensions.radiusSquircleButton, style: .continuous)
                                    .fill(Color.deltaBgOliveDark)
                                    .frame(height: 50)
                                    .frame(maxWidth: .infinity)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DeltaDimensions.radiusSquircleButton, style: .continuous)
                                            .stroke(Color.deltaBorderOlive, lineWidth: 1)
                                    )

                                if key == "x" {
                                    Image(systemName: "delete.left")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(Color.deltaTextOnDark)
                                } else if key == "↩" {
                                    Image(systemName: "arrow.uturn.backward")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(Color.deltaTextOnDark)
                                } else {
                                    Text(key)
                                        .font(DeltaTypography.keypadDigit)
                                        .foregroundColor(Color.deltaTextOnDark)
                                }
                            }
                        }
                        .buttonStyle(KeypadPressStyle())
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

private struct KeypadPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

