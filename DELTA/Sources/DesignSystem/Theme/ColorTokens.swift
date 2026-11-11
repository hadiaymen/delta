import SwiftUI

/// DELTA Design System Color Tokens
/// Derived directly from the MONO UI reference image and approved Figma specifications.
public extension Color {
    // MARK: - Canvas & Backgrounds
    /// Foundational deep obsidian canvas background
    static let deltaBgCanvas = Color(hex: "070A06")
    /// Subtle section background
    static let deltaBgSubtle = Color(hex: "0B100A")
    /// Dark forest-olive container for squircle buttons and list tiles
    static let deltaBgOliveDark = Color(hex: "121A0F")
    /// Active / hovered state for dark squircle elements
    static let deltaBgOliveHover = Color(hex: "1A2416")

    // MARK: - Interactive Neon Lime Surfaces
    /// Primary electric neon lime for hero cards and floating navigation dock
    static let deltaSurfaceLime = Color(hex: "CCFF00")
    /// High-luminance bright lime accent
    static let deltaSurfaceLimeBright = Color(hex: "C4F822")
    /// Muted secondary lime
    static let deltaSurfaceLimeMuted = Color(hex: "A6D908")

    // MARK: - Stacked Card Gradients
    /// Card gradient top stop (chartreuse lime)
    static let deltaCardGradStart = Color(hex: "7DA815")
    /// Card gradient bottom stop (deep forest olive)
    static let deltaCardGradEnd = Color(hex: "39500A")
    /// Background stacked card peek tone
    static let deltaCardPeek = Color(hex: "1E2B08")

    // MARK: - Typography & Glyphs
    /// Primary dark text rendered on top of neon lime surfaces
    static let deltaTextOnLime = Color(hex: "080C08")
    /// Muted secondary text on neon lime surfaces
    static let deltaTextMutedLime = Color(hex: "2B3523")
    /// Primary high-contrast light text rendered on dark canvas
    static let deltaTextOnDark = Color(hex: "F3F6F0")
    /// Muted secondary text for subtitles, TrxIDs, timestamps on dark canvas
    static let deltaTextMutedDark = Color(hex: "8E998B")

    // MARK: - Semantic Expense Accents
    /// Negative outflow / expense indicator
    static let deltaExpenseRed = Color(hex: "FF5C5C")
    /// Positive inflow / refund indicator
    static let deltaIncomeGreen = Color(hex: "CCFF00")

    // MARK: - Dividers & Borders
    /// Subtle hairline border for dark containers
    static let deltaBorderOlive = Color(hex: "1B2616")
    /// Subtle lime stroke highlight
    static let deltaBorderLimeSubtle = Color(hex: "CCFF00").opacity(0.18)
}

// MARK: - Hex Color Initializer
public extension Color {
    init(hex: String) {
        let cleanHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch cleanHex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0,
            opacity: Double(a) / 255.0
        )
    }
}

