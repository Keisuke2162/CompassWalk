import SwiftUI
import Domain

struct ContentView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            MapContainerView(navigationPath: $navigationPath)
                .navigationDestination(for: Destination.self) { destination in
                    HomeView(viewModel: container.makeHomeViewModel(destination: destination))
                }
        }
    }
}
