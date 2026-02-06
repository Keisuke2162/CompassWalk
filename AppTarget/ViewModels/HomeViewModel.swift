import Foundation
import Domain
import UseCase
import Infra

@Observable
@MainActor
final class HomeViewModel {
    private(set) var navigationStatus: NavigationStatus?
    private(set) var isNavigating = false

    let destination: Destination

    private let navigationUseCase: NavigationUseCase
    private let notificationManager: LocalNotificationManager
    private var navigationTask: Task<Void, Never>?
    private var hasNotifiedArrival = false

    init(
        destination: Destination,
        navigationUseCase: NavigationUseCase,
        notificationManager: LocalNotificationManager
    ) {
        self.destination = destination
        self.navigationUseCase = navigationUseCase
        self.notificationManager = notificationManager
    }

    var arrowRotation: Double {
        navigationStatus?.arrowRotation ?? 0
    }

    var distanceText: String {
        guard let status = navigationStatus else { return "---m" }
        if status.distance >= 1000 {
            return String(format: "%.1fkm", status.distance / 1000)
        }
        return String(format: "%.0fm", status.distance)
    }

    func startNavigation() {
        guard !isNavigating else { return }
        isNavigating = true
        hasNotifiedArrival = false

        navigationTask = Task {
            for await status in navigationUseCase.observe(destination: destination) {
                self.navigationStatus = status

                if status.distance < 20, !hasNotifiedArrival {
                    hasNotifiedArrival = true
                    await notificationManager.sendArrivalNotification(
                        destinationName: destination.name
                    )
                }
            }
        }
    }

    func stopNavigation() {
        navigationTask?.cancel()
        navigationTask = nil
        isNavigating = false
    }
}
