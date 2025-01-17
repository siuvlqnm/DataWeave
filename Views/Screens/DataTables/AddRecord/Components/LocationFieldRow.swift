import SwiftUI
import MapKit

struct LocationFieldRow: View {
    @Binding var value: String
    @StateObject private var locationManager = LocationManager()
    @State private var showLocationPicker = false
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedPlace: MKMapItem?
    @State private var searchText = ""
    @State private var isInitialLoad = true
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        VStack {
            if !value.isEmpty, let coordinate = parseCoordinate(from: value) {
                selectedLocationMapView(coordinate: coordinate)
            } else {
                locationPickerButton
            }
        }
        .sheet(isPresented: $showLocationPicker) {
            locationPickerSheet
        }
    }
    
    private var locationPickerButton: some View {
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
    
    private func annotationView(title: String) -> some View {
        VStack {
            Image(systemName: "mappin.circle.fill")
                .font(.title)
            Text(title)
                .font(.caption)
                .padding(4)
                .background(.white.opacity(0.8))
                .cornerRadius(4)
        }
        .foregroundStyle(.red)
    }
    
    private func selectedLocationMapView(coordinate: CLLocationCoordinate2D) -> some View {
        let region = MapCameraPosition.region(MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
        
        return Map(position: .constant(region)) {
            Annotation(selectedPlace?.name ?? "所选位置", coordinate: coordinate) {
                annotationView(title: selectedPlace?.name ?? "所选位置")
            }
        }
        .frame(height: 200)
        .cornerRadius(8)
        .onTapGesture {
            showLocationPicker = true
        }
    }
    
    private var locationPickerSheet: some View {
        NavigationView {
            VStack {
                searchTextField
                
                if !searchResults.isEmpty {
                    searchResultsList
                } else {
                    mapView
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
                        saveLocation()
                    }
                }
            }
            .onAppear {
                handleInitialLoad()
            }
            .onChange(of: locationManager.lastLocation) { _, newLocation in
                handleLocationUpdate(newLocation)
            }
        }
    }
    
    private var searchTextField: some View {
        TextField("搜索地点", text: $searchText)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            .onChange(of: searchText) { _, newValue in
                searchLocations(query: newValue)
            }
    }
    
    private var searchResultsList: some View {
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
    }
    
    private var mapView: some View {
        Map(position: $cameraPosition, interactionModes: .all) {
            UserAnnotation()
            
            if let location = selectedLocation {
                Annotation(selectedPlace?.name ?? "所选位置", coordinate: location) {
                    annotationView(title: selectedPlace?.name ?? "所选位置")
                        .onTapGesture {
                            if let place = selectedPlace {
                                selectPlace(place)
                            }
                        }
                }
            }
            
            ForEach(searchResults, id: \.self) { item in
                if let name = item.name {
                    Annotation(name, coordinate: item.placemark.coordinate) {
                        annotationView(title: name)
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
    
    private func handleInitialLoad() {
        if isInitialLoad {
            locationManager.requestLocation()
            isInitialLoad = false
        }
    }
    
    private func handleLocationUpdate(_ newLocation: CLLocation?) {
        if let location = newLocation {
            let region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            cameraPosition = .region(region)
            searchLocations(coordinate: location.coordinate)
        }
    }
    
    private func saveLocation() {
        if let location = selectedLocation {
            value = "\(location.latitude),\(location.longitude)"
            if let placeName = selectedPlace?.name {
                print("保存地点: \(placeName)")
            }
        }
        showLocationPicker = false
    }
    
    private func searchLocations(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        if let region = cameraPosition.region {
            request.region = region
        } else {
            request.region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 39.9042, longitude: 116.4074),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
        
        MKLocalSearch(request: request).start { response, error in
            searchResults = response?.mapItems ?? []
        }
    }
    
    private func searchLocations(coordinate: CLLocationCoordinate2D) {
        let request = MKLocalSearch.Request()
        request.region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        
        MKLocalSearch(request: request).start { response, error in
            searchResults = response?.mapItems ?? []
        }
    }
    
    private func selectPlace(_ place: MKMapItem) {
        selectedPlace = place
        selectedLocation = place.placemark.coordinate
        cameraPosition = .region(MKCoordinateRegion(
            center: place.placemark.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
        searchText = ""
    }
    
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