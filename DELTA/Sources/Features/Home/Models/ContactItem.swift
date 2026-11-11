import Foundation

/// Represents a frequent payee, personal contact, or favourite person.
public struct ContactItem: Identifiable, Hashable, Codable {
    public let id: String
    public let name: String
    public let maskedIdentifier: String
    public let avatarSystemName: String
    public let initials: String

    public init(
        id: String = UUID().uuidString,
        name: String,
        maskedIdentifier: String,
        avatarSystemName: String = "person.fill",
        initials: String
    ) {
        self.id = id
        self.name = name
        self.maskedIdentifier = maskedIdentifier
        self.avatarSystemName = avatarSystemName
        self.initials = initials
    }
}
