import SwiftUI
import Domain
import UseCase

struct HomeView: View {
    @State var viewModel: HomeViewModel
    @Binding var showMap: Bool
    @State private var showStopAlert = false

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

                Button {
                    showStopAlert = true
                } label: {
                    Text("終了")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 160, height: 44)
                        .background(.red, in: RoundedRectangle(cornerRadius: 12))
                }

                Text("残り \(viewModel.distanceText)")
                    .font(.system(size: 36, weight: .medium, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText())

                Spacer()
                    .frame(height: 40)
            } else {
                Spacer()

                Button {
                    showMap = true
                } label: {
                    VStack(spacing: 12) {
                        Image(systemName: "location.circle")
                            .font(.system(size: 80))
                            .foregroundStyle(.secondary)

                        Text("目的地を選択してください")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }

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
        .alert("案内を終了しますか？", isPresented: $showStopAlert) {
            Button("終了する", role: .destructive) {
                viewModel.stopAndClear()
            }
            Button("キャンセル", role: .cancel) {}
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
