import Foundation

public struct Destination: Sendable, Identifiable, Hashable, Equatable, Codable {
    public let id: UUID
    public let name: String
    public let coordinate: Coordinate

    public init(id: UUID = UUID(), name: String, coordinate: Coordinate) {
        self.id = id
        self.name = name
        self.coordinate = coordinate
    }

    public static let sampleData = Destination(
        name: "東京タワー",
        coordinate: Coordinate(latitude: 35.6586, longitude: 139.7454)
    )
}
