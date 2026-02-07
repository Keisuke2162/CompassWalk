import SwiftUI
import Domain

struct ContentView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var homeViewModel: HomeViewModel?
    @State private var showMap = false

    var body: some View {
        NavigationStack {
            Group {
                if let homeViewModel {
                    HomeView(viewModel: homeViewModel, showMap: $showMap)
                }
            }
            .navigationDestination(isPresented: $showMap) {
                MapContainerView { destination in
                    homeViewModel?.setDestination(destination)
                }
            }
        }
        .onAppear {
            if homeViewModel == nil {
                let vm = container.makeHomeViewModel()
                vm.checkSavedDestination()
                homeViewModel = vm
            }
        }
    }
}
