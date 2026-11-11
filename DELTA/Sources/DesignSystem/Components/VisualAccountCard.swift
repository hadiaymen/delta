import SwiftUI

/// Visual dummy account card component matching the approved DELTA reference design.
/// STRICT GUARDRAIL: Does NOT display usable payment card numbers, CVVs, or expiration dates.
public struct VisualAccountCard: View {
    private let card: DummyAccountCard
    private let isExpanded: Bool

    public init(card: DummyAccountCard, isExpanded: Bool = false) {
        self.card = card
        self.isExpanded = isExpanded
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            // Card Gradient Background with Border & Shadow
            RoundedRectangle(cornerRadius: DeltaDimensions.radiusAccountCard, style: .continuous)
                .fill(cardGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: DeltaDimensions.radiusAccountCard, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                .deltaShadow(DeltaShadows.cardElevation)

            // DELTA Watermark Branding
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("DELTA")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundColor(Color.black.opacity(0.08))
                        .padding(.trailing, 24)
                        .padding(.bottom, 16)
                }
            }

            // Card Face Content
            VStack(alignment: .leading, spacing: 0) {
                // Top Row: Cardholder Name & Brand Tag
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(card.cardholderName)
                            .font(DeltaTypography.cardTitle)
                            .foregroundColor(Color.deltaTextOnDark)

                        Text(card.accountName)
                            .font(.system(size: 11, weight: .bold, design: .default))
                            .tracking(0.6)
                            .foregroundColor(Color(hex: "D7FF68"))
                    }

                    Spacer()

                    // Visual Account Badge
                    HStack(spacing: 4) {
                        if card.isLocked {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(Color.deltaExpenseRed)
                        }

                        Text("DELTA")
                            .font(.system(size: 15, weight: .black, design: .rounded))
                            .foregroundColor(Color.deltaTextOnDark)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.25))
                    )
                }

                Spacer()

                // Center: Balance Display
                VStack(alignment: .leading, spacing: 2) {
                    Text("AVAILABLE BALANCE")
                        .font(.system(size: 9, weight: .bold, design: .default))
                        .tracking(0.8)
                        .foregroundColor(Color(hex: "C2E870").opacity(0.85))

                    Text(card.formattedBalance)
                        .font(.system(size: isExpanded ? 32 : 26, weight: .bold, design: .default))
                        .foregroundColor(Color.deltaTextOnDark)
                }

                Spacer()

                // Bottom Row: Contactless Wave & Dummy Masked Identifier
                HStack(alignment: .bottom) {
                    HStack(spacing: 6) {
                        Image(systemName: DeltaIcons.contactlessWave)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(hex: "D7FF68"))

                        Text(card.accountCategory)
                            .font(DeltaTypography.captionMeta)
                            .foregroundColor(Color(hex: "D7FF68"))
                    }

                    Spacer()

                    // Dummy Visual Identifier (NOT a usable card number or PAN)
                    Text(card.accountIdentifier)
                        .font(DeltaTypography.cardNumber)
                        .foregroundColor(Color.deltaTextOnDark)
                }

                // Expanded Section: Details & Account Stats
                if isExpanded {
                    Divider()
                        .background(Color.white.opacity(0.2))
                        .padding(.vertical, 12)

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("INITIAL BUDGET")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(Color(hex: "C2E870"))
                            Text("$\(card.initialBalance)")
                                .font(DeltaTypography.captionMeta)
                                .foregroundColor(Color.deltaTextOnDark)
                        }

                        Spacer()

                        Text(card.isPrimary ? "PRIMARY ACCOUNT" : "ENVELOPE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color.deltaTextOnLime)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Color.deltaSurfaceLime.opacity(0.2)))
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(22)
        }
        .frame(height: isExpanded ? 260 : 210)
        .animation(DeltaAnimations.tactilePress, value: isExpanded)
    }

    private var cardGradient: LinearGradient {
        switch card.theme {
        case .chartreuseLime:
            return DeltaGradients.cardSurface
        case .forestOlive:
            return DeltaGradients.cardPeekSurface
        case .obsidianDark:
            return LinearGradient(
                colors: [Color(hex: "1A2514"), Color(hex: "0D140A"), Color(hex: "070B05")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .electricLime:
            return LinearGradient(
                colors: [Color(hex: "9FC910"), Color(hex: "759A08"), Color(hex: "3F5605")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}
