import SwiftUI
import Domain
import UseCase
import Infra

struct HomeView: View {
    @State var viewModel: HomeViewModel

    var body: some View {
        VStack(spacing: 24) {
            Text(viewModel.destination.name)
                .font(.title)
                .fontWeight(.bold)

            Spacer()

            ArrowView(rotationDegrees: viewModel.arrowRotation)
                .frame(width: 140, height: 200)

            Spacer()

            Text("残り \(viewModel.distanceText)")
                .font(.system(size: 36, weight: .medium, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())

            Spacer()
                .frame(height: 40)
        }
        .padding()
        .navigationTitle("ナビゲーション")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.startNavigation()
        }
        .onDisappear {
            viewModel.stopNavigation()
        }
    }
}

#Preview {
    let mock = LocationRepositoryMock()
    let useCase = NavigationUseCase(locationRepository: mock)
    let notificationManager = LocalNotificationManager()
    let destination = Destination.sampleData
    let viewModel = HomeViewModel(
        destination: destination,
        navigationUseCase: useCase,
        notificationManager: notificationManager
    )
    NavigationStack {
        HomeView(viewModel: viewModel)
    }
}
