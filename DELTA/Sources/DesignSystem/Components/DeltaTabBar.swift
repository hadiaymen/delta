import SwiftUI

/// Custom neon lime bottom navigation dock matching the reference design.
/// Features 5 strict destinations with an elevated, prominent central Scan button.
public struct DeltaTabBar: View {
    @Binding public var selectedTab: NavigationDestination
    public let onScanPressed: () -> Void

    public init(
        selectedTab: Binding<NavigationDestination>,
        onScanPressed: @escaping () -> Void
    ) {
        self._selectedTab = selectedTab
        self.onScanPressed = onScanPressed
    }

    public var body: some View {
        ZStack(alignment: .top) {
            // Main Neon Lime Dock
            HStack(spacing: 0) {
                // Left Tabs: Home & Cards
                tabButton(destination: .home)
                tabButton(destination: .cards)

                // Spacer reservation for elevated central Scan trigger
                Spacer()
                    .frame(width: 72)

                // Right Tabs: History & Search
                tabButton(destination: .history)
                tabButton(destination: .search)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 24)
            .background(
                Color.deltaSurfaceLime
            )
            .clipShape(
                RoundedRectangle(cornerRadius: DeltaDimensions.radiusNavDock, style: .continuous)
            )
            .shadow(color: Color.black.opacity(0.4), radius: 16, x: 0, y: -4)

            // Prominent Elevated Central Scan Button
            Button(action: {
                onScanPressed()
            }) {
                ZStack {
                    // Outer glow / halo
                    Circle()
                        .fill(Color.deltaSurfaceLime)
                        .frame(width: 66, height: 66)
                        .shadow(color: Color.deltaSurfaceLime.opacity(0.45), radius: 10, x: 0, y: 2)

                    // Inner Dark Core
                    Circle()
                        .fill(Color.deltaBgOliveDark)
                        .frame(width: 54, height: 54)
                        .overlay(
                            Circle()
                                .stroke(Color.deltaBorderOlive, lineWidth: 1.5)
                        )

                    // QR Scanner Icon in Neon Lime
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.deltaSurfaceLime)
                }
            }
            .buttonStyle(ScanCenterButtonStyle())
            .offset(y: -22) // Visually raised above the dock
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func tabButton(destination: NavigationDestination) -> some View {
        let isSelected = selectedTab == destination

        Button(action: {
            selectedTab = destination
        }) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? destination.activeIconName : destination.iconName)
                    .font(.system(size: 20, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? Color.deltaTextOnLime : Color.deltaTextMutedLime.opacity(0.85))

                Text(destination.rawValue)
                    .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? Color.deltaTextOnLime : Color.deltaTextMutedLime.opacity(0.85))
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(TabPressStyle())
    }
}

// MARK: - Scan Center Button Style
private struct ScanCenterButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Tab Item Press Style
private struct TabPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

