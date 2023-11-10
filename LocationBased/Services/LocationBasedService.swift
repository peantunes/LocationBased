//
//  LocationBasedService.swift
//  LocationBased
//
//  Created by Pedro Antunes on 06/11/2023.
//

import Foundation

protocol LocationBasedServicing {
    func monitorLocation(latitude: Double, longitude: Double, name: String)
    func stopMonitoring(name: String)
    func monitoredRegions() -> [LocationRegion]
}

protocol HasLocationBasedService {
    var locationBasedService: LocationBasedServicing { get }
}

class LocationBasedService: LocationBasedServicing {
    typealias Engine = HasLocationManagerProvider & HasNotificationProvider
    let engine: Engine
    
    init(engine: Engine) {
        self.engine = engine
    }
    
    func monitorLocation(latitude: Double, longitude: Double, name: String) {
        let locationRegion = LocationRegion(
            name: name,
            coordinates: LocationRegion.Coordinates(latitude: latitude, longitude: longitude),
            radius: engine.locationManagerProvider.maximumDistance)
        engine.locationManagerProvider.startMonitoring(for: locationRegion)
        engine.locationManagerProvider.delegate = self
    }
    
    func stopMonitoring(name: String) {
        guard let locationRegion = monitoredRegions().first(where: { $0.name == name } ) else { return }
        engine.locationManagerProvider.stopMonitoring(for: locationRegion)
    }
    
    func monitoredRegions() -> [LocationRegion] {
        engine.locationManagerProvider.currentMonitored()
    }
}

extension LocationBasedService: LocationManagerDelegate {
    
    func enterRegion(_ name: String) {
        engine.notificationProvider.sendNotification(with: .init(title: "Approaching region \(name)", body: "Take advantage of the region you are approaching"))
    }
    
    func exitRegion(_ name: String) {
        engine.notificationProvider.sendNotification(with: .init(title: "Leaving region \(name)", body: "Bye bye"))
    }
}
