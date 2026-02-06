import Foundation
import Domain

@Observable
@MainActor
final class MapViewModel {
    var selectedDestination: Destination?

    func selectDestination(name: String, latitude: Double, longitude: Double) {
        selectedDestination = Destination(
            name: name,
            coordinate: Coordinate(latitude: latitude, longitude: longitude)
        )
    }

    func clearSelection() {
        selectedDestination = nil
    }
}
