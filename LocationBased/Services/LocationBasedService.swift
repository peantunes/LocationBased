//
//  LocationBasedService.swift
//  LocationBased
//
//  Created by Pedro Antunes on 06/11/2023.
//

import Foundation

protocol LocationBasedServicing {
    func monitorLocation(latitude: Double, longitude: Double, name: String, distance: Double)
    func stopMonitoring(name: String)
    func monitoredRegions() async -> [LocationRegion]
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
    
    func monitorLocation(latitude: Double, longitude: Double, name: String, distance: Double) {
        let locationRegion = LocationRegion(
            name: name,
            coordinates: LocationRegion.Coordinates(latitude: latitude, longitude: longitude),
            radius: distance, lastEvent: nil)
        engine.locationManagerProvider.startMonitoring(for: locationRegion)
        engine.locationManagerProvider.delegate = self
    }
    
    func stopMonitoring(name: String) {
        Task {
            guard let locationRegion = await monitoredRegions().first(where: { $0.name == name } ) else { return }
            engine.locationManagerProvider.stopMonitoring(for: locationRegion)
        }
    }
    
    func monitoredRegions() async -> [LocationRegion] {
        await engine.locationManagerProvider.currentMonitored()
    }
}

extension LocationBasedService: LocationManagerDelegate {
    
    func enterRegion(_ name: String) {
        engine.notificationProvider.sendNotification(with: .init(title: "Approaching region \(name)", body: "Take advantage of the region you are approaching"))
    }
    
    func exitRegion(_ name: String, duration: TimeInterval?) {
        var timeSpent = ""
        if let duration {
            timeSpent = " after \(duration/3600) hours"
        }
        engine.notificationProvider.sendNotification(with: .init(title: "Leaving region \(name)\(timeSpent)", body: "Bye bye"))
    }
}
