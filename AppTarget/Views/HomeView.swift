import SwiftUI
import Domain
import UseCase

struct HomeView: View {
    @State var viewModel: HomeViewModel
    @Binding var showMap: Bool

    var body: some View {
        VStack(spacing: 24) {
            if let destination = viewModel.destination {
                Text(destination.name)
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
            } else {
                Spacer()

                Image(systemName: "location.circle")
                    .font(.system(size: 80))
                    .foregroundStyle(.secondary)

                Text("目的地を選択してください")
                    .font(.title3)
                    .foregroundStyle(.secondary)

                Spacer()
            }
        }
        .padding()
        .navigationTitle("CompassWalk")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    Text("設定")
                        .navigationTitle("設定")
                } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Button {
                showMap = true
            } label: {
                Image(systemName: "map.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(.blue, in: Circle())
                    .shadow(radius: 4, y: 2)
            }
            .padding(24)
        }
        .alert("案内を再開しますか？", isPresented: $viewModel.showResumeAlert) {
            Button("再開する") {
                viewModel.resumeNavigation()
            }
            Button("キャンセル", role: .cancel) {
                viewModel.declineResume()
            }
        } message: {
            if let pending = viewModel.pendingDestination {
                Text("\(pending.name)への案内を続けますか？")
            }
        }
    }
}

#Preview("未選択") {
    let mock = LocationRepositoryMock()
    let mockNotification = MockNotificationService()
    let mockStore = MockDestinationStore()
    let useCase = NavigationUseCase(locationRepository: mock, notificationService: mockNotification, destinationStore: mockStore)
    let viewModel = HomeViewModel(navigationUseCase: useCase)
    NavigationStack {
        HomeView(viewModel: viewModel, showMap: .constant(false))
    }
}

#Preview("ナビ中") {
    let mock = LocationRepositoryMock()
    let mockNotification = MockNotificationService()
    let mockStore = MockDestinationStore()
    let useCase = NavigationUseCase(locationRepository: mock, notificationService: mockNotification, destinationStore: mockStore)
    let viewModel = HomeViewModel(navigationUseCase: useCase)
    NavigationStack {
        HomeView(viewModel: viewModel, showMap: .constant(false))
            .onAppear {
                viewModel.setDestination(Destination.sampleData)
            }
    }
}
