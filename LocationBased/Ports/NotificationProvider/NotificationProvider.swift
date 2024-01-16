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

        let request = UNNotificationRequest(identifier: message.id, content: content, trigger: trigger(for: message.region))
        
        Task {
            do {
                try await UNUserNotificationCenter.current().add(request)
            } catch let error {
                print(error)
            }
        }
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
        let clRegion = CLCircularRegion(center: .init(latitude: region.coordinates.latitude, longitude: region.coordinates.longitude), radius: region.radius, identifier: region.name)
        clRegion.notifyOnEntry = true
        clRegion.notifyOnExit = true
        return UNLocationNotificationTrigger(region: clRegion, repeats: true)
    }
    
    func scheduledNotifications(callback: @escaping ([NotificationMessage]) -> Void)  {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests(completionHandler: { requests in
            DispatchQueue.main.async {
                callback(requests.map(NotificationMessage.init))
            }
        })
        
    }
    
    func removeNotification(with identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func deliveredNotifications(callback: @escaping ([NotificationMessage]) -> Void) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getDeliveredNotifications { notifications in
            DispatchQueue.main.async {
                callback(notifications.map(\.request).map(NotificationMessage.init))
            }
        }
    }
}

private extension NotificationMessage {
    init(_ notification: UNNotificationRequest) {
        var notificationRegion: LocationRegion? = nil
        if let region = (notification.trigger as? UNLocationNotificationTrigger)?.region {
            notificationRegion = LocationRegion(region)
        }
        self.init(id: notification.identifier, title: notification.content.title, body: notification.content.body, region: notificationRegion)
    }
}
