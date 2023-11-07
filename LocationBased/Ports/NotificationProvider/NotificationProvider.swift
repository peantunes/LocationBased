//
//  NotificationProvider.swift
//  LocationBased
//
//  Created by Pedro Antunes on 06/11/2023.
//

import Foundation
import UserNotifications
import CoreLocation

class NotificationProvider: NotificationProviding {
    
    func sendNotification(with message: NotificationMessage) {
        let content = UNMutableNotificationContent()
        content.title = message.title
        content.body = message.body

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger(for: message.region))

        UNUserNotificationCenter.current().add(request)
    }
    
    func requestPermission(completion: @escaping (Result<Void, Error>) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                completion(.success(()))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
    
    private func trigger(for region: LocationRegion? = nil) -> UNNotificationTrigger {
        guard let region else {
            return UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        }
        return UNLocationNotificationTrigger(region: CLCircularRegion.init(center: .init(latitude: region.coordinates.latitude, longitude: region.coordinates.longitude), radius: region.radius, identifier: region.name), repeats: false)
    }
}
