import SwiftUI

/// Root View managing tab switching across the 5 main destinations.
/// Integrates the custom neon lime bottom navigation dock and respects Dynamic Island / safe areas.
public struct RootView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @State private var selectedTab: NavigationDestination = .home
    @State private var isScanActive: Bool = false

    public init() {}

    public var body: some View {
        ZStack(alignment: .bottom) {
            Color.deltaBgCanvas.ignoresSafeArea()

            // Main Destination Switcher
            Group {
                switch selectedTab {
                case .home:
                    HomeView(service: environment.expenseService)
                case .cards:
                    CardsView(
                        service: environment.expenseService,
                        onBackTapped: {
                            selectedTab = .home
                        }
                    )
                case .scan:
                    ScanView(service: environment.expenseService)
                case .history:
                    HistoryView(service: environment.expenseService)
                case .search:
                    SearchView(service: environment.expenseService)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom Floating Neon Lime Tab Bar
            DeltaTabBar(
                selectedTab: $selectedTab,
                onScanPressed: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selectedTab = .scan
                    }
                }
            )
            .padding(.bottom, 6)
        }
        .preferredColorScheme(.dark)
    }
}

