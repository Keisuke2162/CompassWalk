import Foundation

public protocol DestinationStore: Sendable {
    func save(_ destination: Destination)
    func load() -> Destination?
    func clear()
}
