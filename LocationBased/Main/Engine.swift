//
//  Engine.swift
//  LocationBased
//
//  Created by Pedro Antunes on 06/11/2023.
//

import Foundation

class Engine: ObservableObject {
    lazy var locationManagerProvider: LocationManagerProviding = LocationManagerProvider()
    lazy var notificationProvider: NotificationProviding = NotificationProvider()
    lazy var placeSearchProvider: PlaceSearchProvider = MapKitPlaceSearchProvider()
    
    lazy var locationBasedService: LocationBasedServicing = LocationBasedService(engine: self)
    
    
    static let shared = Engine()
    
    private init() {
        
    }
}

extension Engine: HasLocationManagerProvider { }
extension Engine: HasLocationBasedService { }
extension Engine: HasNotificationProvider { }
extension Engine: HasPlaceSearchProvider { }
