//
//  LocationBasedService.swift
//  LocationBased
//
//  Created by Pedro Antunes on 06/11/2023.
//

import Foundation
import WidgetKit
import RadarSDK

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
        Radar.initialize(publishableKey: "prj_test_pk_6e79a9c4b3edc02e3ee477a660b72188aee1f679")
        
        Radar.startTracking(trackingOptions: RadarTrackingOptions.presetResponsive)
        Radar.setDelegate(self)
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
            completion(regions)
        }
    }
}

extension LocationBasedService: RadarDelegate {
    
    func didReceiveEvents(_ events: [RadarEvent], user: RadarUser?) {
        print(user)
        events.forEach { radar in
            engine.notificationProvider.sendNotification(with: .init(title: "Approaching Radar region \(radar.description)", body: "By Radar"))
        }
    }
    
    func didUpdateLocation(_ location: CLLocation, user: RadarUser) {
    
    }
    
    func didUpdateClientLocation(_ location: CLLocation, stopped: Bool, source: RadarLocationSource) {
        
    }
    
    func didFail(status: RadarStatus) {
        
    }
    
    func didLog(message: String) {
        
    }
}



extension LocationBasedService: LocationManagerDelegate {
    
    func enterRegion(_ name: String) {
        engine.notificationProvider.sendNotification(with: .init(title: "Approaching region \(name)", body: "Take advantage of the region you are approaching"))
        reloadContent()
    }
    
    func exitRegion(_ name: String, duration: TimeInterval?) {
        var timeSpent = ""
        if let duration {
            let formatter = DateComponentsFormatter()
            timeSpent = " after \(formatter.string(from: abs(duration)) ?? "")"
        }
        engine.notificationProvider.sendNotification(with: .init(title: "Leaving region \(name)\(timeSpent)", body: "Bye bye"))
        reloadContent()
        
    }
    
    private func reloadContent() {
        monitoredRegions(completion: { _ in
            WidgetCenter.shared.reloadAllTimelines()
        })
    }
}
