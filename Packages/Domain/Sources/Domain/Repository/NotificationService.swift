import Foundation

public protocol NotificationService: Sendable {
    func sendArrivalNotification(destinationName: String) async
}
