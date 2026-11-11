import SwiftUI

/// The five strict navigation destinations for DELTA.
public enum NavigationDestination: String, CaseIterable, Identifiable {
    case home = "Home"
    case cards = "Cards"
    case scan = "Scan"
    case history = "History"
    case search = "Search"

    public var id: String { rawValue }

    /// SF Symbol icon name for inactive/default tab state
    public var iconName: String {
        switch self {
        case .home:
            return "house"
        case .cards:
            return "creditcard"
        case .scan:
            return "qrcode.viewfinder"
        case .history:
            return "clock.arrow.circlepath"
        case .search:
            return "magnifyingglass"
        }
    }

    /// SF Symbol icon name for selected/active tab state
    public var activeIconName: String {
        switch self {
        case .home:
            return "house.fill"
        case .cards:
            return "creditcard.fill"
        case .scan:
            return "qrcode.viewfinder"
        case .history:
            return "clock.arrow.circlepath"
        case .search:
            return "magnifyingglass"
        }
    }
}

