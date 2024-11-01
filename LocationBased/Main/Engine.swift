//
//  Engine.swift
//  LocationBased
//
//  Created by Pedro Antunes on 06/11/2023.
//

import Foundation

class Engine: ObservableObject {
    lazy var locationManagerProvider: LocationManagerProviding = {
//        if #available(iOS 17, *) {
//            return LocationMonitorManager()
//        } else {
            return LocationManagerProvider()
//        }
    }()
    lazy var notificationProvider: NotificationProviding = NotificationProvider()
    lazy var placeSearchProvider: PlaceSearchProvider = MapKitPlaceSearchProvider()
    lazy var keyValueStoreProvider: KeyValueStoreProviding = KeyValueStoreProvider()
    lazy var userActivityProvider: UserActivityProviding = UserActivityProvider()
    
    lazy var locationBasedService: LocationBasedServicing = LocationBasedService(engine: self)
    
    static let shared = Engine()
    
    private init() {
        
    }
}

extension Engine: HasLocationManagerProvider { }
extension Engine: HasLocationBasedService { }
extension Engine: HasNotificationProvider { }
extension Engine: HasPlaceSearchProvider { }
extension Engine: HasKeyValueStore { }
extension Engine: HasUserActivityProvider { }
