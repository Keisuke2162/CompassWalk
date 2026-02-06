import Foundation
import UserNotifications

public final class LocalNotificationManager: Sendable {

    public init() {}

    /// 通知の許可をリクエストする
    public func requestAuthorization() async {
        try? await UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        )
    }

    /// 目的地に近づいた（20m以内）際のローカル通知を即時送信する
    public func sendArrivalNotification(destinationName: String) async {
        let content = UNMutableNotificationContent()
        content.title = "まもなく到着"
        content.body = "\(destinationName)まであと少しです！"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        try? await UNUserNotificationCenter.current().add(request)
    }
}
