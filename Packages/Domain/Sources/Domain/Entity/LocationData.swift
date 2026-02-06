import Foundation

public struct LocationData: Sendable, Equatable {
    public let coordinate: Coordinate
    public let magneticHeading: Double
    public let speed: Double
    public let course: Double

    public init(coordinate: Coordinate, magneticHeading: Double, speed: Double, course: Double) {
        self.coordinate = coordinate
        self.magneticHeading = magneticHeading
        self.speed = speed
        self.course = course
    }
}
