//
//  LocationManagerProviding.swift
//  LocationBased
//
//  Created by Pedro Antunes on 06/11/2023.
//

import Foundation

struct LocationRegion {
    struct Coordinates {
        let latitude: Double
        let longitude: Double
    }
    let name: String
    let coordinates: Coordinates
    let radius: Double
}

protocol LocationManagerProviding: AnyObject {
    var delegate: LocationManagerDelegate? { set get }
    var maximumDistance: Double { get }
    
    func startMonitoring(for locationRegion: LocationRegion)
    func currentMonitored() -> [LocationRegion]
    func requestAccess()
}

protocol LocationManagerDelegate: AnyObject {
    func enterRegion(_ name: String)
    func exitRegion(_ name: String)
}

protocol HasLocationManagerProvider {
    var locationManagerProvider: LocationManagerProviding { get }
}
