import SwiftUI
@preconcurrency import MapKit
import Domain

// MARK: - MapContainerView

struct MapContainerView: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = MapViewModel()
    let onDestinationSelected: (Destination) -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            MapViewRepresentable(viewModel: viewModel)
                .ignoresSafeArea(edges: .top)

            if let destination = viewModel.selectedDestination {
                DestinationCard(destination: destination) {
                    onDestinationSelected(destination)
                    dismiss()
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .padding()
            }
        }
        .animation(.spring(duration: 0.3), value: viewModel.selectedDestination)
        .navigationTitle("マップ")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            container.locationRepository.requestAuthorization()
        }
    }
}

// MARK: - DestinationCard

struct DestinationCard: View {
    let destination: Destination
    let onStartNavigation: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text(destination.name)
                .font(.headline)

            Button(action: onStartNavigation) {
                Text("案内開始")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.blue, in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - MapViewRepresentable (UIViewRepresentable)

struct MapViewRepresentable: UIViewRepresentable {
    let viewModel: MapViewModel

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.selectableMapFeatures = [.pointsOfInterest]

        // 現在位置が取得できない場合のフォールバック（東京駅付近）
        let tokyoRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671),
            latitudinalMeters: 2000,
            longitudinalMeters: 2000
        )
        mapView.setRegion(tokyoRegion, animated: false)

        // 現在位置が取得でき次第、そこへ移動する
        mapView.userTrackingMode = .follow

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {}

    static func dismantleUIView(_ uiView: MKMapView, coordinator: Coordinator) {
        uiView.userTrackingMode = .none
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, MKMapViewDelegate {
        let viewModel: MapViewModel

        init(viewModel: MapViewModel) {
            self.viewModel = viewModel
        }

        func mapView(_ mapView: MKMapView, didSelect annotation: any MKAnnotation) {
            guard let feature = annotation as? MKMapFeatureAnnotation else { return }

            let coordinate = feature.coordinate
            let fallbackName = feature.title ?? "不明な場所"
            let request = MKMapItemRequest(mapFeatureAnnotation: feature)
            let vm = viewModel

            Task { @MainActor in
                do {
                    let mapItem = try await request.mapItem
                    let name = mapItem.name ?? fallbackName
                    vm.selectDestination(
                        name: name,
                        latitude: coordinate.latitude,
                        longitude: coordinate.longitude
                    )
                } catch {
                    vm.selectDestination(
                        name: fallbackName,
                        latitude: coordinate.latitude,
                        longitude: coordinate.longitude
                    )
                }
            }

            mapView.deselectAnnotation(annotation, animated: true)
        }
    }
}
