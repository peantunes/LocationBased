//
//  LocationBasedService.swift
//  LocationBased
//
//  Created by Pedro Antunes on 06/11/2023.
//

import Foundation

protocol LocationBasedServicing {
    func monitorLocation(latitude: Double, longitude: Double, name: String)
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
        engine.notificationProvider.requestPermission { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                print("success")
                
                let locationRegion = LocationRegion(
                    name: name,
                    coordinates: LocationRegion.Coordinates(latitude: latitude, longitude: longitude),
                    radius: engine.locationManagerProvider.maximumDistance)
                engine.locationManagerProvider.startMonitoring(for: locationRegion)
                engine.locationManagerProvider.delegate = self
                
            case .failure(let error):
                print(error)
            }
        }
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
