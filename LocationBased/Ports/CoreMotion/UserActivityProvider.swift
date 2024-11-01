//
//  UserActivityProvider.swift
//  LocationBased
//
//  Created by Pedro Antunes on 17/05/2024.
//

import Foundation
import CoreMotion

class UserActivityProvider: UserActivityProviding {
    
    private let activityManager = CMMotionActivityManager()
    var monitoredContent: [ActivityInfo] = []
    weak var delegate: UserActivityDelegate?
    
    func startMonitoring() -> Bool {
        if CMMotionActivityManager.isActivityAvailable() {
            activityManager.startActivityUpdates(to: .main) { [weak self] motion in
                guard let motion else {
                    return
                }
                let current = ActivityInfo(motion)
                self?.monitoredContent.append(current)
                self?.delegate?.currentActivity(current)
            }
            return true
        }
        return false
    }
    
    func historicData(from: Date, to: Date) async throws -> [ActivityInfo] {
        var activityInfoList: [ActivityInfo] = []
        
        try await withCheckedThrowingContinuation { continuation in
            activityManager.queryActivityStarting(from: from, to: to, to: OperationQueue.main) { (activities: [CMMotionActivity]?, error: Error?) in
                
                guard let activities else {
                    print(error?.localizedDescription ?? "")
                    continuation.resume()
                    return
                }
                
                activityInfoList = activities.map(ActivityInfo.init).sorted { $0.startDate > $1.startDate }
                
                continuation.resume()
            }
        }
        
        return activityInfoList
        
    }
    
    func stopMonitoring() {
        activityManager.stopActivityUpdates()
    }
}

extension ActivityInfo.Confidence {
    init(_ confidence: CMMotionActivityConfidence) {
        switch confidence {
        case .high: self = .high
        case .medium: self = .medium
        case .low: self = .low
        @unknown default:
            self = .low
        }
    }
}

extension ActivityInfo {
    init(_ activity: CMMotionActivity) {
        self.init(type: ActivityType(activity), startDate: activity.startDate, confidence: Confidence(activity.confidence))
    }
}

extension ActivityInfo.ActivityType {
    init(_ activity: CMMotionActivity) {
        if activity.automotive {
            self = .automotive
        } else if activity.cycling {
            self = .cycling
        } else if activity.running {
            self = .running
        } else if activity.stationary {
            self = .stationary
        } else if activity.walking {
            self = .walking
        } else {
            self = .unknown
        }
    }
}
