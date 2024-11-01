//
//  UserActivityProviding.swift
//  LocationBased
//
//  Created by Pedro Antunes on 23/05/2024.
//

import Foundation

protocol UserActivityDelegate: AnyObject {
    func currentActivity(_ activity: ActivityInfo)
}

protocol HasUserActivityProvider {
    var userActivityProvider: UserActivityProviding { get }
}

protocol UserActivityProviding: AnyObject {
    var monitoredContent: [ActivityInfo] { get }
    var delegate: UserActivityDelegate? { get set }
    func startMonitoring() -> Bool
    func stopMonitoring()
    func historicData(from: Date, to: Date) async throws -> [ActivityInfo]
}

struct ActivityInfo {
    enum ActivityType {
        case walking
        case automotive
        case stationary
        case cycling
        case running
        case unknown
    }
    enum Confidence: String {
        case low
        case medium
        case high
    }
    
    let type: ActivityType
    let startDate: Date
    let confidence: Confidence
}
