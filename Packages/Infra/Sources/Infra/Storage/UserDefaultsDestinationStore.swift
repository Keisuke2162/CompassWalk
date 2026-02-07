import Foundation
import Domain

public final class UserDefaultsDestinationStore: DestinationStore, @unchecked Sendable {
    private let key = "com.compasswalk.activeDestination"
    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func save(_ destination: Destination) {
        guard let data = try? JSONEncoder().encode(destination) else { return }
        defaults.set(data, forKey: key)
    }

    public func load() -> Destination? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(Destination.self, from: data)
    }

    public func clear() {
        defaults.removeObject(forKey: key)
    }
}
