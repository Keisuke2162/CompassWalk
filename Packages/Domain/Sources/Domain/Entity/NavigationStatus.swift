import Foundation

public struct NavigationStatus: Sendable, Equatable {
    /// 目的地までの残り距離（メートル）
    public let distance: Double
    /// 現在地から目的地への方位角（北を0°、時計回りに0〜360°）
    public let bearing: Double
    /// デバイスの磁気コンパスが示す向き（北を0°、時計回りに0〜360°）
    public let deviceHeading: Double
    /// 移動速度（m/s）
    public let speed: Double
    /// 移動方向（北を0°、時計回りに0〜360°）
    public let course: Double

    public init(distance: Double, bearing: Double, deviceHeading: Double, speed: Double, course: Double) {
        self.distance = distance
        self.bearing = bearing
        self.deviceHeading = deviceHeading
        self.speed = speed
        self.course = course
    }

    /// 矢印の回転角度（bearing - deviceHeading を -180〜180° に正規化）
    public var arrowRotation: Double {
        var rotation = (bearing - deviceHeading).truncatingRemainder(dividingBy: 360)
        if rotation > 180 { rotation -= 360 }
        if rotation < -180 { rotation += 360 }
        return rotation
    }
}
