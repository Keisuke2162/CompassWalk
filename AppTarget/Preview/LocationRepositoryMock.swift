import Foundation
import Domain
import UseCase
import Infra

/// Preview 用のモックリポジトリ。
/// 目的地（東京タワー）に向かって少しずつ近づきながら、ヘディングが回転する様子をシミュレートする。
final class LocationRepositoryMock: LocationRepository, @unchecked Sendable {

    func requestAuthorization() {}
    func startUpdating() {}
    func stopUpdating() {}

    func observeLocationData() -> AsyncStream<LocationData> {
        AsyncStream { continuation in
            let task = Task {
                // 東京タワーの南西約200m地点からスタート
                let destinationLat = 35.6586
                let destinationLon = 139.7454
                var lat = 35.6570
                var lon = 139.7440
                var heading: Double = 0

                while !Task.isCancelled {
                    // 目的地に向かって徐々に移動
                    lat += (destinationLat - lat) * 0.003
                    lon += (destinationLon - lon) * 0.003

                    // コンパスが回転する様子をシミュレート
                    heading = (heading + 2).truncatingRemainder(dividingBy: 360)

                    let data = LocationData(
                        coordinate: Coordinate(latitude: lat, longitude: lon),
                        magneticHeading: heading,
                        speed: 1.4,
                        course: 45
                    )
                    continuation.yield(data)

                    try? await Task.sleep(for: .milliseconds(100))
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
