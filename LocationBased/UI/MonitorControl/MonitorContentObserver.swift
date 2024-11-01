//
//  MonitorContentObserver.swift
//  LocationBased
//
//  Created by Pedro Antunes on 08/11/2023.
//

import Foundation

class MonitorContentObserver: ObservableObject {
    typealias Engine = HasPlaceSearchProvider & HasLocationBasedService & HasNotificationProvider & HasLocationManagerProvider & HasUserActivityProvider
    
    @Published var places: [LocationRegion] = []
    @Published var localNotifications: [NotificationMessage] = []
    @Published var deliveredNotification: [NotificationMessage] = []
    @Published var searchText = ""
    @Published var searchResult: SearchResult?
    @Published var distance: Double = 100.0
    @Published var showDeliveredNotifications = false
    @Published var lastActivity: ActivityInfo? = nil
    
    private let engine: Engine
    
    init(engine: Engine) {
        self.engine = engine
        engine.userActivityProvider.delegate = self
        if engine.userActivityProvider.startMonitoring() {
            
        }
    }
    
    var maximumDistance: Double {
        engine.locationManagerProvider.maximumDistance
    }
    
    func askPermissions() {
        engine.locationManagerProvider.requestAccess()
        
        engine.notificationProvider.requestPermission { _ in }
    }
    
    func refreshResults() {
        engine.locationBasedService.monitoredRegions { newPlaces in
            self.places = newPlaces
        }
        
        notifications()
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
        engine.notificationProvider.sendNotification(with: NotificationMessage(id: UUID().uuidString, title: place.name, body: "You are approaching \(place.name)", region: LocationRegion(name: place.name, coordinates: .init(latitude: place.coordinates.latitude, longitude: place.coordinates.longitude), radius: distance, lastEvent: nil, eventState: .unknown)))
        // just notification
        engine.notificationProvider.sendNotification(with: NotificationMessage(id: UUID().uuidString, title: place.name, body: "Notification booked for \(place.name)", region: nil))
        searchResult = nil
        searchText = ""
        refreshResults()
    }
    
    func notifications() {
        engine.notificationProvider.scheduledNotifications { notifications in
            self.localNotifications = notifications
        }
        deliveredNotificationCheck()
    }
    
    func removeNotification(at offSets: IndexSet) {
        offSets.forEach {
            let notification = localNotifications[$0]
            engine.notificationProvider.removeNotification(with: notification.id)
        }
        notifications()
    }
    
    func deliveredNotificationCheck() {
        engine.notificationProvider.deliveredNotifications { notifications in
            self.deliveredNotification = notifications
        }
    }
}

extension MonitorContentObserver: UserActivityDelegate {
    func currentActivity(_ activity: ActivityInfo) {
        lastActivity = activity
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

