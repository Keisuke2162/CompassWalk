import Foundation
import Domain
import Infra
import UseCase

@Observable
@MainActor
final class DependencyContainer {
    let locationRepository: any LocationRepository
    let navigationUseCase: NavigationUseCase
    let notificationManager: LocalNotificationManager

    init() {
        let repo = LocationRepositoryImpl()
        self.locationRepository = repo
        self.navigationUseCase = NavigationUseCase(locationRepository: repo)
        self.notificationManager = LocalNotificationManager()
    }

    func makeHomeViewModel(destination: Destination) -> HomeViewModel {
        HomeViewModel(
            destination: destination,
            navigationUseCase: navigationUseCase,
            notificationManager: notificationManager
        )
    }
}
