import SwiftUI

/// Horizontally scrollable Favourite People carousel with View All navigation.
public struct FavoriteContactsSection: View {
    public let people: [ContactItem]
    public let onAddPerson: () -> Void
    public let onSelectPerson: (ContactItem) -> Void
    public let onViewAll: () -> Void

    public init(
        people: [ContactItem],
        onAddPerson: @escaping () -> Void,
        onSelectPerson: @escaping (ContactItem) -> Void,
        onViewAll: @escaping () -> Void
    ) {
        self.people = people
        self.onAddPerson = onAddPerson
        self.onSelectPerson = onSelectPerson
        self.onViewAll = onViewAll
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header Row with "Favourite People" & "View all >"
            HStack {
                Text("Favourite People")
                    .font(DeltaTypography.sectionHeader)
                    .foregroundColor(Color.deltaTextOnDark)

                Spacer()

                Button(action: onViewAll) {
                    Text("View all >")
                        .font(DeltaTypography.actionLabel)
                        .foregroundColor(Color.deltaTextMutedDark)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 20)

            // Horizontal Scrollable People
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Add Squircle Button
                    Button(action: onAddPerson) {
                        ZStack {
                            RoundedRectangle(cornerRadius: DeltaDimensions.radiusSquircleTile, style: .continuous)
                                .fill(Color.deltaBgOliveDark)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    RoundedRectangle(cornerRadius: DeltaDimensions.radiusSquircleTile, style: .continuous)
                                        .stroke(Color.deltaBorderOlive, lineWidth: 1)
                                )

                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color.deltaTextOnDark)
                        }
                    }
                    .buttonStyle(SquircleButtonStyle())

                    // People Chips
                    ForEach(people) { person in
                        ContactAvatarChip(
                            name: person.name,
                            maskedIdentifier: person.maskedIdentifier,
                            initials: person.initials,
                            action: {
                                onSelectPerson(person)
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}
