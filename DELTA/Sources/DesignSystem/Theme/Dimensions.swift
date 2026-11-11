import SwiftUI

/// DELTA Design System Geometry, Spacing & Spatial Dimensions
public struct DeltaDimensions {
    // MARK: - Spacing Scale
    public struct Spacing {
        public static let xxs: CGFloat = 2.0
        public static let xs: CGFloat = 4.0
        public static let sm: CGFloat = 8.0
        public static let md: CGFloat = 12.0
        public static let base: CGFloat = 16.0
        public static let lg: CGFloat = 20.0
        public static let xl: CGFloat = 24.0
        public static let xxl: CGFloat = 32.0
        public static let xxxl: CGFloat = 40.0
    }

    // MARK: - Corner Radii Scale
    public struct Radius {
        public static let sm: CGFloat = 8.0
        public static let md: CGFloat = 12.0
        public static let tile: CGFloat = 16.0
        public static let squircle: CGFloat = 18.0
        public static let card: CGFloat = 24.0
        public static let heroSurface: CGFloat = 32.0
        public static let navDock: CGFloat = 38.0
        public static let full: CGFloat = 9999.0
    }

    // MARK: - Corner Radii Constants (Direct Access)
    public static let radiusHeroSurface: CGFloat = Radius.heroSurface
    public static let radiusAccountCard: CGFloat = Radius.card
    public static let radiusSquircleButton: CGFloat = Radius.squircle
    public static let radiusSquircleTile: CGFloat = Radius.tile
    public static let radiusNavDock: CGFloat = Radius.navDock
    public static let radiusFull: CGFloat = Radius.full

    // MARK: - Component Specific Sizes
    public static let sizeTopBarButton: CGFloat = 42.0
    public static let sizeActionButton: CGFloat = 58.0
    public static let sizeScanCenterButton: CGFloat = 58.0
    public static let sizeScanCenterHalo: CGFloat = 66.0
    public static let sizeAvatar: CGFloat = 42.0
    public static let heightCard: CGFloat = 215.0
    public static let heightKeypadKey: CGFloat = 50.0
}
