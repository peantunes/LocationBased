//
//  LocationRegion.swift
//  LocationBased
//
//  Created by Pedro Antunes on 14/11/2023.
//

import Foundation

struct LocationRegion: Codable {
    struct Coordinates: Codable {
        let latitude: Double
        let longitude: Double
    }
    enum State: String, Codable {
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
