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
    @State private var cameraPosition: MapCameraPosition = .automatic
    
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
                        .gesture(
                            LongPressGesture(minimumDuration: 0.5)
                                .sequenced(before: DragGesture(minimumDistance: 0))
                                .onEnded { value in
                                    if let region = position.region {
                                        selectedLocation = region.center
                                        // 反向地理编码获取地点信息
                                        lookupLocation(at: region.center)
                                    }
                                }
                        )
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
                        // 初始化时自动搜索附近地点
                        searchLocations(near: location.coordinate)
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
        request.region = MKCoordinateRegion(
            center: selectedLocation ?? CLLocationCoordinate2D(latitude: 39.9042, longitude: 116.4074),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                searchResults = []
                return
            }
            searchResults = response.mapItems
        }
    }
    
    // 搜索附近地点
    private func searchLocations(near coordinate: CLLocationCoordinate2D) {
        let request = MKLocalSearch.Request()
        request.region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        request.resultTypes = [.pointOfInterest]
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                searchResults = []
                return
            }
            searchResults = response.mapItems
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
    
    // 反向地理编码
    private func lookupLocation(at coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                selectedPlace = MKMapItem(placemark: MKPlacemark(placemark: placemark))
            }
        }
    }
    
    // 从字符串解析坐标
    private func parseCoordinate(from string: String) -> CLLocationCoordinate2D? {
        let components = string.split(separator: ",")
        guard components.count == 2,
              let latitude = Double(components[0]),
              let longitude = Double(components[1]) else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// 更新 LocationManager 以支持新的 MapKit 功能
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var locationStatus: CLAuthorizationStatus?
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
        guard let location = locations.first else { return }
        lastLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationStatus = manager.authorizationStatus
    }
}

#Preview {
    @State var location = ""
    return LocationFieldRow(value: $location)
        .padding()
}
