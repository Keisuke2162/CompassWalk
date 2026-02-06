import SwiftUI

@main
struct CompassWalkApp: App {
    private let container = DependencyContainer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(container)
        }
    }
}
