//
//  LocationBasedService.swift
//  LocationBased
//
//  Created by Pedro Antunes on 06/11/2023.
//

import Foundation
import WidgetKit

protocol LocationBasedServicing {
    func monitorLocation(latitude: Double, longitude: Double, name: String, distance: Double)
    func stopMonitoring(name: String)
    func monitoredRegions(completion: @escaping ([LocationRegion]) -> Void)
}

protocol HasLocationBasedService {
    var locationBasedService: LocationBasedServicing { get }
}

class LocationBasedService: NSObject, LocationBasedServicing {
    
    typealias Engine = HasLocationManagerProvider & HasNotificationProvider & HasKeyValueStore
    let engine: Engine
    
    init(engine: Engine) {
        self.engine = engine
        super.init()
        engine.locationManagerProvider.delegate = self
    }
    
    func monitorLocation(latitude: Double, longitude: Double, name: String, distance: Double) {
        let locationRegion = LocationRegion(
            name: name,
            coordinates: LocationRegion.Coordinates(latitude: latitude, longitude: longitude),
            radius: distance, lastEvent: nil, eventState: .unknown)
        engine.locationManagerProvider.startMonitoring(for: locationRegion)
    }
    
    func stopMonitoring(name: String) {
        monitoredRegions { regions in
            guard let locationRegion = regions.first(where: { $0.name == name } ) else { return }
            self.engine.locationManagerProvider.stopMonitoring(for: locationRegion)
        }
    }
    
    func monitoredRegions(completion: @escaping ([LocationRegion]) -> Void) {
        Task {
            let regions = await engine.locationManagerProvider.currentMonitored()
            if let inside =
                regions.first(where: { $0.eventState == .enter }) ?? regions.first,
               let encoded = try? JSONEncoder().encode(inside) {
                engine.keyValueStoreProvider.setValue(encoded, forKey: "currentLocation")
            }
            DispatchQueue.main.async {
                completion(regions)
            }
        }
    }
}

extension LocationBasedService: LocationManagerDelegate {
    
    func enterRegion(_ name: String) {
        engine.notificationProvider.sendNotification(with: .init(id: UUID().uuidString, title: "Approaching region \(name)", body: "Take advantage of the region you are approaching"))
        reloadContent()
    }
    
    func exitRegion(_ name: String, duration: TimeInterval?) {
        var timeSpent = ""
        if let duration {
            let formatter = DateComponentsFormatter()
            timeSpent = " after \(formatter.string(from: abs(duration)) ?? "")"
        }
        engine.notificationProvider.sendNotification(with: .init(id: UUID().uuidString, title: "Leaving region \(name)\(timeSpent)", body: "Bye bye"))
        reloadContent()
        
    }
    
    private func reloadContent() {
        monitoredRegions(completion: { _ in
            WidgetCenter.shared.reloadAllTimelines()
        })
    }
}
