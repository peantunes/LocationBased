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
    enum State: String {
        case enter = "inside"
        case leave = "away"
        case unknown
    }
    let name: String
    let coordinates: Coordinates
    let radius: Double
    let lastEvent: Date?
    let eventState: State
}

struct LocationEvent {
    
}

protocol LocationManagerProviding: AnyObject {
    var delegate: LocationManagerDelegate? { set get }
    var maximumDistance: Double { get }
    
    func startMonitoring(for locationRegion: LocationRegion)
    func stopMonitoring(for locationRegion: LocationRegion)
    func currentMonitored() async -> [LocationRegion]
    func requestAccess()
//    func addObserver(observer: LocationManagerDelegate)
//    func removeObserver(observer: LocationManagerDelegate)
}

protocol LocationManagerDelegate: AnyObject {
    func enterRegion(_ name: String)
    func exitRegion(_ name: String, duration: TimeInterval?)
}

protocol HasLocationManagerProvider {
    var locationManagerProvider: LocationManagerProviding { get }
}
