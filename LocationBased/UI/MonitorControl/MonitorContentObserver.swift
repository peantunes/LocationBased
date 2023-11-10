//
//  MonitorContentObserver.swift
//  LocationBased
//
//  Created by Pedro Antunes on 08/11/2023.
//

import Foundation

class MonitorContentObserver: ObservableObject {
    typealias Engine = HasPlaceSearchProvider & HasLocationBasedService & HasNotificationProvider & HasLocationManagerProvider
    
    @Published var places: [LocationRegion] = []
    @Published var searchText = ""
    @Published var searchResult: SearchResult?
    @Published var distance: Double = 100.0
    
    private let engine: Engine
    
    init(engine: Engine) {
        self.engine = engine
    }
    
    var maximumDistance: Double {
        engine.locationManagerProvider.maximumDistance
    }
    
    func askPermissions() {
        engine.locationManagerProvider.requestAccess()
        
        engine.notificationProvider.requestPermission { _ in }
    }
    
    func refreshResults() {
        Task {
            places = await engine.locationBasedService.monitoredRegions()
        }
    }
    
    func delete(at offSets: IndexSet) {
        offSets.forEach {
            engine.locationBasedService.stopMonitoring(name: places[$0].name)
        }
        refreshResults()
    }
    
    func searchPlaces(text: String) {
        engine.placeSearchProvider.searchBy(query: text, regionRestriction: SearchRegionRestriction.all) { result in
            switch result {
            case .success(let locations):
                let searchLocations = locations.places.map(Location.init)
                self.searchResult = SearchResult(locations: searchLocations)
            case .failure:
                self.searchResult = SearchResult(locations: [])
            }
        }
    }
    
    func addPlace(place: Location) {
        engine.locationBasedService.monitorLocation(latitude: place.coordinates.latitude, longitude: place.coordinates.longitude, name: place.name, distance: distance)
        searchResult = nil
        searchText = ""
    }
}

extension LocationRegion: Identifiable {
    var id: String {
        name
    }
}

private extension Location {
    init(_ place: PlaceSearchLocation) {
        self.init(id: UUID().uuidString,
                  coordinates: (latitude: place.coordinate.latitude, longitude: place.coordinate.longitude),
                  name: place.name ?? "<no name>",
                  address: place.address)
    }
}

