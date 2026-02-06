import Foundation

public protocol LocationRepository: Sendable {
    func requestAuthorization()
    func startUpdating()
    func stopUpdating()
    func observeLocationData() -> AsyncStream<LocationData>
}
