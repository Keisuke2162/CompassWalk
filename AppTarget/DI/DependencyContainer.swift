import Foundation
import Domain
import Infra
import UseCase

@Observable
@MainActor
final class DependencyContainer {
    let locationRepository: any LocationRepository
    let navigationUseCase: NavigationUseCase

    init() {
        let repo = LocationRepositoryImpl()
        let notificationManager = LocalNotificationManager()
        let destinationStore = UserDefaultsDestinationStore()
        self.locationRepository = repo
        self.navigationUseCase = NavigationUseCase(
            locationRepository: repo,
            notificationService: notificationManager,
            destinationStore: destinationStore
        )
    }

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(navigationUseCase: navigationUseCase)
    }
}
