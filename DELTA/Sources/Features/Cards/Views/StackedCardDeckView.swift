import SwiftUI

/// Stacked personal account card presentation matching the approved DELTA reference design.
/// Features overlapping layered cards, smooth spring-based stack transitions,
/// horizontal swipe gesture, tap-to-select, and card expansion.
public struct StackedCardDeckView: View {
    public let cards: [DummyAccountCard]
    @Binding public var selectedIndex: Int
    @State private var dragOffset: CGFloat = 0.0
    @State private var isExpanded: Bool = false

    public init(cards: [DummyAccountCard], selectedIndex: Binding<Int>) {
        self.cards = cards
        self._selectedIndex = selectedIndex
    }

    public var body: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .top) {
                if cards.isEmpty {
                    RoundedRectangle(cornerRadius: DeltaDimensions.radiusAccountCard, style: .continuous)
                        .fill(Color.deltaBgOliveDark)
                        .frame(height: 210)
                        .overlay(
                            Text("No Accounts Available")
                                .font(DeltaTypography.bodySemibold)
                                .foregroundColor(Color.deltaTextMutedDark)
                        )
                } else {
                    // Render cards in reverse order so selected card sits on top
                    ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                        if shouldRenderCard(at: index) {
                            cardView(for: index, card: card)
                        }
                    }
                }
            }
            .frame(height: isExpanded ? 270 : 225)
            .padding(.horizontal, 20)

            // Carousel Dot Indicator
            if cards.count > 1 {
                HStack(spacing: 6) {
                    ForEach(0..<cards.count, id: \.self) { idx in
                        Capsule()
                            .fill(selectedIndex == idx ? Color.deltaSurfaceLime : Color.deltaBorderOlive)
                            .frame(width: selectedIndex == idx ? 16 : 6, height: 4)
                            .animation(DeltaAnimations.tactilePress, value: selectedIndex)
                    }
                }
                .padding(.top, 4)
            }
        }
    }

    private func shouldRenderCard(at index: Int) -> Bool {
        // Render current card and up to 2 cards behind it for depth
        let diff = index - selectedIndex
        return diff >= 0 && diff <= 2
    }

    @ViewBuilder
    private func cardView(for index: Int, card: DummyAccountCard) -> some View {
        let diff = CGFloat(index - selectedIndex)
        let isTopCard = index == selectedIndex

        // Geometry & Depth transformations
        let yOffset: CGFloat = diff == 0 ? 0 : -diff * 14
        let scale: CGFloat = diff == 0 ? 1.0 : (1.0 - diff * 0.045)
        let opacity: Double = diff == 0 ? 1.0 : (1.0 - Double(diff) * 0.18)

        VisualAccountCard(
            card: card,
            isExpanded: isTopCard && isExpanded
        )
        .scaleEffect(scale)
        .offset(x: isTopCard ? dragOffset : 0, y: yOffset)
        .opacity(opacity)
        .zIndex(Double(100 - index))
        .onTapGesture {
            if isTopCard {
                withAnimation(DeltaAnimations.tactilePress) {
                    isExpanded.toggle()
                }
            } else {
                withAnimation(DeltaAnimations.tabTransition) {
                    selectedIndex = index
                }
            }
        }
        .gesture(
            isTopCard ?
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation.width
                }
                .onEnded { value in
                    let threshold: CGFloat = 60
                    withAnimation(DeltaAnimations.tabTransition) {
                        if value.translation.width < -threshold && selectedIndex < cards.count - 1 {
                            selectedIndex += 1
                        } else if value.translation.width > threshold && selectedIndex > 0 {
                            selectedIndex -= 1
                        }
                        dragOffset = 0
                    }
                }
            : nil
        )
        .animation(DeltaAnimations.tactilePress, value: isExpanded)
    }
}
