import SwiftUI
import MapKit

struct LocationFieldRow: View {
    @Binding var value: String
    @StateObject private var locationManager = LocationManager()
    @State private var showLocationPicker = false
    @State private var position = MapCameraPosition.region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.9042, longitude: 116.4074),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    ))
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedPlace: MKMapItem?
    @State private var searchText = ""
    @State private var isInitialLoad = true

    var body: some View {
        VStack {
            if !value.isEmpty, let coordinate = parseCoordinate(from: value) {
                // 显示选中的位置地图
                Map(position: .constant(MapCameraPosition.region(MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )))) {
                    Marker(selectedPlace?.name ?? "所选位置", coordinate: coordinate)
                }
                .frame(height: 200)
                .cornerRadius(8)
                .onTapGesture {
                    showLocationPicker = true
                }
            } else {
                // 显示选择位置按钮
                HStack {
                    Text("选择位置")
                        .foregroundColor(.secondary)
                    Spacer()
                    Image(systemName: "location.fill")
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .onTapGesture {
                    showLocationPicker = true
                }
            }
        }
        .sheet(isPresented: $showLocationPicker) {
            NavigationView {
                VStack {
                    // 搜索栏
                    TextField("搜索地点", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .onChange(of: searchText) { newValue in
                            searchLocations(query: newValue)
                        }

                    if !searchResults.isEmpty {
                        // 搜索结果列表
                        List(searchResults, id: \.self) { item in
                            Button {
                                selectPlace(item)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(item.name ?? "未知地点")
                                        .foregroundColor(.primary)
                                    if let address = item.placemark.thoroughfare {
                                        Text(address)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    } else {
                        // 地图视图
                        Map(position: $position, interactionModes: .all) {
                            UserAnnotation()

                            if let location = selectedLocation {
                                Marker(selectedPlace?.name ?? "所选位置", coordinate: location)
                            }

                            ForEach(searchResults, id: \.self) { item in
                                if let name = item.name {
                                    Annotation(name, coordinate: item.placemark.coordinate) {
                                        Image(systemName: "mappin.circle.fill")
                                            .foregroundColor(.red)
                                            .onTapGesture {
                                                selectPlace(item)
                                            }
                                    }
                                }
                            }
                        }
                        .mapStyle(.standard(pointsOfInterest: .including([
                            .restaurant,
                            .store,
                            .hotel,
                            .cafe
                        ])))
                        .mapControls {
                            MapCompass()
                            MapScaleView()
                            MapUserLocationButton()
                        }
                    }
                }
                .navigationTitle("选择位置")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("取消") {
                            showLocationPicker = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("保存") {
                            if let location = selectedLocation {
                                value = "\(location.latitude),\(location.longitude)"
                                if let placeName = selectedPlace?.name {
                                    print("保存地点: \(placeName)")
                                }
                            }
                            showLocationPicker = false
                        }
                    }
                }
                .onAppear {
                    if isInitialLoad {
                        locationManager.requestLocation()
                        isInitialLoad = false
                    }
                }
                .onChange(of: locationManager.lastLocation) { newLocation in
                    if let location = newLocation {
                        let region = MKCoordinateRegion(
                            center: location.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        )
                        position = .region(region)
                        searchLocations(coordinate: location.coordinate)
                    }
                }
            }
        }
    }

    // 搜索地点
    private func searchLocations(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = position.region ?? MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 39.9042, longitude: 116.4074),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )

        MKLocalSearch(request: request).start { response, error in
            searchResults = response?.mapItems ?? []
        }
    }

    private func searchLocations(coordinate: CLLocationCoordinate2D) {
        let request = MKLocalSearch.Request()
        request.region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))

        MKLocalSearch(request: request).start { response, error in
            searchResults = response?.mapItems ?? []
        }
    }

    // 选择地点
    private func selectPlace(_ place: MKMapItem) {
        selectedPlace = place
        selectedLocation = place.placemark.coordinate
        position = .region(MKCoordinateRegion(
            center: place.placemark.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
        searchText = ""
    }

    // 从字符串解析坐标
    private func parseCoordinate(from string: String) -> CLLocationCoordinate2D? {
        let components = string.split(separator: ",")
        guard components.count == 2,
              let latitude = Double(components[0]),
              let longitude = Double(components[1]) else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var lastLocation: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.first
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}