import SwiftUI

/// DELTA Design System Typography Scale
/// Provides typographic styles matching the modern, high-contrast fintech aesthetic.
public struct DeltaTypography {
    /// Hero Currency Display: 38pt, Bold, tight tracking with LargeTitle scaling
    public static let displayHero = Font.system(size: 38, weight: .bold, design: .default)

    /// Large Header: 24pt, SemiBold with Title scaling
    public static let titleLarge = Font.system(size: 24, weight: .semibold, design: .default)

    /// Standard Screen Title: 18pt, SemiBold with Headline scaling
    public static let screenTitle = Font.system(size: 18, weight: .semibold, design: .default)

    /// Section Header: 16pt, SemiBold with Subheadline scaling
    public static let sectionHeader = Font.system(size: 16, weight: .semibold, design: .default)

    /// Cardholder Name: 16pt, Bold with Headline scaling
    public static let cardTitle = Font.system(size: 16, weight: .bold, design: .default)

    /// Card Masked Account Number: 15pt, Monospaced SemiBold
    public static let cardNumber = Font.system(size: 15, weight: .semibold, design: .monospaced)

    /// Transaction Title / Button Title: 14pt, SemiBold with Body scaling
    public static let bodySemibold = Font.system(size: 14, weight: .semibold, design: .default)

    /// Standard Body: 14pt, Regular with Body scaling
    public static let bodyRegular = Font.system(size: 14, weight: .regular, design: .default)

    /// Micro Metadata (TrxIDs, Dates, Subtitles): 11pt, Regular with Caption2 scaling
    public static let captionMeta = Font.system(size: 11, weight: .regular, design: .monospaced)

    /// Small Action Label: 12pt, Medium with Caption scaling
    public static let actionLabel = Font.system(size: 12, weight: .medium, design: .default)

    /// Keypad Digits: 24pt, SemiBold with Title scaling
    public static let keypadDigit = Font.system(size: 24, weight: .semibold, design: .default)

    /// Compact Pill Badge: 11pt, SemiBold with Caption2 scaling
    public static let pillBadge = Font.system(size: 11, weight: .semibold, design: .default)
}

