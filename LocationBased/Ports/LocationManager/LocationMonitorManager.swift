//
//  LocationMonitorManager.swift
//  LocationBased
//
//  Created by Pedro Antunes on 10/11/2023.
//

import Foundation
import CoreLocation

@available(iOS 17, *)
class LocationMonitorManager: LocationManagerProviding {
    
    private var locationMonitor: CLMonitor!
    
    init() {
        Task {
            await locationMonitor = CLMonitor("MyMonitor")
        }
    }
    
    var delegate: LocationManagerDelegate? {
        didSet {
            monitor()
        }
    }
    
    var maximumDistance: Double {
        2000 // x§§CLLocationManager().maximumRegionMonitoringDistance
    }
    
    func startMonitoring(for locationRegion: LocationRegion) {
        let condition = CLMonitor.CircularGeographicCondition(
            center: CLLocationCoordinate2D(latitude: locationRegion.coordinates.latitude, longitude: locationRegion.coordinates.longitude),
            radius: locationRegion.radius)
        Task {
            await locationMonitor.add(condition, identifier: locationRegion.name)
        }
    }
    
    func stopMonitoring(for locationRegion: LocationRegion) {
        Task {
            await locationMonitor.remove(locationRegion.name)
        }
    }
    
    func currentMonitored() async -> [LocationRegion] {
        var locations: [LocationRegion] = []
        for id in await locationMonitor.identifiers {
            guard let monitoredRegion = await locationMonitor.record(for: id),
                  let condition = monitoredRegion.condition as? CLMonitor.CircularGeographicCondition else {
                continue
            }
            
            locations.append(LocationRegion(name: id, coordinates: LocationRegion.Coordinates(condition.center), radius: condition.radius,
                                            lastEvent: monitoredRegion.lastEvent.date, eventState: .init(monitoredRegion.lastEvent.state)))
        }
        return locations.sorted(by: { $0.lastEvent ?? .now > $1.lastEvent ?? .now })
    }
    
    func requestAccess() {
        CLLocationManager().requestAlwaysAuthorization()
    }
    
    private func monitor() {
        Task {
            for try await event in await locationMonitor.events {
                let lastEvent = await locationMonitor.record(for: event.identifier)?.lastEvent
                
                switch(event.state) {
                case .satisfied:
                    delegate?.enterRegion(event.identifier)
                case .unsatisfied:
                    var duration: Double? = nil
                    if let lastEvent,
                       lastEvent.state == .satisfied {
                        duration = lastEvent.date.timeIntervalSinceNow
                    }
                    
                    delegate?.exitRegion(event.identifier, duration: duration)
                case .unknown:
                    print(event)
                @unknown default:
                    print("none")
                }
            }
            print("end of the loop monitor")
        }
    }
    
}

@available(iOS 17.0, *)
extension LocationRegion.State {
    init(_ state: CLMonitor.Event.State) {
        switch state {
        case .satisfied:
            self = .enter
        case .unsatisfied:
            self = .leave
        @unknown default:
            self = .unknown
        }
    }
}
