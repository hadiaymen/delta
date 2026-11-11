import SwiftUI

/// Profile header bar featuring Hadi Aymen, notification shortcut with badge, and milestone trigger.
public struct HomeHeaderView: View {
    @ObservedObject public var service: ExpenseTrackingService
    public let onNotificationTapped: () -> Void
    public let onTrophyTapped: () -> Void

    public init(
        service: ExpenseTrackingService,
        onNotificationTapped: @escaping () -> Void,
        onTrophyTapped: @escaping () -> Void
    ) {
        self.service = service
        self.onNotificationTapped = onNotificationTapped
        self.onTrophyTapped = onTrophyTapped
    }

    public var body: some View {
        HStack(spacing: 12) {
            // Profile Avatar with Initials "HA"
            ZStack {
                Circle()
                    .fill(Color(hex: "233215"))
                    .frame(width: DeltaDimensions.sizeAvatar, height: DeltaDimensions.sizeAvatar)
                    .overlay(
                        Circle().stroke(Color.deltaSurfaceLime.opacity(0.35), lineWidth: 1.5)
                    )

                Text("HA")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(Color.deltaSurfaceLime)
            }

            // User Display Name: Hadi Aymen & Handle
            VStack(alignment: .leading, spacing: 2) {
                Text(service.userDisplayName)
                    .font(DeltaTypography.bodySemibold)
                    .foregroundColor(Color.deltaTextOnDark)

                Text(service.userHandle)
                    .font(DeltaTypography.captionMeta)
                    .foregroundColor(Color.deltaTextMutedDark)
            }

            Spacer()

            // Milestone / Trophy Squircle Button
            SquircleButton(
                iconName: DeltaIcons.achievementTrophy,
                size: DeltaDimensions.sizeTopBarButton,
                style: .dark,
                action: onTrophyTapped
            )

            // Notification Shortcut with Badge
            ZStack(alignment: .topTrailing) {
                SquircleButton(
                    iconName: DeltaIcons.notificationBell,
                    size: DeltaDimensions.sizeTopBarButton,
                    style: .dark,
                    action: onNotificationTapped
                )

                // Unread Indicator Pill
                if service.unreadNotificationCount > 0 {
                    Circle()
                        .fill(Color.deltaSurfaceLime)
                        .frame(width: 9, height: 9)
                        .overlay(
                            Circle().stroke(Color.deltaBgCanvas, lineWidth: 1.5)
                        )
                        .offset(x: -4, y: 4)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }
}
