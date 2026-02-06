import Foundation
import CoreLocation
import Domain

public final class LocationRepositoryImpl: NSObject, LocationRepository, CLLocationManagerDelegate, @unchecked Sendable {
    private let locationManager: CLLocationManager
    private var locationContinuation: AsyncStream<LocationData>.Continuation?

    private var latestCoordinate: Coordinate?
    private var latestHeading: Double = 0
    private var latestSpeed: Double = 0
    private var latestCourse: Double = 0

    public override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1
        locationManager.headingFilter = 1
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
    }

    // MARK: - LocationRepository

    public func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    public func startUpdating() {
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }

    public func stopUpdating() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
        locationContinuation?.finish()
    }

    public func observeLocationData() -> AsyncStream<LocationData> {
        locationContinuation?.finish()
        return AsyncStream { continuation in
            self.locationContinuation = continuation
            continuation.onTermination = { [weak self] _ in
                self?.locationContinuation = nil
            }
        }
    }

    // MARK: - CLLocationManagerDelegate

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        latestCoordinate = Coordinate(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        latestSpeed = max(location.speed, 0)
        latestCourse = location.course >= 0 ? location.course : 0

        // 方角の補正ロジック:
        // 基本はデバイスのコンパス（Magnetic Heading）を使用する。
        // 移動中（一定以上の速度がある場合）は移動ベクトルの方向（course）を用いた
        // 補正により、コンパスの誤差を軽減できる。
        if latestSpeed > 1.0 {
            // TODO: 進行方向(B)による補正ロジック
            // latestHeading を latestCourse で補正する枠組み
            // 例: ローパスフィルタでコンパス値と進行方向を混合
            // let alpha = 0.3
            // latestHeading = alpha * latestCourse + (1 - alpha) * latestHeading
        }

        emitLocationData()
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        latestHeading = newHeading.magneticHeading
        emitLocationData()
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // 位置情報取得エラー（権限拒否、圏外など）はログのみ
    }

    // MARK: - Private

    private func emitLocationData() {
        guard let coordinate = latestCoordinate else { return }
        let data = LocationData(
            coordinate: coordinate,
            magneticHeading: latestHeading,
            speed: latestSpeed,
            course: latestCourse
        )
        locationContinuation?.yield(data)
    }
}
