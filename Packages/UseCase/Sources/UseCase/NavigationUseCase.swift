import Foundation
import Domain

public final class NavigationUseCase: Sendable {
    private let locationRepository: any LocationRepository

    public init(locationRepository: any LocationRepository) {
        self.locationRepository = locationRepository
    }

    /// 目的地に対するナビゲーション情報をリアルタイムに計算し、AsyncStream で返す。
    /// ストリーム開始時に位置情報の取得を開始し、ストリーム終了時に停止する。
    public func observe(destination: Destination) -> AsyncStream<NavigationStatus> {
        let repo = locationRepository
        repo.startUpdating()

        return AsyncStream { continuation in
            let task = Task {
                for await data in repo.observeLocationData() {
                    let distance = Self.calculateDistance(
                        from: data.coordinate,
                        to: destination.coordinate
                    )
                    let bearing = Self.calculateBearing(
                        from: data.coordinate,
                        to: destination.coordinate
                    )

                    let status = NavigationStatus(
                        distance: distance,
                        bearing: bearing,
                        deviceHeading: data.magneticHeading,
                        speed: data.speed,
                        course: data.course
                    )
                    continuation.yield(status)
                }
                continuation.finish()
            }

            continuation.onTermination = { _ in
                task.cancel()
                repo.stopUpdating()
            }
        }
    }

    // MARK: - Haversine Distance

    /// 2点間の距離をメートルで計算（Haversine公式）
    private static func calculateDistance(from: Coordinate, to: Coordinate) -> Double {
        let earthRadius: Double = 6_371_000 // メートル

        let lat1 = from.latitude * .pi / 180
        let lat2 = to.latitude * .pi / 180
        let deltaLat = (to.latitude - from.latitude) * .pi / 180
        let deltaLon = (to.longitude - from.longitude) * .pi / 180

        let a = sin(deltaLat / 2) * sin(deltaLat / 2)
            + cos(lat1) * cos(lat2) * sin(deltaLon / 2) * sin(deltaLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))

        return earthRadius * c
    }

    // MARK: - Bearing

    /// 現在地から目的地への方位角を度数で計算（北=0°、時計回り）
    private static func calculateBearing(from: Coordinate, to: Coordinate) -> Double {
        let lat1 = from.latitude * .pi / 180
        let lat2 = to.latitude * .pi / 180
        let deltaLon = (to.longitude - from.longitude) * .pi / 180

        let y = sin(deltaLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon)

        let bearing = atan2(y, x) * 180 / .pi
        return (bearing + 360).truncatingRemainder(dividingBy: 360)
    }
}
