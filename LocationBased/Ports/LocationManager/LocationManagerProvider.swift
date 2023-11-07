//
//  LocationManagerProvider.swift
//  LocationBased
//
//  Created by Pedro Antunes on 06/11/2023.
//

import Foundation
import CoreLocation

class LocationManagerProvider: NSObject, LocationManagerProviding {
    let locationManager = CLLocationManager()
    
    weak var delegate: LocationManagerDelegate?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    var maximumDistance: Double {
        100 // locationManager.maximumRegionMonitoringDistance
    }
    
    func startMonitoring(for locationRegion: LocationRegion) {
        let location = CLLocationCoordinate2D(latitude: locationRegion.coordinates.latitude, longitude: locationRegion.coordinates.longitude)
        let region = CLCircularRegion(center: location, radius: locationRegion.radius, identifier: locationRegion.name)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        locationManager.startMonitoring(for: region)
    }
    
    func currentMonitored() -> [LocationRegion] {
        locationManager.monitoredRegions.compactMap(LocationRegion.init)
    }
    
    func requestAccess() {
        locationManager.requestAlwaysAuthorization()
    }
}

extension LocationManagerProvider: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        delegate?.enterRegion(region.identifier)
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        delegate?.exitRegion(region.identifier)
    }
}

extension LocationRegion {
    init?(_ region: CLRegion) {
        guard let circularRegion = region as? CLCircularRegion else { return nil }
        self.init(name: circularRegion.identifier, coordinates: Coordinates.init(circularRegion.center), radius: circularRegion.radius)
    }
}

extension LocationRegion.Coordinates {
    init(_ location: CLLocationCoordinate2D) {
        self.init(latitude: location.latitude, longitude: location.longitude)
    }
}
