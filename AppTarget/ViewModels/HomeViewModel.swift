import Foundation
import Domain
import UseCase

@Observable
@MainActor
final class HomeViewModel {
    private(set) var navigationStatus: NavigationStatus?
    private(set) var isNavigating = false
    private(set) var destination: Destination?
    var showResumeAlert = false

    private let navigationUseCase: NavigationUseCase
    private var navigationTask: Task<Void, Never>?
    private(set) var pendingDestination: Destination?

    init(navigationUseCase: NavigationUseCase) {
        self.navigationUseCase = navigationUseCase
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

    func checkSavedDestination() {
        guard let saved = navigationUseCase.loadSavedDestination() else { return }
        pendingDestination = saved
        showResumeAlert = true
    }

    func resumeNavigation() {
        guard let pending = pendingDestination else { return }
        pendingDestination = nil
        destination = pending
        startNavigation()
    }

    func declineResume() {
        pendingDestination = nil
        navigationUseCase.clearSavedDestination()
    }

    func setDestination(_ destination: Destination) {
        stopNavigation()
        self.destination = destination
        navigationUseCase.saveDestination(destination)
        startNavigation()
    }

    func startNavigation() {
        guard let destination, !isNavigating else { return }
        isNavigating = true

        navigationTask = Task {
            for await status in navigationUseCase.observe(destination: destination) {
                self.navigationStatus = status
            }
        }
    }

    func stopAndClear() {
        stopNavigation()
        destination = nil
        navigationUseCase.clearSavedDestination()
    }

    func stopNavigation() {
        navigationTask?.cancel()
        navigationTask = nil
        isNavigating = false
        navigationStatus = nil
    }
}
